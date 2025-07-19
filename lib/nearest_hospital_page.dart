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
      final hospitals = await _fetchNearbyHospitals(
          _userPosition!.latitude, _userPosition!.longitude);
      setState(() {
        _hospitals = hospitals;
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

  Future<List<dynamic>> _fetchNearbyHospitals(double lat, double lon) async {
    final url =
        'http://localhost:5000/api/geo/nearby-hospitals?lat=$lat&lon=$lon';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hospitals');
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
                          height: 220,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(_userPosition!.latitude,
                                  _userPosition!.longitude),
                              zoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
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
                                  ..._hospitals.map((h) => Marker(
                                        point: LatLng(h['lat'], h['lon']),
                                        width: 40,
                                        height: 40,
                                        builder: (ctx) => const Icon(
                                            Icons.local_hospital,
                                            color: Colors.red,
                                            size: 32),
                                      ))
                                ],
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
                                  title: Text(h['name'] ?? 'Unnamed Hospital'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(h['address'] ?? ''),
                                      const SizedBox(height: 4),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.directions),
                                        label: const Text('Get Direction'),
                                        onPressed: () =>
                                            _openGoogleMapsDirection(
                                                h['lat'], h['lon']),
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
                                          '${(h['distance'] / 1000).toStringAsFixed(2)} km')
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
