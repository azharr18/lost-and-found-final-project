import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import '../models/item.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  User? _currentUser;
  bool _isOwner = false;
  String _address = "Mencari alamat...";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (widget.item.latitude == null || widget.item.longitude == null) {
      if (!mounted) return;
      setState(() => _address = "Lokasi tidak diketahui");
      return;
    }
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(widget.item.latitude!, widget.item.longitude!);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _address = "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
        });
      } else {
        setState(() => _address = "${widget.item.latitude}, ${widget.item.longitude}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _address = "${widget.item.latitude}, ${widget.item.longitude}");
    }
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getProfile();
    if (!mounted) return;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _isOwner = (user.id == widget.item.userId);
      });
    }
  }

  void _showReportDialog() {
    String selectedReason = 'Barang Palsu';
    final List<String> reasons = ['Barang Palsu', 'Penipuan / Fraud', 'Informasi Tidak Akurat', 'Spam / Iklan', 'Lainnya'];
    File? evidencePhoto;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Laporkan Barang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pilih alasan mengapa Anda melaporkan barang ini:'),
                    SizedBox(height: 16),
                    ...reasons.map((reason) => RadioListTile(
                      title: Text(reason),
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedReason = value as String;
                        });
                      },
                    )).toList(),
                    SizedBox(height: 16),
                    Text('Sertakan Foto Bukti (Opsional):', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setStateDialog(() {
                            evidencePhoto = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: evidencePhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(evidencePhoto!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey[600]),
                                  SizedBox(height: 4),
                                  Text('Pilih Foto', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    final success = await ItemService.reportItem(widget.item.id, selectedReason, evidencePath: evidencePhoto?.path);
                    if (!mounted) return;
                    if (success) {
                      messenger.showSnackBar(SnackBar(content: Text('Laporan berhasil dikirim.')));
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text('Gagal mengirim laporan.')));
                    }
                  },
                  child: Text('Kirim Laporan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _chatWithReporter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: widget.item.userId,
          itemContext: widget.item,
        ),
      ),
    );
  }

  Future<void> _resolveItem() async {
    bool success = await ItemService.resolveItem(widget.item.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Barang berhasil ditandai sebagai telah dikembalikan.')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui status barang.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white30,
                backgroundImage: widget.item.userPhotoUrl != null
                    ? CachedNetworkImageProvider(
                        widget.item.userPhotoUrl!,
                        headers: const {'ngrok-skip-browser-warning': 'true'},
                      )
                    : null,
                child: widget.item.userPhotoUrl == null
                    ? Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 8),
              Text(
                widget.item.userName ?? 'User ${widget.item.userId}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Laporkan Penipuan', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Photo Container
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: widget.item.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.item.photoUrl!,
                              httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error, size: 100, color: Colors.grey),
                            )
                        : Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
                  ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: (widget.item.status == 'selesai' || widget.item.resolvedBy != null)
                              ? Colors.blueAccent
                              : (widget.item.status == 'hilang' ? Colors.deepOrangeAccent : Colors.green),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          (widget.item.status == 'selesai' || widget.item.resolvedBy != null)
                              ? 'Selesai'
                              : (widget.item.status == 'hilang' ? 'Hilang' : 'Ditemukan'),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Title and Bounty
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                if (widget.item.bountyPoints > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(widget.item.bountyPoints),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24),
            // Description
            Text(
              'Deskripsi barang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              widget.item.description ?? 'Tidak ada deskripsi.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 24),
            // Location Title
            Text(
              'Perkiraan Titik Hilang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.deepOrangeAccent, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _address,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Mini Map
            if (widget.item.latitude != null && widget.item.longitude != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(widget.item.latitude!, widget.item.longitude!),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.lostandfound.app', // Changed to comply with OSM policy
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.item.latitude!, widget.item.longitude!),
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on, color: Colors.deepOrangeAccent, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 24),
            // Buttons
            if (!_isOwner && widget.item.status != 'selesai')
              ElevatedButton.icon(
                onPressed: _chatWithReporter,
                icon: Icon(Icons.chat),
                label: Text('kirim pesan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryBlue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            if (_isOwner && widget.item.status != 'selesai')
              ElevatedButton.icon(
                onPressed: _resolveItem,
                icon: Icon(Icons.check_circle),
                label: Text('Barang Telah Dikembalikan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
