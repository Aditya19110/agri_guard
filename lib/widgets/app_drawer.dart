import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agri_gurad/config/app_theme.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = 'AgriGuard User';
  String userEmail = '';
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (currentUser != null) {
      setState(() {
        userEmail = currentUser!.email ?? 'No Email';
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('name')) {
            setState(() {
              userName = data['name'];
            });
          }
        }
      } catch (e) {
        // Handle error silently, use default name
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Custom Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.secondaryGreen,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // User Info
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.camera_alt_rounded,
                  title: 'Crop Analysis',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Analysis History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/history');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.store_rounded,
                  title: 'Nearby Stores',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/stores');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Divider(),
                ),
                
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog();
                  },
                ),
              ],
            ),
          ),
          
          // Logout Section
          Container(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            child: _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () => _logout(context),
              isDestructive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppTheme.errorColor : AppTheme.primaryGreen,
          size: AppConstants.iconMedium,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        hoverColor: AppTheme.lightGreen,
        splashColor: AppTheme.accentGreen.withOpacity(0.2),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: Row(
          children: [
            Icon(
              Icons.agriculture_rounded,
              color: AppTheme.primaryGreen,
              size: AppConstants.iconLarge,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            const Text('About AgriGuard Plus'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgriGuard Plus is your smart agriculture companion for crop disease detection and management.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text('Version: 1.0.0'),
            Text('Developer: Aditya K.'),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              '© 2024 AgriGuard Plus. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.help_outline_rounded,
              color: AppTheme.primaryGreen,
              size: AppConstants.iconLarge,
            ),
            SizedBox(width: AppConstants.paddingSmall),
            Text('Help & Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with AgriGuard Plus?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text('• Take clear photos of affected crop areas'),
            Text('• Ensure good lighting for better analysis'),
            Text('• Follow the recommendations provided'),
            Text('• Contact agricultural experts for severe cases'),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'For technical support, please contact:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('Email: support@agriguardplus.com'),
            Text('Phone: +1 234-567-8900'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.agriculture, color: Colors.white),
            ),
            decoration: const BoxDecoration(color: Color(0xFF00796B)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}