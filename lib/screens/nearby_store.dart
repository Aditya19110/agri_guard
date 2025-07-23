import 'package:flutter/material.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agri_gurad/config/app_theme.dart';

class NearbyStoresScreen extends StatefulWidget {
  const NearbyStoresScreen({super.key});

  @override
  State<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Sample stores data
  final List<Map<String, dynamic>> _sampleStores = [
    {
      'name': 'AgriMart Supplies',
      'address': '123 Farm Road, Agricultural District',
      'phone': '+1 234-567-8900',
      'rating': 4.5,
      'type': 'Seeds & Fertilizers',
      'isOpen': true,
    },
    {
      'name': 'Green Valley Equipment',
      'address': '456 Harvest Lane, Farm Valley',
      'phone': '+1 234-567-8901',
      'rating': 4.2,
      'type': 'Tools & Machinery',
      'isOpen': true,
    },
    {
      'name': 'Organic Crop Solutions',
      'address': '789 Organic Way, Eco Village',
      'phone': '+1 234-567-8902',
      'rating': 4.8,
      'type': 'Organic Products',
      'isOpen': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
          setState(() {
            _errorMessage = 'Location permission denied. Please grant permission to find nearby stores.';
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _addMarkers(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _addMarkers(double lat, double lng) {
    // Add current location marker
    _markers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'You are here',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    // Add sample store markers
    for (int i = 0; i < _sampleStores.length; i++) {
      final store = _sampleStores[i];
      _markers.add(Marker(
        markerId: MarkerId('store_$i'),
        position: LatLng(
          lat + (0.002 * (i + 1)) * (i % 2 == 0 ? 1 : -1),
          lng + (0.003 * (i + 1)) * (i % 2 == 0 ? 1 : -1),
        ),
        infoWindow: InfoWindow(
          title: store['name'],
          snippet: store['type'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          store['isOpen'] ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Nearby Agricultural Stores'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildMapView(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.backgroundColor,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Finding your location...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.backgroundColor,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              Text(
                'Location Access Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              Text(
                _errorMessage ?? 'Unable to access location',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _getCurrentLocation();
                },
                icon: const Icon(Icons.refresh, color: AppTheme.primaryGreen),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingXLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Column(
      children: [
        // Map View
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.borderRadiusLarge),
                bottomRight: Radius.circular(AppConstants.borderRadiusLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.borderRadiusLarge),
                bottomRight: Radius.circular(AppConstants.borderRadiusLarge),
              ),
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
                compassEnabled: true,
                mapToolbarEnabled: true,
              ),
            ),
          ),
        ),
        
        // Store List
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.store,
                      color: AppTheme.primaryGreen,
                      size: AppConstants.iconMedium,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      'Nearby Stores',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sampleStores.length,
                    itemBuilder: (context, index) {
                      final store = _sampleStores[index];
                      return _buildStoreCard(store);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: store['isOpen'] 
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Icon(
                Icons.store,
                color: store['isOpen'] ? AppTheme.successColor : AppTheme.errorColor,
                size: AppConstants.iconMedium,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store['name'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: store['isOpen'] 
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          store['isOpen'] ? 'OPEN' : 'CLOSED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store['type'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.primaryOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${store['rating']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      const Icon(
                        Icons.phone,
                        color: AppTheme.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store['phone'],
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
