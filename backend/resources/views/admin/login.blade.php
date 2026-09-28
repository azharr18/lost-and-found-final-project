<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Lost & Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded shadow-md w-96">
        <h2 class="text-2xl font-bold mb-6 text-center text-blue-600">Admin Panel</h2>
        
        @if($errors->any())
            <div class="bg-red-100 text-red-700 p-3 rounded mb-4 text-sm">
                {{ $errors->first() }}
            </div>
        @endif

        <form method="POST" action="/admin/login">
            @csrf
            <div class="mb-4">
                <label class="block text-gray-700 text-sm font-bold mb-2">Email</label>
                <input type="email" name="email" required class="w-full border rounded px-3 py-2 focus:outline-none focus:border-blue-500">
            </div>
            <div class="mb-6">
                <label class="block text-gray-700 text-sm font-bold mb-2">Password</label>
                <input type="password" name="password" required class="w-full border rounded px-3 py-2 focus:outline-none focus:border-blue-500">
            </div>
            <button type="submit" class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded hover:bg-blue-700">
                Login
            </button>
        </form>
    </div>
</body>
</html>
