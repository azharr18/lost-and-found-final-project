<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lapor Barang - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    
    <!-- Leaflet Map CSS & JS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js"></script>

    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800">

    <nav class="bg-blue-900 text-white p-4 shadow-md flex justify-between items-center">
        <a href="{{ route('user.dashboard') }}" class="text-xl font-bold flex items-center gap-2 hover:text-blue-200">
            <span>&larr; Kembali</span>
        </a>
    </nav>

    <main class="max-w-3xl mx-auto p-6 mt-10 bg-white rounded-2xl shadow-sm border mb-20">
        <h2 class="text-2xl font-bold mb-6 text-center text-blue-900">Laporkan Barang</h2>

        @if($errors->any())
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded">
                <ul>
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('user.items.store') }}" method="POST" enctype="multipart/form-data" class="space-y-5">
            @csrf
            
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Nama Barang</label>
                <input type="text" name="name" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 transition" placeholder="Contoh: Dompet Hitam Kulit">
            </div>

            <div>
                <label class="block text-gray-700 font-semibold mb-2">Deskripsi Detail</label>
                <textarea name="description" rows="4" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 transition" placeholder="Jelaskan ciri-ciri barang..."></textarea>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">Status</label>
                    <select name="status" class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 transition">
                        <option value="hilang">Saya Kehilangan Barang (Lost)</option>
                        <option value="ditemukan">Saya Menemukan Barang (Found)</option>
                    </select>
                </div>
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">Hadiah / Imbalan (Rp.) - Opsional</label>
                    <input type="number" name="bounty_points" min="0" class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 transition" placeholder="Contoh: 50000">
                </div>
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">Foto Barang</label>
                    <input type="file" name="photo" accept="image/*" class="w-full px-4 py-2 rounded-xl border border-gray-300 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
                </div>
            </div>

            <hr class="my-6 border-gray-200">
            
            <h3 class="font-bold text-xl text-gray-800">Tentukan Lokasi</h3>
            <p class="text-sm text-gray-500 mb-4">Geser peta dan klik pada titik di mana barang tersebut hilang atau ditemukan.</p>

            <!-- Map Container -->
            <div style="position: relative;">
                <div id="map" style="height: 350px; width: 100%; border-radius: 12px; border: 1px solid #ccc; z-index: 1; background-color: #f3f4f6;">
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #666; z-index: 0; font-weight: bold;">Memuat Peta...</div>
                </div>
                <button type="button" id="centerMapBtn" class="hover:bg-gray-50 transition" style="display: none; position: absolute; bottom: 20px; right: 20px; z-index: 2; background: white; padding: 10px 16px; border-radius: 8px; font-weight: bold; box-shadow: 0 4px 6px rgba(0,0,0,0.2); border: 2px solid #3B82F6; color: #1E3A8A; cursor: pointer; display: flex; align-items: center; gap: 8px;">
                    <svg class="w-5 h-5 text-blue-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd"></path></svg>
                    Lokasi Saya
                </button>
            </div>

            <div class="mt-4">
                <label class="block text-gray-700 font-semibold mb-2">Alamat / Nama Jalan</label>
                <input type="text" id="addressInput" readonly class="w-full px-4 py-3 rounded-xl border border-gray-300 bg-gray-100 focus:outline-none text-gray-600" placeholder="Pilih dari peta untuk memuat alamat...">
                <p id="loadingAddress" class="text-xs text-blue-500 mt-1" style="display:none;">Sedang mencari alamat...</p>
                
                <!-- Hidden inputs for backend -->
                <input type="hidden" id="latInput" name="latitude" required>
                <input type="hidden" id="lngInput" name="longitude" required>
            </div>

            <div class="pt-6">
                <button type="submit" class="w-full bg-blue-600 text-white font-bold py-4 rounded-xl hover:bg-blue-700 shadow-md transition text-lg">
                    Publikasikan Laporan
                </button>
            </div>
        </form>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var map = L.map('map').setView([-6.200000, 106.816666], 13);
            
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            setTimeout(function() { map.invalidateSize(); }, 500);

            var marker = null;
            var latInput = document.getElementById('latInput');
            var lngInput = document.getElementById('lngInput');
            var addressInput = document.getElementById('addressInput');
            var loadingText = document.getElementById('loadingAddress');
            var centerBtn = document.getElementById('centerMapBtn');
            var globalUserLat = null;
            var globalUserLng = null;

            if (navigator.geolocation && (window.location.protocol === 'https:' || window.location.hostname === '127.0.0.1' || window.location.hostname === 'localhost')) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    globalUserLat = position.coords.latitude;
                    globalUserLng = position.coords.longitude;
                    map.setView([globalUserLat, globalUserLng], 15);
                    
                    centerBtn.style.display = 'flex';
                    centerBtn.addEventListener('click', function() {
                        if(globalUserLat !== null) {
                            map.setView([globalUserLat, globalUserLng], 15, { animate: true });
                        }
                    });
                }, function(error) {}, { enableHighAccuracy: true, timeout: 5000 });
            }

            map.on('click', function(e) {
                var lat = e.latlng.lat;
                var lng = e.latlng.lng;

                // Update hidden inputs for Laravel
                latInput.value = lat.toFixed(8);
                lngInput.value = lng.toFixed(8);

                if (marker) {
                    marker.setLatLng(e.latlng);
                } else {
                    marker = L.marker(e.latlng).addTo(map);
                }

                // Reverse Geocoding via Nominatim
                loadingText.style.display = 'block';
                addressInput.value = "Menunggu data jalan...";
                
                fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`)
                    .then(response => response.json())
                    .then(data => {
                        loadingText.style.display = 'none';
                        if(data && data.display_name) {
                            var shortAddress = data.display_name;
                            // Simplify address if it's too long
                            var parts = shortAddress.split(', ');
                            if(parts.length > 3) {
                                shortAddress = parts.slice(0, 3).join(', '); // Ambil 3 bagian pertama saja
                            }
                            addressInput.value = shortAddress;
                            marker.bindPopup("<b>Lokasi:</b><br>" + shortAddress).openPopup();
                        } else {
                            addressInput.value = "Nama jalan tidak ditemukan pada titik ini.";
                            marker.bindPopup("Titik Lokasi Barang").openPopup();
                        }
                    })
                    .catch(error => {
                        loadingText.style.display = 'none';
                        addressInput.value = "Gagal memuat alamat. Pastikan koneksi internet stabil.";
                        marker.bindPopup("Titik Lokasi Barang").openPopup();
                    });
            });
        });
    </script>
</body>
</html>
