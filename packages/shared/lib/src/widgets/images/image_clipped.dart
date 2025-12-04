import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/images/image_loading_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageClipped extends StatelessWidget {
  const ImageClipped({super.key, required this.imageUrl, this.width, this.height, this.borderRadius = 24});

  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final defaultColor = context.ext.colors.white[300];
    final cacheHeight = height == null ? null : (height! * MediaQuery.of(context).devicePixelRatio).toInt();
    // final cacheHeight = height == null ? null : height!.toInt();

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                memCacheHeight: cacheHeight, // We only use memCacheHeight because we want to keep the aspect ratio \
                // Also, it is cropped using the [ResizeImage] so it's ok
                width: width,
                height: height,
                errorWidget: (context, url, error) => ColoredBox(color: defaultColor),
                fit: BoxFit.cover,
                progressIndicatorBuilder: imageLoadingProgressIndicator,
              )
            : ColoredBox(color: defaultColor),
      ),
    );
  }
}
