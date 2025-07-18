import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class NearestHospitalPage extends StatefulWidget {
  NearestHospitalPage({Key? key}) : super(key: key);

  @override
  State<NearestHospitalPage> createState() => _NearestHospitalPageState();
}

class _NearestHospitalPageState extends State<NearestHospitalPage> {
  // DEMO: Override user location for testing. To revert, restore Geolocator.getCurrentPosition().
  final LatLng userLocation = LatLng(2.272765507229266, 102.44556190685111);
  final MapController _mapController = MapController();
  double _zoom = 14.0;
  final double _minZoom = 3.0;
  final double _maxZoom = 18.0;

  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;
  int? _selectedClinicIndex;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  Future<void> _initLocationAndFetch() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Do NOT call Geolocator.getCurrentPosition(); use fixed location for demo
      await fetchClinics();
      // Center map on user location
      _mapController.move(userLocation, _zoom);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, please enable them in settings.");
    }
  }

  Future<void> fetchClinics() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:5000';
      final response = await http.get(Uri.parse('$backendUrl/api/geo/clinics'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          clinics = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _call(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      print('Calling $phone...');
    }
  }

  void _navigate(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _navigateToClinic(double lat, double lon, int index) async {
    setState(() {
      _selectedClinicIndex = index;
      _zoom = 16.0;
      _routePoints = []; // Clear previous polyline
    });
    await _fetchAndDrawRoute(
        userLocation.latitude, userLocation.longitude, lat, lon);
  }

  Future<void> _fetchAndDrawRoute(
      double startLat, double startLon, double endLat, double endLon) async {
    final apiKey =
        dotenv.env['GEOAPIFY_API_KEY'] ?? '78975a0ab83d46e2bd5a71dbbf0c3069';
    final url =
        'https://api.geoapify.com/v1/routing?waypoints=$startLat,$startLon|$endLat,$endLon&mode=drive&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        if (features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          if (geometry['type'] == 'LineString') {
            final coords = geometry['coordinates'] as List<dynamic>;
            final points = coords
                .map<LatLng>((c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                .toList();
            setState(() {
              _routePoints = points; // Only one active polyline
            });
            // Fit map to route
            if (points.isNotEmpty) {
              var bounds = LatLngBounds.fromPoints(points);
              _mapController.fitBounds(
                bounds,
                options: const FitBoundsOptions(padding: EdgeInsets.all(40)),
              );
            }
          } else if (geometry['type'] == 'MultiLineString') {
            final coords = geometry['coordinates'] as List<dynamic>;
            if (coords.isNotEmpty) {
              final line = coords[0] as List<dynamic>;
              final points = line
                  .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(), (c[0] as num).toDouble()))
                  .toList();
              setState(() {
                _routePoints = points;
              });
              if (points.isNotEmpty) {
                var bounds = LatLngBounds.fromPoints(points);
                _mapController.fitBounds(
                  bounds,
                  options: const FitBoundsOptions(padding: EdgeInsets.all(40)),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  void _zoomIn() {
    setState(() {
      if (_zoom < _maxZoom) {
        _zoom += 1;
        if (userLocation != null) {
          _mapController.move(userLocation!, _zoom);
        }
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoom > _minZoom) {
        _zoom -= 1;
        if (userLocation != null) {
          _mapController.move(userLocation!, _zoom);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiKey =
        dotenv.env['GEOAPIFY_API_KEY'] ?? '78975a0ab83d46e2bd5a71dbbf0c3069';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Hospitals',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF5FAFF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: userLocation,
                              zoom: _zoom,
                              minZoom: _minZoom,
                              maxZoom: _maxZoom,
                              interactiveFlags: InteractiveFlag.pinchZoom |
                                  InteractiveFlag.drag,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$apiKey',
                                userAgentPackageName: 'com.example.mindcare',
                                tileProvider: NetworkTileProvider(),
                              ),
                              MarkerLayer(
                                markers: [
                                  // User marker
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: userLocation,
                                    builder: (ctx) => const Icon(
                                        Icons.my_location,
                                        color: Colors.blue,
                                        size: 32),
                                  ),
                                  // Clinic markers
                                  ...clinics.asMap().entries.map((entry) {
                                    final c = entry.value;
                                    final idx = entry.key;
                                    return Marker(
                                      width: 40,
                                      height: 40,
                                      point: LatLng(
                                          (c['latitude'] as num).toDouble(),
                                          (c['longitude'] as num).toDouble()),
                                      builder: (ctx) => AnimatedScale(
                                        scale: _selectedClinicIndex == idx
                                            ? 1.3
                                            : 1.0,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: Icon(
                                          Icons.local_hospital,
                                          color: _selectedClinicIndex == idx
                                              ? Colors.orange
                                              : Colors.red,
                                          size: 32,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              if (_routePoints.isNotEmpty)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _routePoints,
                                      color: Colors.blue,
                                      strokeWidth: 5,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Legend
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.circle,
                                      color: Colors.blue, size: 12),
                                  SizedBox(width: 4),
                                  Text('Your Location',
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 12),
                                  Icon(Icons.circle,
                                      color: Colors.red, size: 12),
                                  SizedBox(width: 4),
                                  Text('Hospitals',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          // Zoom buttons
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Column(
                              children: [
                                FloatingActionButton(
                                  heroTag: 'zoomIn',
                                  mini: true,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  onPressed: _zoomIn,
                                  child: const Icon(Icons.add),
                                  elevation: 2,
                                ),
                                const SizedBox(height: 10),
                                FloatingActionButton(
                                  heroTag: 'zoomOut',
                                  mini: true,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  onPressed: _zoomOut,
                                  child: const Icon(Icons.remove),
                                  elevation: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // List Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Text(
                    'Nearby Hospitals (${clinics.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      final c = clinics[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.local_hospital,
                                      color: Colors.red, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['clinic_name'] ?? 'Unknown Clinic',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          c['address'] ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.straighten,
                                                size: 15, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              '', // Distance calculation can be added later
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _call(c['phone']),
                                        icon: const Icon(Icons.phone, size: 16),
                                        label: const Text('Call'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          side: const BorderSide(
                                              color: Color(0xFFCBD5E1)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _navigateToClinic(
                                            (c['latitude'] as num).toDouble(),
                                            (c['longitude'] as num).toDouble(),
                                            index),
                                        icon: const Icon(Icons.navigation,
                                            size: 16),
                                        label: const Text('Navigate'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
