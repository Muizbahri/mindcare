import 'package:flutter/material.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({Key? key}) : super(key: key);

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  int selectedCategory = 0;
  int playingTrack = 0;
  double progress = 0.2;
  double volume = 0.75;
  bool isPlaying = true;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Relaxation & Calm',
      'subtitle': 'Soothing sounds to help you unwind',
      'color': Color(0xFF38BDF8),
      'tracks': [
        {
          'name': 'Ocean Waves',
          'subtitle': 'Nature Sounds',
          'duration': '10:00',
        },
        {
          'name': 'Forest Rain',
          'subtitle': 'Ambient Collection',
          'duration': '8:30',
        },
        {
          'name': 'Gentle Piano',
          'subtitle': 'Peaceful Melodies',
          'duration': '6:45',
        },
        {
          'name': 'Meditation Bell',
          'subtitle': 'Mindful Music',
          'duration': '12:00',
        },
        {
          'name': 'Wind Chimes',
          'subtitle': 'Zen Garden',
          'duration': '7:20',
        },
      ],
    },
    {
      'title': 'Focus & Concentration',
      'subtitle': 'Ambient music for better focus',
      'color': Color(0xFF8B5CF6),
      'tracks': [
        {
          'name': 'Deep Focus',
          'subtitle': 'Ambient Collection',
          'duration': '9:00',
        },
        {
          'name': 'Study Flow',
          'subtitle': 'Focus Beats',
          'duration': '7:45',
        },
        {
          'name': 'Brainwave',
          'subtitle': 'Concentration',
          'duration': '8:10',
        },
      ],
    },
    {
      'title': 'Motivation & Energy',
      'subtitle': 'Uplifting music to boost your mood',
      'color': Color(0xFFF59E42),
      'tracks': [
        {
          'name': 'Morning Sun',
          'subtitle': 'Uplifting Tunes',
          'duration': '6:30',
        },
        {
          'name': 'Power Up',
          'subtitle': 'Motivation Mix',
          'duration': '5:50',
        },
        {
          'name': 'Happy Vibes',
          'subtitle': 'Feel Good',
          'duration': '7:00',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final category = categories[selectedCategory];
    final tracks = category['tracks'] as List<Map<String, String>>;
    final currentTrack = tracks[playingTrack];
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
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
                        'Music Player',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Mood Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(categories.length, (i) {
                      final cat = categories[i];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = i;
                            playingTrack = 0;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: i == selectedCategory
                                ? cat['color'].withOpacity(0.07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: i == selectedCategory
                                ? Border.all(color: cat['color'], width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cat['color'].withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.music_note,
                                    color: cat['color'], size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cat['subtitle'],
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Now Playing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.music_note,
                              color: category['color'], size: 32),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          currentTrack['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentTrack['subtitle']!,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Progress bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('0:00',
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13)),
                            Text(currentTrack['duration']!,
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13)),
                          ],
                        ),
                        Slider(
                          value: progress,
                          onChanged: (v) => setState(() => progress = v),
                          min: 0,
                          max: 1,
                          activeColor: category['color'],
                          inactiveColor: category['color'].withOpacity(0.2),
                        ),
                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, size: 28),
                              onPressed: playingTrack > 0
                                  ? () => setState(() {
                                        playingTrack--;
                                        progress = 0;
                                      })
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: Colors.green,
                                size: 44,
                              ),
                              onPressed: () =>
                                  setState(() => isPlaying = !isPlaying),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.skip_next, size: 28),
                              onPressed: playingTrack < tracks.length - 1
                                  ? () => setState(() {
                                        playingTrack++;
                                        progress = 0;
                                      })
                                  : null,
                            ),
                          ],
                        ),
                        // Volume
                        Row(
                          children: [
                            const Icon(Icons.volume_up,
                                size: 20, color: Color(0xFF64748B)),
                            Expanded(
                              child: Slider(
                                value: volume,
                                onChanged: (v) => setState(() => volume = v),
                                min: 0,
                                max: 1,
                                activeColor: category['color'],
                                inactiveColor:
                                    category['color'].withOpacity(0.2),
                              ),
                            ),
                            Text('${(volume * 100).round()}',
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Playlist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, bottom: 8),
                          child: Text(
                            category['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: category['color'],
                            ),
                          ),
                        ),
                        ...List.generate(tracks.length, (i) {
                          final track = tracks[i];
                          final isCurrent = i == playingTrack;
                          return GestureDetector(
                            onTap: () => setState(() {
                              playingTrack = i;
                              progress = 0;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? category['color'].withOpacity(0.07)
                                    : Colors.transparent,
                                border: isCurrent
                                    ? Border(
                                        left: BorderSide(
                                            color: category['color'], width: 3),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent
                                        ? Icons.play_arrow
                                        : Icons.play_circle_outline,
                                    color: isCurrent
                                        ? category['color']
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track['name']!,
                                          style: TextStyle(
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            color: isCurrent
                                                ? category['color']
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          track['subtitle']!,
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(track['duration']!,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins', fontSize: 13)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Music Therapy Tips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.favorite, color: Color(0xFF10B981)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Listening to calming music can reduce stress, improve mood, and support mental wellbeing.',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontFamily: 'Poppins',
                              fontSize: 14,
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
