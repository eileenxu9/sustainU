import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({Key? key}) : super(key: key);

  void _showRedeemDialog(BuildContext context, String reward) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully redeemed: $reward! 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
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
              const Text(
                'You have 10 points!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF681b98),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Redeem Your Points',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  RewardButton(
                    pointsRequired: 3,
                    reward: '\$10 Dining Dollars',
                    onPressed: () => _showRedeemDialog(context, '\$10 Dining Dollars'),
                  ),
                  RewardButton(
                    pointsRequired: 5,
                    reward: 'NYU Eats Merch',
                    onPressed: () => _showRedeemDialog(context, 'NYU Eats Merch'),
                  ),
                  RewardButton(
                    pointsRequired: 100,
                    reward: 'Omakase Dinner with Juan de Pablo',
                    onPressed: () => _showRedeemDialog(context, 'Omakase Dinner with Juan de Pablo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardButton extends StatelessWidget {
  final int pointsRequired;
  final String reward;
  final VoidCallback onPressed;

  const RewardButton({
    Key? key,
    required this.pointsRequired,
    required this.reward,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.star, color: Colors.white),
      label: Text('$pointsRequired pts → $reward', style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        backgroundColor: const Color(0xFF8c24a8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}