import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/music_search_controller.dart';
import '../services/music_service.dart';
import 'music_search_header.dart';
import 'music_search_results_list.dart';

class MusicSearchBottomSheet extends StatelessWidget {
  final Function(MusicModel) onMusicSelected;

  const MusicSearchBottomSheet({super.key, required this.onMusicSelected});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MusicSearchController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF16182B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
      ),
      child: Column(
        children: [
          MusicSearchHeader(
            controller: c.searchController,
            onSubmitted: c.search,
            onChanged: c.onQueryChanged,
            onClear: c.clearSearch,
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Obx(
              () => MusicSearchResultsList(
                results: c.searchResults,
                isLoading: c.isLoading.value,
                isLoadingMore: c.isLoadingMore.value,
                scrollController: c.scrollController,
                currentUrl: c.currentUrl.value,
                isPlaying: c.isPlaying.value,
                isBuffering: c.isBuffering.value,
                onPlayToggle: c.togglePlay,
                onSelect: (m) {
                  c.audioPlayer.stop();
                  onMusicSelected(m);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
