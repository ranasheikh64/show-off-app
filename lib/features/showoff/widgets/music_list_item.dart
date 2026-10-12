import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_theme.dart';
import '../services/music_service.dart';

class MusicListItem extends StatelessWidget {
  final MusicModel music;
  final bool isPlaying;
  final VoidCallback onPlayToggle;
  final VoidCallback onSelect;

  const MusicListItem({
    super.key,
    required this.music,
    required this.isPlaying,
    required this.onPlayToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isPlaying ? AppTheme.primaryBlue.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 48.w,
              height: 48.w,
              child: music.coverImage != null
                  ? Image.network(
                      music.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _fallbackCover(),
                    )
                  : _fallbackCover(),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  music.title,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  music.artist,
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onPlayToggle,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? AppTheme.primaryBlue : Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onSelect,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF4D8D), AppTheme.primaryBlue]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      child: Icon(Icons.music_note_rounded, color: AppTheme.primaryBlue, size: 24.sp),
    );
  }
}

