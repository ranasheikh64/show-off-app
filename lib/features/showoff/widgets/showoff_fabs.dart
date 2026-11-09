import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowOffFabs extends StatelessWidget {
  final VoidCallback onChats;
  final VoidCallback onAddPost;
  final bool visible;
  final int unreadCount;

  const ShowOffFabs({
    super.key,
    required this.onChats,
    required this.onAddPost,
    this.visible = true,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(1.6, 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: _buildButtons(),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(
            unreadCount > 99 ? '99+' : '$unreadCount',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          backgroundColor: const Color(0xFFFF3B5C),
          offset: const Offset(-2, -2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onChats,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: const Color(0xFF007BFF),
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4D8D), Color(0xFFFF7A59)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4D8D).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddPost,
              borderRadius: BorderRadius.circular(30.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
