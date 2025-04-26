import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // On iOS simulator, localhost works. On Android use 10.0.2.2
  final _baseUrl = 'http://127.0.0.1:8000/';
  final _storage = FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('${_baseUrl}auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // adjust key name if you’re using JWT (e.g. data['access'])
      await _storage.write(key: 'token', value: data['key']);
      return true;
    }
    return false;
  }

  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> logout() => _storage.delete(key: 'token');

  Map<String,String> _authHeaders(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<dynamic>> fetchFeed() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${_baseUrl}food-items/'), // for example
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load feed');
  }

  Future<List<dynamic>> fetchMealSwipes() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${_baseUrl}meal-swipes/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load meal swipes');
  }

  Future<bool> postMealSwipe(int count) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${_baseUrl}meal-swipes/'),
      headers: _authHeaders(token),
      body: jsonEncode({'available_swipes': count}),
    );
    return res.statusCode == 201;
  }

  Future<bool> claimMealSwipe(int id) async {
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('${_baseUrl}meal-swipes/$id/'),
      headers: _authHeaders(token),
      body: jsonEncode({'requested_by': 'current_user_id'}),
    );
    return res.statusCode == 200;
  }

  Future<int> fetchPoints() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${_baseUrl}incentives/'),
      headers: _authHeaders(token),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      // assuming one Incentive object per user
      return list.isNotEmpty ? list.first['points'] as int : 0;
    }
    throw Exception('Failed to load points');
  }

  Future<bool> redeemReward() async {
    final token = await getToken();
    // e.g. POST to some /redeem/ endpoint
    final res = await http.post(
      Uri.parse('${_baseUrl}incentives/1/'), // adjust as needed
      headers: _authHeaders(token),
      body: jsonEncode({'points': 0}),
    );
    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await _storage.read(key: 'token');
    final res = await http.get(
        Uri.parse('$_baseUrl' + 'auth/user/'),
        headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
        },
    );
    print('PROFILE → ${res.statusCode}: ${res.body}');
    if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
        throw Exception('Profile load failed: ${res.statusCode}');
    }
  }

  Future<bool> createMealSwipe(int count) async {
    final token = await _storage.read(key:'token');
    final res = await http.post(
      Uri.parse('$_baseUrl' + 'meal-swipes/'),
      headers: {
        'Content-Type': 'application/json',
        if (token!=null) 'Authorization':'Token $token'
      },
      body: jsonEncode({'available_swipes': count}),
    );
    return res.statusCode == 201;
  }

  Future<bool> createFoodItem({
    required String name,
    String? description,
    required String location,
  }) async {
    final token = await _storage.read(key:'token');
    final res = await http.post(
      Uri.parse('$_baseUrl' + 'food-items/'),
      headers: {
        'Content-Type': 'application/json',
        if (token!=null) 'Authorization':'Token $token'
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'location': location,
      }),
    );
    return res.statusCode == 201;
  }

  Future<bool> createRestaurantDeal({
    required String restaurantName,
    required String dealDescription,
    required String location,
  }) async {
    final token = await _storage.read(key:'token');
    final res = await http.post(
      Uri.parse('$_baseUrl' + 'restaurant-deals/'),
      headers: {
        'Content-Type': 'application/json',
        if (token!=null) 'Authorization':'Token $token'
      },
      body: jsonEncode({
        'restaurant_name': restaurantName,
        'deal_description': dealDescription,
        'location': location,
      }),
    );
    return res.statusCode == 201;
  }

  Future<bool> createIncentive(int points) async {
    final token = await _storage.read(key:'token');
    final user = await fetchProfile(); // get your user ID
    final res = await http.post(
      Uri.parse('$_baseUrl' + 'incentives/'),
      headers: {
        'Content-Type': 'application/json',
        if (token!=null) 'Authorization':'Token $token'
      },
      body: jsonEncode({
        'user': user['id'],
        'points': points,
      }),
    );
    return res.statusCode == 201;
  }
}
