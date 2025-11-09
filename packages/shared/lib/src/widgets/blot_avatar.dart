import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
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
        AppIcons.blotBigAlt.icon(context, size: size * 1.1, color: context.ext.theme.accentLight),
        AppAvatar(avatarUrl: avatarUrl, size: size),
      ],
    );
  }
}
