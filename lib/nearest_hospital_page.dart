import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class NearestHospitalPage extends StatefulWidget {
  const NearestHospitalPage({Key? key}) : super(key: key);

  @override
  State<NearestHospitalPage> createState() => _NearestHospitalPageState();
}

class _NearestHospitalPageState extends State<NearestHospitalPage> {
  void _openGoogleMapsDirection(double destLat, double destLon) async {
    if (_userPosition == null) return;
    final origin = '${_userPosition!.latitude},${_userPosition!.longitude}';
    final destination = '$destLat,$destLon';
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Position? _userPosition;
  List<dynamic> _hospitals = [];
  bool _loading = true;
  String? _error;
  List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initHospitals();
  }

  Future<void> _initHospitals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _userPosition = await _getCurrentLocation();
      final clinics = await _fetchNearbyClinics(
          _userPosition!.latitude, _userPosition!.longitude);
      setState(() {
        _hospitals = clinics;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<List<dynamic>> _fetchNearbyClinics(double lat, double lon) async {
    final url = 'http://10.0.2.2:5000/api/geo/nearby-clinics?lat=$lat&lon=$lon';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load clinics');
    }
  }

  Future<List<LatLng>> _fetchRoute(LatLng origin, LatLng dest) async {
    final apiKey = '78975a0ab83d46e2bd5a71dbbf0c3069'; // API key kamu
    final url =
        'https://api.geoapify.com/v1/routing?waypoints=${origin.latitude},${origin.longitude}|${dest.latitude},${dest.longitude}&mode=drive&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      final points = coords[0] as List; // Ambil list pertama
      return points.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearest Hospitals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    if (_userPosition != null)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 320, // Perbesar tinggi map
                          width: double.infinity, // Pastikan map full width
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  center: LatLng(_userPosition!.latitude,
                                      _userPosition!.longitude),
                                  zoom: 14,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=78975a0ab83d46e2bd5a71dbbf0c3069',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(_userPosition!.latitude,
                                            _userPosition!.longitude),
                                        width: 40,
                                        height: 40,
                                        builder: (ctx) => const Icon(
                                            Icons.my_location,
                                            color: Colors.blue,
                                            size: 32),
                                      ),
                                      ..._hospitals
                                          .where((h) =>
                                              h['latitude'] != null &&
                                              h['longitude'] != null)
                                          .map((h) => Marker(
                                                point: LatLng(
                                                  (h['latitude'] as num)
                                                      .toDouble(),
                                                  (h['longitude'] as num)
                                                      .toDouble(),
                                                ),
                                                width: 40,
                                                height: 40,
                                                builder: (ctx) => const Icon(
                                                    Icons.local_hospital,
                                                    color: Colors.red,
                                                    size: 32),
                                              ))
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
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Column(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: 'zoomIn',
                                      mini: true,
                                      onPressed: () {
                                        _mapController.move(
                                            _mapController.center,
                                            _mapController.zoom + 1);
                                      },
                                      child: const Icon(Icons.add),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton(
                                      heroTag: 'zoomOut',
                                      mini: true,
                                      onPressed: () {
                                        _mapController.move(
                                            _mapController.center,
                                            _mapController.zoom - 1);
                                      },
                                      child: const Icon(Icons.remove),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Nearby Hospitals (${_hospitals.length})',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    Expanded(
                      child: _hospitals.isEmpty
                          ? const Center(child: Text('No hospitals found.'))
                          : ListView.builder(
                              itemCount: _hospitals.length,
                              itemBuilder: (context, idx) {
                                final h = _hospitals[idx];
                                return ListTile(
                                  leading: const Icon(Icons.local_hospital,
                                      color: Colors.red),
                                  title: Text(
                                      h['clinic_name'] ?? 'Unnamed Clinic'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(h['address'] ?? ''),
                                      const SizedBox(height: 4),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.directions),
                                        label: const Text('Get Direction'),
                                        onPressed: () async {
                                          final origin = LatLng(
                                              _userPosition!.latitude,
                                              _userPosition!.longitude);
                                          final dest = LatLng(
                                              (h['latitude'] as num).toDouble(),
                                              (h['longitude'] as num)
                                                  .toDouble());
                                          final route =
                                              await _fetchRoute(origin, dest);
                                          setState(() {
                                            _routePoints = route;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          textStyle:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: h['distance'] != null
                                      ? Text(
                                          '${(h['distance'] as num).toStringAsFixed(2)} km')
                                      : null,
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
