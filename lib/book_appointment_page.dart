import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({Key? key}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

// Model Appointment tanpa userName dan userEmail
class Appointment {
  final String appointmentDate;
  final String appointmentTime;
  final String counselorName;

  Appointment({
    required this.appointmentDate,
    required this.appointmentTime,
    required this.counselorName,
  });

  Map<String, dynamic> toJson() => {
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'counselor_name': counselorName,
      };
}

class AppointmentController {
  static Future<bool> bookAppointment(Appointment appointment) async {
    final url = Uri.parse('http://10.0.2.2:5000/api/appointments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment.toJson()),
    );
    return response.statusCode == 200;
  }
}

String convertTo24Hour(String input) {
  // Clean hidden characters: non-breaking space (U+00A0), narrow no-break space (U+202F), etc.
  input = input
      .replaceAll('\u202f', ' ') // narrow no-break space
      .replaceAll('\u00a0', ' ') // non-breaking space
      .replaceAll(RegExp(r'\s+'), ' ') // collapse multiple spaces
      .trim();

  final time = DateFormat.jm().parse(input);
  return DateFormat('HH:mm:ss').format(time);
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  // Senarai counselor statik
  final List<Map<String, dynamic>> counselors = [
    {'id': 1, 'full_name': 'Dr. Taylor Alison Swift'},
    {'id': 2, 'full_name': 'Dr. Daniel Hakim'},
    {'id': 3, 'full_name': 'Dr. Nurul Aina'},
    {'id': 4, 'full_name': 'Dr. Ahmad Zaki'},
  ];
  String? selectedCounselorId;
  DateTime? selectedDate;
  String? selectedTime;
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
    if (selectedCounselorId != null &&
        selectedDate != null &&
        selectedTime != null) {
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
        title: const Text('Book Appointment'),
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
                    DropdownButtonFormField<String>(
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
                onPressed: () async {
                  final appointment = Appointment(
                    appointmentDate: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                    appointmentTime: selectedTime ?? '',
                    counselorName: counselors.firstWhere((c) =>
                            c['id'].toString() ==
                            (selectedCounselorId ?? ''))['full_name'] ??
                        '',
                  );
                  print('Booking data: ' + jsonEncode(appointment.toJson()));
                  final url =
                      Uri.parse('http://10.0.2.2:5000/api/appointments');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(appointment.toJson()),
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Appointment booked successfully!')),
                    );
                  } else {
                    print(
                        'Booking failed: ${response.statusCode} ${response.body}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to book appointment. ${response.body}')),
                    );
                  }
                },
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
          ],
        ),
      ),
    );
  }
}
