import 'package:elshodaa_mall/screens/home/main_home.dart';
import 'package:elshodaa_mall/screens/signup.dart';
import 'package:elshodaa_mall/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.id:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      // case LoginPage.id:
      //   return MaterialPageRoute(builder: (context) => const LoginPage());
      case SignUpScreen.id:
        return MaterialPageRoute(builder: (context) => const SignUpScreen());

      case UserDashboard.id:
        return MaterialPageRoute(builder: (context) => UserDashboard());

      default:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
