import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class EmergencySupportPage extends StatefulWidget {
  const EmergencySupportPage({Key? key}) : super(key: key);

  @override
  State<EmergencySupportPage> createState() => _EmergencySupportPageState();
}

class _EmergencySupportPageState extends State<EmergencySupportPage> {
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

  void _openGoogleMapsDirection(double destLat, double destLon) async {
    if (_userPosition == null) return;
    final origin = '${_userPosition!.latitude},${_userPosition!.longitude}';
    final destination = '$destLat,$destLon';
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Emergency Support',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Danger Alert Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF87171)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFF87171)),
                            SizedBox(width: 8),
                            Text(
                              'If you are in immediate danger:',
                              style: TextStyle(
                                color: Color(0xFFB91C1C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'If you are experiencing thoughts of self-harm or suicide, please reach out for help immediately. You are not alone, and support is available.',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text(
                              'Call 988 – Suicide & Crisis Lifeline',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF87171),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Emergency Contacts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.phone, color: Color(0xFF3B82F6)),
                            SizedBox(width: 8),
                            Text(
                              'Emergency Contacts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ContactCard(
                          title: 'National Suicide Prevention Lifeline',
                          subtitle: '24/7 crisis support',
                          value: '988',
                          icon: Icons.phone,
                          color: Color(0xFF3B82F6),
                          actionLabel: 'Call',
                          onAction: () {},
                        ),
                        _ContactCard(
                          title: 'Crisis Text Line',
                          subtitle: 'Text-based crisis support',
                          value: 'Text HOME to 741741',
                          icon: Icons.sms,
                          color: Color(0xFF6366F1),
                          actionLabel: 'Text',
                          onAction: () {},
                        ),
                        _ContactCard(
                          title: 'Emergency Services',
                          subtitle: 'Immediate emergency assistance',
                          value: '911',
                          icon: Icons.local_hospital,
                          color: Color(0xFFF87171),
                          actionLabel: 'Call',
                          onAction: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                // Location Confirmation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, color: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location found. Showing nearby facilities.',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nearby Facilities
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_hospital, color: Color(0xFF3B82F6)),
                          SizedBox(width: 8),
                          Text(
                            'Nearby Mental Health Facilities',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_loading)
                        const Center(child: CircularProgressIndicator()),
                      if (_error != null) Center(child: Text(_error!)),
                      if (!_loading && _error == null)
                        ..._hospitals.map((h) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          h['name'] ?? 'Unnamed Hospital',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (h['distance'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6)
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${(h['distance'] / 1000).toStringAsFixed(2)} km',
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (h['address'] != null)
                                    Text(
                                      h['address'],
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _openGoogleMapsDirection(
                                                  h['lat'], h['lon']),
                                          icon: const Icon(Icons.directions,
                                              color: Color(0xFF3B82F6),
                                              size: 18),
                                          label: const Text('Directions',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF3B82F6))),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Color(0xFF3B82F6)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Footer
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You Are Not Alone\nHelp is available 24/7. These resources are here to support you through difficult times.',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final VoidCallback onAction;
  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
