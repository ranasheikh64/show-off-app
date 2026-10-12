// ignore_for_file: avoid_print, library_prefixes

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/api_url.dart';
import '../../../core/storage/hive_service.dart';

class SocketService {
  static IO.Socket? _socket;

  static void initSocket() {
    if (_socket != null && _socket!.connected) return;

    final token = HiveService.getToken();
    if (token == null) return;

    _socket = IO.io(ApiUrl.socketUrl, IO.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build());

    _socket?.onConnect((_) {
      print('🟢 === Socket Connected Successfully ===');
      print('Socket ID: ${_socket?.id}');
      _listeners.forEach((event, callbacks) {
        for (var cb in callbacks) {
          _socket?.off(event);
          _socket?.on(event, cb);
        }
      });
      // Flush any queued offline messages
      while (_offlineMessageQueue.isNotEmpty) {
        final item = _offlineMessageQueue.removeAt(0);
        print('🚀 [Socket FLUSH QUEUE] Sending ${item['event']}: ${item['data']}');
        _socket?.emit(item['event'], item['data']);
      }
    });

    _socket?.onDisconnect((reason) {
      print('🔴 === Socket Disconnected ===');
      print('Reason: $reason');
    });

    _socket?.onConnectError((err) {
      print('❌ === Socket Connect Error ===');
      print('Error details: $err');
      print('Attempted URL: ${ApiUrl.socketUrl}');
    });

    _socket?.onError((err) {
      print('⚠️ === Socket General Error ===');
      print('Error details: $err');
    });

    _socket?.onReconnect((attempt) {
      print('🔄 === Socket Reconnected === (Attempt: $attempt)');
    });

    _socket?.onReconnectAttempt((attempt) {
      print('⏳ === Socket Reconnecting... === (Attempt: $attempt)');
    });

    _socket?.onReconnectError((err) {
      print('❌ === Socket Reconnect Error ===');
      print('Error: $err');
    });

    _socket?.onReconnectFailed((_) {
      print('🛑 === Socket Reconnect Failed ===');
    });

    // Attach any listeners registered before init
    _listeners.forEach((event, callbacks) {
      for (var cb in callbacks) {
        _socket?.on(event, cb);
      }
    });
  }

  static final Map<String, List<Function(dynamic)>> _listeners = {};

  static bool get isConnected => _socket?.connected == true;

  static void joinChat(String chatId) {
    _socket?.emit('join_chat', chatId);
  }

  static final List<Map<String, dynamic>> _offlineMessageQueue = [];

  static void emit(String event, dynamic data) {
    print('📤 [Socket OUT] $event (connected: $isConnected): $data');
    if (_socket != null && _socket!.connected) {
      _socket?.emit(event, data);
    } else {
      print('⏳ [Socket QUEUED] $event queued until connected');
      _offlineMessageQueue.add({'event': event, 'data': data});
      initSocket();
    }
  }

  static void emitWithAck(String event, dynamic data, Function(dynamic) ack) {
    print('📤 [Socket OUT with Ack] $event: $data');
    _socket?.emitWithAck(event, data, ack: ack);
  }

  static void on(String event, Function(dynamic) callback) {
    print('👂 [Socket Reg Listener] $event');
    _listeners.putIfAbsent(event, () => []);
    if (!_listeners[event]!.contains(callback)) {
      _listeners[event]!.add(callback);
    }
    _socket?.on(event, callback);
  }

  static void off(String event) {
    print('🔇 [Socket Unreg Listener] $event');
    _listeners.remove(event);
    _socket?.off(event);
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
