import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({Key? key}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<Map<String, dynamic>> counselors = [];
  String? selectedCounselorId;
  DateTime? selectedDate;
  String? selectedTime;
  bool isLoading = true;
  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    fetchCounselors();
  }

  Future<List<Map<String, dynamic>>> fetchCounselors() async {
    final url = 'http://10.0.2.2:5000/api/geo/counselors';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print('Counselor API status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Counselor data: $data');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Counselor API error: ${response.body}');
        throw Exception('Failed to load counselors');
      }
    } catch (e) {
      print('Error fetching counselors: $e');
      return [];
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _confirmAppointment() {
    // TODO: Implement backend call to save appointment
    if (selectedCounselorId != null &&
        selectedDate != null &&
        selectedTime != null) {
      // Prepare data
      final data = {
        'counselor_id': selectedCounselorId,
        'selected_date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'selected_time': selectedTime,
      };
      print('Appointment data: $data');
      // Show confirmation (for demo)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment confirmed!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF5FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Counselor
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person_outline, color: Color(0xFFA78BFA)),
                        SizedBox(width: 8),
                        Text('Select Counselor',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchCounselors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError ||
                            (snapshot.data?.isEmpty ?? true)) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child:
                                Text('No counselors found or failed to load.'),
                          );
                        } else {
                          final counselors = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Choose a counselor',
                            ),
                            value: selectedCounselorId,
                            items: counselors
                                .map((c) => DropdownMenuItem<String>(
                                      value: c['id'].toString(),
                                      child: Text(c['full_name'] ?? 'Unknown'),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCounselorId = val;
                              });
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Select Date
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Color(0xFFA78BFA)),
                        SizedBox(width: 8),
                        Text('Select Date',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Pick a date',
                            suffixIcon: Icon(Icons.calendar_today,
                                color: Colors.grey[400]),
                          ),
                          controller: TextEditingController(
                            text: selectedDate == null
                                ? ''
                                : DateFormat('yyyy-MM-dd')
                                    .format(selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Select Time
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time, color: Color(0xFFA78BFA)),
                        SizedBox(width: 8),
                        Text('Select Time',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: timeSlots
                          .map((slot) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTime = slot;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedTime == slot
                                        ? const Color(0xFFA78BFA)
                                        : Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFA78BFA)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      color: selectedTime == slot
                                          ? Colors.white
                                          : const Color(0xFFA78BFA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _confirmAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA78BFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Previous Appointments (optional, placeholder)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Previous Appointments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('No previous appointments found.',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
