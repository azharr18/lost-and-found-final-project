import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    final result = await AuthService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _phoneController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registrasi Gagal'),
          content: Text(result['message']),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryBlue,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Daftar', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
