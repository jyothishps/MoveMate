import 'package:flutter/material.dart';
import 'package:qr_packing_app/screens/home/home_tab.dart';
import 'package:qr_packing_app/screens/profile/profile_screen.dart';
import 'package:qr_packing_app/screens/qr/scan_qr_screen.dart';
import 'package:qr_packing_app/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Tab order: 0 Home, 1 Search, 2 Scan, 3 Profile.
    final tabs = <Widget>[
      HomeTab(
        onSearchTap: () => _goToTab(1),
        onScanTap: () => _goToTab(2),
      ),
      const SearchScreen(),
      const ScanQrScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}