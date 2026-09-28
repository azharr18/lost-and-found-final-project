<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\WebAuthController;
use App\Http\Controllers\UserWebController;
use App\Http\Middleware\AdminMiddleware;

Route::get('/', function () {
    return view('welcome');
});

// Authentication Routes
Route::get('/register', [WebAuthController::class, 'showRegister'])->name('register');
Route::post('/register', [WebAuthController::class, 'register']);
Route::get('/login', [WebAuthController::class, 'showLogin'])->name('login');
Route::post('/login', [WebAuthController::class, 'login']);
Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

// Legacy Admin Login redirect
Route::redirect('/admin/login', '/login');

Route::middleware(['auth'])->group(function () {
    // User Routes
    Route::get('/user/dashboard', [UserWebController::class, 'dashboard'])->name('user.dashboard');
    Route::post('/user/notifications/mark-all-read', [UserWebController::class, 'markAllRead']);
    Route::get('/user/notifications/{id}/read', [UserWebController::class, 'readNotification']);
    Route::get('/user/items/create', [UserWebController::class, 'createItem'])->name('user.items.create');
    Route::post('/user/items/{id}/resolve', [UserWebController::class, 'resolveItem']);
    Route::post('/user/items', [UserWebController::class, 'storeItem'])->name('user.items.store');
    Route::get('/user/items/{id}', [UserWebController::class, 'showItem'])->name('user.items.show');

    // Chat Routes
    Route::get('/user/chat', [UserWebController::class, 'chatInbox'])->name('user.chat.inbox');
    Route::get('/user/chat/{receiver_id}', [UserWebController::class, 'chatConversation'])->name('user.chat.conversation');
    Route::post('/user/chat/{receiver_id}', [UserWebController::class, 'sendMessage'])->name('user.chat.send');

    // Admin Routes
    Route::middleware([AdminMiddleware::class])->group(function () {
        Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
        Route::get('/admin/users', [AdminController::class, 'users'])->name('admin.users');
        Route::get('/admin/items', [AdminController::class, 'items'])->name('admin.items');
        Route::post('/admin/items/{id}/delete', [AdminController::class, 'deleteItem'])->name('admin.deleteItem');
        Route::post('/admin/reports/{id}/resolve', [AdminController::class, 'resolveReport'])->name('admin.resolveReport');
    });
});
