import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userName = 'Agri Guard User';
  String userEmail = 'No Email';

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
          if (data.containsKey('name')) {
            setState(() {
              userName = data['name'];
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Guard Plus Dashboard'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _openDrawer(context),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('This is the settings page.'),
      ),
    );
  }
}