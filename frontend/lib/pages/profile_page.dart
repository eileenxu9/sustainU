import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = ApiService();
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _api.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final user = snap.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile'), centerTitle: true),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 60, backgroundImage: AssetImage('images/profile.png')),
                const SizedBox(height: 30),
                Text(user['username'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Email: ${user['email']}'),
                Text('Role: ${user['role']}'),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFd1c3e9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('Meal Swipes: ${user['available_swipes'] ?? 0}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('Points: ${user['points'] ?? 0}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
