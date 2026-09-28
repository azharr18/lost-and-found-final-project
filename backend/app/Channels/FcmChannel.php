<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Firebase\Contract\Messaging;

class FcmChannel
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    public function send($notifiable, Notification $notification)
    {
        if (! $notifiable->fcm_token) {
            return;
        }

        $message = $notification->toFcm($notifiable);

        try {
            $this->messaging->send($message);
        } catch (\Exception $e) {
            // Ignore for prototype
        }
    }
}