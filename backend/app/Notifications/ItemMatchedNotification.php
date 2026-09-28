<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ItemMatchedNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    protected $matchedItem;
    protected $message;

    public function __construct($matchedItem, $message)
    {
        $this->matchedItem = $matchedItem;
        $this->message = $message;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toDatabase(object $notifiable): array
    {
        return [
            'item_id' => $this->matchedItem->id,
            'item_name' => $this->matchedItem->name,
            'message' => $this->message,
        ];
    }
}
