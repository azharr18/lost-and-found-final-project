<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$items = \App\Models\Item::whereNotNull('photo_url')->get();
foreach($items as $i) {
    $i->photo_url = str_replace('http://172.16.24.56:8000', 'https://brandless-wispiest-ardelle.ngrok-free.dev', $i->photo_url);
    $i->save();
}
echo "Done\n";
