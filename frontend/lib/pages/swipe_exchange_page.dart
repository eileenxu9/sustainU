// lib/pages/swipe_exchange_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SwipeExchangePage extends StatefulWidget {
  const SwipeExchangePage({super.key});

  @override
  State<SwipeExchangePage> createState() => _SwipeExchangePageState();
}

class _SwipeExchangePageState extends State<SwipeExchangePage> {
  final ApiService _api = ApiService();
  int _availableSwipes    = 0;  // user’s current balance
  int _donateCount        = 1;  // how many the user wants to give
  int _donationSwipes     = 0;  // how many swipes remain in the first donation record
  bool _loading           = false;
  bool _initialLoading    = true;

  @override
  void initState() {
    super.initState();
    _loadSwipes();
  }

  Future<void> _loadSwipes() async {
    setState(() => _initialLoading = true);
    try {
      // 1) get your current swipe count
      _availableSwipes = await _api.fetchMySwipes();

      // 2) look for the first unclaimed donation
      final history = await _api.fetchMealSwipeHistory();
      if (history.isNotEmpty) {
        final record = history.firstWhere(
          (s) => s['requested_by'] == null && (s['available_swipes'] as int) > 0,
          orElse: () => history.first,
        ) as Map<String, dynamic>;

        _donationSwipes   = record['available_swipes'] as int;
      } else {
        _donationSwipes  = 0;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading swipes: $e')),
      );
    } finally {
      setState(() => _initialLoading = false);
    }
  }

  void _increment() {
    setState(() => _donateCount++);
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

    final ok1 = await _api.spendSwipes(_donateCount);
    final ok2 = await _api.postMealSwipe(_donateCount);

    setState(() => _loading = false);

    if (ok1 && ok2) {
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

  Future<void> _claimSwipes() async {
    if (_donationSwipes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No swipes available to claim."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // claim up to 2, but never more than what's in the donation record
    final toClaim = min(2, _donationSwipes);
    final ok      = await _api.claimMealSwipe(toClaim);

    setState(() => _loading = false);

    if (ok) {
      await _loadSwipes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swipes claimed successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to claim swipes.'),
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
                  // 1) show user’s current balance
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

                  // 2) donation controls
                  const Text(
                    'Select Number of Swipes',
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

                  const SizedBox(height: 20),

                  // 3) claim button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _claimSwipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Claim Swipes', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}