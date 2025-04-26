import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CommunityFridgesPage extends StatelessWidget {
  const CommunityFridgesPage({Key? key}) : super(key: key);

  // Center the map on NYU
  static const LatLng _nyuCenter = LatLng(40.7291, -73.9965);

  // Three sample “community fridge” markers near campus
  static final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('fridge1'),
      position: LatLng(40.7308, -73.9973),
      infoWindow: InfoWindow(
        title: 'Community Fridge A',
        snippet: 'W Washington Square',
      ),
    ),
    Marker(
      markerId: MarkerId('fridge2'),
      position: LatLng(40.7275, -73.9940),
      infoWindow: InfoWindow(
        title: 'Community Fridge B',
        snippet: '3rd Ave & E 8th St',
      ),
    ),
    Marker(
      markerId: MarkerId('fridge3'),
      position: LatLng(40.7320, -73.9992),
      infoWindow: InfoWindow(
        title: 'Community Fridge C',
        snippet: 'MacDougal St & Washington Sq N',
      ),
    ),
  };

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
        markers: _markers,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
