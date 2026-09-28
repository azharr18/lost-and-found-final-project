import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../constants.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'item_detail_screen.dart';
import 'chat_list_screen.dart';
import 'notifications_screen.dart';

import 'dart:async';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _nearbyItems = [];
  List<Item> _recentItems = [];
  String _searchQuery = '';
  bool _isLoading = true;
  Position? _currentPosition;
  User? _currentUser;
  double _radius = 10.0; // 10 km by default
  int _unreadCount = 0;
  int _unreadNotifCount = 0;
  Timer? _pollingTimer;

  List<Item> get _filteredNearbyItems {
    if (_searchQuery.isEmpty) return _nearbyItems;
    return _nearbyItems.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<Item> get _filteredRecentItems {
    if (_searchQuery.isEmpty) return _recentItems;
    return _recentItems.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserAndData();
    _startUnreadPolling();
  }

  void _startUnreadPolling() {
    _fetchUnreadCount();
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchUnreadCount();
    });
  }

  Future<void> _fetchUnreadCount() async {
    final convos = await ChatService.getConversations();
    final notifs = await NotificationService.getHistory();
    if (!mounted) return;
    int chatCount = 0;
    for (var c in convos) {
      chatCount += (c['unread_count'] as int?) ?? 0;
    }
    int notifCount = 0;
    for (var n in notifs) {
      if (n['read_at'] == null) notifCount++;
    }
    if (_unreadCount != chatCount || _unreadNotifCount != notifCount) {
      setState(() {
        _unreadCount = chatCount;
        _unreadNotifCount = notifCount;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserAndData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getProfile();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Minta izin aktifkan GPS
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('GPS Mati'),
          content: Text('Aplikasi ini membutuhkan GPS untuk menemukan barang di sekitar Anda. Tolong aktifkan GPS/Lokasi di pengaturan HP Anda.'),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Buka Pengaturan'),
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
            )
          ],
        )
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Izin GPS Ditolak Permanen'),
          content: Text('Anda telah menolak izin lokasi. Mohon izinkan secara manual di Pengaturan Aplikasi agar fitur berjalan dengan baik.'),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Buka Pengaturan'),
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openAppSettings();
              },
            )
          ],
        )
      );
      return;
    }

    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null && mounted) {
      _currentPosition = position;
      _fetchItems(); // Load quickly using last known position
    }

    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 3),
      );
      if (!mounted) return;
      _currentPosition = position;
      _fetchItems(); // Refresh with new position
    } catch (e) {
      if (!mounted) return;
      if (_currentPosition == null) {
        // Fallback location only if absolutely no location is available
        _currentPosition = Position(
          longitude: 106.8456,
          latitude: -6.2088,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _fetchItems();
      }
    }
  }

  Future<void> _fetchItems() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);
    _radius = await AuthService.getRadius();
    
    final nearby = await ItemService.getNearbyItems(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _radius,
    );
    
    final recent = await ItemService.getRecentItems();
    
    if (!mounted) return;
    setState(() {
      _nearbyItems = nearby;
      _recentItems = recent;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue, // Dark blue background for top part
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _fetchUserAndData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildNearbySection(),
                      _buildRecentSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            backgroundImage: _currentUser?.photoUrl != null
                ? CachedNetworkImageProvider(
                    _currentUser!.photoUrl!,
                    headers: const {'ngrok-skip-browser-warning': 'true'},
                  )
                : null,
            child: _currentUser?.photoUrl == null
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12),
          Text(
            'Hii ${_currentUser?.name ?? "User"}',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '$_unreadCount',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListScreen()),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                  _fetchUnreadCount();
                },
              ),
              if (_unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '$_unreadNotifCount',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari Barang...',
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                      FocusScope.of(context).unfocus();
                    },
                  )
                : Icon(Icons.tune, color: Colors.white),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ditemukan di Sekitarmu',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _filteredNearbyItems.isEmpty 
              ? Center(child: Text('Tidak ada barang ditemukan', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filteredNearbyItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredNearbyItems[index];
                    return _buildHorizontalCard(item);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(Item item) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
        if (result == true) {
          _fetchItems();
        }
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppConstants.bgLightBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(12).copyWith(bottom: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.photoUrl!,
                              httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.grey),
                            )
                          : Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.primaryBlue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppConstants.primaryBlue),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Estimasi ${((item.distance ?? 0) * 1000).toInt()} meter',
                              style: TextStyle(fontSize: 10, color: AppConstants.primaryBlue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status == 'hilang' ? Colors.deepOrangeAccent : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status == 'hilang' ? 'Hilang' : 'Ditemukan',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.bgLightBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Terbaru',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryBlue),
          ),
          SizedBox(height: 16),
          _filteredRecentItems.isEmpty ? Center(child: Text('Tidak ada laporan terbaru', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _filteredNearbyItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredNearbyItems[index];
                  return _buildVerticalCard(item);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard(Item item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.photoUrl!,
                          httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.grey),
                        )
                      : Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.status == 'hilang' ? Colors.deepOrangeAccent : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status == 'hilang' ? 'Hilang' : 'Ditemukan',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryBlue),
                ),
                SizedBox(height: 4),
                Text(
                  'Baru saja', // TODO: Format actual created_at
                  style: TextStyle(color: AppConstants.primaryBlue, fontSize: 12),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
                    );
                    if (result == true) {
                      _fetchItems();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text('Lihat Detail', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








