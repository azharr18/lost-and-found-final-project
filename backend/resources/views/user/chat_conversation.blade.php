<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat dengan {{ $receiver->name }}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-100 text-gray-800 h-screen flex flex-col">

    <nav class="bg-blue-900 text-white p-4 shadow-md flex items-center gap-4 z-10 sticky top-0">
        <a href="{{ route('user.chat.inbox') }}" class="hover:text-blue-200 transition">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
        </a>
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white text-blue-900 rounded-full flex items-center justify-center font-bold text-lg">
                {{ strtoupper(substr($receiver->name, 0, 1)) }}
            </div>
            <div>
                <h1 class="font-bold text-lg leading-tight">{{ $receiver->name }}</h1>
            </div>
        </div>
    </nav>

    <main id="chatbox" class="flex-1 max-w-2xl w-full mx-auto p-4 overflow-y-auto flex flex-col gap-3">
        @if($messages->isEmpty())
            <div class="text-center text-gray-400 mt-10 text-sm">
                Mulai percakapan dengan {{ $receiver->name }}
            </div>
        @endif

        @foreach($messages as $msg)
            @if($msg->sender_id == Auth::id())
                <!-- My Message -->
                <div class="self-end bg-blue-600 text-white px-4 py-2 rounded-2xl rounded-br-sm max-w-[80%] shadow-sm">
                    <p>{{ $msg->message }}</p>
                    <span class="text-[10px] text-blue-200 block text-right mt-1">{{ $msg->created_at->format('H:i') }}</span>
                </div>
            @else
                <!-- Their Message -->
                <div class="self-start bg-white border px-4 py-2 rounded-2xl rounded-bl-sm max-w-[80%] shadow-sm">
                    <p class="text-gray-800">{{ $msg->message }}</p>
                    <span class="text-[10px] text-gray-400 block mt-1">{{ $msg->created_at->format('H:i') }}</span>
                </div>
            @endif
        @endforeach
    </main>

    <div class="bg-white p-4 shadow-[0_-2px_10px_rgba(0,0,0,0.05)] w-full max-w-2xl mx-auto">
        <form action="{{ route('user.chat.send', $receiver->id) }}" method="POST" class="flex gap-2">
            @csrf
            <input type="text" name="message" required autocomplete="off" placeholder="Ketik pesan..." class="flex-1 px-4 py-3 bg-gray-100 border-transparent rounded-full focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition outline-none">
            <button type="submit" class="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center text-white hover:bg-blue-700 transition flex-shrink-0 shadow-md">
                <svg class="w-5 h-5 translate-x-[-1px] translate-y-[1px]" fill="currentColor" viewBox="0 0 20 20"><path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z"></path></svg>
            </button>
        </form>
    </div>

    <script>
        // Scroll to bottom automatically
        var chatbox = document.getElementById('chatbox');
        chatbox.scrollTop = chatbox.scrollHeight;
    </script>
</body>
</html>
