import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

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

  void _logout() async {
    await _api.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // loading spinner
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // error state
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('Profile'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Image.asset(
                    'images/NYUTorch.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            body: Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            ),
          );
        }

        // success state
        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'images/NYUTorch.png',
                  width: 30,
                  height: 30,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
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
                      user['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Email: ${user['email'] ?? ''}"),
                    Text("Role: ${user['role'] ?? ''}"),
                    const SizedBox(height: 20),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.swipe),
                        title: Text(
                          "Swipes: ${user['available_swipes'] ?? 0}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(
                          "Points: ${user['points'] ?? 0}",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
