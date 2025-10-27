import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/loading/loading_indicator.dart';

Widget imageLoadingProgressIndicator(BuildContext context, String url, DownloadProgress progress) => ColoredBox(
  color: context.ext.theme.backgroundHover.withValues(alpha: 0.5),
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (progress.progress != null)
          LoadingIndicator(constraints: BoxConstraints.tight(const Size(24, 24)), value: progress.progress),
        if (devMode && progress.totalSize != null)
          AppText(
            '${(progress.progress! * 100).toStringAsFixed(0)}%\n${(progress.totalSize! / 1024 / 1024).toStringAsFixed(1)} MB',
            style: AppTextStyles.bodySmall,
          ),
      ],
    ),
  ),
);
