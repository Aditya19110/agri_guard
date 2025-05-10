import 'package:flutter/material.dart';
import 'package:agri_gurad/screens/login_screen.dart';
import 'package:agri_gurad/screens/registration.dart';
import 'package:agri_gurad/screens/home_page.dart';
import 'package:agri_gurad/screens/splash.dart';
import 'package:agri_gurad/screens/settings.dart';
import 'package:agri_gurad/screens/prediction.dart';
import 'package:agri_gurad/screens/history_screen.dart';
import 'package:agri_gurad/screens/nearby_store.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => SplashScreen(),
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/dashboard': (context) => DashboardScreen(),
  '/settings': (context) => SettingsPage(),
  '/history':(context) => HistoryScreen(),
  '/stores':(context)=> NearbyStoresScreen(),
  '/prediction':(context) => PredictionPage(),
};