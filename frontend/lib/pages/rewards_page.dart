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

  @override
  void initState() {
    super.initState();
    _pointsFuture = _api.fetchPoints();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _pointsFuture,
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final pts = snap.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Rewards')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You have $pts points!', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (await _api.redeemReward()) {
                      setState(() => _pointsFuture = _api.fetchPoints());
                    }
                  },
                  child: const Text('Redeem Dining Dollars'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
