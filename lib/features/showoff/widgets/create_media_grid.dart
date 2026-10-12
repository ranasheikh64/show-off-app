import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'create_media_tile.dart';

class CreateMediaGrid extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddTap;
  final void Function(int) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const CreateMediaGrid({
    super.key,
    required this.images,
    required this.onAddTap,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 40.w - 20.w) / 3;
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemCount: images.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return AddMediaTile(onTap: onAddTap);
            final imgIndex = index - 1;
            return _buildDraggableTile(imgIndex, itemWidth);
          },
        );
      },
    );
  }

  Widget _buildDraggableTile(int index, double size) {
    final file = images[index];
    final isFirst = index == 0;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorder(details.data, index),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: size,
              height: size,
              child: Transform.scale(
                scale: 1.08,
                child: Opacity(
                  opacity: 0.92,
                  child: MediaImageTile(file: file, isFirst: isFirst, onRemove: () {}),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: MediaImageTile(file: file, isFirst: isFirst, onRemove: () => onRemove(index)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: isHovered ? Border.all(color: const Color(0xFFFF4D8D), width: 2.5) : null,
            ),
            child: MediaImageTile(file: file, isFirst: isFirst, onRemove: () => onRemove(index)),
          ),
        );
      },
    );
  }
}
