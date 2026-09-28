<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\User;
use App\Notifications\NewItemNotification;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ItemController extends Controller
{
    public function myItems(Request $request)
    {
        $items = Item::with('user')->where('user_id', $request->user()->id)->orderBy('created_at', 'desc')->get();
        return response()->json($items);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'required|in:hilang,ditemukan',
            'bounty_points' => 'required|integer|min:0',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'photo' => 'nullable|image|max:10240',
        ]);

        $photoUrl = null;
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('items', 'public');
            $photoUrl = url('storage/' . $path);
            
            if (str_contains(config('app.url'), 'ngrok') || str_contains(config('app.url'), 'https') || str_contains($photoUrl, 'ngrok')) {
                $photoUrl = str_replace('http://', 'https://', $photoUrl);
            }
        }

        $item = Item::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'description' => $request->description,
            'status' => $request->status,
            'bounty_points' => $request->bounty_points,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'photo_url' => $photoUrl,
        ]);

        // AUTO-MATCHING ALGORITHM
        $oppositeStatus = $item->status === 'hilang' ? 'ditemukan' : 'hilang';
        $radius = 10; // km

        $matches = \App\Models\Item::select('*')
            ->selectRaw('( 6371 * acos( cos( radians(?) ) *
                cos( radians( latitude ) ) *
                cos( radians( longitude ) - radians(?) ) +
                sin( radians(?) ) *
                sin( radians( latitude ) ) )
            ) AS distance', [$item->latitude, $item->longitude, $item->latitude])
            ->where('status', $oppositeStatus)
            ->where('id', '!=', $item->id)
            ->where('user_id', '!=', $item->user_id)
            ->where(function($query) use ($item) {
                // simple keyword matching
                $words = explode(' ', $item->name);
                foreach($words as $word) {
                    if (strlen($word) > 2) {
                        $query->orWhere('name', 'LIKE', '%' . $word . '%');
                    }
                }
            })
            ->having('distance', '<', $radius)
            ->get();

        foreach ($matches as $match) {
            $matchOwner = \App\Models\User::find($match->user_id);
            if ($matchOwner) {
                $msg = $item->status === 'ditemukan' 
                    ? "Ada barang ditemukan ('{$item->name}') yang mirip dengan barang Anda yang hilang!" 
                    : "Seseorang mencari barang hilang ('{$item->name}') yang mirip dengan barang temuan Anda!";
                $matchOwner->notify(new \App\Notifications\ItemMatchedNotification($item, $msg));
            }

            // Notify the current creator as well
            $currentOwner = $request->user();
            $msg2 = $match->status === 'ditemukan'
                ? "Kami menemukan barang ('{$match->name}') yang mirip dengan laporan kehilangan Anda!"
                : "Seseorang mencari barang hilang ('{$match->name}') yang mirip dengan laporan temuan Anda!";
            $currentOwner->notify(new \App\Notifications\ItemMatchedNotification($match, $msg2));
        }

        return response()->json($item, 201);
    }

        public function recent(Request $request)
    {
        $items = Item::with('user')
            ->where('status', '!=', 'selesai')
            ->where('created_at', '>=', now()->subDay())
            ->orderBy('created_at', 'desc')
            ->get();
            
        return response()->json($items);
    }

    public function nearby(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'required|numeric|min:0', // in kilometers
        ]);

        $lat = $request->latitude;
        $lon = $request->longitude;
        $radius = $request->radius;

        // Haversine formula
        $items = Item::with('user')
            ->select('*')
            ->selectRaw(
                '( 6371 * acos( cos( radians(?) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians(?) ) + sin( radians(?) ) * sin( radians( latitude ) ) ) ) AS distance',
                [$lat, $lon, $lat]
            )
            ->where('status', '!=', 'selesai')
            ->having('distance', '<=', $radius)
            ->orderBy('distance', 'asc')
            ->get();

        return response()->json($items);
    }

    public function resolve(Request $request, $id)
    {
        $request->validate([
            'finder_id' => 'nullable|exists:users,id',
        ]);

        $item = Item::findOrFail($id);

        if ($item->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($item->status === 'selesai') {
            return response()->json(['message' => 'Item already resolved'], 400);
        }

        DB::transaction(function () use ($item, $request) {
            $item->update([
                'status' => 'selesai',
            ]);

            if ($request->has('finder_id') && $request->finder_id) {
                $finder = User::findOrFail($request->finder_id);
                $finder->update([
                    'points' => $finder->points + $item->bounty_points
                ]);
            }
        });

        return response()->json(['message' => 'Item resolved']);
    }

    public function report(Request $request, $id)
    {
        $request->validate([
            'reason' => 'required|string|max:255',
            'evidence' => 'nullable|image|max:10240',
        ]);

        $item = Item::findOrFail($id);
        
        $evidenceUrl = null;
        if ($request->hasFile('evidence')) {
            $path = $request->file('evidence')->store('reports', 'public');
            $evidenceUrl = url('storage/' . $path);
            
            if (str_contains(config('app.url'), 'ngrok') || str_contains(config('app.url'), 'https')) {
                $evidenceUrl = str_replace('http://', 'https://', $evidenceUrl);
            }
        }

        \App\Models\Report::create([
            'reporter_id' => $request->user()->id,
            'item_id' => $item->id,
            'reason' => $request->reason,
            'evidence_url' => $evidenceUrl,
            'status' => 'pending',
        ]);

        return response()->json(['message' => 'Report submitted successfully'], 201);
    }
}


