<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class WebAuthController extends Controller
{
        public function showRegister()
    {
        return view('auth.register');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user',
        ]);

        Auth::login($user);

        return redirect('/user/dashboard');
    }

    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        // Support both username for admin and email for users
        $loginType = filter_var($request->input('login_id'), FILTER_VALIDATE_EMAIL) ? 'email' : 'name';
        
        $credentials = [
            $loginType => $request->input('login_id'),
            'password' => $request->input('password')
        ];

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();
            if (Auth::user()->role === 'admin') {
                return redirect()->intended('/admin/dashboard');
            }
            return redirect()->intended('/user/dashboard');
        }

        return back()->withErrors([
            'login_id' => 'Kredensial tidak cocok atau akun tidak ditemukan.',
        ]);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    }
}

