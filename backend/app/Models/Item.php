<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;

class Item extends Model
{
    protected $fillable = ['user_id', 'name', 'description', 'status', 'bounty_points', 'resolved_by', 'photo_url', 'latitude', 'longitude'];
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function resolver()
    {
        return $this->belongsTo(User::class, 'resolved_by');
    }
}
