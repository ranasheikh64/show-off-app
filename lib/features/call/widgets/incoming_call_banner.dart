import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';

class IncomingCallBanner extends StatelessWidget {
  const IncomingCallBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return Obx(() {
      final session = ctrl.currentSession.value;
      if (session == null) return const SizedBox.shrink();

      final isVideo = session.callType == CallType.video;

      return Container(
        width: double.infinity,
        color: const Color(0xFF8B0000), // Solid crimson bar across the top
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 6.h,
          bottom: 10.h,
          left: 14.w,
          right: 14.w,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.white24,
              backgroundImage: session.peerAvatar != null && session.peerAvatar!.isNotEmpty
                  ? CachedNetworkImageProvider(session.peerAvatar!)
                  : null,
              child: session.peerAvatar == null || session.peerAvatar!.isEmpty
                  ? Icon(
                      isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: Colors.white,
                      size: 18.r,
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 13.5.sp),
                  children: [
                    TextSpan(
                      text: '${session.peerName} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: isVideo ? 'calling (video)...' : 'calling (audio)...',
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: ctrl.rejectCall,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_end, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: ctrl.acceptCall,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
