import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';
import '../widgets/call_controls.dart';
import '../widgets/call_video_views.dart';
import '../widgets/call_audio_view.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0C1F),
        body: Stack(
          children: [
            // Body: Video or Audio
            Positioned.fill(
              child: Obx(() {
                final isVideo = ctrl.currentSession.value?.callType == CallType.video;
                return isVideo ? const CallVideoViews() : const CallAudioView();
              }),
            ),

            // Top Status Bar (Duration / Title for Video Calls)
            Positioned(
              top: 40.h,
              left: 20.w,
              right: 140.w,
              child: Obx(() {
                final isConnected = ctrl.callStatus.value == CallStatus.connected;
                final duration = ctrl.callDuration.value;
                final minutes = (duration ~/ 60).toString().padLeft(2, '0');
                final seconds = (duration % 60).toString().padLeft(2, '0');
                final session = ctrl.currentSession.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session?.peerName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(blurRadius: 8, color: Colors.black87)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isConnected
                          ? '$minutes:$seconds'
                          : (session?.isOutgoing == true ? 'Ringing...' : 'Connecting...'),
                      style: TextStyle(
                        color: isConnected ? Colors.greenAccent : Colors.white70,
                        fontSize: 13.sp,
                        shadows: const [Shadow(blurRadius: 8, color: Colors.black87)],
                      ),
                    ),
                  ],
                );
              }),
            ),

            // Bottom Controls Bar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: CallControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
