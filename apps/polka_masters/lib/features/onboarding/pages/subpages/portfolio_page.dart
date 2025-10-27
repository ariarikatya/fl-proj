import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends OnboardingPageState<PortfolioPage, OnboardingController, PortfolioData?> {
  late final images = List.generate(5, (i) => useNotifier<XFile?>('$i', null));

  @override
  List<Listenable> get dependencies => images;

  @override
  String? get continueLabel => 'Создать профиль';

  @override
  PortfolioData? validateContinue() {
    if (images.every((i) => i.value == null)) return null;
    return images.map((n) => n.value?.path).nonNulls.toList();
  }

  @override
  void complete(OnboardingController controller, PortfolioData? data) {
    controller.completePortfolioPage(data);
    // TODO: show loader
  }

  @override
  List<Widget> content() => [
    AppText('Загрузи фото своих лучших работ', style: AppTextStyles.headingLarge),
    SizedBox(height: 16),
    AppText(
      'Мы покажем их клиентам в твоей карточке',
      style: AppTextStyles.headingSmall.copyWith(color: context.ext.theme.textSecondary, fontWeight: FontWeight.w500),
    ),
    SizedBox(height: 16),
    Row(
      spacing: 8,
      children: [
        for (var image in images.take(3))
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: image,
              builder: (context, value, child) {
                return ImagePickerWidget(
                  onImageAdded: (image0) => image.value = image0,
                  onDelete: () => image.value = null,
                  image: value,
                );
              },
            ),
          ),
      ],
    ),
    SizedBox(height: 16),
    Row(
      spacing: 8,
      children: [
        for (var image in images.skip(3).take(2))
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: image,
              builder: (context, value, child) {
                return ImagePickerWidget(
                  onImageAdded: (image0) => image.value = image0,
                  onDelete: () => image.value = null,
                  image: value,
                );
              },
            ),
          ),
        Spacer(),
      ],
    ),
  ];
}
