// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/call_model.dart';
import '../services/webrtc_service.dart';
import '../../chat/services/socket_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/push_notification_service.dart';
import '../widgets/incoming_call_banner.dart';
import '../../../routes/app_router.dart';
import '../../../main.dart';

class CallController extends GetxController {
  final WebRtcService webRtc = WebRtcService();

  final Rx<CallStatus> callStatus = CallStatus.idle.obs;
  final Rx<CallSessionModel?> currentSession = Rx<CallSessionModel?>(null);
  final RxInt callDuration = 0.obs;

  final RxBool isMicMuted = false.obs;
  final RxBool isVideoOff = false.obs;
  final RxBool isSpeakerOn = false.obs;
  final RxBool isFrontCamera = true.obs;

  Timer? _durationTimer;
  bool _isInitialized = false;
  OverlayEntry? _bannerOverlay;

  @override
  void onInit() {
    super.onInit();
    SocketService.initSocket();
    initSocketListeners();
  }

  void initSocketListeners() {
    if (_isInitialized) return;
    _isInitialized = true;

    print('📞 [CallCtrl] Registering socket event listeners...');
    SocketService.on('incoming_call', _handleIncomingCall);
    SocketService.on('call_accepted', _handleCallAccepted);
    SocketService.on('receive_ice_candidate', _handleRemoteCandidate);
    SocketService.on('call_rejected', _handleCallRejected);
    SocketService.on('call_ended', _handleCallEnded);
  }

