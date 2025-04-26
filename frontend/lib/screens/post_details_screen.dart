import 'package:flutter/material.dart';

// 🎨 Colors and Fonts
const Color primaryPurple = Color(0xFF57068C);
const Color whiteColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF333333);

class PostDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final DateTime pickupDate;
  final String donorName;
  final String donorNetId;
  final String type;

  const PostDetailsScreen({
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'images/NYU_Torch.png',
              width: 30,
              height: 30,
            ),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light gray background
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  const Row(
                    children: [
                      Icon(Icons.bookmark_border),
                      SizedBox(width: 8),
                      Text(
                        'Description',
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
                  ),

                  const SizedBox(height: 20),

                  // Pickup Date
                  const Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 8),
                      Text(
                        'Pickup Date',
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${pickupDate.month}/${pickupDate.day}/${pickupDate.year}",
                    style: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
                  ),

                  const SizedBox(height: 20),

                  // Donor
                  const Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text(
                        'Donor',
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$donorName ($donorNetId)',
                    style: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
                  ),

                  const SizedBox(height: 20),

                  // Type
                  const Row(
                    children: [
                      Icon(Icons.star_border),
                      SizedBox(width: 8),
                      Text(
                        'Type',
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    type,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
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
                  // TODO: Implement requesting food action
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
}
