<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\ChatController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'profile']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user/items', [ItemController::class, 'myItems']);

    Route::post('/items', [ItemController::class, 'store']);
    Route::get('/items/nearby', [ItemController::class, 'nearby']);
    Route::get('/items/recent', [ItemController::class, 'recent']);
    Route::post('/items/{id}/resolve', [ItemController::class, 'resolve']);
    Route::post('/items/{id}/report', [ItemController::class, 'report']);

    Route::get('/conversations', [ChatController::class, 'conversations']);
    Route::get('/chats/{other_user_id}', [ChatController::class, 'index']);
    Route::post('/chats/{other_user_id}/read', [ChatController::class, 'markRead']);
    Route::post('/chats', [ChatController::class, 'store']);

    Route::get('/notifications', [\App\Http\Controllers\NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [\App\Http\Controllers\NotificationController::class, 'markRead']);
});
