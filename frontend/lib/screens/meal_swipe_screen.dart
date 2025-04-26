import 'package:flutter/material.dart';

class MealSwipeScreen extends StatefulWidget {
  const MealSwipeScreen({super.key});

  @override
  State<MealSwipeScreen> createState() => _MealSwipeScreenState();
}

class _MealSwipeScreenState extends State<MealSwipeScreen> {
  int _availableSwipes = 14; // Should fetch from backend eventually
  int _donateCount = 2; // Default donation count

  void _increment() {
    setState(() {
      _donateCount++;
    });
  }

  void _decrement() {
    if (_donateCount > 1) {
      setState(() {
        _donateCount--;
      });
    }
  }

  void _shareSwipes() {
    if (_donateCount > _availableSwipes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You Don't Have Enough Swipes"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _availableSwipes -= _donateCount;
        _donateCount = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Swipe Shared Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Meal Swipe Sharing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Image.asset('images/NYUTorch.png', width: 30, height: 30,),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Card
            Card(
              color: Colors.purple.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.purple),
                ),
                title: const Text('Tian Wang'),
                subtitle: Text('$_availableSwipes swipes remaining\nLast synced 2 min ago'),
              ),
            ),
            const SizedBox(height: 30),

            // Donate Swipe Section
            const Text(
              "Donate Your Meal Swipes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus Button
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
                Text(
                  '$_donateCount',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 20),
                // Plus Button
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
              "You'll have ${_availableSwipes - _donateCount} swipes left after this donation.",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _shareSwipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Share Swipes', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.purple)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
