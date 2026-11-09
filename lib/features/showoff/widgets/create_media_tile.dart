import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_theme.dart';

class AddMediaTile extends StatelessWidget {
  final VoidCallback onTap;
  const AddMediaTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF4D8D).withValues(alpha: 0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          color: const Color(0xFFFF4D8D).withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, size: 32.sp, color: const Color(0xFFFF4D8D)),
            SizedBox(height: 6.h),
            Text(
              'Add',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFFFF4D8D)),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaImageTile extends StatelessWidget {
  final File file;
  final bool isFirst;
  final VoidCallback onRemove;

  const MediaImageTile({
    super.key,
    required this.file,
    required this.isFirst,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        if (isFirst)
          Positioned(
            bottom: 6.h,
            left: 6.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF4D8D), AppTheme.primaryBlue]),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                'Cover',
                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Positioned(
          top: 5.h,
          right: 5.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 14.sp),
            ),
          ),
        ),
      ],
    );
  }
}
