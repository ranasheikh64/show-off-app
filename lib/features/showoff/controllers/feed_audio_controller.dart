import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class FeedAudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _debounceTimer;
  String? _currentUrl;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  void playMusic(String url, {Duration debounce = const Duration(milliseconds: 350)}) {
    if (_currentUrl == url && _audioPlayer.playing) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () async {
      try {
        if (_currentUrl == url && _audioPlayer.playing) return;
        _currentUrl = url;
        await _audioPlayer.setUrl(url);
        _audioPlayer.play();
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    });
  }

  void pauseMusic() {
    _debounceTimer?.cancel();
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    }
  }

  void stopMusic() {
    _debounceTimer?.cancel();
    _currentUrl = null;
    _audioPlayer.stop();
  }
}

