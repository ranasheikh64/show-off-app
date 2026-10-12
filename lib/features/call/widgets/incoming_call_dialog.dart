import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';

class IncomingCallDialog extends StatelessWidget {
  const IncomingCallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: const Color(0xFF16182B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Obx(() {
            final session = ctrl.currentSession.value;
            if (session == null) return const SizedBox.shrink();

            final isVideo = session.callType == CallType.video;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 42.r,
                  backgroundColor: const Color(0xFF2A2D4A),
                  backgroundImage: session.peerAvatar != null
                      ? CachedNetworkImageProvider(session.peerAvatar!)
                      : null,
                  child: session.peerAvatar == null
                      ? Icon(Icons.person, size: 42.r, color: Colors.white70)
                      : null,
                ),
                SizedBox(height: 16.h),
                Text(
                  session.peerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: isVideo ? Colors.blueAccent : Colors.greenAccent,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isVideo ? 'Incoming Video Call...' : 'Incoming Audio Call...',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionBtn(
                      icon: Icons.call_end_rounded,
                      color: Colors.redAccent,
                      label: 'Decline',
                      onTap: ctrl.rejectCall,
                    ),
                    _actionBtn(
                      icon: isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: Colors.greenAccent.shade700,
                      label: 'Accept',
                      onTap: ctrl.acceptCall,
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32.r),
          child: Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28.r),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
