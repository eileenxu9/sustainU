import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final _api = ApiService();
  late Future<int> _pointsFuture;

  // Available rewards
  final List<Map<String, dynamic>> _rewards = [
    {'points': 3, 'label': '\$10 Dining Dollars'},
    {'points': 5, 'label': 'NYU Eats Merch'},
    {'points': 100, 'label': 'Omakase Dinner with Juan de Pablo'},
  ];

  @override
  void initState() {
    super.initState();
    _refreshPoints();
  }

  void _refreshPoints() {
    setState(() {
      _pointsFuture = _api.fetchPoints();
    });
  }

  Future<void> _redeem(String reward, int cost) async {
    final pts = await _pointsFuture;
    if (pts < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough points to redeem.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPoints = pts - cost;
    final success = await _api.updatePoints(newPoints); // 🔥 Use the new updatePoints()

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully redeemed: $reward! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshPoints();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redemption failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _pointsFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final pts = snap.data ?? 0;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text('Rewards'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.star, size: 80, color: Color(0xFFab47bd)),
                  const SizedBox(height: 20),
                  Text(
                    'You have $pts points!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF681b98),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Redeem Your Points',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: _rewards.map((r) {
                      final cost = r['points'] as int;
                      final label = r['label'] as String;
                      final enabled = pts >= cost;
                      return RewardButton(
                        pointsRequired: cost,
                        reward: label,
                        enabled: enabled,
                        onPressed: () => _redeem(label, cost),
                      );
                    }).toList(),
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

class RewardButton extends StatelessWidget {
  final int pointsRequired;
  final String reward;
  final VoidCallback onPressed;
  final bool enabled;

  const RewardButton({
    super.key,
    required this.pointsRequired,
    required this.reward,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.star, color: Colors.white),
      label: Text(
        '$pointsRequired pts → $reward',
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        backgroundColor:
            enabled ? const Color(0xFF8c24a8) : Colors.grey.shade400,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
