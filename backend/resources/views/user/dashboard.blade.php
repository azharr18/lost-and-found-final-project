<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard User - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    
    <!-- Leaflet Map CSS & JS (Cloudflare CDN - Anti Blokir) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js"></script>

    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800 min-h-screen flex flex-col">

    <nav class="bg-blue-900 text-white p-4 shadow-md flex justify-between items-center z-10 sticky top-0 relative">
        <div class="text-xl font-bold flex items-center gap-2">
            <span>Lost&Found</span>
            <span class="bg-blue-700 text-xs px-2 py-1 rounded-full">User Web</span>
        </div>
        <div class="flex items-center gap-6 relative">
            <!-- Notifications Dropdown -->
            <div class="relative group">
                <button onmouseenter="markNotificationsAsRead()" class="relative flex items-center justify-center p-2 rounded-full hover:bg-blue-800 transition">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                    @if(Auth::user()->unreadNotifications->count() > 0)
                        <span id="notifBadge" class="absolute top-0 right-0 bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full border-2 border-blue-900">{{ Auth::user()->unreadNotifications->count() }}</span>
                    @endif
                </button>
                <div class="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-xl overflow-hidden hidden group-hover:block border border-gray-100 z-50">
                    <div class="p-3 bg-gray-50 border-b text-gray-800 font-bold text-sm">Notifikasi</div>
                    <div class="max-h-64 overflow-y-auto">
                        @forelse(Auth::user()->unreadNotifications as $notif)
                            <a href="/user/notifications/{{ $notif->id }}/read" class="block p-3 border-b hover:bg-blue-50 transition">
                                <p class="text-sm text-gray-800 font-semibold">{{ $notif->data['message'] }}</p>
                                <p class="text-xs text-gray-500">{{ $notif->created_at->diffForHumans() }}</p>
                            </a>
                        @empty
                            <div class="p-4 text-sm text-gray-500 text-center">Belum ada notifikasi</div>
                        @endforelse
                    </div>
                </div>
            </div>

            <span class="font-semibold">Halo, {{ Auth::user()->name }}</span>
            <form action="{{ route('logout') }}" method="POST">
                @csrf
                <button type="submit" class="bg-red-500 hover:bg-red-600 px-4 py-2 rounded-lg text-sm font-bold transition">Logout</button>
            </form>
        </div>
    </nav>

    <div class="flex-1 flex flex-col md:flex-row max-w-7xl w-full mx-auto p-6 gap-6 items-start">
        <!-- Sidebar -->
        <aside class="w-full md:w-1/4 sticky top-24">
            <div class="bg-white rounded-2xl shadow-sm border p-6 mb-6">
                <div class="text-center mb-4">
                    @if(Auth::user()->photo_url)
                        <img src="{{ str_starts_with(Auth::user()->photo_url, 'http') ? Auth::user()->photo_url : asset('storage/' . Auth::user()->photo_url) }}" class="w-20 h-20 rounded-full mx-auto mb-3 object-cover shadow-sm border border-gray-200">
                    @else
                        <div class="w-20 h-20 bg-gray-200 text-gray-500 rounded-full mx-auto mb-3 flex items-center justify-center"><svg class="w-10 h-10" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path></svg></div>
                    @endif
                    <h3 class="font-bold text-lg">{{ Auth::user()->name }}</h3>
                    <p class="text-sm text-gray-500">{{ Auth::user()->email }}</p>
                </div>
                <a href="{{ route('user.items.create') }}" class="block text-center bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700 transition">
                    + Lapor Barang
                </a>
                <a href="{{ route('user.chat.inbox') }}" class="mt-3 flex items-center justify-center gap-2 text-center bg-white border-2 border-blue-600 text-blue-600 font-bold py-3 rounded-xl hover:bg-blue-50 transition">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"></path></svg>
                    Pesan (Chat)
                </a>
            </div>

            <!-- My Reports -->
            <div class="bg-white rounded-2xl shadow-sm border p-6">
                <h3 class="font-bold text-lg mb-4">Laporan Saya</h3>
                @if($myItems->isEmpty())
                    <p class="text-sm text-gray-500 text-center">Belum ada laporan.</p>
                @else
                    <ul class="space-y-3">
                        @foreach($myItems as $myItem)
                            <li class="p-3 bg-gray-50 rounded-xl border text-sm flex justify-between items-center">
                                <div>
                                    <a href="{{ url('/user/items/' . $myItem->id) }}" class="font-bold block text-blue-900 hover:underline">{{ $myItem->name }}</a>
                                    <span class="text-xs text-gray-500">Status: {{ ucfirst($myItem->status) }}</span>
                                </div>
                                @if($myItem->status !== 'selesai')
                                    <form action="{{ url('/user/items/' . $myItem->id . '/resolve') }}" method="POST" class="ml-2">
                                        @csrf
                                        <button type="submit" class="text-xs bg-green-500 hover:bg-green-600 text-white px-3 py-1.5 rounded-lg shadow-sm font-semibold" onclick="return confirm('Apakah Anda yakin urusan barang ini sudah selesai?')">
                                            @if($myItem->status == 'hilang')
                                                Tandai Ketemu
                                            @else
                                                Tandai Selesai
                                            @endif
                                        </button>
                                    </form>
                                @endif
                            </li>
                        @endforeach
                    </ul>
                @endif
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 bg-white rounded-2xl shadow-sm border p-6 w-full">
            @if(session('success'))
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded">
                    {{ session('success') }}
                </div>
            @endif

            <div class="flex flex-col md:flex-row justify-between items-center mb-4 gap-4">
                <h2 class="text-2xl font-bold">Peta & Barang Sekitar</h2>
                
                <!-- Filter Jarak -->
                <div class="flex items-center gap-2">
                    <label class="font-semibold text-gray-600 text-sm">Filter Jarak:</label>
                    <select id="radiusFilter" class="border border-gray-300 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-600">
                        <option value="999999">Semua Jarak</option>
                        <option value="500">Radius 500 Meter</option>
                        <option value="1000">Radius 1 KM</option>
                        <option value="5000">Radius 5 KM</option>
                    </select>
                </div>
            </div>

            <!-- Map Container -->
            <div style="position: relative; margin-bottom: 24px;">
                <div id="map" style="height: 400px; width: 100%; border-radius: 12px; border: 1px solid #ccc; z-index: 1; background-color: #f3f4f6;">
                    <!-- Fallback text -->
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #666; z-index: 0; font-weight: bold;">Memuat Peta dari Server...</div>
                </div>
                <button id="centerMapBtn" class="hover:bg-gray-50 transition" style="display: none; position: absolute; bottom: 20px; right: 20px; z-index: 2; background: white; padding: 10px 16px; border-radius: 8px; font-weight: bold; box-shadow: 0 4px 6px rgba(0,0,0,0.2); border: 2px solid #3B82F6; color: #1E3A8A; cursor: pointer; display: flex; align-items: center; gap: 8px;">
                    <svg class="w-5 h-5 text-blue-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd"></path></svg>
                    Pusatkan ke Saya
                </button>
            </div>
            
            <!-- Items Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="itemsContainer">
                @foreach($items as $item)
                    <div class="item-card border rounded-2xl overflow-hidden hover:shadow-lg transition bg-white cursor-pointer" 
                         style="height: 380px; display: flex; flex-direction: column;"
                         onclick="window.location.href='/user/items/{{ $item->id }}'"
                         data-id="{{ $item->id }}"
                         data-lat="{{ $item->latitude }}" 
                         data-lng="{{ $item->longitude }}"
                         data-name="{{ $item->name }}"
                         data-status="{{ $item->status }}">
                        
                        <div class="bg-gray-200 relative" style="height: 180px; flex-shrink: 0;">
                            @if($item->photo_url)
                                <img src="{{ str_starts_with($item->photo_url, 'http') ? $item->photo_url : asset('storage/' . $item->photo_url) }}" class="w-full h-full object-cover">
                            @else
                                <div class="w-full h-full flex items-center justify-center text-gray-400 font-bold">No Image</div>
                            @endif
                            <div class="absolute top-3 left-3 px-3 py-1 rounded-full text-xs font-bold text-white {{ $item->status == 'hilang' ? 'bg-red-500' : 'bg-green-500' }}">
                                {{ strtoupper($item->status) }}
                            </div>
                            @if($item->bounty_points > 0)
                            <div class="absolute top-3 right-3 px-3 py-1 rounded-full text-xs font-bold text-yellow-900 bg-yellow-400 shadow-md flex items-center gap-1">
                                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path></svg>
                                Rp. {{ number_format($item->bounty_points, 0, ',', '.') }}
                            </div>
                            @endif
                        </div>
                        <div style="padding: 16px; display: flex; flex-direction: column; flex-grow: 1;">
                            <h3 class="font-bold text-lg mb-1 truncate">{{ $item->name }}</h3>
                            <p class="text-sm text-gray-500 mb-3" style="flex-grow: 1; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">{{ $item->description }}</p>
                            <div class="mt-auto flex justify-between items-center" style="margin-top: auto;">
                                <span class="text-xs text-gray-400 truncate" style="max-width: 50%;">Oleh: {{ $item->user->name }}</span>
                                <span class="text-xs font-bold text-blue-600 distance-text text-right" style="max-width: 50%;">Sedang menghitung...</span>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        </main>
    </div>

    <script>
        function markNotificationsAsRead() {
            const badge = document.getElementById('notifBadge');
            if (badge) {
                // Immediately hide it for UX
                badge.style.display = 'none';
                
                // Fire ajax to backend
                fetch('/user/notifications/mark-all-read', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json'
                    }
                });
            }
        }
        
        document.addEventListener("DOMContentLoaded", function() {
            try {
                // Inisialisasi Peta Langsung
                var map = L.map('map').setView([-6.200000, 106.816666], 13);
                
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; OpenStreetMap contributors'
                }).addTo(map);

                // Fix container resizes
                setTimeout(function() { map.invalidateSize(); }, 500);

                var userMarker = null;
                var userLat = null;
                var userLng = null;
                var radiusCircle = null;
                var itemMarkers = [];
                var cards = document.querySelectorAll('.item-card');

                function calculateDistance(lat1, lon1, lat2, lon2) {
                    var R = 6371e3; 
                    var phi1 = lat1 * Math.PI/180;
                    var phi2 = lat2 * Math.PI/180;
                    var deltaLat = (lat2-lat1) * Math.PI/180;
                    var deltaLng = (lon2-lon1) * Math.PI/180;
                    var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) + Math.cos(phi1) * Math.cos(phi2) * Math.sin(deltaLng/2) * Math.sin(deltaLng/2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                    return R * c; 
                }

                function applyFilter() {
                    var maxDistance = parseFloat(document.getElementById('radiusFilter').value);
                    
                    itemMarkers.forEach(m => map.removeLayer(m));
                    itemMarkers = [];
                    if(radiusCircle) map.removeLayer(radiusCircle);

                    if(userLat !== null && maxDistance < 999999) {
                        radiusCircle = L.circle([userLat, userLng], {
                            color: '#3B82F6', fillColor: '#3B82F6', fillOpacity: 0.1, radius: maxDistance
                        }).addTo(map);
                    }

                    cards.forEach(card => {
                        var itemId = card.getAttribute('data-id');
                        var itemLat = parseFloat(card.getAttribute('data-lat'));
                        var itemLng = parseFloat(card.getAttribute('data-lng'));
                        var itemName = card.getAttribute('data-name');
                        var status = card.getAttribute('data-status');
                        var distText = card.querySelector('.distance-text');

                        if (userLat === null) {
                            distText.innerText = "Jarak tdk diketahui";
                            card.style.display = 'flex';
                            addMarker(itemLat, itemLng, itemName, status, itemId);
                            return;
                        }

                        var distance = calculateDistance(userLat, userLng, itemLat, itemLng);
                        if (distance < 1000) { distText.innerText = Math.round(distance) + " m"; } 
                        else { distText.innerText = (distance / 1000).toFixed(1) + " KM"; }

                        if (distance <= maxDistance) {
                            card.style.display = 'flex';
                            addMarker(itemLat, itemLng, itemName, status, itemId);
                        } else {
                            card.style.display = 'none';
                        }
                    });
                }

                function addMarker(lat, lng, name, status, id) {
                    var color = status === 'hilang' ? 'red' : 'green';
                    var markerHtml = `<div style="background-color: ${color}; width: 14px; height: 14px; border-radius: 50%; border: 2px solid white; box-shadow: 0 0 4px rgba(0,0,0,0.5);"></div>`;
                    var customIcon = L.divIcon({ html: markerHtml, className: '', iconSize: [14, 14], iconAnchor: [7, 7] });
                    var marker = L.marker([lat, lng], {icon: customIcon}).addTo(map)
                        .bindPopup("<b>" + name + "</b><br>Status: " + status.toUpperCase() + "<br><span style='color:blue; text-decoration:underline; cursor:pointer;'>Membuka detail...</span>");
                    
                    marker.on('click', function() {
                        window.location.href = '/user/items/' + id;
                    });
                    
                    itemMarkers.push(marker);
                }

                // Render semua marker seketika sebelum nunggu GPS!
                applyFilter();
                document.getElementById('radiusFilter').addEventListener('change', applyFilter);

                // Baru minta GPS (Minta izin ke user)
                if (navigator.geolocation && (window.location.protocol === 'https:' || window.location.hostname === '127.0.0.1' || window.location.hostname === 'localhost')) {
                    navigator.geolocation.getCurrentPosition(function(position) {
                        userLat = position.coords.latitude;
                        userLng = position.coords.longitude;
                        map.setView([userLat, userLng], 14);
                        userMarker = L.marker([userLat, userLng]).addTo(map).bindPopup("<b>Lokasi Anda</b>").openPopup();
                        applyFilter(); // Filter ulang berdasarkan koordinat

                        // Tampilkan tombol "Pusatkan ke Saya" & fungsikan
                        var centerBtn = document.getElementById('centerMapBtn');
                        centerBtn.style.display = 'flex';
                        centerBtn.addEventListener('click', function() {
                            if(userLat !== null) {
                                map.setView([userLat, userLng], 14, { animate: true });
                            }
                        });

                    }, function(error) {
                        if (error.code === 1) {
                            alert("Peringatan: Anda menolak akses Lokasi. Peta tidak dapat menghitung jarak dengan akurat.");
                        } else {
                            alert("Peringatan: Gagal mendapatkan sinyal GPS. Mohon aktifkan GPS (Lokasi) pada perangkat Anda.");
                        }
                    }, {
                        enableHighAccuracy: true,
                        timeout: 5000,
                        maximumAge: 0
                    });
                }
            } catch(e) {
                console.error("Map Error: ", e);
            }
        });
    </script>
    <!-- Toast Notifications (Bottom Right) -->
    <div id="toastContainer" class="fixed bottom-4 right-4 z-50 flex flex-col gap-2"></div>

    <script>
        function markNotificationsAsRead() {
            const badge = document.getElementById('notifBadge');
            if (badge) {
                // Immediately hide it for UX
                badge.style.display = 'none';
                
                // Fire ajax to backend
                fetch('/user/notifications/mark-all-read', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json'
                    }
                });
            }
        }
        
        document.addEventListener("DOMContentLoaded", function() {
            let unreadNotifs = @json(Auth::user()->unreadNotifications);
            if (unreadNotifs.length > 0) {
                // Show the latest one as a popup toast
                let latest = unreadNotifs[0];
                let toast = document.createElement('div');
                toast.className = 'bg-white border-l-4 border-blue-500 shadow-xl p-4 rounded-lg flex items-start gap-3 w-80 transform transition-all translate-x-full opacity-0';
                toast.innerHTML = `
                    <div class="flex-1">
                        <p class="font-bold text-gray-800 text-sm">Notifikasi Baru</p>
                        <p class="text-sm text-gray-600 mt-1">${latest.data.message}</p>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-gray-400 hover:text-gray-600">&times;</button>
                `;
                document.getElementById('toastContainer').appendChild(toast);
                
                setTimeout(() => {
                    toast.classList.remove('translate-x-full', 'opacity-0');
                }, 100);

                setTimeout(() => {
                    toast.classList.add('translate-x-full', 'opacity-0');
                    setTimeout(() => toast.remove(), 300);
                }, 5000);
            }
        });
    </script>
</body>
</html>










