class ApiService {
 
  Future<List<dynamic>> fetchFeed() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate loading
  return [
    {
      'name': 'Free Pizza!',
      'description': 'Leftover pizza from event',
      'pickup_time': '2025-04-30T18:00:00',
      'donor_name': 'Tian Wang',
      'donor_netid': 'tw2445',
      'type': 'Leftover Food',
    },
    {
      'name': 'Extra Groceries Available',
      'description': 'Vegetables and fruits',
      'pickup_time': '2025-05-01T12:00:00',
      'donor_name': 'Eileen Xu',
      'donor_netid': 'elx204',
      'type': 'Grocery',
    },

  ];
  }
}