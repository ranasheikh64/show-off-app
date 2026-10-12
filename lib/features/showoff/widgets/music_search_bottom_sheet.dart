import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/feed_audio_controller.dart';
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
  final _searchController = TextEditingController();
  final _audioPlayer = AudioPlayer();
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
    if (Get.isRegistered<FeedAudioController>()) Get.find<FeedAudioController>().pauseMusic();
    _search();
    _playerSub = _audioPlayer.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() {
        _isPlaying = s.playing && s.processingState != ProcessingState.completed;
        _isBuffering = s.processingState == ProcessingState.buffering || s.processingState == ProcessingState.loading;
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

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search([String? q]) async {
    setState(() => _isLoading = true);
    final res = await MusicService.searchMusic(q);
    if (mounted) setState(() { _searchResults = res; _isLoading = false; });
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
      debugPrint('Audio error: $e');
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
              _audioPlayer.stop();
              _search();
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
