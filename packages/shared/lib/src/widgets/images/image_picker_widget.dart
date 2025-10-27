import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';
import 'package:dotted_border/dotted_border.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({
    super.key,
    // required this.isMain,
    // required this.onMain,
    required this.onDelete,
    required this.image,
    this.onImageAdded,
    this.onPickImage,
  });

  // final bool isMain;
  // final VoidCallback onMain;
  final Function()? onPickImage;
  final Function(XFile image)? onImageAdded;
  final VoidCallback onDelete;
  final XFile? image;

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) onImageAdded?.call(image);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage ?? _pickImage,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 110,
          height: 144,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: image == null
                      ? SizedBox.shrink()
                      // ? Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(14),
                      //       color: context.ext.theme.backgroundDisabled,
                      //     ),
                      //   )
                      : Image.file(File(image!.path), fit: BoxFit.cover),
                ),
              ),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(14),
                  dashPattern: [3, 3],
                  color: context.ext.theme.iconsDefault,
                ),
                child: Center(
                  child: image != null
                      ? SizedBox.shrink()
                      : Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.ext.theme.accentLight,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: AppIcons.add.icon(context, size: 16),
                        ),
                ),
              ),
              if (image != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.ext.theme.accentLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AppIcons.close.icon(context, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// GestureDetector(
//   onTap: onMain,
//   child: Material(
//     color: Colors.transparent,
//     child: Row(
//       children: [
//         Checkbox(
//           value: isMain,
//           activeColor: context.ext.theme.accent,
//           onChanged: (_) => onMain(),
//           visualDensity: VisualDensity.compact,
//         ),
//         Expanded(child: AppText('Установить главным', style: AppTextStyles.bodySmall)),
//       ],
//     ),
//   ),
// ),
