<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Chat;
use App\Models\User;

class ChatController extends Controller
{
    public function index(Request $request, $other_user_id)
    {
        $userId = $request->user()->id;
        
        $chats = Chat::where(function ($query) use ($userId, $other_user_id) {
            $query->where('sender_id', $userId)
                  ->where('receiver_id', $other_user_id);
        })->orWhere(function ($query) use ($userId, $other_user_id) {
            $query->where('sender_id', $other_user_id)
                  ->where('receiver_id', $userId);
        })->orderBy('created_at', 'asc')->get();

        return response()->json($chats);
    }

    public function store(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'message' => 'required|string',
        ]);

        $chat = Chat::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'message' => $request->message,
        ]);

        // Send FCM Notification
        try {
            $receiver = User::find($request->receiver_id);
            if ($receiver && $receiver->fcm_token) {
                $messaging = app('firebase.messaging');
                $message = \Kreait\Firebase\Messaging\CloudMessage::withTarget('token', $receiver->fcm_token)
                    ->withNotification(\Kreait\Firebase\Messaging\Notification::create($request->user()->name, $request->message));
                $messaging->send($message);
            }
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('FCM Error: ' . $e->getMessage());
        }

        return response()->json($chat, 201);
    }

    public function conversations(Request $request)
    {
        $userId = $request->user()->id;

        // Get all unique users the current user has chatted with
        $userIds = Chat::where('sender_id', $userId)
            ->pluck('receiver_id')
            ->merge(
                Chat::where('receiver_id', $userId)->pluck('sender_id')
            )
            ->unique();

        $users = \App\Models\User::whereIn('id', $userIds)->select('id', 'name', 'email', 'photo_url')->get()->map(function($user) use ($userId) {
            $user->unread_count = Chat::where('sender_id', $user->id)
                ->where('receiver_id', $userId)
                ->where('is_read', false)
                ->count();
            
            $lastMessage = Chat::where(function($q) use ($userId, $user) {
                    $q->where('sender_id', $userId)->where('receiver_id', $user->id);
                })
                ->orWhere(function($q) use ($userId, $user) {
                    $q->where('sender_id', $user->id)->where('receiver_id', $userId);
                })
                ->orderBy('created_at', 'desc')
                ->first();
                
            $user->last_message = $lastMessage ? $lastMessage->message : null;
            $user->last_message_time = $lastMessage ? $lastMessage->created_at : null;

            return $user;
        });

        // Sort users by last message time descending
        $users = $users->sortByDesc('last_message_time')->values();

        return response()->json($users);
    }

    public function markRead(Request $request, $other_user_id)
    {
        Chat::where('sender_id', $other_user_id)
            ->where('receiver_id', $request->user()->id)
            ->update(['is_read' => true]);
            
        return response()->json(['message' => 'ok']);
    }
}
