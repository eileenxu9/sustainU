import 'package:flutter/material.dart';
import '../services/fake_api_services.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _api = ApiService();
  late Future<List<dynamic>> _feedFuture;
  String _category = 'All';
  final _categories = [
    'All',
    'Campus Event Leftovers',
    'Extra Groceries',
    'Restaurant Deals',
  ];

  @override
  void initState() {
    super.initState();
    _feedFuture = _api.fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Feed'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'images/NYUTorch.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: _category,
              onChanged: (v) => setState(() => _category = v!),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _feedFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Error: ${snap.error}'),
                  );
                }
                List<dynamic> items = snap.data!;
                // ✨ FILTER items based on selected _category
                if (_category != 'All') {
                  items = items.where((it) {
                    final type = it['type'] ?? '';
                    if (_category == 'Campus Event Leftovers') {
                      return type == 'Leftover Food';   // must match exactly!
                    } else if (_category == 'Extra Groceries') {
                      return type == 'Grocery';
                    } else if (_category == 'Restaurant Deals') {
                      return type == 'Restaurant Deal';
                    }
                    return true;
                  }).toList();
                }
                if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No posts available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          it['name'] ?? it['restaurant_name'] ?? '',
                        ),
                        subtitle: Text(
                          it['description'] ?? '',
                        ),
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