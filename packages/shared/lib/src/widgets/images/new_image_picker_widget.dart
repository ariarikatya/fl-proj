import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:dotted_border/dotted_border.dart';

class NewImagePickerWidget extends StatefulWidget {
  const NewImagePickerWidget({super.key, required this.onImageUpdate, required this.upload, this.initialImageUrl});

  final String? initialImageUrl;
  final Function(String? imageUrl) onImageUpdate;
  final PhotoUploadFunction upload;

  @override
  State<NewImagePickerWidget> createState() => _NewImagePickerWidgetState();
}

class _NewImagePickerWidgetState extends State<NewImagePickerWidget> with SingleImagePickerMixin {
  @override
  String? get initialImageUrl => widget.initialImageUrl;

  @override
  Function(String? imageUrl) get onImageUpdate => widget.onImageUpdate;

  @override
  PhotoUploadFunction get upload => widget.upload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 144,
      child: Stack(
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Material(
              color: context.ext.colors.white[200],
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(14),
                  dashPattern: [3, 3],
                  color: context.ext.colors.black[700],
                ),
                child: Center(
                  child: image != null
                      ? SizedBox.shrink()
                      : Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.ext.colors.pink[50],
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: AppIcons.add.icon(context, size: 16),
                        ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(borderRadius: BorderRadius.circular(14), child: image ?? SizedBox.shrink()),
          ),
          if (loading)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(color: context.ext.colors.pink[50].withValues(alpha: 0.5)),
                  child: Center(child: LoadingIndicator(constraints: BoxConstraints.tight(Size(24, 24)))),
                ),
              ),
            ),
          if (hasImage)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: deleteImage,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.ext.colors.pink[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppIcons.close.icon(context, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
