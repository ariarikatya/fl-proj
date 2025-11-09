import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';
import 'package:dotted_border/dotted_border.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({
    super.key,
    required this.onDelete,
    required this.image,
    this.imagePLaceholderUrl,
    this.onPlaceholderDelete,
    this.onImageAdded,
    this.onPickImage,
  }) : assert(
         (imagePLaceholderUrl == onPlaceholderDelete) || (imagePLaceholderUrl != null && onPlaceholderDelete != null),
         'You should provide either both imagePlaceholderUrl and onPlaceholderDelete or none of them',
       );

  final Function()? onPickImage;
  final Function(XFile image)? onImageAdded;
  final VoidCallback onDelete;
  final VoidCallback? onPlaceholderDelete;
  final XFile? image;
  final String? imagePLaceholderUrl;

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) onImageAdded?.call(image);
  }

  @override
  Widget build(BuildContext context) {
    Widget? picture;
    if (imagePLaceholderUrl != null) {
      picture = CachedNetworkImage(imageUrl: imagePLaceholderUrl!, fit: BoxFit.cover);
    } else if (image != null) {
      picture = Image.file(File(image!.path), fit: BoxFit.cover);
    }

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
                child: ClipRRect(borderRadius: BorderRadius.circular(14), child: picture ?? SizedBox.shrink()),
              ),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(14),
                  dashPattern: [3, 3],
                  color: context.ext.theme.iconsDefault,
                ),
                child: Center(
                  child: picture != null
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
              if (picture != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: imagePLaceholderUrl != null ? onPlaceholderDelete : onDelete,
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
