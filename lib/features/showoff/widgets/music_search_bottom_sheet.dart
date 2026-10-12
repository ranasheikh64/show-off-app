import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/app_theme.dart';
import '../services/music_service.dart';
import 'music_list_item.dart';
import 'music_search_header.dart';

class MusicSearchBottomSheet extends StatefulWidget {
  final Function(MusicModel) onMusicSelected;

  const MusicSearchBottomSheet({super.key, required this.onMusicSelected});

  @override
  State<MusicSearchBottomSheet> createState() => _MusicSearchBottomSheetState();
}

class _MusicSearchBottomSheetState extends State<MusicSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _debounce;
  List<MusicModel> _searchResults = [];
  bool _isLoading = false;
  String? _currentUrl;

  @override
  void dispose() {
    _debounce?.cancel();
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
    if (_currentUrl == url && _audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      _currentUrl = url;
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    }
    if (mounted) setState(() {});
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, size: 48.sp, color: Colors.white24),
            SizedBox(height: 8.h),
            Text('Search your favorite songs ✨', style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, i) {
        final m = _searchResults[i];
        final isPlaying = _currentUrl == m.previewUrl && _audioPlayer.playing;
        return MusicListItem(
          music: m,
          isPlaying: isPlaying,
          onPlayToggle: () => _togglePlay(m.previewUrl),
          onSelect: () {
            _audioPlayer.stop();
            widget.onMusicSelected(m);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

