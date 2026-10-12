import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';
import 'music_search_header.dart';
import 'music_search_results_list.dart';

class MusicSearchBottomSheet extends StatefulWidget {
  final Function(MusicModel) onMusicSelected;

  const MusicSearchBottomSheet({super.key, required this.onMusicSelected});

  @override
  State<MusicSearchBottomSheet> createState() => _MusicSearchBottomSheetState();
}

class _MusicSearchBottomSheetState extends State<MusicSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  Timer? _debounce;
  List<MusicModel> _searchResults = [];
  bool _isLoading = false;
  String? _currentUrl;
  bool _isPlaying = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _playerSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing = state.playing && state.processingState != ProcessingState.completed;
      final buffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      setState(() {
        _isPlaying = playing;
        _isBuffering = buffering;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _playerSub?.cancel();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return setState(() => _searchResults = []);
    setState(() => _isLoading = true);
    final results = await MusicService.searchMusic(query.trim());
    if (mounted) setState(() { _searchResults = results; _isLoading = false; });
  }

  Future<void> _togglePlay(String url) async {
    try {
      if (_currentUrl == url && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _currentUrl = url);
        await _audioPlayer.setUrl(url);
        _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF16182B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
      ),
      child: Column(
        children: [
          MusicSearchHeader(
            controller: _searchController,
            onSubmitted: _search,
            onChanged: _onQueryChanged,
            onClear: () {
              _searchController.clear();
              setState(() => _searchResults = []);
              _audioPlayer.stop();
            },
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: MusicSearchResultsList(
              results: _searchResults,
              isLoading: _isLoading,
              currentUrl: _currentUrl,
              isPlaying: _isPlaying,
              isBuffering: _isBuffering,
              onPlayToggle: _togglePlay,
              onSelect: (m) {
                _audioPlayer.stop();
                widget.onMusicSelected(m);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

