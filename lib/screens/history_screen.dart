import 'package:flutter/material.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Your analysis history will be shown here.'),
      ),
    );
  }
}
