import 'package:flutter/material.dart';
import '../services/api_service.dart'; // <-- Don't forget this!

// 🎨 Colors and Fonts
const Color primaryPurple = Color(0xFF57068C);
const Color whiteColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF333333);

class PostDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final DateTime pickupDate;
  final String donorName;
  final String donorNetId;
  final String type;
  final int postId; // <-- NEW FIELD

  const PostDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.pickupDate,
    required this.donorName,
    required this.donorNetId,
    required this.type,
    required this.postId, // <-- NEW FIELD
  });

  @override
  Widget build(BuildContext context) {
    final _api = ApiService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        title: const Text(
          'Post Details',
          style: TextStyle(color: whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    icon: Icons.bookmark_border,
                    label: 'Description',
                    content: description,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.calendar_today,
                    label: 'Pickup Date',
                    content: '${pickupDate.month}/${pickupDate.day}/${pickupDate.year}',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.person,
                    label: 'Donor',
                    content: '$donorName ($donorNetId)',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.star_border,
                    label: 'Type',
                    content: type,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Request'),
                      content: const Text('Are you sure you want to claim this food item?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Claim'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final success = await _api.claimFoodItem(postId);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item successfully claimed!')),
                      );
                      Navigator.pop(context); // Back to feed
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to claim. It may have been taken already.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Request Food',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String label, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}

