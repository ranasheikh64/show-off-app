enum CallType { audio, video }

enum CallStatus {
  idle,
  outgoing, // calling peer, ringing
  incoming, // received call, ringing
  connected, // peer answered, in call
  ended,
}

class CallSessionModel {
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final CallType callType;
  final bool isOutgoing;
  final dynamic sdpOffer;

  const CallSessionModel({
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    required this.callType,
    required this.isOutgoing,
    this.sdpOffer,
  });

  CallSessionModel copyWith({
    String? peerId,
    String? peerName,
    String? peerAvatar,
    CallType? callType,
    bool? isOutgoing,
    dynamic sdpOffer,
  }) {
    return CallSessionModel(
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      callType: callType ?? this.callType,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      sdpOffer: sdpOffer ?? this.sdpOffer,
    );
  }
}
