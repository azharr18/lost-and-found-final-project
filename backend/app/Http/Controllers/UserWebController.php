<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\Chat;
use App\Models\User;
use App\Notifications\NewItemNotification;
use Illuminate\Support\Facades\Notification;
use App\Models\Report;
use Illuminate\Support\Facades\Auth;

class UserWebController extends Controller
{
    public function dashboard()
    {
        $items = Item::where('status', '!=', 'selesai')->with('user')->orderBy('created_at', 'desc')->get();
        $myReports = Report::where('reporter_id', Auth::id())->with('item')->get();
        $myItems = Item::where('user_id', Auth::id())->where('status', '!=', 'selesai')->orderBy('created_at', 'desc')->get();
        
        return view('user.dashboard', compact('items', 'myReports', 'myItems'));
    }

    public function showItem($id)
    {
        $item = Item::with('user')->findOrFail($id);
        return view('user.item_detail', compact('item'));
    }

        public function resolveItem($id)
    {
        $item = Item::findOrFail($id);
        if ($item->user_id !== Auth::id()) {
            return back()->with('error', 'Tidak berhak.');
        }
        $item->status = 'selesai';
        $item->save();
        return back()->with('success', 'Laporan berhasil diselesaikan.');
    }

            public function markAllRead()
    {
        Auth::user()->unreadNotifications->markAsRead();
        return response()->json(['success' => true]);
    }

    public function readNotification($id)
    {
        $notification = Auth::user()->notifications()->where('id', $id)->first();
        if ($notification) {
            $notification->markAsRead();
            if (isset($notification->data['item_id'])) {
                return redirect('/user/items/' . $notification->data['item_id']);
            }
        }
        return redirect('/user/dashboard');
    }

    public function createItem()
    {
        return view('user.create_item');
    }

    public function storeItem(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'status' => 'required|in:hilang,ditemukan',
            'photo' => 'nullable|image',
            'bounty_points' => 'nullable|numeric|min:0'
        ]);

        $photoUrl = null;
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('items', 'public');
            $photoUrl = url('storage/' . $path);
            
            // Force HTTPS if using Ngrok
            if (str_contains(config('app.url'), 'ngrok') || str_contains(config('app.url'), 'https') || str_contains($photoUrl, 'ngrok')) {
                $photoUrl = str_replace('http://', 'https://', $photoUrl);
            }
        }

        $item = Item::create([
            'user_id' => Auth::id(),
            'name' => $request->name,
            'description' => $request->description,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'status' => $request->status,
            'photo_url' => $photoUrl,
            'bounty_points' => $request->bounty_points ?? 0
        ]);

        // Send Notification to all users except reporter
        $users = User::where('id', '!=', Auth::id())->get();
        Notification::send($users, new NewItemNotification($item));

        return redirect('/user/dashboard')->with('success', 'Barang berhasil dipublikasikan!');
    }

    public function chatInbox()
    {
        $userId = Auth::id();
        $chats = Chat::where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->with(['sender', 'receiver'])
            ->orderBy('created_at', 'desc')
            ->get();

        $contacts = collect();
        foreach ($chats as $chat) {
            $otherUser = $chat->sender_id == $userId ? $chat->receiver : $chat->sender;
            if (!$contacts->contains('id', $otherUser->id)) {
                $otherUser->last_message = $chat->message;
                $otherUser->last_message_time = $chat->created_at;
                $contacts->push($otherUser);
            }
        }

        return view('user.chat_inbox', compact('contacts'));
    }

    public function chatConversation($receiver_id)
    {
        $userId = Auth::id();
        $receiver = User::findOrFail($receiver_id);

        $messages = Chat::where(function($q) use ($userId, $receiver_id) {
                $q->where('sender_id', $userId)->where('receiver_id', $receiver_id);
            })->orWhere(function($q) use ($userId, $receiver_id) {
                $q->where('sender_id', $receiver_id)->where('receiver_id', $userId);
            })->orderBy('created_at', 'asc')->get();

        Chat::where('sender_id', $receiver_id)->where('receiver_id', $userId)->update(['is_read' => true]);

        return view('user.chat_conversation', compact('messages', 'receiver'));
    }

    public function sendMessage(Request $request, $receiver_id)
    {
        $request->validate(['message' => 'required|string']);

        Chat::create([
            'sender_id' => Auth::id(),
            'receiver_id' => $receiver_id,
            'message' => $request->message
        ]);

        return redirect()->back();
    }
}







