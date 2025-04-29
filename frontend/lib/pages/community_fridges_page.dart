import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityFridgesPage extends StatefulWidget {
  const CommunityFridgesPage({Key? key}) : super(key: key);

  @override
  _CommunityFridgesPageState createState() => _CommunityFridgesPageState();
}

class _CommunityFridgesPageState extends State<CommunityFridgesPage> {
  // Center the map on NYU
  static const LatLng _nyuCenter = LatLng(40.7291, -73.9965);

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  // Initialize Google Places with your API key
  final _places = GoogleMapsPlaces(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
  );

  @override
  void initState() {
    super.initState();
    _searchNearbyFridges();
  }

  Future<void> _searchNearbyFridges() async {
    final response = await _places.searchNearbyWithRadius(
      Location(lat: _nyuCenter.latitude, lng: _nyuCenter.longitude),
      2000,
      keyword: 'food bank',
      type: 'establishment',
    );

    // **VERY IMPORTANT**: bail out if the widget is no longer in the tree
    if (!mounted) return;

    if (response.status == "OK") {
      final results = response.results;
      setState(() {
        _markers.clear();
        for (var place in results) {
          final markerId = MarkerId(place.placeId);
          final pos = LatLng(
            place.geometry!.location.lat,
            place.geometry!.location.lng,
          );
          _markers.add(
            Marker(
              markerId: markerId,
              position: pos,
              infoWindow: InfoWindow(
                title: place.name,
                snippet: place.vicinity,
              ),
            ),
          );
        }
      });
    } else {
      // safe to log without calling setState
      debugPrint('Places API error: ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Fridges'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _nyuCenter,
          zoom: 15,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
