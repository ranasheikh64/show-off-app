import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/call_model.dart';

class WebRtcService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool _renderersInitialized = false;

  bool isAudioMuted = false;
  bool isVideoOff = false;
  bool isSpeakerOn = false;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': ['stun:stun.l.google.com:19302', 'stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302']},
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _offerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  Future<void> initRenderers() async {
    if (!_renderersInitialized) {
      localRenderer = RTCVideoRenderer();
      remoteRenderer = RTCVideoRenderer();
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      _renderersInitialized = true;
    }
  }

  Future<void> openUserMedia(CallType callType) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': callType == CallType.video
          ? {
              'facingMode': 'user',
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'optional': [],
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;

    // Default speaker settings: video -> speaker ON, audio -> speaker OFF (earpiece)
    isSpeakerOn = callType == CallType.video;
    _localStream?.getAudioTracks().firstOrNull?.enableSpeakerphone(isSpeakerOn);
  }

  Future<RTCPeerConnection> createConnection({
    required Function(RTCIceCandidate candidate) onCandidate,
    required Function() onConnectionEstablished,
    required Function() onConnectionClosed,
  }) async {
    _peerConnection = await createPeerConnection(_iceServers, {});

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        onCandidate(candidate);
      }
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
      }
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        onConnectionEstablished();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        onConnectionClosed();
      }
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    return _peerConnection!;
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer(_offerConstraints);
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer(_offerConstraints);
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(String sdp, String type) async {
    final description = RTCSessionDescription(sdp, type);
    await _peerConnection?.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection?.addCandidate(candidate);
  }

  void toggleMic() {
    final audioTrack = _localStream?.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      isAudioMuted = !isAudioMuted;
      audioTrack.enabled = !isAudioMuted;
    }
  }

  void toggleVideo() {
    final videoTrack = _localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      isVideoOff = !isVideoOff;
      videoTrack.enabled = !isVideoOff;
    }
  }

  Future<void> switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  void toggleSpeaker() {
    final audioTrack = _localStream?.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      isSpeakerOn = !isSpeakerOn;
      audioTrack.enableSpeakerphone(isSpeakerOn);
    }
  }

  Future<void> dispose() async {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;

    try {
      _remoteStream?.getTracks().forEach((track) => track.stop());
      await _remoteStream?.dispose();
    } catch (_) {}
    _remoteStream = null;

    try {
      await _peerConnection?.close();
      await _peerConnection?.dispose();
    } catch (_) {}
    _peerConnection = null;

    if (_renderersInitialized) {
      try {
        localRenderer.srcObject = null;
        await localRenderer.dispose();
      } catch (_) {}

      try {
        remoteRenderer.srcObject = null;
        await remoteRenderer.dispose();
      } catch (_) {}
      _renderersInitialized = false;
    }
  }
}
