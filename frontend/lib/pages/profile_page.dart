import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

/// Combined payload for ProfilePage
class _ProfileData {
  final Map<String, dynamic> basic;    // /auth/user/ payload
  final Map<String, dynamic> full;     // /users/{id}/ payload
  final int totalSwipes;
  final int points;
  _ProfileData({
    required this.basic,
    required this.full,
    required this.totalSwipes,
    required this.points,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = ApiService();
  late Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  Future<_ProfileData> _loadProfileData() async {
    // 1) basic info (pk, username, email)
    final basic = await _api.fetchProfile();
    final int pk = (basic['id'] ?? basic['pk']) as int;

    // 2) full user record (includes your `role` field)
    final full = await _api.fetchUserDetails(pk);

    // 3) meal-swipes: filter only this user's, then sum
    final swipes = await _api.fetchMealSwipes();
    final totalSwipes = swipes.fold<int>(
      0,
      (sum, s) {
        // s['user'] is the FK PK of the user on that swipe row
        return (s['user'] as int) == pk
            ? sum + (s['available_swipes'] as int)
            : sum;
      },
    );

    // 4) incentive points
    final points = await _api.fetchPoints();

    return _ProfileData(
      basic: basic,
      full: full,
      totalSwipes: totalSwipes,
      points: points,
    );
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
    return FutureBuilder<_ProfileData>(
      future: _profileFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('Profile'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
                ),
                IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
              ],
            ),
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        final data = snap.data!;
        final userFull = data.full;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('images/profile.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userFull['username'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Email: ${userFull['email']}"),
                  Text("Role: ${userFull['role']}"),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.swipe),
                      title: Text('Swipes: ${data.totalSwipes}'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Text('Points: ${data.points}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
