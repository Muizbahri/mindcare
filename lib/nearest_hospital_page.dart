import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearestHospitalPage extends StatefulWidget {
  const NearestHospitalPage({Key? key}) : super(key: key);

  @override
  State<NearestHospitalPage> createState() => _NearestHospitalPageState();
}

class _NearestHospitalPageState extends State<NearestHospitalPage> {
  Position? _position;
  bool _loading = true;
  String? _error;

  // Placeholder hospital data
  final List<Map<String, dynamic>> hospitals = [
    {
      'name': 'City Mental Health Center',
      'address': '123 Healthcare St, Open 24/7',
      'lat': 37.7749,
      'lng': -122.4194,
      'distance': '1.2 km',
      'phone': '123-456-7890',
    },
    {
      'name': 'Downtown Clinic',
      'address': '456 Wellness Ave, Open 8AM-8PM',
      'lat': 37.7849,
      'lng': -122.4094,
      'distance': '2.1 km',
      'phone': '987-654-3210',
    },
    {
      'name': 'General Hospital',
      'address': '789 Medical Blvd, 24/7',
      'lat': 37.7649,
      'lng': -122.4294,
      'distance': '3.0 km',
      'phone': '555-123-4567',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied.';
          _loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Mental Health Support',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF5FAFF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: User's Current Location
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _position != null
                                  ? 'Your current location: ${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                                  : 'Location not available',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Section 2: Interactive Map
                    if (_position != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FlutterMap(
                              options: MapOptions(
                                center: LatLng(
                                    _position!.latitude, _position!.longitude),
                                zoom: 13.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.mindcare',
                                ),
                                MarkerLayer(
                                  markers: [
                                    // User location marker
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: LatLng(_position!.latitude,
                                          _position!.longitude),
                                      builder: (ctx) => const Icon(
                                          Icons.my_location,
                                          color: Colors.blue,
                                          size: 32),
                                    ),
                                    // Hospital markers
                                    ...hospitals.map((h) => Marker(
                                          width: 40,
                                          height: 40,
                                          point: LatLng(h['lat'], h['lng']),
                                          builder: (ctx) => const Icon(
                                              Icons.local_hospital,
                                              color: Colors.red,
                                              size: 32),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Section 3: List of Nearby Hospitals/Clinics
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hospitals.length,
                        itemBuilder: (context, i) {
                          final h = hospitals[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            margin: const EdgeInsets.only(bottom: 14),
                            child: ListTile(
                              leading: const Icon(Icons.local_hospital,
                                  color: Colors.red),
                              title: Text(h['name'],
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['address'],
                                      style: const TextStyle(
                                          fontFamily: 'Poppins', fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 15, color: Color(0xFF3B82F6)),
                                      const SizedBox(width: 2),
                                      Text(h['distance'],
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                    child: const Text('Call',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontSize: 12)),
                                  ),
                                  const SizedBox(height: 6),
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFF3B82F6)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                    ),
                                    child: const Text('Directions',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Color(0xFF3B82F6),
                                            fontSize: 12)),
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
