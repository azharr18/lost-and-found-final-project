<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pesan - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800 h-screen flex flex-col">

    <nav class="bg-blue-900 text-white p-4 shadow-md flex justify-between items-center z-10">
        <a href="{{ route('user.dashboard') }}" class="text-xl font-bold flex items-center gap-2 hover:text-gray-200 transition">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
            <span>Kembali ke Dashboard</span>
        </a>
    </nav>

    <main class="flex-1 max-w-2xl w-full mx-auto p-4 sm:p-6 flex flex-col h-full overflow-hidden">
        <h2 class="text-3xl font-bold text-blue-900 mb-6">Pesan Masuk</h2>

        <div class="bg-white rounded-2xl shadow-sm border overflow-hidden flex-1 overflow-y-auto">
            @if($contacts->isEmpty())
                <div class="flex flex-col items-center justify-center h-full p-10 text-center">
                    <div class="w-24 h-24 bg-blue-50 text-blue-300 rounded-full flex items-center justify-center mb-4">
                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-700 mb-2">Belum ada obrolan</h3>
                    <p class="text-gray-500">Mulai obrolan dengan penemu atau pelapor barang.</p>
                </div>
            @else
                <ul class="divide-y divide-gray-100">
                    @foreach($contacts as $contact)
                        <li>
                            <a href="{{ route('user.chat.conversation', $contact->id) }}" class="flex items-center gap-4 p-4 hover:bg-blue-50 transition">
                                <div class="w-14 h-14 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center font-bold text-xl flex-shrink-0">
                                    {{ strtoupper(substr($contact->name, 0, 1)) }}
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-baseline mb-1">
                                        <h4 class="text-lg font-bold text-gray-900 truncate">{{ $contact->name }}</h4>
                                        <span class="text-xs text-gray-400 whitespace-nowrap">{{ $contact->last_message_time->diffForHumans() }}</span>
                                    </div>
                                    <p class="text-gray-500 text-sm truncate">{{ $contact->last_message }}</p>
                                </div>
                            </a>
                        </li>
                    @endforeach
                </ul>
            @endif
        </div>
    </main>

</body>
</html>
