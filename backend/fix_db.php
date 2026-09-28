<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$items = App\Models\Item::whereNotNull('photo_url')->get();
foreach ($items as $item) {
    if (!str_starts_with($item->photo_url, 'http')) {
        $url = url('storage/' . $item->photo_url);
        $url = str_replace('http://', 'https://', $url);
        $item->photo_url = $url;
        $item->save();
    } elseif (str_starts_with($item->photo_url, 'http://')) {
        // Also force https if it's http
        $item->photo_url = str_replace('http://', 'https://', $item->photo_url);
        $item->save();
    }
}
echo "Database items fixed!\n";