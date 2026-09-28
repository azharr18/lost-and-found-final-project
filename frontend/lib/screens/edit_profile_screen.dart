import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final res = await AuthService.updateProfile(
      _nameController.text,
      _phoneController.text.isEmpty ? null : _phoneController.text,
      _passwordController.text,
      photoPath: _imageFile?.path,
    );
    setState(() => _isLoading = false);

    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui')));
      Navigator.pop(context, true); // return true to indicate refresh needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : (widget.user.photoUrl != null
                            ? CachedNetworkImageProvider(
                                widget.user.photoUrl!,
                                headers: {'ngrok-skip-browser-warning': 'true'},
                              )
                            : null),
                    child: _imageFile == null && widget.user.photoUrl == null
                        ? Icon(Icons.person, size: 50, color: AppConstants.primaryBlue)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password Baru (Opsional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
