import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_theme.dart';
import '../services/music_service.dart';
import 'music_list_item.dart';

class MusicSearchResultsList extends StatelessWidget {
  final List<MusicModel> results;
  final bool isLoading;
  final String? currentUrl;
  final bool isPlaying;
  final bool isBuffering;
  final Function(String) onPlayToggle;
  final Function(MusicModel) onSelect;

  const MusicSearchResultsList({
    super.key,
    required this.results,
    required this.isLoading,
    required this.currentUrl,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPlayToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    if (results.isEmpty) {
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
      itemCount: results.length,
      itemBuilder: (context, i) {
        final m = results[i];
        final isCurrent = currentUrl == m.previewUrl;
        return MusicListItem(
          music: m,
          isPlaying: isCurrent && isPlaying,
          isLoading: isCurrent && isBuffering,
          onPlayToggle: () => onPlayToggle(m.previewUrl),
          onSelect: () => onSelect(m),
        );
      },
    );
  }
}
