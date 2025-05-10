import 'package:flutter/material.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NearbyStoresScreen extends StatefulWidget {
  @override
  _NearbyStoresScreenState createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _addMarker(position.latitude, position.longitude);  // Add marker for the current location
    });
  }

  // Function to add markers (simulating nearby stores for now)
  void _addMarker(double lat, double lng) {
    _markers.add(Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: 'Your Location'),
    ));
    // Example of adding nearby stores (replace with real data from an API)
    _markers.add(Marker(
      markerId: MarkerId('store_1'),
      position: LatLng(lat + 0.002, lng + 0.002),
      infoWindow: InfoWindow(title: 'Store 1'),
    ));
    _markers.add(Marker(
      markerId: MarkerId('store_2'),
      position: LatLng(lat - 0.003, lng - 0.003),
      infoWindow: InfoWindow(title: 'Store 2'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stores'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Google Map displaying user's location and nearby stores
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),
              ],
            ),
    );
  }
}
