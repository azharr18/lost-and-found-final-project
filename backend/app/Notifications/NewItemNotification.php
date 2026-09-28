<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Channels\FcmChannel;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

class NewItemNotification extends Notification
{
    use Queueable;

    public $item;

    public function __construct($item)
    {
        $this->item = $item;
    }

    public function via($notifiable)
    {
        return ['database', FcmChannel::class];
    }

    public function toArray($notifiable)
    {
        if ($this->item->status == 'ditemukan') {
            $message = "Terdapat barang hilang didekatmu";
        } else {
            $message = "Seseorang kehilangan barang di dekatmu";
        }

        return [
            'item_id' => $this->item->id,
            'item_name' => $this->item->name,
            'message' => $message,
            'status' => $this->item->status
        ];
    }

    public function toFcm($notifiable)
    {
        if ($this->item->status == 'ditemukan') {
            $title = "Ada Temuan!";
            $body = "Terdapat barang hilang didekatmu";
        } else {
            $title = "Pemberitahuan Orang Hilang Barang";
            $body = "Seseorang kehilangan barang di dekatmu";
        }

        return CloudMessage::new()
            ->withNotification(FcmNotification::create($title, $body))
            ->withData([
                'item_id' => (string)$this->item->id,
                'type' => 'new_item'
            ])
            ->withToken($notifiable->fcm_token);
    }
}