import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'package:boostseller/utils/http.override.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const BoostSellerApp());
}

class BoostSellerApp extends StatelessWidget {
  const BoostSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoostSeller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
