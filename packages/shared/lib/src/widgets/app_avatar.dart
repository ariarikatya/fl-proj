import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

const _defaultSize = 40.0;

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.avatarUrl,
    this.size,
    this.borderColor,
    this.provider,
    this.shadow = true,
  });

  final String? avatarUrl;
  final ImageProvider? provider;

  final double? size;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? _defaultSize,
      width: size ?? _defaultSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? context.ext.theme.backgroundHover,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          if (shadow)
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 1),
              color: Colors.black.withValues(alpha: 0.1),
            ),
        ],
        color: avatarUrl != null && avatarUrl!.isNotEmpty
            ? null
            : context.ext.theme.backgroundHover,
        image: provider != null
            ? DecorationImage(image: provider!, fit: BoxFit.cover)
            : avatarUrl != null && avatarUrl!.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }
}
