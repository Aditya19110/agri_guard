import 'package:flutter/material.dart';
import 'package:agri_gurad/screens/login_screen.dart';
import 'package:agri_gurad/screens/registration.dart';

import 'package:agri_gurad/screens/splash.dart';
import 'package:agri_gurad/screens/settings.dart';
import 'package:agri_gurad/screens/prediction.dart';
import 'package:agri_gurad/screens/history_screen.dart';
import 'package:agri_gurad/screens/nearby_store.dart';
import 'package:agri_gurad/screens/main_layout.dart';

final Map<String, WidgetBuilder> _routes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/dashboard': (context) => const MainLayout(),
  '/settings': (context) => const SettingsPage(),
  '/history': (context) => const HistoryScreen(),
  '/stores': (context) => const NearbyStoresScreen(),
  '/prediction': (context) => const PredictionPage(),
};

Route<dynamic>? generateRoute(RouteSettings settings) {
  final builder = _routes[settings.name];
  if (builder != null) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
  return null;
}
