import 'package:flutter/material.dart';
import 'package:agri_gurad/screens/home_page.dart';
import 'package:agri_gurad/screens/history_screen.dart';
import 'package:agri_gurad/screens/nearby_store.dart';
import 'package:agri_gurad/screens/settings.dart';
import 'package:agri_gurad/config/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const NearbyStoresScreen(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.lightGreen,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(
                Icons.home,
                color: AppTheme.primaryGreen,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(
                Icons.history,
                color: AppTheme.primaryGreen,
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: const Icon(Icons.store_outlined),
              selectedIcon: const Icon(
                Icons.store,
                color: AppTheme.primaryGreen,
              ),
              label: 'Stores',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
