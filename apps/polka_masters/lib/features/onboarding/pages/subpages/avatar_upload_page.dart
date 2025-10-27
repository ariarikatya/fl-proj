import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class AvatarUploadPage extends StatefulWidget {
  const AvatarUploadPage({super.key});

  @override
  State<AvatarUploadPage> createState() => _AvatarUploadPageState();
}

class _AvatarUploadPageState extends OnboardingPageState<AvatarUploadPage, OnboardingController, XFile> {
  late final avatar = useNotifier<XFile?>('avatar', null);

  @override
  List<Listenable> get dependencies => [avatar];

  @override
  XFile? validateContinue() => avatar.value;

  @override
  void complete(OnboardingController controller, XFile image) => controller.completeUploadAvatarPage(image);

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatar.value = image;
    }
  }

  @override
  List<Widget> content() => [
    AppText('Загрузи свое фото', style: AppTextStyles.headingLarge),
    SizedBox(height: 16),
    AppText(
      'Мы покажем его в твоей карточке, это поможет клиентам лучше узнать тебя',
      style: AppTextStyles.headingSmall.copyWith(color: context.ext.theme.textSecondary, fontWeight: FontWeight.w500),
    ),
    SizedBox(height: 40),
    Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: ValueListenableBuilder(
          valueListenable: avatar,
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AppIcons.blotBig.icon(context, size: 168, color: context.ext.theme.accent),
                AppAvatar(avatarUrl: '', size: 160, provider: value != null ? FileImage(File(value.path)) : null),
                if (value == null)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.ext.theme.accentLight,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: AppIcons.add.icon(context, size: 16),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  ];
}
