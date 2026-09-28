<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Report;
use App\Models\Item;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    public function showLogin()
    {
        return view('admin.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials)) {
            if (Auth::user()->role !== 'admin') {
                Auth::logout();
                return back()->withErrors([
                    'email' => 'Anda bukan admin.',
                ]);
            }

            $request->session()->regenerate();
            return redirect()->intended('/admin/dashboard');
        }

        return back()->withErrors([
            'email' => 'Kredensial tidak cocok.',
        ]);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/admin/login');
    }

    public function dashboard()
    {
        $reports = Report::with(['reporter', 'item'])->orderBy('created_at', 'desc')->get();
        return view('admin.dashboard', compact('reports'));
    }

    public function users()
    {
        $users = \App\Models\User::orderBy('created_at', 'desc')->get();
        return view('admin.users', compact('users'));
    }

    public function items()
    {
        $items = Item::with('user')->orderBy('created_at', 'desc')->get();
        return view('admin.items', compact('items'));
    }

    public function deleteItem($id)
    {
        $item = Item::findOrFail($id);
        $item->delete(); 
        return back()->with('success', 'Barang dan seluruh laporannya telah dihapus.');
    }

    public function resolveReport($id)
    {
        $report = Report::findOrFail($id);
        $report->delete();
        return back()->with('success', 'Laporan telah dihapus (ditolak). Barangnya tetap aman.');
    }
}
