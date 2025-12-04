import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:shared/src/widgets/images/app_multi_image_provider.dart';

Future<Dialog?> showAppImageViewer(BuildContext context, List<String> images, {int initialIndex = 0}) async {
  final imageProvider = images.length == 1
      ? SingleImageProvider(CachedNetworkImageProvider(images.first))
      : AppMultiImageProvider([for (var url in images) CachedNetworkImageProvider(url)], initialIndex: initialIndex);

  return showImageViewerPager(
    context,
    imageProvider,
    immersive: false,
    useSafeArea: true,
    doubleTapZoomable: true,
    swipeDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    backgroundColor: Colors.transparent,
  );
}
