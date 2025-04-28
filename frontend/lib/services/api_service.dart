import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ─── Configuration ────────────────────────────────────────────────

  /// Base URL for your Django backend
  final String _baseUrl = 'http://127.0.0.1:8000/';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, String> _authHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

  // ─── Authentication ───────────────────────────────────────────────

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

  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> logout() => _storage.delete(key: 'token');

  // ─── User “Current State” ─────────────────────────────────────────

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'auth/user/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Profile load failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> fetchUserDetails(int pk) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'users/$pk/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('User details failed: ${res.statusCode}');
  }

  Future<int> fetchMySwipes() async {
    final id = (await fetchProfile())['id'] as int;
    final me = await fetchUserDetails(id);
    return me['available_swipes'] as int? ?? 0;
  }

  Future<int> fetchMyPoints() async {
    final id = (await fetchProfile())['id'] as int;
    final me = await fetchUserDetails(id);
    return me['points'] as int? ?? 0;
  }

  Future<bool> _patchUser(Map<String, dynamic> patch) async {
    final profile = await fetchProfile();
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('$_baseUrl' 'users/${profile['id']}/'),
      headers: _authHeaders(token),
      body: jsonEncode(patch),
    );
    return res.statusCode == 200;
  }

  Future<bool> spendSwipes(int count) async {
    final current = await fetchMySwipes();
    return _patchUser({'available_swipes': current - count});
  }

  Future<bool> receiveSwipes(int count) async {
    final current = await fetchMySwipes();
    return _patchUser({'available_swipes': current + count});
  }

  Future<bool> addPoints(int pts) async {
    final current = await fetchMyPoints();
    return _patchUser({'points': current + pts});
  }

  Future<bool> resetPoints() => _patchUser({'points': 0});

  // ─── History Endpoints ─────────────────────────────────────────────

  Future<List<dynamic>> fetchMealSwipeHistory() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'meal-swipes/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load swipe history: ${res.statusCode}');
  }

  Future<bool> postMealSwipeHistory(int count) async {
    final me = await fetchProfile();
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'meal-swipes/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'user': me['id'],
        'available_swipes': count,
      }),
    );
    return res.statusCode == 201;
  }


  /// POST /meal-swipes/claim/ with JSON { "count": <n> }
  Future<bool> claimMealSwipe(int count) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'meal-swipes/claim/'),
      headers: _authHeaders(token),
      body: jsonEncode({'count': count}),
    );
    return res.statusCode == 200;
  }

  // ─── Other Resources ───────────────────────────────────────────────

  Future<List<dynamic>> fetchFeed() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'food-items/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load feed: ${res.statusCode}');
  }

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

  Future<List<dynamic>> fetchRestaurantDeals() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl' 'restaurant-deals/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load deals: ${res.statusCode}');
  }

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

  Future<bool> claimFoodItem(int id) async {
  final token = await getToken();
  final res = await http.patch(
    Uri.parse('$_baseUrl' 'food-items/$id/claim/'),
    headers: _authHeaders(token),
  );
  return res.statusCode == 200;
  }
  /// Shares count swipes and rewards 5 pts per swipe.
  Future<bool> postMealSwipe(int count) async {
    final token   = await getToken();
    final profile = await fetchProfile();
    final res = await http.post(
      Uri.parse('$_baseUrl' 'meal-swipes/'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'user': profile['id'],
        'available_swipes': count,
      }),
    );
    if (res.statusCode == 201) {
      // give points: 5 per swipe
      await _patchUser({'points': (profile['points'] as int) + count * 5});
      return true;
    }
    return false;
  }

  /// Deducts exactly pts from the current user.
  Future<bool> deductPoints(int pts) async {
    final profile = await fetchProfile();
    final newPts  = (profile['points'] as int) - pts;
    return _patchUser({'points': newPts < 0 ? 0 : newPts});
  }
}
