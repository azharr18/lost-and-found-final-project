import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import 'item_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final List<Item> items; // Can be empty if we fetch inside
  final Position? initialPosition;

  const MapScreen({Key? key, required this.items, this.initialPosition}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _radiusKm = 10.0;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  List<Item> _mapItems = [];

  @override
  void initState() {
    super.initState();
    _mapItems = widget.items;
    _initRadius();
    if (widget.initialPosition != null) {
      _currentLocation = LatLng(widget.initialPosition!.latitude, widget.initialPosition!.longitude);
    } else {
      _fetchLocationAndItems();
    }
  }

  Future<void> _initRadius() async {
    final r = await AuthService.getRadius();
    if (mounted) {
      setState(() => _radiusKm = r);
    }
  }

  Future<void> _fetchLocationAndItems() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('GPS Mati'),
            content: Text('Aplikasi ini membutuhkan GPS untuk menampilkan peta. Tolong aktifkan GPS/Lokasi di pengaturan HP Anda.'),
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
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Izin GPS Ditolak Permanen'),
            content: Text('Anda telah menolak izin lokasi. Mohon izinkan secara manual di Pengaturan Aplikasi agar peta bisa memuat lokasi Anda.'),
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
        throw Exception('Location permissions are permanently denied');
      }

      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
        });
        _fetchNearby();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 3),
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchNearby();
    } catch (e) {
      if (!mounted) return;
      if (_currentLocation == null) {
        // Fallback location (e.g., center of Jakarta) so the map still loads
        setState(() {
          _currentLocation = LatLng(-6.2088, 106.8456);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi GPS. Menggunakan lokasi default.')),
        );
        _fetchNearby();
      }
    }
  }

  Future<void> _fetchNearby() async {
    if (_currentLocation != null) {
      final items = await ItemService.getNearbyItems(
          _currentLocation!.latitude, _currentLocation!.longitude, _radiusKm);
      if (!mounted) return;
      setState(() {
        _mapItems = items;
      });
    }
  }

  void _centerMap() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lostandfound.app', // Changed to comply with OSM policy
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentLocation!,
                    color: AppConstants.primaryBlue.withOpacity(0.2),
                    borderStrokeWidth: 2,
                    borderColor: AppConstants.primaryBlue,
                    useRadiusInMeter: true,
                    radius: _radiusKm * 1000,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  ..._mapItems.where((i) => i.latitude != null && i.longitude != null).map((item) {
                    return Marker(
                      point: LatLng(item.latitude!, item.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
                          );
                        },
                        child: Icon(
                          Icons.location_on,
                          color: item.status == 'hilang' ? Colors.deepOrangeAccent : Colors.green,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: _radiusKm,
                    icon: Icon(Icons.arrow_drop_down, color: AppConstants.primaryBlue),
                    style: TextStyle(color: AppConstants.primaryBlue, fontWeight: FontWeight.bold),
                    items: [
                      DropdownMenuItem(value: 0.5, child: Text('500 Meter')),
                      DropdownMenuItem(value: 1.0, child: Text('1 KM')),
                      DropdownMenuItem(value: 5.0, child: Text('5 KM')),
                      DropdownMenuItem(value: 10.0, child: Text('10 KM')),
                    ],
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _radiusKm = newValue;
                        });
                        AuthService.saveRadius(newValue);
                        _fetchNearby();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppConstants.primaryBlue,
              onPressed: _centerMap,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