  void _showIncomingBanner() {
    _hideIncomingBanner();
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay != null) {
      _bannerOverlay = OverlayEntry(
        builder: (_) => const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: IncomingCallBanner(),
          ),
        ),
      );
      overlay.insert(_bannerOverlay!);
    }
  }

  void _hideIncomingBanner() {
    _bannerOverlay?.remove();
    _bannerOverlay = null;
  }

  Future<void> _handleIncomingCall(dynamic data) async {
    print('📞 🔔 [CallCtrl INCOMING_CALL RECEIVED] Data: $data');
    if (data is! Map) return;
    final callerId = data['callerId']?.toString() ?? '';
    final callerName = data['callerName']?.toString() ?? 'Caller';
    final callerAvatar = data['callerAvatar']?.toString();
    final callTypeStr = data['callType']?.toString() ?? 'video';
    final offer = data['offer'];

    final callType = callTypeStr == 'audio' ? CallType.audio : CallType.video;
    print('📞 [CallCtrl] Incoming call from $callerName ($callerId), type: $callTypeStr, current status: ${callStatus.value}');

    // If currently already busy in a call, reject automatically
    if (callStatus.value != CallStatus.idle) {
      print('📞 [CallCtrl] User is currently busy, auto-rejecting call.');
      SocketService.emit('reject_call', {
        'callerId': callerId,
        'reason': 'User is busy on another call',
      });
      return;
    }

    currentSession.value = CallSessionModel(
      peerId: callerId,
      peerName: callerName,
      peerAvatar: callerAvatar,
      callType: callType,
      isOutgoing: false,
      sdpOffer: offer,
    );
    callStatus.value = CallStatus.incoming;

    // Show sleek top incoming call banner
    _showIncomingBanner();
  }

  /// Trigger incoming call from Push Notification payload (FCM)
  void handleIncomingCallPayload(Map<String, dynamic> data) {
    _handleIncomingCall(data);
  }

  Future<void> _handleCallAccepted(dynamic data) async {
    print('📞 ✅ [CallCtrl CALL_ACCEPTED RECEIVED] Data: $data');
    if (data is! Map) return;
    final answer = data['answer'];
    if (answer != null && answer is Map) {
      final sdp = answer['sdp']?.toString() ?? '';
      final type = answer['type']?.toString() ?? 'answer';
      await webRtc.setRemoteDescription(sdp, type);
      callStatus.value = CallStatus.connected;
      _startTimer();
    }
  }

  Future<void> _handleRemoteCandidate(dynamic data) async {
    print('📞 ❄️ [CallCtrl ICE_CANDIDATE RECEIVED]');
    if (data is! Map) return;
    final candidate = data['candidate'];
    if (candidate != null && candidate is Map<String, dynamic>) {
      await webRtc.addIceCandidate(candidate);
    }
  }

  void _handleCallRejected(dynamic data) {
    print('📞 ❌ [CallCtrl CALL_REJECTED RECEIVED] Data: $data');
    final reason = data is Map ? data['reason']?.toString() : 'Call declined';
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(reason ?? 'User declined the call'),
        backgroundColor: Colors.black87,
      ),
    );
    _cleanup();
  }

  void _handleCallEnded(dynamic data) {
    print('📞 🛑 [CallCtrl CALL_ENDED RECEIVED] Data: $data');
    _cleanup();
  }

  Future<void> startCall({
    required String peerId,
    required String peerName,
    String? peerAvatar,
    required CallType callType,
  }) async {
    print('📞 🚀 [CallCtrl startCall] Calling $peerName ($peerId), type: $callType');
    final hasPermissions = await _requestPermissions(callType);
    if (!hasPermissions) {
      print('❌ [CallCtrl startCall] Permissions not granted.');
      MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Camera and Microphone permissions are required.')),
      );
      return;
    }

    await webRtc.initRenderers();
    await webRtc.openUserMedia(callType);

    currentSession.value = CallSessionModel(
      peerId: peerId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      callType: callType,
      isOutgoing: true,
    );
    callStatus.value = CallStatus.outgoing;
    isSpeakerOn.value = webRtc.isSpeakerOn;

    // Navigate to Call Screen via GoRouter
    print('📞 [CallCtrl] Navigating to /call screen for outgoing call...');
    try {
      appRouter.push('/call');
    } catch (e) {
      print('❌ [CallCtrl] Failed to navigate to /call: $e');
    }

    await webRtc.createConnection(
      onCandidate: (candidate) {
        SocketService.emit('ice_candidate', {
          'targetId': peerId,
          'candidate': candidate.toMap(),
        });
      },
      onConnectionEstablished: () {
        callStatus.value = CallStatus.connected;
        _startTimer();
      },
      onConnectionClosed: () {
        _cleanup();
      },
    );

    final offer = await webRtc.createOffer();
    final authUser = Get.find<AuthController>().currentUser.value;

    SocketService.emitWithAck('call_user', {
      'receiverId': peerId,
      'callType': callType == CallType.audio ? 'audio' : 'video',
      'offer': offer.toMap(),
      'callerInfo': {
        'name': authUser?.name ?? 'Someone',
        'avatar': authUser?.profileImage,
      },
    }, (res) {
      if (res is Map && res['isBusy'] == true) {
        MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('User is currently on another call.')),
        );
        _cleanup();
      }
    });
  }

  Future<void> acceptCall() async {
    final session = currentSession.value;
    print('📞 🟢 [CallCtrl.acceptCall] Triggered. Session: ${session?.peerName}, offer: ${session?.sdpOffer != null}');
    if (session == null || session.sdpOffer == null) {
      print('❌ [CallCtrl.acceptCall] Aborted: session or sdpOffer is null! (session: $session)');
      return;
    }

    print('📞 [CallCtrl.acceptCall] Requesting permissions for ${session.callType}...');
    final hasPermissions = await _requestPermissions(session.callType);
    if (!hasPermissions) {
      print('❌ [CallCtrl.acceptCall] Permissions denied.');
      rejectCall(reason: 'Permission denied');
      return;
    }

    _hideIncomingBanner();

    print('📞 [CallCtrl.acceptCall] Initializing renderers and media...');
    await webRtc.initRenderers();
    await webRtc.openUserMedia(session.callType);
    isSpeakerOn.value = webRtc.isSpeakerOn;

    // Navigate to Call Screen via GoRouter
    print('📞 [CallCtrl.acceptCall] Navigating to /call screen...');
    try {
      appRouter.push('/call');
      print('✅ [CallCtrl.acceptCall] Successfully pushed /call to appRouter');
    } catch (e, st) {
      print('❌ [CallCtrl.acceptCall] Failed to navigate to /call: $e\n$st');
    }

    await webRtc.createConnection(
      onCandidate: (candidate) {
        SocketService.emit('ice_candidate', {
          'targetId': session.peerId,
          'candidate': candidate.toMap(),
        });
      },
      onConnectionEstablished: () {
        callStatus.value = CallStatus.connected;
        _startTimer();
      },
      onConnectionClosed: () {
        _cleanup();
      },
    );

    final offerMap = session.sdpOffer as Map;
    await webRtc.setRemoteDescription(
      offerMap['sdp']?.toString() ?? '',
      offerMap['type']?.toString() ?? 'offer',
    );

    final answer = await webRtc.createAnswer();
    SocketService.emit('answer_call', {
      'callerId': session.peerId,
      'answer': answer.toMap(),
    });

    callStatus.value = CallStatus.connected;
    _startTimer();
  }

  void rejectCall({String? reason}) {
    final session = currentSession.value;
    if (session != null) {
      SocketService.emit('reject_call', {
        'callerId': session.peerId,
        'reason': reason ?? 'Call declined',
      });
    }
    _hideIncomingBanner();
    final nav = rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    _cleanup();
  }

  void endCall() {
    final session = currentSession.value;
    if (session != null) {
      SocketService.emit('end_call', {
        'targetId': session.peerId,
      });
    }
    _cleanup();
  }

  void toggleMic() {
    webRtc.toggleMic();
    isMicMuted.value = webRtc.isAudioMuted;
  }

  void toggleVideo() {
    webRtc.toggleVideo();
    isVideoOff.value = webRtc.isVideoOff;
  }

  void switchCamera() async {
    await webRtc.switchCamera();
    isFrontCamera.value = !isFrontCamera.value;
  }

  void toggleSpeaker() {
    webRtc.toggleSpeaker();
    isSpeakerOn.value = webRtc.isSpeakerOn;
  }

  void _startTimer() {
    _durationTimer?.cancel();
    callDuration.value = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDuration.value++;
    });
  }

  Future<void> _cleanup() async {
    PushNotificationService.cancelCallNotification();
    _hideIncomingBanner();
    _durationTimer?.cancel();
    _durationTimer = null;
    callDuration.value = 0;
    callStatus.value = CallStatus.ended;

    // Pop the call screen or dialog if open
    final nav = rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }

    currentSession.value = null;
    isMicMuted.value = false;
    isVideoOff.value = false;

    await webRtc.dispose();

    callStatus.value = CallStatus.idle;
  }

  Future<bool> _requestPermissions(CallType type) async {
    final mic = await Permission.microphone.request();
    if (type == CallType.video) {
      final cam = await Permission.camera.request();
      return mic.isGranted && cam.isGranted;
    }
    return mic.isGranted;
  }

  @override
  void onClose() {
    SocketService.off('incoming_call');
    SocketService.off('call_accepted');
    SocketService.off('receive_ice_candidate');
    SocketService.off('call_rejected');
    SocketService.off('call_ended');
    _cleanup();
    super.onClose();
  }
}
