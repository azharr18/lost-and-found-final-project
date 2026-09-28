<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gray-50 flex h-screen overflow-hidden text-gray-800" x-data="{ imgModal: false, imgSrc: '' }">

    <!-- Sidebar -->
    <aside class="w-64 bg-indigo-900 text-white flex flex-col">
        <div class="h-16 flex items-center justify-center font-bold text-xl border-b border-indigo-800">
            <i class="fas fa-search-location mr-2"></i> Lost & Found
        </div>
        <nav class="flex-1 px-4 py-6 space-y-2">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center px-4 py-3 bg-indigo-800 rounded-lg text-white font-medium">
                <i class="fas fa-chart-line w-6 text-indigo-300"></i>
                Laporan Penipuan
            </a>
            <a href="{{ route('admin.users') }}" class="flex items-center px-4 py-3 hover:bg-indigo-800 rounded-lg text-indigo-200 font-medium transition"><i class="fas fa-users w-6 text-indigo-300"></i>
                Pengguna
            </a>
            <a href="{{ route('admin.items') }}" class="flex items-center px-4 py-3 hover:bg-indigo-800 rounded-lg text-indigo-200 font-medium transition"><i class="fas fa-boxes w-6 text-indigo-300"></i>
                Barang (Items)
            </a>
        </nav>
        <div class="p-4 border-t border-indigo-800">
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button type="submit" class="flex items-center w-full px-4 py-3 hover:bg-red-600 rounded-lg text-indigo-200 hover:text-white font-medium transition">
                    <i class="fas fa-sign-out-alt w-6"></i>
                    Keluar (Logout)
                </button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col h-screen overflow-hidden">
        
        <!-- Header -->
        <header class="h-16 bg-white shadow-sm flex items-center px-8 justify-between z-10">
            <h1 class="text-2xl font-semibold text-gray-800">Dasbor Administrator</h1>
            <div class="flex items-center space-x-4">
                <div class="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-bold border-2 border-indigo-500">
                    A
                </div>
                <span class="font-medium">Administrator</span>
            </div>
        </header>

        <!-- Main scrollable area -->
        <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 p-8">
            
            <!-- Stats -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center">
                    <div class="p-4 rounded-full bg-blue-100 text-blue-600 mr-4">
                        <i class="fas fa-flag fa-lg"></i>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 font-medium">Total Laporan</p>
                        <p class="text-3xl font-bold text-gray-800">{{ $reports->count() }}</p>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center">
                    <div class="p-4 rounded-full bg-yellow-100 text-yellow-600 mr-4">
                        <i class="fas fa-clock fa-lg"></i>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 font-medium">Menunggu Tindakan</p>
                        <p class="text-3xl font-bold text-gray-800">{{ $reports->where("status", "pending")->count() }}</p>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center">
                    <div class="p-4 rounded-full bg-green-100 text-green-600 mr-4">
                        <i class="fas fa-check-circle fa-lg"></i>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500 font-medium">Laporan Selesai</p>
                        <p class="text-3xl font-bold text-gray-800">{{ $reports->where("status", "resolved")->count() }}</p>
                    </div>
                </div>
            </div>

            @if(session("success"))
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded mb-6 flex items-center shadow-sm">
                    <i class="fas fa-check-circle mr-3 text-xl"></i>
                    <p>{{ session("success") }}</p>
                </div>
            @endif

            <!-- Table Section -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                    <h3 class="text-lg font-semibold text-gray-800">Laporan Penipuan / Pelanggaran</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Tgl / Waktu</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Pelapor</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Barang / Target</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Alasan & Bukti</th>
                                <th class="px-6 py-3 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            @forelse($reports as $report)
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {{ $report->created_at->format("d M Y") }}<br>
                                        <span class="text-xs">{{ $report->created_at->format("H:i") }}</span>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="flex items-center">
                                            <div class="flex-shrink-0 h-8 w-8 bg-indigo-100 rounded-full flex items-center justify-center text-indigo-700 font-bold">
                                                {{ substr($report->reporter->name ?? "U", 0, 1) }}
                                            </div>
                                            <div class="ml-3">
                                                <div class="text-sm font-medium text-gray-900">{{ $report->reporter->name ?? "Unknown" }}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        @if($report->item)
                                            <div class="text-sm text-gray-900 font-medium">{{ $report->item->name }}</div>
                                            <div class="text-xs text-gray-500">Pemilik: {{ $report->item->user->name ?? "Unknown" }}</div>
                                        @else
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                                                Dihapus (Take Down)
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="text-sm text-red-600 font-medium">{{ $report->reason }}</div>
                                        @if($report->evidence_url)
                                            <button @click="imgModal = true; imgSrc = '{{ $report->evidence_url }}'" class="mt-1 text-xs text-indigo-600 hover:text-indigo-900 flex items-center">
                                                <i class="fas fa-image mr-1"></i> Lihat Bukti Foto
                                            </button>
                                        @else
                                            <div class="mt-1 text-xs text-gray-400"><i class="fas fa-times mr-1"></i> Tidak ada bukti foto</div>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-center">
                                        @if($report->status == "pending")
                                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                                                Menunggu
                                            </span>
                                        @else
                                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                Selesai
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        @if($report->status == "pending")
                                            <div class="flex justify-end space-x-2">
                                                @if($report->item)
                                                    <form method="POST" action="/admin/items/{{ $report->item->id }}/delete" onsubmit="return confirm('Apakah Anda yakin ingin MENGHAPUS BARANG ini? Semua laporan yang berkaitan dengan barang ini juga akan otomatis terhapus bersama barangnya!');">
                                                        @csrf
                                                        <button type="submit" title="Hapus Barang" class="text-white bg-red-600 hover:bg-red-700 px-3 py-1.5 rounded text-xs transition flex items-center">
                                                            <i class="fas fa-trash-alt mr-1"></i> Take Down
                                                        </button>
                                                    </form>
                                                @endif
                                                <form method="POST" action="/admin/reports/{{ $report->id }}/resolve" onsubmit="return confirm('Tolak dan hapus laporan ini? Barang akan dibiarkan aman.');">
                                                    @csrf
                                                    <button type="submit" title="Tolak Laporan" class="text-white bg-gray-500 hover:bg-gray-600 px-3 py-1.5 rounded text-xs transition flex items-center">
                                                        <i class="fas fa-times mr-1"></i> Tolak Laporan
                                                    </button>
                                                </form>
                                            </div>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="px-6 py-10 text-center text-gray-500">
                                        <i class="fas fa-inbox fa-3x mb-3 text-gray-300 block"></i>
                                        Belum ada laporan masuk saat ini.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Image Modal -->
    <div x-show="imgModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75" x-cloak style="display: none;">
        <div class="relative bg-white rounded-lg shadow-xl max-w-3xl w-full mx-4 overflow-hidden" @click.away="imgModal = false">
            <div class="flex justify-between items-center p-4 border-b">
                <h3 class="text-lg font-semibold">Bukti Foto Laporan</h3>
                <button @click="imgModal = false" class="text-gray-500 hover:text-gray-700 focus:outline-none">
                    <i class="fas fa-times fa-lg"></i>
                </button>
            </div>
            <div class="p-4 flex justify-center bg-gray-100">
                <img :src="imgSrc" class="max-h-[70vh] object-contain rounded border border-gray-300" alt="Bukti Foto">
            </div>
            <div class="p-4 border-t bg-gray-50 flex justify-end">
                <button @click="imgModal = false" class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300">Tutup</button>
            </div>
        </div>
    </div>
</body>
</html>


