import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';

class MusicSearchBottomSheet extends StatefulWidget {
  final Function(MusicModel) onMusicSelected;

  const MusicSearchBottomSheet({super.key, required this.onMusicSelected});

  @override
  State<MusicSearchBottomSheet> createState() => _MusicSearchBottomSheetState();
}

class _MusicSearchBottomSheetState extends State<MusicSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<MusicModel> _searchResults = [];
  bool _isLoading = false;
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _searchMusic(String query) async {
    print('=== [BottomSheet] Search triggered with query: "$query" ===');
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await MusicService.searchMusic(query);
      print('=== [BottomSheet] Got ${results.length} results ===');

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('=== [BottomSheet] Error: $e ===');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause(String url) async {
    try {
      if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
        await _audioPlayer.pause();
        setState(() {});
      } else {
        setState(() {
          _currentlyPlayingUrl = url;
        });
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() {});
      }
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Search Music 🎵',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search input
          TextField(
            controller: _searchController,
            onSubmitted: _searchMusic,
            decoration: InputDecoration(
              hintText: 'Search for a song...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchResults = []);
                  _audioPlayer.stop();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          // Results list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(child: Text('Search a song to add to your post!'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final music = _searchResults[index];
                          final isPlaying = _currentlyPlayingUrl == music.previewUrl && _audioPlayer.playing;

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: music.coverImage != null
                                  ? Image.network(music.coverImage!, width: 50, height: 50, fit: BoxFit.cover)
                                  : Container(width: 50, height: 50, color: Colors.grey.shade300, child: const Icon(Icons.music_note)),
                            ),
                            title: Text(music.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(music.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Theme.of(context).primaryColor, size: 30),
                                  onPressed: () => _togglePlayPause(music.previewUrl),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onPressed: () {
                                    _audioPlayer.stop();
                                    widget.onMusicSelected(music);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
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
