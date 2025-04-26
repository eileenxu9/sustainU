import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _api = ApiService();
  late Future<List<dynamic>> _feedFuture;
  String _category = 'All';
  final _categories = ['All', 'Campus Event Leftovers', 'Extra Groceries', 'Restaurant Deals'];

  @override
  void initState() {
    super.initState();
    _feedFuture = _api.fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: _category,
              onChanged: (v) => setState(() => _category = v!),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _feedFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final items = snap.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(it['name'] ?? it['restaurant_name'] ?? ''),
                        subtitle: Text(it['description'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
