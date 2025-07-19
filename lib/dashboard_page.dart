import 'package:flutter/material.dart';
import 'translate_demo.dart';
import 'translate_service.dart';
import 'self_assessment_flow.dart';
import 'music_player_page.dart';
import 'mental_health_articles_page.dart';
import 'emergency_support_page.dart';
import 'nearest_hospital_page.dart';
import 'book_appointment_page.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final DateTime date;
  DashboardPage({Key? key, this.userName = 'Demo', DateTime? date})
      : date = date ?? DateTime(2025, 7, 16),
        super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // All texts to be translated
  late String greeting;
  late String howFeeling;
  late String checkInDesc;
  late String startAssessment;
  late String nearestHospital;
  late String nearestHospitalDesc;
  late String bookAppointment;
  late String bookAppointmentDesc;
  late String articles;
  late String articlesDesc;
  late String music;
  late String musicDesc;
  late String emergency;
  late String emergencyDesc;
  late String getHelpNow;
  late String privacy;
  late String privacyDesc;
  late String dateString;
  bool isTranslating = false;

  @override
  void initState() {
    super.initState();
    _setDefaultTexts();
  }

  void _setDefaultTexts() {
    greeting = 'Good Evening,';
    howFeeling = 'How are you feeling today?';
    checkInDesc =
        'Take a moment to check in with yourself. Your mental health matters.';
    startAssessment = 'Start Assessment';
    nearestHospital = 'Nearest Hospital';
    nearestHospitalDesc = 'Find nearby help.';
    bookAppointment = 'Book Appointment';
    bookAppointmentDesc = 'Schedule a session with a counselor';
    articles = 'Mental Health Articles';
    articlesDesc = 'Educational resources';
    music = 'Calming Music';
    musicDesc = 'Mood-supportive playlists';
    emergency = 'Emergency Support';
    emergencyDesc =
        "If you're experiencing a mental health crisis, immediate help is available.";
    getHelpNow = 'Get Help Now';
    privacy =
        'Your data is encrypted and private. We never share your personal information.';
    privacyDesc = '';
    dateString = _formattedDate(widget.date);
  }

  String _formattedDate(DateTime date) {
    final weekDay = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][date.weekday - 1];
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][date.month - 1];
    return '$weekDay, $month ${date.day}, ${date.year}';
  }

  String currentLang = 'en';
  Future<void> _toggleLanguage() async {
    if (isTranslating) return;
    if (currentLang == 'en') {
      setState(() => isTranslating = true);
      try {
        greeting = await translateText('Good Evening,', 'ms');
        howFeeling = await translateText('How are you feeling today?', 'ms');
        checkInDesc = await translateText(
            'Take a moment to check in with yourself. Your mental health matters.',
            'ms');
        startAssessment = await translateText('Start Assessment', 'ms');
        nearestHospital = await translateText('Nearest Hospital', 'ms');
        nearestHospitalDesc = await translateText('Find nearby help.', 'ms');
        bookAppointment = await translateText('Book Appointment', 'ms');
        bookAppointmentDesc =
            await translateText('Schedule a session with a counselor', 'ms');
        articles = await translateText('Mental Health Articles', 'ms');
        articlesDesc = await translateText('Educational resources', 'ms');
        music = await translateText('Calming Music', 'ms');
        musicDesc = await translateText('Mood-supportive playlists', 'ms');
        emergency = await translateText('Emergency Support', 'ms');
        emergencyDesc = await translateText(
            "If you're experiencing a mental health crisis, immediate help is available.",
            'ms');
        getHelpNow = await translateText('Get Help Now', 'ms');
        privacy = await translateText(
            'Your data is encrypted and private. We never share your personal information.',
            'ms');
        setState(() {
          currentLang = 'ms';
        });
      } catch (e) {}
      setState(() => isTranslating = false);
    } else {
      _setDefaultTexts();
      setState(() {
        currentLang = 'en';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Translate Button
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton.icon(
                  onPressed: isTranslating ? null : _toggleLanguage,
                  icon: const Icon(Icons.translate),
                  label: Text(
                    isTranslating
                        ? (currentLang == 'en'
                            ? 'Translating...'
                            : 'Menterjemah...')
                        : (currentLang == 'en'
                            ? 'Translate to Malay'
                            : 'Tukar ke English'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // Header Card
              Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(text: greeting + '\n'),
                                TextSpan(
                                  text: widget.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateString,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Assessment Section
              Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        Text(
                          howFeeling,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      checkInDesc,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SelfAssessmentFlow()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          startAssessment,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Feature Grid
              SizedBox(
                width: 400,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.25,
                  children: [
                    _FeatureCard(
                      icon: Icons.location_on,
                      iconColor: Color(0xFFF87171),
                      title: nearestHospital,
                      subtitle: nearestHospitalDesc,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NearestHospitalPage()),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.calendar_today,
                      iconColor: Color(0xFFA78BFA),
                      title: bookAppointment,
                      subtitle: bookAppointmentDesc,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookAppointmentPage(),
                          ),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.menu_book_outlined,
                      iconColor: Color(0xFF38BDF8),
                      title: articles,
                      subtitle: articlesDesc,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MentalHealthArticlesPage()),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.music_note,
                      iconColor: Color(0xFF34D399),
                      title: music,
                      subtitle: musicDesc,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MusicPlayerPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Emergency Section
              Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone_in_talk_outlined,
                            color: Color(0xFFF87171)),
                        const SizedBox(width: 8),
                        Text(
                          emergency,
                          style: const TextStyle(
                            color: Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emergencyDesc,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EmergencySupportPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF87171),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          getHelpNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Privacy Disclaimer
              Container(
                width: 400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        privacy,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
