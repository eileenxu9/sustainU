import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SwipeExchangePage extends StatefulWidget {
  const SwipeExchangePage({super.key});

  @override
  State<SwipeExchangePage> createState() => _SwipeExchangePageState();
}

class _SwipeExchangePageState extends State<SwipeExchangePage> {
  final _api = ApiService();
  late int _availableSwipes;
  int _donateCount = 1;
  bool _loading = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSwipes();
  }

  Future<void> _loadSwipes() async {
    setState(() => _initialLoading = true);
    try {
      final swipes = await _api.fetchMealSwipes();
      final me = swipes.firstWhere(
        (s) => s['requested_by'] == null,
        orElse: () => swipes.first,
      );
      setState(() {
        _availableSwipes = me['available_swipes'] as int;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading swipes: \$e')),
      );
    } finally {
      setState(() => _initialLoading = false);
    }
  }

  void _increment() {
    if (_donateCount < _availableSwipes) {
      setState(() => _donateCount++);
    }
  }

  void _decrement() {
    if (_donateCount > 1) {
      setState(() => _donateCount--);
    }
  }

  Future<void> _shareSwipes() async {
    if (_donateCount > _availableSwipes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You don't have enough swipes."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final success = await _api.postMealSwipe(_donateCount);
    setState(() => _loading = false);

    if (success) {
      await _loadSwipes();
      setState(() => _donateCount = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swipe shared successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share swipe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Meal Swipe Exchange'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
          ),
        ],
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.purple),
                      ),
                      title: Text('$_availableSwipes swipes remaining'),
                      subtitle: const Text('Last synced: just now'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Donate Your Meal Swipes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _decrement,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey.shade300,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      Text('$_donateCount', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _increment,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey.shade300,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You'll have \$${_availableSwipes - _donateCount} swipes left.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _shareSwipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Share Swipes', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
