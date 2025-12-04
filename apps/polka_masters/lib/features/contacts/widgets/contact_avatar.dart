import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar(this.contact, {super.key, this.size = 64, this.fontSize});

  final Contact contact;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    if (contact.avatarUrl != null) {
      return ImageClipped(width: size, height: size, borderRadius: size, imageUrl: contact.avatarUrl);
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.ext.colors.black[700], borderRadius: BorderRadius.circular(size)),
      child: AppText(
        contact.initials,
        style: AppTextStyles.headingLarge.copyWith(fontSize: fontSize, height: 1, color: context.ext.colors.white[100]),
      ),
    );
  }
}

class ContactBlotAvatar extends StatelessWidget {
  const ContactBlotAvatar({super.key, required this.contact, this.size = 160});
  final Contact contact;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppIcons.blotBig.icon(context, size: size + 8, color: context.ext.colors.pink[500]),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: context.ext.colors.white[300], width: 1),
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: ContactAvatar(contact, size: size, fontSize: size / 4),
        ),
      ],
    );
  }
}
