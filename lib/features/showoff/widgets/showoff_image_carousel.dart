import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/image_preview_screen.dart';

class ShowOffImageCarousel extends StatefulWidget {
  final List<String> images;
  final Widget overlay;

  const ShowOffImageCarousel({
    super.key,
    required this.images,
    required this.overlay,
  });

  @override
  State<ShowOffImageCarousel> createState() => _ShowOffImageCarouselState();
}

class _ShowOffImageCarouselState extends State<ShowOffImageCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;
    return SizedBox(
      height: 460.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: count,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      images: widget.images,
                      initialIndex: i,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'imagePreview_${widget.images[i]}',
                child: CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  memCacheWidth: 720,
                  maxWidthDiskCache: 1080,
                  filterQuality: FilterQuality.low,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF16182B),
                    child: const Center(
                      child: Icon(Icons.photo_rounded, color: Colors.white24, size: 36),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF16182B),
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x22000000),
                    Color(0x99000000),
                    Color(0xEA000000),
                  ],
                  stops: [0.0, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          if (count > 1) ...[
            Positioned(top: 14.h, right: 14.w, child: _counter(count)),
            Positioned(bottom: 10.h, left: 0, right: 0, child: _dots(count)),
          ],
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: count > 1 ? 30.h : 16.h,
            child: widget.overlay,
          ),
        ],
      ),
    );
  }

  Widget _counter(int count) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      '${_current + 1}/$count',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _dots(int count) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      count,
      (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        width: i == _current ? 18.w : 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: i == _current ? Colors.white : Colors.white54,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
    ),
  );
}
