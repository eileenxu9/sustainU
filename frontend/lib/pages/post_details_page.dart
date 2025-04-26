import 'package:flutter/material.dart';

// 🎨 Colors and Fonts
const Color primaryPurple = Color(0xFF57068C);
const Color whiteColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF333333);

/// A page that shows detailed information about a food post.
class PostDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final DateTime pickupDate;
  final String donorName;
  final String donorNetId;
  final String type;

  const PostDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.pickupDate,
    required this.donorName,
    required this.donorNetId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
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

            // Title (Food name)
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

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light gray background
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

            // Request Food Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add your request logic here
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
