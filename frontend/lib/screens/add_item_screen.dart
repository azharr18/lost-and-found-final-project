import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import '../services/item_service.dart';

class AddItemScreen extends StatefulWidget {
  final Position? currentPosition;

  const AddItemScreen({Key? key, this.currentPosition}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _bountyController = TextEditingController();
  
  String _status = 'hilang';
  File? _imageFile;
  bool _isLoading = false;
  
  double? _lat;
  double? _lon;
  double? _deviceLat;
  double? _deviceLon;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.currentPosition != null) {
      _lat = widget.currentPosition!.latitude;
      _lon = widget.currentPosition!.longitude;
      _deviceLat = _lat;
      _deviceLon = _lon;
    } else {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _lat = lastPosition.latitude;
          _lon = lastPosition.longitude;
          _deviceLat = lastPosition.latitude;
          _deviceLon = lastPosition.longitude;
        });
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 3),
      );
      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _deviceLat = position.latitude;
        _deviceLon = position.longitude;
      });
    } catch (e) {
      if (!mounted) return;
      if (_lat == null || _lon == null) {
        // Fallback location (e.g., center of Jakarta)
        setState(() {
          _lat = -6.2088;
          _lon = 106.8456;
          _deviceLat = -6.2088;
          _deviceLon = 106.8456;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image to 50% quality to improve upload and load times
      maxWidth: 1080, // Resize image to max 1080px width
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and Location are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error = await ItemService.storeItem(
      name: _nameController.text,
      description: _descController.text,
      status: _status,
      bountyPoints: int.tryParse(_bountyController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      lat: _lat!,
      lon: _lon!,
      photoPath: _imageFile?.path,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item successfully reported!')),
      );
      _nameController.clear();
      _descController.clear();
      _bountyController.clear();
      setState(() {
        _imageFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Lapor Barang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Nama Barang'),
            SizedBox(height: 8),
            _buildTextField(_nameController, 'Contoh: Kunci Motor Vario'),
            
            SizedBox(height: 20),
            _buildLabel('Status'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'hilang', child: Text('Saya Kehilangan Barang')),
                    DropdownMenuItem(value: 'ditemukan', child: Text('Saya Menemukan Barang')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _status = val!;
                    });
                  },
                ),
              ),
            ),
            
            SizedBox(height: 20),
            _buildLabel('Deskripsi Tambahan'),
            SizedBox(height: 8),
            _buildTextField(_descController, 'Ciri-ciri khusus, warna, lokasi...', maxLines: 4),

            SizedBox(height: 20),
            _buildLabel('Bounty Points (Opsional)'),
            SizedBox(height: 8),
            _buildTextField(_bountyController, 'Contoh: 50', keyboardType: TextInputType.number),
            
            SizedBox(height: 20),
            _buildLabel('Foto Barang'),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Color(0xFFD6E4FF), // light blue background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryBlue, width: 1.5),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: AppConstants.primaryBlue),
                          SizedBox(height: 12),
                          Text('Klik untuk Upload Foto', style: TextStyle(color: AppConstants.primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : null,
              ),
            ),

            SizedBox(height: 20),
            _buildLabel('Lokasi Barang'),
            SizedBox(height: 8),
            _lat == null || _lon == null
                ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants.primaryBlue, width: 1.5),
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants.primaryBlue, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_lat!, _lon!),
                              initialZoom: 15.0,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _lat = point.latitude;
                                  _lon = point.longitude;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.lostandfound.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (_deviceLat != null && _deviceLon != null)
                                    Marker(
                                      point: LatLng(_deviceLat!, _deviceLon!),
                                      width: 24,
                                      height: 24,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Marker(
                                    point: LatLng(_lat!, _lon!),
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: FloatingActionButton.small(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                if (_deviceLat != null && _deviceLon != null) {
                                  _mapController.move(LatLng(_deviceLat!, _deviceLon!), 15.0);
                                  setState(() {
                                    _lat = _deviceLat;
                                    _lon = _deviceLon;
                                  });
                                }
                              },
                              child: Icon(Icons.my_location, color: AppConstants.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            SizedBox(height: 8),
            Text('Geser atau ketuk peta untuk menyesuaikan titik lokasi.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            
            SizedBox(height: 40),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Simpan Laporan', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: AppConstants.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
