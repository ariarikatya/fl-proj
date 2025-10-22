import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/widgets/images/image_loading_progress_indicator.dart';

class ImageScroll extends StatelessWidget {
  const ImageScroll({super.key, required this.imageUrls, this.padding = const EdgeInsets.symmetric(horizontal: 24)});

  final List<String> imageUrls;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          spacing: 8,
          children: [
            for (int i = 0; i < imageUrls.length; i++)
              CachedNetworkImage(
                imageUrl: imageUrls[i],
                width: 168,
                height: 224,
                memCacheHeight: (224 * MediaQuery.of(context).devicePixelRatio).toInt(),
                errorWidget: (context, url, error) => ColoredBox(color: AppColors.backgroundHover),
                progressIndicatorBuilder: imageLoadingProgressIndicator,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  width: 168,
                  height: 224,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundHover,
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
