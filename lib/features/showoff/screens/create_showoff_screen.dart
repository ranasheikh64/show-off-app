import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_theme.dart';
import '../controllers/showoff_controller.dart';
import '../widgets/create_media_grid.dart';
import '../widgets/create_upload_progress.dart';
import '../services/music_service.dart';
import '../widgets/music_search_bottom_sheet.dart';

class CreateShowOffScreen extends StatefulWidget {
  const CreateShowOffScreen({super.key});

  @override
  State<CreateShowOffScreen> createState() => _CreateShowOffScreenState();
}

class _CreateShowOffScreenState extends State<CreateShowOffScreen> {
  final _ctrl = Get.find<ShowOffController>();
  final _picker = ImagePicker();
  final List<File> _images = [];
  bool _isPicking = false;
  MusicModel? _selectedMusic;

  Future<void> _pickImages() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picked = await _picker.pickMultiImage(); // Pick without compression first
      if (picked.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        
        for (var x in picked) {
          final originalFile = File(x.path);
          final originalBytes = await originalFile.length();
          final originalKb = originalBytes / 1024;
          
          final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_comp.jpg';
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            x.path,
            targetPath,
            quality: 50,
          );
          
          if (compressedFile != null) {
            final compressedBytes = await File(compressedFile.path).length();
            final compressedKb = compressedBytes / 1024;
            debugPrint('=== ORIGINAL SIZE: ${originalKb.toStringAsFixed(2)} KB | COMPRESSED SIZE: ${compressedKb.toStringAsFixed(2)} KB ===');
            setState(() => _images.add(File(compressedFile.path)));
          } else {
            setState(() => _images.add(originalFile));
          }
        }
      }
    } finally {
      _isPicking = false;
    }
  }

  void _remove(int i) => setState(() => _images.removeAt(i));

  Future<void> _post() async {
    if (_images.isEmpty) {
      _showSnack('Please select at least one photo ✨', isError: true);
      return;
    }
    final ok = await _ctrl.createPost(
      _images.map((e) => e.path).toList(),
      musicUrl: _selectedMusic?.previewUrl,
      musicTitle: _selectedMusic?.title,
      musicArtist: _selectedMusic?.artist,
    );
    if (!mounted) return;
    if (ok) {
      _showSnack('Posted successfully! 🎉');
      Navigator.pop(context);
    } else {
      _showSnack('Failed to post. Try again.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16182B),
      body: Obx(() {
        if (_ctrl.isUploading.value) {
          return CreateUploadProgress(progress: _ctrl.uploadProgress.value);
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildHint()),
            SliverToBoxAdapter(child: _buildMusicSelector()),
            SliverFillRemaining(
              child: CreateMediaGrid(
                images: _images,
                onAddTap: _pickImages,
                onRemove: _remove,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF16182B),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: GestureDetector(
              onTap: _ctrl.isUploading.value ? null : _post,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4D8D), AppTheme.primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'POST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          colors: [Color(0xFFFF4D8D), AppTheme.primaryBlue],
        ).createShader(r),
        child: Text(
          'Create Post',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16.sp, color: Colors.white70),
          SizedBox(width: 6.w),
          Text(
            'First photo will be your cover · Tap + to add more',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => MusicSearchBottomSheet(
              onMusicSelected: (music) {
                setState(() => _selectedMusic = music);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.music_note_rounded, color: AppTheme.primaryBlue, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMusic != null ? _selectedMusic!.title : 'Add Music',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedMusic != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        _selectedMusic!.artist,
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              if (_selectedMusic != null)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white70, size: 20.sp),
                  onPressed: () {
                    setState(() => _selectedMusic = null);
                  },
                )
              else
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
