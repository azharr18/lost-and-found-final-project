<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    protected $fillable = ['reporter_id', 'item_id', 'reason', 'status', 'evidence_url'];

    public function reporter()
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}
