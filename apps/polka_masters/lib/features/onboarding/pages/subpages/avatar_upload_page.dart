import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class AvatarUploadPage extends StatefulWidget {
  const AvatarUploadPage({super.key});

  @override
  State<AvatarUploadPage> createState() => _AvatarUploadPageState();
}

class _AvatarUploadPageState extends OnboardingPageState<AvatarUploadPage, OnboardingController, String> {
  late final avatar = useNotifier<String?>('avatar', null);

  @override
  List<Listenable> get dependencies => [avatar];

  @override
  String? validateContinue() => avatar.value;

  @override
  void complete(OnboardingController controller, String image) => controller.completeUploadAvatarPage(image);

  @override
  List<Widget> content() => [
    AppText('Загрузи свое фото', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Людям проще выбрать мастера, когда они видят лицо за работой. Фото — это часть доверия',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 40),
    Center(child: _AvatarPickerWidget(onImageUpdate: (url) => avatar.value = url)),
  ];
}

class _AvatarPickerWidget extends StatefulWidget {
  const _AvatarPickerWidget({required this.onImageUpdate});

  final Function(String? imageUrl) onImageUpdate;

  @override
  State<_AvatarPickerWidget> createState() => __AvatarPickerWidgetState();
}

class __AvatarPickerWidgetState extends State<_AvatarPickerWidget> with SingleImagePickerMixin {
  @override
  String? get initialImageUrl => null;

  @override
  Function(String? imageUrl) get onImageUpdate => widget.onImageUpdate;

  @override
  PhotoUploadFunction get upload => Dependencies().profileRepository.uploadSinglePhoto;

  @override
  bool get canPickImage => !loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: SizedBox(
        height: 160,
        width: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppAvatar(avatarUrl: '', provider: imageProvider, size: 160),
            if (loading)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(color: context.ext.colors.pink[50].withValues(alpha: 0.5)),
                    child: Center(child: LoadingIndicator(constraints: BoxConstraints.tight(const Size(24, 24)))),
                  ),
                ),
              ),

            if (!hasImage && !loading)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: context.ext.colors.pink[50], borderRadius: BorderRadius.circular(40)),
                child: FIcons.plus.icon(context, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
