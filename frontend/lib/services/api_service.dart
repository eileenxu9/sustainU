import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Base URL for the backend API
  final String _baseUrl = 'http://127.0.0.1:8000/';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Logs in the user and stores the authentication token.
  Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl' 'auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _storage.write(key: 'token', value: data['key'] as String);
      return true;
    }
    return false;
  }

  /// Retrieves the stored token.
  Future<String?> getToken() => _storage.read(key: 'token');

  /// Deletes the stored token (logout).
  Future<void> logout() => _storage.delete(key: 'token');

  /// Builds headers for authorized requests.
  Map<String, String> _authHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

  /// Fetches a generic feed (e.g. food items).
  Future<List<dynamic>> fetchFeed() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'food-items/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load feed: ${res.statusCode}');
  }

  /// Retrieves all meal-swipe records.
  Future<List<dynamic>> fetchMealSwipes() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'meal-swipes/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load meal swipes: ${res.statusCode}');
  }

  /// Creates (shares) a new meal-swipe record.
  Future<bool> postMealSwipe(int count) async {
    final token = await getToken();
    final profile = await fetchProfile();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'meal-swipes/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'user': profile['id'],
        'available_swipes': count,
      }),
    );
    return res.statusCode == 201;
  }

  /// Claims part of an existing meal-swipe.
  Future<bool> claimPartialMealSwipe(int id, int claimedCount) async {
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('$_baseUrl' 'meal-swipes/$id/'),
      headers: _authHeaders(token),
      body: jsonEncode({'claim_count': claimedCount}),
    );
    return res.statusCode == 200;
  }

  /// Fetches the current user's profile data.
  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'auth/user/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Profile load failed: ${res.statusCode}');
  }

  /// Fetches another user's details by primary key.
  Future<Map<String, dynamic>> fetchUserDetails(int pk) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'users/$pk/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('User details failed: ${res.statusCode}');
  }

  /// Retrieves current incentive points.
  Future<int> fetchPoints() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'incentives/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.isNotEmpty ? list.first['points'] as int : 0;
    }
    throw Exception('Failed to load points: ${res.statusCode}');
  }

  /// Redeems rewards (resets points).
  Future<bool> redeemReward() async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'incentives/1/'),
      headers: _authHeaders(token),
      body: jsonEncode({'points': 0}),
    );
    return res.statusCode == 200;
  }

  /// Creates a new meal-swipe record (alias to postMealSwipe).
  Future<bool> createMealSwipe(int count) => postMealSwipe(count);

  /// Creates a new food item entry.
  Future<bool> createFoodItem({
    required String name,
    String? description,
    required String location,
  }) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'food-items/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'name': name,
        'description': description,
        'location': location,
      }),
    );
    return res.statusCode == 201;
  }

  /// Creates a new restaurant deal entry.
  Future<bool> createRestaurantDeal({
    required String restaurantName,
    required String dealDescription,
    required String location,
  }) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'restaurant-deals/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'restaurant_name': restaurantName,
        'deal_description': dealDescription,
        'location': location,
      }),
    );
    return res.statusCode == 201;
  }

  /// Adds incentive points for the user.
  Future<bool> createIncentive(int points) async {
    final token = await getToken();
    final user = await fetchProfile();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'incentives/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'user': user['id'],
        'points': points,
      }),
    );
    return res.statusCode == 201;
  }
}
