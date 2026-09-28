<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Poppins', sans-serif; } </style>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center py-10">

    <div class="bg-white p-10 rounded-3xl shadow-xl w-full max-w-md border border-gray-100">
        <div class="text-center mb-8">
            <h2 class="text-3xl font-bold text-blue-900 mb-2">Buat Akun</h2>
            <p class="text-gray-500">Daftar untuk melaporkan barang hilang / ditemukan</p>
        </div>

        @if($errors->any())
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded">
                <ul class="list-disc ml-4 text-sm">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('register') }}" method="POST">
            @csrf
            
            <div class="mb-5">
                <label class="block text-gray-700 font-semibold mb-2">Nama Lengkap</label>
                <input type="text" name="name" value="{{ old('name') }}" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-transparent transition" placeholder="John Doe">
            </div>

            <div class="mb-5">
                <label class="block text-gray-700 font-semibold mb-2">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-transparent transition" placeholder="anda@contoh.com">
            </div>

            <div class="mb-5">
                <label class="block text-gray-700 font-semibold mb-2">Password</label>
                <input type="password" name="password" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-transparent transition" placeholder="Minimal 8 karakter">
            </div>

            <div class="mb-8">
                <label class="block text-gray-700 font-semibold mb-2">Konfirmasi Password</label>
                <input type="password" name="password_confirmation" required class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-transparent transition" placeholder="Ketik ulang password">
            </div>

            <button type="submit" class="w-full bg-blue-700 text-white font-bold py-3 px-4 rounded-xl hover:bg-blue-800 transition shadow-lg">
                Daftar Sekarang
            </button>
        </form>

        <div class="mt-6 text-center space-y-2">
            <p class="text-sm text-gray-600">Sudah punya akun? <a href="{{ route('login') }}" class="text-blue-600 font-bold hover:underline">Masuk di sini</a></p>
            <a href="/" class="block text-blue-600 hover:underline text-sm">Kembali ke Beranda</a>
        </div>
    </div>

</body>
</html>
