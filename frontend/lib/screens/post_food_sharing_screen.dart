import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 🎨 Custom SustainU Theme Colors
const Color primaryPurple = Color(0xFF57068C);
const Color whiteColor = Color(0xFFFFFFFF);
const Color fontColor1 = Color(0xFF333333);
const Color fontColor2 = Color(0xFF000000);
const Color fontColor3 = Color(0xFF999999);
const Color dropdownFillColor = Color(0xFFD9D9D9);
const Color boxBorderColor = Color(0xFFCCCCCC);

class PostFoodSharingScreen extends StatefulWidget {
  const PostFoodSharingScreen({super.key});

  @override
  State<PostFoodSharingScreen> createState() => _PostFoodSharingScreenState();
}

class _PostFoodSharingScreenState extends State<PostFoodSharingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedType;
  DateTime? _selectedPickupTime;
  File? _pickedImage;

  bool _validateForm() {
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a food title')),
    );
    return false;
  }
  if (_selectedType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a type')),
    );
    return false;
  }
  if (_selectedPickupTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a pickup time')),
    );
    return false;
  }
  if (_pickedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please upload a photo')),
    );
    return false;
  }
  return true;
}


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedPickupTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        title: const Text(
          'Post Food Sharing',
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
              'images/NYU_Torch.png',  // <- make sure this path is correct!
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'Have surplus food? Share it with those in need!',
              style: TextStyle(fontSize: 16, color: fontColor1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'images/good_food.jpg',  // placeholder food image
              height: 180,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),

            // Food Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Food Title',
                labelStyle: TextStyle(color: fontColor1),
                filled: true,
                fillColor: whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: boxBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: fontColor1),
                filled: true,
                fillColor: whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: boxBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown for Food Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: dropdownFillColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: boxBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: primaryPurple),
                ),
              ),
              hint: Text('Select Type', style: TextStyle(color: fontColor2)),
              items: ['Grocery', 'Leftover'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: TextStyle(color: fontColor2)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Pickup Time and Upload Photo Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, color: fontColor3),
                    label: Text(
                      _selectedPickupTime == null
                          ? 'Select Time...'
                          : '${_selectedPickupTime!.month}/${_selectedPickupTime!.day}/${_selectedPickupTime!.year}',
                      style: TextStyle(color: fontColor3),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      side: const BorderSide(color: boxBorderColor),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, color: fontColor3),
                    label: Text(
                      'Upload Photo',
                      style: TextStyle(color: fontColor3),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      side: const BorderSide(color: boxBorderColor),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preview Picked Image
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.file(
                  _pickedImage!,
                  height: 150,
                ),
              ),

            const SizedBox(height: 20),

            // Start Sharing Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Post to backend later
                   if (_validateForm()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Posting your food...')),
                    );
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Start Sharing',
                  style: TextStyle(fontSize: 18, color: whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
