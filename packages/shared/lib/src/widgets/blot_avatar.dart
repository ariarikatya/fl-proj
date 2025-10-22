import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_avatar.dart';

class BlotAvatar extends StatelessWidget {
  const BlotAvatar({super.key, required this.avatarUrl, this.size = 68});

  final String avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppIcons.blotBig.icon(size: size * 1.1, color: AppColors.accent),
        AppAvatar(avatarUrl: avatarUrl, size: size),
      ],
    );
  }
}
