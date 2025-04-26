import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    runApp(const SustainUApp());
  } catch (e, st) {
    print("❌ startup failed: $e\n$st");
  }
}

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
