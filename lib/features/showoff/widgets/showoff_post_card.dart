import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/showoff_model.dart';
import 'showoff_image_carousel.dart';

class ShowOffPostCard extends StatelessWidget {
  final ShowOffModel post;
  final bool isMine;
  final VoidCallback onChoose;
  final VoidCallback onMessage;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ShowOffPostCard({
    super.key,
    required this.post,
    required this.isMine,
    required this.onChoose,
    required this.onMessage,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        child: Material(
          color: const Color(0xFF16182B),
          borderRadius: BorderRadius.circular(24.r),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shadowColor: Colors.black26,
          child: Stack(
            children: [
              ShowOffImageCarousel(
                images: post.images,
                overlay: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _userInfo(),
                    if (!isMine) ...[SizedBox(height: 14.h), _actions(context)],
                  ],
                ),
              ),
              if (isMine)
                Positioned(top: 12.h, left: 12.w, child: _deleteButton()),
              if (!isMine)
                Positioned(top: 12.h, left: 12.w, child: _reportButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfo() {
    final user = post.user;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (user?.profileImage != null) ...[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFF2A2D4A),
                    backgroundImage: CachedNetworkImageProvider(
                      user!.profileImage!,
                      maxHeight: 80,
                      maxWidth: 80,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Flexible(
                child: Text(
                  user?.name ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (user?.age != null) ...[
                Text(
                  ', ${user!.age}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (user?.passion != null && user!.passion.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              user.passion.take(3).join('  •  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (user?.preferences != null && user!.preferences.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.white70, size: 14.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Looking for: ${user.preferences.take(2).join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (post.musicTitle != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.music_note_rounded, color: Colors.pinkAccent, size: 14.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${post.musicTitle} • ${post.musicArtist}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _deleteButton() => Material(
    color: Colors.black54,
    shape: const CircleBorder(),
    child: IconButton(
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      onPressed: onDelete,
    ),
  );

  Widget _reportButton(BuildContext context) {
    int reportCount = post.reportedBy.length;
    Color iconColor = Colors.white54;
    IconData iconData = Icons.flag_outlined;

    if (reportCount >= 4) {
      iconColor = Colors.redAccent;
      iconData = Icons.flag_rounded;
    } else if (reportCount >= 1) {
      iconColor = Colors.amber;
      iconData = Icons.flag_rounded;
    }

    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(iconData, color: iconColor),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E2036),
              title: const Text('Report Content', style: TextStyle(color: Colors.white)),
              content: const Text(
                'Are you sure you want to report this user/post for inappropriate behavior? False reports may lead to account suspension.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onReport();
                  },
                  child: const Text('Report', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context) {
    void handleAction(VoidCallback action, String actionName) {
      if (post.reportedBy.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E2036),
            title: const Text('Warning', style: TextStyle(color: Colors.amber)),
            content: Text(
              'This post has been flagged by other users for inappropriate content. Are you sure you want to $actionName?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  action();
                },
                child: const Text('Proceed', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        action();
      }
    }

    return Row(
      children: [
        Expanded(
          child: _button(
            post.isChosen ? 'Loved' : 'Show Love',
            post.isChosen ? Icons.check_circle_rounded : Icons.favorite_rounded,
            () => handleAction(onChoose, 'show love to this user'),
            gradient: post.isChosen
                ? const [Color(0xFF8E9AAF), Color(0xFFB8C0CC)]
                : const [Color(0xFFFF4D8D), Color(0xFFFF7A59)],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _button(
            'Message',
            Icons.chat_bubble_rounded,
            () => handleAction(onMessage, 'message this user'),
            gradient: const [Color(0xFF007BFF), Color(0xFF5AA9FF)],
          ),
        ),
      ],
    );
  }

  Widget _button(
    String label,
    IconData icon,
    VoidCallback onTap, {
    required List<Color> gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
