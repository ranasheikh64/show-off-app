import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';

class CallAudioView extends StatelessWidget {
  const CallAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return Obx(() {
      final session = ctrl.currentSession.value;
      final isConnected = ctrl.callStatus.value == CallStatus.connected;
      final duration = ctrl.callDuration.value;

      final minutes = (duration ~/ 60).toString().padLeft(2, '0');
      final seconds = (duration % 60).toString().padLeft(2, '0');

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2D4A).withValues(alpha: 0.5),
              ),
              child: CircleAvatar(
                radius: 64.r,
                backgroundColor: const Color(0xFF1E2036),
                backgroundImage: session?.peerAvatar != null
                    ? CachedNetworkImageProvider(session!.peerAvatar!)
                    : null,
                child: session?.peerAvatar == null
                    ? Icon(Icons.person, size: 64.r, color: Colors.white70)
                    : null,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              session?.peerName ?? 'Unknown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isConnected
                  ? '$minutes:$seconds'
                  : (session?.isOutgoing == true ? 'Ringing...' : 'Connecting...'),
              style: TextStyle(
                color: isConnected ? Colors.greenAccent : Colors.white60,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}
