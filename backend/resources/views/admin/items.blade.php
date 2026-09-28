<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manajemen Barang - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; } </style>
</head>
<body class="h-screen flex overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 bg-indigo-900 flex flex-col shadow-xl z-20">
        <div class="p-6 border-b border-indigo-800 flex items-center justify-between">
            <h2 class="text-2xl font-bold text-white tracking-wider flex items-center gap-2">
                <i class="fas fa-shield-alt text-indigo-400"></i> Admin
            </h2>
        </div>
        <nav class="flex-1 px-4 py-6 space-y-2">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center px-4 py-3 hover:bg-indigo-800 rounded-lg text-indigo-200 font-medium transition">
                <i class="fas fa-chart-line w-6 text-indigo-300"></i>
                Laporan Penipuan
            </a>
            <a href="{{ route('admin.users') }}" class="flex items-center px-4 py-3 hover:bg-indigo-800 rounded-lg text-indigo-200 font-medium transition">
                <i class="fas fa-users w-6 text-indigo-300"></i>
                Pengguna
            </a>
            <a href="{{ route('admin.items') }}" class="flex items-center px-4 py-3 bg-indigo-800 rounded-lg text-white font-medium transition">
                <i class="fas fa-boxes w-6 text-indigo-300"></i>
                Barang (Items)
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-hidden relative">
        <!-- Topbar -->
        <header class="bg-white shadow-sm border-b border-gray-200 h-16 flex items-center justify-between px-8 z-10">
            <h1 class="text-xl font-bold text-gray-800">Manajemen Barang (Items)</h1>
            <div class="flex items-center gap-4">
                <form action="{{ route('logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="text-sm font-semibold text-gray-600 hover:text-red-600 transition flex items-center gap-2">
                        <i class="fas fa-sign-out-alt"></i> Keluar
                    </button>
                </form>
            </div>
        </header>

        <div class="flex-1 overflow-auto p-8 relative z-0">
            @if(session('success'))
                <div class="mb-4 bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded shadow-sm">
                    <p class="font-bold">Berhasil</p>
                    <p>{{ session('success') }}</p>
                </div>
            @endif

            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                    <h3 class="text-lg font-semibold text-gray-800">Daftar Seluruh Barang Terlapor</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Barang</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Pelapor (Owner)</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            @foreach($items as $item)
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">#{{ $item->id }}</td>
                                    <td class="px-6 py-4 text-sm text-gray-900">
                                        <p class="font-bold">{{ $item->name }}</p>
                                        <p class="text-xs text-gray-500 line-clamp-1">{{ $item->description }}</p>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ $item->user->name }}</td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm">
                                        @if($item->status == 'hilang')
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">HILANG</span>
                                        @elseif($item->status == 'ditemukan')
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">DITEMUKAN</span>
                                        @else
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">{{ strtoupper($item->status) }}</span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <form method="POST" action="{{ route('admin.deleteItem', $item->id) }}" onsubmit="return confirm('Apakah Anda yakin ingin MENGHAPUS BARANG ini secara permanen?');" class="inline">
                                            @csrf
                                            <button type="submit" title="Hapus Barang" class="text-white bg-red-600 hover:bg-red-700 px-3 py-1.5 rounded text-xs transition flex items-center">
                                                <i class="fas fa-trash-alt mr-1"></i> Hapus
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>

