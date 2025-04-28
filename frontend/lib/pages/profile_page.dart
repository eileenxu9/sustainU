import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _fullFuture;

  @override
  void initState() {
    super.initState();
    _fullFuture = _loadFullProfile();
  }

  Future<Map<String, dynamic>> _loadFullProfile() async {
    final basic = await _api.fetchProfile();
    final full  = await _api.fetchUserDetails(basic['id'] as int);
    return {
      'username': full['username'],
      'email': full['email'],
      'role': full['role'],
      'swipes': full['available_swipes'],
      'points': full['points'],
    };
  }

  void _logout() async {
    await _api.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fullFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Theme.of(context).primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        final user = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(radius: 60, backgroundImage: AssetImage('images/profile.png')),
                const SizedBox(height: 20),
                Text(user['username'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Email: ${user['email']}'),
                Text('Role: ${user['role']}'),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.swipe),
                  title: Text('Swipes: ${user['swipes']}'),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text('Points: ${user['points']}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
