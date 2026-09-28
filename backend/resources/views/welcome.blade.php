<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lost & Found - Temukan Barangmu</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800">
    <nav class="bg-blue-900 text-white p-4 shadow-lg flex justify-between items-center">
        <div class="text-2xl font-bold tracking-wider">Lost&Found</div>
        <div class="flex gap-4">
            <a href="{{ route('login') }}" class="text-white hover:text-gray-200 font-semibold py-2">Masuk</a>
            <a href="{{ route('register') }}" class="bg-yellow-400 text-blue-900 px-6 py-2 rounded-full font-bold hover:bg-yellow-300 transition shadow-sm">Daftar</a>
        </div>
    </nav>

    <main class="max-w-6xl mx-auto px-4 py-16 text-center">
        <h1 class="text-5xl font-bold text-blue-900 mb-6">Kehilangan Sesuatu? Atau Menemukan Barang?</h1>
        <p class="text-xl text-gray-600 mb-10 max-w-2xl mx-auto">Platform terpercaya untuk membantu mahasiswa dan masyarakat menemukan kembali barang berharga mereka yang hilang di area kampus atau sekitarnya.</p>
        
        <div class="flex justify-center gap-6">
            <a href="/login" class="bg-blue-600 text-white px-8 py-3 rounded-xl font-semibold hover:bg-blue-700 shadow-md transition">Cari Barang Saya</a>
            <a href="/login" class="bg-white border-2 border-blue-600 text-blue-600 px-8 py-3 rounded-xl font-semibold hover:bg-blue-50 shadow-md transition">Laporkan Temuan</a>
        </div>

        <div class="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border">
                <div class="flex justify-center mb-4">
                    <svg class="w-12 h-12 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                </div>
                <h3 class="text-xl font-bold mb-2">Cari Cepat</h3>
                <p class="text-gray-500">Sistem pintar kami membantu mencocokkan barang hilang dengan barang yang ditemukan secara akurat.</p>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border">
                <div class="flex justify-center mb-4">
                    <svg class="w-12 h-12 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"></path></svg>
                </div>
                <h3 class="text-xl font-bold mb-2">Komunitas Peduli</h3>
                <p class="text-gray-500">Terhubung langsung dengan penemu barang melalui fitur live chat bawaan aplikasi kami.</p>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border">
                <div class="flex justify-center mb-4">
                    <svg class="w-12 h-12 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.243-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                </div>
                <h3 class="text-xl font-bold mb-2">Lacak Lokasi</h3>
                <p class="text-gray-500">Lihat lokasi penemuan barang langsung dari peta interaktif yang mudah digunakan.</p>
            </div>
        </div>
    </main>

    <footer class="bg-gray-900 text-gray-400 text-center p-6 mt-10">
        <p>&copy; 2026 Lost & Found App. All rights reserved.</p>
    </footer>
</body>
</html>
