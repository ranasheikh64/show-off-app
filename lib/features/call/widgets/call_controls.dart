import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';
import '../models/call_model.dart';

class CallControls extends StatelessWidget {
  const CallControls({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();

    return Obx(() {
      final session = ctrl.currentSession.value;
      final isVideo = session?.callType == CallType.video;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF16182B).withValues(alpha: 0.92),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn(
              icon: ctrl.isMicMuted.value ? Icons.mic_off_rounded : Icons.mic_rounded,
              isActive: !ctrl.isMicMuted.value,
              onTap: ctrl.toggleMic,
            ),
            _btn(
              icon: ctrl.isSpeakerOn.value ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              isActive: ctrl.isSpeakerOn.value,
              onTap: ctrl.toggleSpeaker,
            ),
            if (isVideo) ...[
              _btn(
                icon: ctrl.isVideoOff.value ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                isActive: !ctrl.isVideoOff.value,
                onTap: ctrl.toggleVideo,
              ),
              _btn(
                icon: Icons.cameraswitch_rounded,
                isActive: true,
                onTap: ctrl.switchCamera,
              ),
            ],
            _btn(
              icon: Icons.call_end_rounded,
              isActive: true,
              isDestructive: true,
              onTap: ctrl.endCall,
            ),
          ],
        ),
      );
    });
  }

  Widget _btn({
    required IconData icon,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    Color bg = isDestructive
        ? Colors.redAccent
        : (isActive ? const Color(0xFF2E3258) : Colors.white24);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24.r),
      ),
    );
  }
}
