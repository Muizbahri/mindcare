import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({Key? key}) : super(key: key);

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _showBigPlayer = false;

  final List<Map<String, String>> _songs = [
    {
      'title': '…Ready For It?',
      'artist': 'Taylor Swift',
      'asset': 'audio/Taylor Swift - …Ready For It_.mp3',
    },
    {
      'title': '22',
      'artist': 'Taylor Swift',
      'asset': 'audio/Taylor Swift - 22.mp3',
    },
    {
      'title': 'Shake It Off',
      'artist': 'Taylor Swift',
      'asset': 'audio/Taylor Swift - Shake It Off.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    _loadSong(_currentIndex, autoPlay: false);
  }

  Future<void> _loadSong(int index, {bool autoPlay = true}) async {
    await _audioPlayer.stop();
    await _audioPlayer.setSource(AssetSource(_songs[index]['asset']!));
    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    if (autoPlay) await _audioPlayer.resume();
  }

  void _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _next() async {
    int nextIndex = (_currentIndex + 1) % _songs.length;
    await _loadSong(nextIndex);
  }

  void _previous() async {
    int prevIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    await _loadSong(prevIndex);
  }

  void _seek(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildBigPlayer() {
    final song = _songs[_currentIndex];
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _showBigPlayer = false),
              child: Align(
                alignment: Alignment.topRight,
                child:
                    Icon(Icons.expand_more, size: 32, color: Colors.grey[700]),
              ),
            ),
            Icon(Icons.music_note, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(song['title']!,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(song['artist']!,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value:
                  _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
              onChanged: (value) => _seek(value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position)),
                Text(_formatTime(_duration)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  onPressed: _previous,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 56,
                    color: Colors.green,
                  ),
                  onPressed: _playPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  onPressed: _next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final song = _songs[_currentIndex];
    return GestureDetector(
      onTap: () => setState(() => _showBigPlayer = true),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.music_note, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(song['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(song['artist']!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.green, size: 32),
              onPressed: _playPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 28),
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Stack(
        children: [
          Column(
            children: [
              if (_showBigPlayer)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBigPlayer(),
                ),
              if (!_showBigPlayer) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, idx) {
                      final song = _songs[idx];
                      final isSelected = idx == _currentIndex;
                      return ListTile(
                        leading: Icon(Icons.music_note,
                            color: isSelected ? Colors.orange : Colors.grey),
                        title: Text(song['title']!),
                        subtitle: Text(song['artist']!),
                        trailing: isSelected && _isPlaying
                            ? Icon(Icons.equalizer, color: Colors.green)
                            : null,
                        onTap: () async {
                          await _loadSong(idx);
                          setState(() {
                            _showBigPlayer = true;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 64), // space for mini player
              ],
            ],
          ),
          // Mini player always at bottom
          if (!_showBigPlayer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildMiniPlayer(),
            ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
