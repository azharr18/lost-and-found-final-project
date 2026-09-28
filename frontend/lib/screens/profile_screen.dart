import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

import 'edit_profile_screen.dart';
import 'my_reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getProfile();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Profile Card
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppConstants.primaryBlue, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: AppConstants.bgLightBlue,
                            backgroundImage: _user?.photoUrl != null
                                ? CachedNetworkImageProvider(
                                    _user!.photoUrl!,
                                    headers: {'ngrok-skip-browser-warning': 'true'},
                                  )
                                : null,
                            child: _user?.photoUrl == null
                                ? Icon(Icons.person, size: 40, color: AppConstants.primaryBlue)
                                : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user!.name,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _user!.email,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              if (_user!.phoneNumber != null) ...[
                                SizedBox(height: 2),
                                Text(
                                  _user!.phoneNumber!,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: AppConstants.primaryBlue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
                            );
                            if (result == true) {
                              _loadUser();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Menu Options
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuOption(Icons.history, 'Riwayat Laporan', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyReportsScreen()),
                          );
                        }),
                        Divider(height: 1, indent: 50, endIndent: 16),
                        _buildMenuOption(Icons.help_outline, 'Pusat Bantuan', () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Pusat Bantuan'),
                              content: Text('Hubungi admin di admin@lostandfound.com untuk bantuan lebih lanjut.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout, color: Colors.red),
                      label: Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
                        minimumSize: Size(double.infinity, 54),
                        backgroundColor: Colors.red.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConstants.bgLightBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppConstants.primaryBlue, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
