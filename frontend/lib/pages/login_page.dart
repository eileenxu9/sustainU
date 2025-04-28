import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _api = ApiService();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final success = await _api.login(_userCtrl.text, _passCtrl.text);
    setState(() { _loading = false; });
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SustainU',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            // full-width header image
            Container(
              width: double.infinity,
              child: Image.asset(
                'images/wsp.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _userCtrl, decoration: const InputDecoration(hintText: 'Username')),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {/* TODO: forgot pw */},
              child: const Text('Forgot password?', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {/* TODO: signup */},
              child: const Text(
                'New user? Sign Up',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF681b98)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
