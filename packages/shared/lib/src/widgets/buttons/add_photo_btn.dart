import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/widgets/app_text.dart';

class AddPhotoBtn extends StatelessWidget {
  const AddPhotoBtn({super.key, required this.onImagePicked});

  final void Function(XFile xfile) onImagePicked;

  Future<void> changePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logger.info('Image picked: ${image.path}, size: ${await image.length() ~/ 1024} KB');
      onImagePicked(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changePhoto(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(color: context.ext.theme.backgroundHover, borderRadius: BorderRadius.circular(16)),
        child: Row(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcons.camera.icon(context, size: 16),
            AppText('Добавить', style: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
