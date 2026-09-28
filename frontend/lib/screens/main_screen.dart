import 'package:flutter/material.dart';
import '../constants.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'add_item_screen.dart';
import 'profile_screen.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.startPolling();
  }

  @override
  void dispose() {
    NotificationService.stopPolling();
    super.dispose();
  }

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(items: []), // We will need to update this to fetch items globally or within MapScreen
    AddItemScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.primaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My profile',
          ),
        ],
      ),
    );
  }
}
