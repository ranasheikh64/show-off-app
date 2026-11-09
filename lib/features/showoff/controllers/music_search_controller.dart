import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';
import 'feed_audio_controller.dart';

class MusicSearchController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  StreamSubscription<PlayerState>? _playerSub;
  Timer? _debounce;

  final RxList<MusicModel> searchResults = <MusicModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString currentUrl = ''.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;

  String _query = '';
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<FeedAudioController>()) {
      Get.find<FeedAudioController>().pauseMusic();
    }
    scrollController.addListener(_onScroll);
    search();
    _playerSub = audioPlayer.playerStateStream.listen((s) {
      isPlaying.value = s.playing && s.processingState != ProcessingState.completed;
      isBuffering.value = s.processingState == ProcessingState.buffering ||
          s.processingState == ProcessingState.loading;
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    _playerSub?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value && !isLoadingMore.value && hasMore.value) {
      loadMore();
    }
  }

  void onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => search(q));
  }

  Future<void> search([String? q]) async {
    _page = 1;
    hasMore.value = true;
    _query = q ?? '';
    isLoading.value = true;
    final res = await MusicService.searchMusic(query: _query, page: _page);
    searchResults.assignAll(res);
    isLoading.value = false;
    hasMore.value = res.length >= 20;
  }

  Future<void> loadMore() async {
    isLoadingMore.value = true;
    final next = _page + 1;
    final res = await MusicService.searchMusic(query: _query, page: next);
    _page = next;
    searchResults.addAll(res);
    isLoadingMore.value = false;
    hasMore.value = res.isNotEmpty;
  }

  Future<void> togglePlay(String url) async {
    try {
      if (currentUrl.value == url && isPlaying.value) {
        await audioPlayer.pause();
      } else {
        currentUrl.value = url;
        await audioPlayer.setUrl(url);
        audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    audioPlayer.stop();
    search();
  }
}
