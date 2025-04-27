import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'post_details_page.dart';  
import 'post_food_sharing_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _api = ApiService();
  late Future<List<dynamic>> _feedFuture;
  String _category = 'All';
  final _categories = <String>[
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostFoodSharingPage()),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: _category,
              onChanged: (v) {
                setState(() {
                  _category = v!;
                  _feedFuture = _api.fetchFeed(category: _category);
                });
              },
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
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
                    DateTime pickupDate;
                    try {
                      pickupDate = DateTime.parse(it['timestamp'] as String);
                    } catch (_) {
                      pickupDate = DateTime.now();
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(it['name'] ?? it['restaurant_name'] ?? ''),
                        subtitle: Text(it['description'] ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailsPage(
                                title: it['name'] ?? it['restaurant_name'] ?? '',
                                description: it['description'] ?? '',
                                pickupDate: pickupDate,
                                donorName: 'User ${it['posted_by']}', 
                                donorNetId: '',
                                type: it['location'] ?? '',
                                postId: it['id'], // <-- Pass the postId here!
                              ),
                            ),
                          );
                        },
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
