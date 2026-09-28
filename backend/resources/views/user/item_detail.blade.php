<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail Barang - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js"></script>
    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800 min-h-screen flex flex-col">

    <nav class="bg-blue-900 text-white p-4 shadow-md flex justify-between items-center z-10 sticky top-0">
        <a href="{{ route('user.dashboard') }}" class="text-xl font-bold flex items-center gap-2 hover:text-gray-200 transition">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
            <span>Kembali</span>
        </a>
    </nav>

    <main class="flex-1 max-w-4xl w-full mx-auto p-6 mt-6">
        <div class="bg-white rounded-2xl shadow-sm border overflow-hidden">
            <!-- Header Image -->
            <div class="h-64 bg-gray-200 relative w-full">
                @if($item->photo_url)
                    <img src="{{ str_starts_with($item->photo_url, 'http') ? $item->photo_url : asset('storage/' . $item->photo_url) }}" class="w-full h-full object-cover">
                @else
                    <div class="w-full h-full flex items-center justify-center text-gray-400 font-bold text-2xl">No Image Available</div>
                @endif
                <div class="absolute top-4 left-4 px-4 py-2 rounded-full text-sm font-bold text-white {{ $item->status == 'hilang' ? 'bg-red-500' : 'bg-green-500' }} shadow-lg">
                    STATUS: {{ strtoupper($item->status) }}
                </div>
                @if($item->bounty_points > 0)
                <div class="absolute top-4 right-4 px-4 py-2 rounded-full text-sm font-bold text-yellow-900 bg-yellow-400 shadow-lg flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                    Imbalan: Rp. {{ number_format($item->bounty_points, 0, ',', '.') }}
                </div>
                @endif
            </div>

            <!-- Content -->
            <div class="p-8">
                <h1 class="text-3xl font-bold mb-4">{{ $item->name }}</h1>
                
                <div class="flex items-center gap-4 mb-6 p-4 bg-blue-50 rounded-xl border border-blue-100">
                    @if($item->user->photo_url)
                        <img src="{{ str_starts_with($item->user->photo_url, 'http') ? $item->user->photo_url : asset('storage/' . $item->user->photo_url) }}" class="w-12 h-12 rounded-full object-cover shadow-sm border border-gray-200">
                    @else
                        <div class="w-12 h-12 bg-blue-200 text-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
                            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path></svg>
                        </div>
                    @endif
                    <div>
                        <p class="text-sm text-gray-500">Dilaporkan oleh</p>
                        <p class="font-bold text-lg text-blue-900">{{ $item->user->name }}</p>
                    </div>
                </div>

                <h3 class="font-bold text-xl mb-2">Deskripsi Barang</h3>
                <p class="text-gray-600 mb-8 whitespace-pre-wrap leading-relaxed">{{ $item->description }}</p>

                <h3 class="font-bold text-xl mb-4">Lokasi {{ $item->status == 'hilang' ? 'Terakhir Dilihat' : 'Ditemukan' }}</h3>
                <div id="map" class="w-full h-64 rounded-xl border shadow-inner mb-6 z-0"></div>

                @if($item->user_id !== Auth::id())
                    <hr class="my-6 border-gray-200">
                    <h3 class="font-bold text-xl mb-4">Kirim Pesan ke Pelapor</h3>
                    <form action="{{ route('user.chat.send', $item->user_id) }}" method="POST" class="flex gap-2">
                        @csrf
                        <input type="text" name="message" required placeholder="Tulis pesan untuk {{ $item->user->name }}..." class="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 transition">
                        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-xl shadow-md transition flex justify-center items-center gap-2">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path></svg>
                            Kirim
                        </button>
                    </form>
                    <a href="{{ route('user.chat.conversation', $item->user_id) }}" class="block text-center text-blue-600 hover:underline mt-4 text-sm font-semibold">Lihat Riwayat Obrolan</a>
                @else
                    <div class="mt-6 bg-blue-50 border border-blue-200 text-blue-800 px-4 py-3 rounded-xl flex items-center gap-3">
                        <svg class="w-6 h-6 text-blue-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>
                        <span class="font-semibold">Ini adalah laporan Anda sendiri.</span>
                    </div>
                @endif
        </div>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var lat = {{ $item->latitude }};
            var lng = {{ $item->longitude }};
            
            var map = L.map('map').setView([lat, lng], 16);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            var color = "{{ $item->status == 'hilang' ? 'red' : 'green' }}";
            var markerHtml = `<div style="background-color: ${color}; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 6px rgba(0,0,0,0.5);"></div>`;
            var customIcon = L.divIcon({ html: markerHtml, className: '', iconSize: [16, 16], iconAnchor: [8, 8] });
            
            L.marker([lat, lng], {icon: customIcon}).addTo(map)
                .bindPopup("<b>{{ $item->name }}</b><br>Lokasi dicatat di sini.").openPopup();
        });
    </script>
</body>
</html>

