import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'feed_page.dart';

class PostFoodSharingPage extends StatefulWidget {
  const PostFoodSharingPage({super.key});

  @override
  _PostFoodSharingPageState createState() => _PostFoodSharingPageState();
}

class _PostFoodSharingPageState extends State<PostFoodSharingPage> {
  final _api = ApiService();

  // ─── form state ────────────────────────────────────────────────────
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedPickupTime;
  File?     _pickedImage;
  bool      _submitting       = false;

  // ─── role & type choices ───────────────────────────────────────────
  String?     _role;
  late List<String> _typeOptions;
  String?     _selectedType;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final profile = await _api.fetchProfile();
    setState(() {
      _role = profile['role'] as String?;
      _typeOptions = (_role == 'admin')
        ? ['Leftovers', 'Restaurant Deal']
        : ['Leftovers'];
    });
  }

  bool get _isFormValid {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedType == null) return false;

    // if leftovers, require date + image
    if (_selectedType == 'Leftovers') {
      return _selectedPickupTime != null && _pickedImage != null;
    }
    // if deal, no extra fields
    return true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  Future<void> _pickDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedPickupTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    setState(() => _submitting = true);

    bool success;
    if (_selectedType == 'Restaurant Deal') {
      // Admin-only path
      success = await _api.createRestaurantDeal(
        restaurantName: _titleController.text.trim(),
        dealDescription: _descriptionController.text.trim(),
        location: 'NYU Campus', // or allow admin to enter location
      );
    } else {
      // Leftovers path
      final dateStr = _selectedPickupTime!;
      success = await _api.createFoodItem(
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: '${dateStr.month}/${dateStr.day}/${dateStr.year}',
      );
    }

    setState(() => _submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FeedPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // still loading role?
    if (_role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Post Food Sharing'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('images/NYUTorch.png', width: 30, height: 30),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Type selector (student: only Leftovers; admin: both)
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _typeOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
            ),
            const SizedBox(height: 16),

            // Only for Leftovers: date & photo
            if (_selectedType == 'Leftovers') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedPickupTime == null
                            ? 'Pick Date'
                            : '${_selectedPickupTime!.month}/${_selectedPickupTime!.day}/${_selectedPickupTime!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Upload Photo'),
                    ),
                  ),
                ],
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 16),
                Image.file(_pickedImage!, height: 150),
              ],
            ],

            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedType == 'Restaurant Deal'
                            ? 'Post Deal'
                            : 'Start Sharing',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
