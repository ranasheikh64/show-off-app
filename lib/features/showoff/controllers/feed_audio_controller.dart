import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class FeedAudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Track currently playing URL to avoid restarting the same song
  String? _currentUrl;
  
  @override
  void onInit() {
    super.onInit();
    // Optional: Loop the music if it's a short preview
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> playMusic(String url) async {
    try {
      if (_currentUrl == url && _audioPlayer.playing) return;
      
      _currentUrl = url;
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void pauseMusic() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    }
  }
  
  void stopMusic() {
    _currentUrl = null;
    _audioPlayer.stop();
  }
}
