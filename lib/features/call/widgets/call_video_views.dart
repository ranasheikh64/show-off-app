import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';

class CallVideoViews extends StatelessWidget {
  const CallVideoViews({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return Obx(() {
      final isConnected = ctrl.callStatus.value == CallStatus.connected;
      final session = ctrl.currentSession.value;

      return Stack(
        children: [
          // Remote Video
          Positioned.fill(
            child: isConnected
                ? RTCVideoView(
                    ctrl.webRtc.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: const Color(0xFF0B0C1F),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50.r,
                            backgroundColor: const Color(0xFF2A2D4A),
                            child: const Icon(Icons.person, size: 50, color: Colors.white70),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            session?.peerName ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Connecting video stream...',
                            style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Floating Local Video
          Positioned(
            top: 50.h,
            right: 16.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: 110.w,
                height: 150.h,
                color: const Color(0xFF1E2036),
                child: ctrl.isVideoOff.value
                    ? const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54, size: 30),
                      )
                    : RTCVideoView(
                        ctrl.webRtc.localRenderer,
                        mirror: ctrl.isFrontCamera.value,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
