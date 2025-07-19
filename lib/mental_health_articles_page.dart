import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MentalHealthArticlesPage extends StatefulWidget {
  const MentalHealthArticlesPage({Key? key}) : super(key: key);

  @override
  State<MentalHealthArticlesPage> createState() => _MentalHealthArticlesPageState();
}

class _MentalHealthArticlesPageState extends State<MentalHealthArticlesPage> {
  final List<Map<String, dynamic>> categories = [
    {'label': 'All', 'icon': Icons.menu_book_outlined},
    {'label': 'Depression', 'icon': Icons.psychology_alt_outlined},
    {'label': 'Anxiety', 'icon': Icons.favorite_border},
    {'label': 'Self-care', 'icon': Icons.spa_outlined},
    {'label': 'Wellness', 'icon': Icons.nightlight_round},
    {'label': 'Mindfulness', 'icon': Icons.self_improvement},
  ];
  int selectedCategory = 0;

  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Understanding Depression: Signs and Symptoms',
      'desc': 'Learn about the common signs of depression and when to seek help.',
      'category': 'Depression',
      'icon': Icons.psychology_alt_outlined,
      'color': Color(0xFF3B82F6),
      'readTime': '5 min read',
      'url': 'https://www.psychiatry.org/patients-families/depression/what-is-depression',
    },
    {
      'title': 'Managing Anxiety in Daily Life',
      'desc': 'Practical strategies to cope with anxiety and stress.',
      'category': 'Anxiety',
      'icon': Icons.favorite_border,
      'color': Color(0xFF10B981),
      'readTime': '7 min read',
      'url': 'https://www.betterhealth.vic.gov.au/health/conditionsandtreatments/anxiety-treatment-options',
    },
    {
      'title': 'Building Resilience and Coping Skills',
      'desc': 'Develop mental strength and healthy coping mechanisms.',
      'category': 'Self-care',
      'icon': Icons.spa_outlined,
      'color': Color(0xFF8B5CF6),
      'readTime': '6 min read',
      'url': 'https://www.verywellmind.com/ways-to-become-more-resilient-2795063#:~:text=Being%20optimistic,negative%20comments%20in%20your%20head.',
    },
    {
      'title': 'The Importance of Sleep for Mental Health',
      'desc': 'How quality sleep impacts your mental wellbeing.',
      'category': 'Wellness',
      'icon': Icons.nightlight_round,
      'color': Color(0xFF6366F1),
      'readTime': '4 min read',
      'url': 'https://www.mentalhealth.org.uk/explore-mental-health/publications/sleep-matters-impact-sleep-health-and-wellbeing',
    },
    {
      'title': 'Mindfulness and Meditation for Beginners',
      'desc': 'Simple techniques to start your mindfulness journey.',
      'category': 'Mindfulness',
      'icon': Icons.self_improvement,
      'color': Color(0xFFF59E42),
      'readTime': '8 min read',
      'url': 'https://www.mindful.org/meditation/mindfulness-getting-started/',
    },
  ];

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 0
        ? articles
        : articles.where((a) => a['category'] == categories[selectedCategory]['label']).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Mental Health Articles',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            // Category Filter
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final selected = i == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF3B82F6).withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(
                                color: const Color(0xFF3B82F6), width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(cat['icon'],
                              size: 18,
                              color: selected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            cat['label'],
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Articles List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final a = filtered[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: a['color'].withOpacity(0.13),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(a['icon'], color: a['color'], size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a['desc'],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: a['color'].withOpacity(0.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                a['category'],
                                style: TextStyle(
                                  color: a['color'],
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time, size: 15, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 2),
                            Text(
                              a['readTime'],
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF3B82F6)),
                              onPressed: () => _openArticle(a['url']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        'Educational Resources\nThese articles are for informational purposes and don\'t replace professional medical advice.',
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
          ],
        ),
      ),
    );
  }
}
