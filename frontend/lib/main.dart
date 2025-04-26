import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/login_page.dart';

void main() => runApp(const SustainUApp());

class SustainUApp extends StatelessWidget {
  const SustainUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SustainU',
      theme: buildAppTheme(),
      home: const LoginPage(),
    );
  }
}
