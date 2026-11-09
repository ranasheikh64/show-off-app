import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_theme.dart';

class MusicSearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClear;

  const MusicSearchHeader({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.w,
          height: 4.h,
          margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFFF4D8D), AppTheme.primaryBlue],
                ).createShader(r),
                child: Text('Select Music 🎵', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: Icon(Icons.close, color: Colors.white70, size: 22.sp), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              hintText: 'Search song or artist name...',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 13.sp),
              prefixIcon: IconButton(
                icon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22.sp),
                onPressed: () => onSubmitted(controller.text),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white54, size: 18.sp),
                onPressed: onClear,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }
}

