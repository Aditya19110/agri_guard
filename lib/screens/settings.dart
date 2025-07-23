import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';
import 'package:agri_gurad/config/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userName = 'AgriGuard User';
  String userEmail = 'No Email';
  String userAddress = 'No Address';
  
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _dataBackupEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (currentUser != null) {
      setState(() {
        userEmail = currentUser!.email ?? 'No Email';
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        final data = userDoc.data();
        if (userDoc.exists && data is Map<String, dynamic>) {
          setState(() {
            userName = data['name'] ?? 'AgriGuard User';
            userAddress = data['address'] ?? 'No Address';
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Section
                _buildProfileSection(),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // App Settings
                _buildSettingsSection(
                  title: 'App Settings',
                  icon: Icons.settings,
                  children: [
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Receive analysis updates and tips',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Location Services',
                      subtitle: 'Help find nearby agricultural stores',
                      value: _locationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _locationEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Data Backup',
                      subtitle: 'Automatically backup analysis history',
                      value: _dataBackupEnabled,
                      onChanged: (value) {
                        setState(() {
                          _dataBackupEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Account Settings
                _buildSettingsSection(
                  title: 'Account',
                  icon: Icons.account_circle,
                  children: [
                    _buildActionTile(
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      icon: Icons.edit,
                      onTap: () {
                        _showEditProfileDialog();
                      },
                    ),
                    _buildActionTile(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: Icons.lock,
                      onTap: () {
                        _showChangePasswordDialog();
                      },
                    ),
                    _buildActionTile(
                      title: 'Privacy Policy',
                      subtitle: 'View our privacy policy',
                      icon: Icons.privacy_tip,
                      onTap: () {
                        _showPrivacyDialog();
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Support Section
                _buildSettingsSection(
                  title: 'Support',
                  icon: Icons.help,
                  children: [
                    _buildActionTile(
                      title: 'Help Center',
                      subtitle: 'Get help and support',
                      icon: Icons.help_center,
                      onTap: () {
                        _showHelpDialog();
                      },
                    ),
                    _buildActionTile(
                      title: 'Report an Issue',
                      subtitle: 'Report bugs or problems',
                      icon: Icons.bug_report,
                      onTap: () {
                        _showReportIssueDialog();
                      },
                    ),
                    _buildActionTile(
                      title: 'Rate App',
                      subtitle: 'Rate us on the app store',
                      icon: Icons.star,
                      onTap: () {
                        _showRatingDialog();
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // App Version
                Center(
                  child: Text(
                    'AgriGuard Plus v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightGreen,
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: AppTheme.primaryGreen,
              size: 35,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (userAddress != 'No Address') ...[
                  const SizedBox(height: 4),
                  Text(
                    userAddress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: AppConstants.iconMedium,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryGreen,
        size: AppConstants.iconMedium,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Text('Change Password'),
        content: const Text('Password change feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'AgriGuard Plus Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data. '
            'This privacy policy explains how we collect, use, and protect your information.\n\n'
            '1. Data Collection: We collect only necessary information for app functionality.\n'
            '2. Data Usage: Your data is used to provide personalized crop analysis.\n'
            '3. Data Protection: We implement security measures to protect your data.\n'
            '4. Data Sharing: We do not share your personal data with third parties.\n\n'
            'For questions about this policy, contact us at privacy@agriguardplus.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryGreen)),
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
        title: const Text('Help Center'),
        content: const Text('Help center with detailed guides will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Text('Report an Issue'),
        content: const Text('Issue reporting feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Text('Rate AgriGuard Plus'),
        content: const Text('Thank you for using AgriGuard Plus! App store rating will be available when the app is published.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}