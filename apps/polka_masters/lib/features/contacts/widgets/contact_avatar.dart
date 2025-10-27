import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar(this.avatarUrl, {super.key});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      border: Border.all(color: context.ext.theme.borderStrong),
      shape: BoxShape.circle,
    ),
    child: ImageClipped(width: 48, height: 48, borderRadius: 48, imageUrl: avatarUrl),
  );
}
