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
    final future = controller.completePortfolioPage(data);
    LoadingOverlay.load(context, future, message: 'Создаем твой профиль');
  }

  @override
  List<Widget> content() => [
    AppText('Загрузи свои лучшие работы', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Мы покажем их клиентам в твоей карточке в приложении POLKA',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 16),
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
    const SizedBox(height: 16),
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
        const Spacer(),
      ],
    ),
  ];
}
