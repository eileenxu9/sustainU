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
    'Leftover Food',
    'Restaurant Deals',
  ];

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  void _refreshFeed() {
    setState(() {
      _feedFuture = _api.fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Feed'),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFoodSharingPage()),
          ).then((_) => _refreshFeed());
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  borderRadius: BorderRadius.circular(24),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (v) => setState(() {
                    _category = v!;
                    _refreshFeed();
                  }),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                final allItems = snap.data! as List<dynamic>;
                final items = allItems
                    .where((it) => it['claimed_by'] == null)
                    .cast<Map<String, dynamic>>()
                    .toList()
                  ..retainWhere((it) {
                    final name = (it['name'] ?? it['restaurant_name'] ?? '')
                        .toString()
                        .toLowerCase();
                    final isDeal = it.containsKey('restaurant_name');
                    switch (_category) {
                      case 'Leftover Food':
                        return !isDeal;
                      case 'Restaurant Deals':
                        return isDeal;
                      default:
                        return true;
                    }
                  });

                if (items.isEmpty) {
                  return const Center(child: Text('No posts in this category.'));
                }

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                            it['name'] ?? it['restaurant_name'] ?? ''),
                        subtitle: Text(it['description'] ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailsPage(
                                title: it['name'] ?? it['restaurant_name'] ?? '',
                                description: it['description'] ?? '',
                                pickupDate: pickupDate,
                                donorName: "User ${it['posted_by']}",
                                donorNetId: '',
                                type: it.containsKey('restaurant_name')
                                    ? 'Restaurant Deal'
                                    : 'Food Item',
                                postId: it['id'] as int,
                              ),
                            ),
                          ).then((_) => _refreshFeed());
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
