import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class AboutOnboardingPage extends StatefulWidget {
  const AboutOnboardingPage({super.key});

  @override
  State<AboutOnboardingPage> createState() => _AboutOnboardingPageState();
}

class _AboutOnboardingPageState extends OnboardingPageState<AboutOnboardingPage, OnboardingController, UserData> {
  late final _controllers = [for (var i = 0; i < 3; i++) useController('$i')];
  late final exp = useNotifier<String?>('exp', null);

  @override
  List<Listenable> get dependencies => [..._controllers, exp];

  @override
  UserData? validateContinue() {
    final nameParts = _controllers[0].text.trim().split(' ');
    final profession = _controllers[1].text.trim();
    final about = _controllers[2].text.trim();
    final experience = exp.value;

    if (nameParts.length != 2 || profession.isEmpty || about.isEmpty || experience == null) {
      return null;
    }
    final data = (
      name: nameParts.first,
      surname: nameParts.last,
      profession: profession,
      experience: experience,
      about: about,
    );
    return data;
  }

  @override
  void complete(OnboardingController controller, UserData data) => controller.completeAboutPage(data);

  @override
  List<Widget> content() => [
    AppText('Расскажи о себе', style: AppTextStyles.headingLarge),
    SizedBox(height: 24),
    AppTextFormField(labelText: 'Имя и Фамилия', controller: _controllers[0], validator: Validators.fullName),
    SizedBox(height: 16),
    AppTextFormField(labelText: 'Твоя профессия (Стилист по волосам)', controller: _controllers[1]),
    SizedBox(height: 16),
    AppText('Выбери свой стаж', style: AppTextStyles.headingSmall),
    SizedBox(height: 16),
    _ExperiencePicker(experience: exp),
    SizedBox(height: 24),
    AppText('Расскажи о себе и работе \nс клиентами', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
    AppTextFormField(
      hintText: 'Например, что любишь в своей \nработе, как проводишь встречи \nс клиентами',
      maxLines: 4,
      controller: _controllers[2],
    ),
  ];
}

class _ExperiencePicker extends StatelessWidget {
  const _ExperiencePicker({required this.experience});

  final ValueNotifier<String?> experience;

  static const _values = ['до 1 года', '1-3 года', '3-5 лет', 'от 5 лет'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: experience,
      builder: (context, value, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _values
              .map(
                (e) => AppChip(
                  enabled: value == e,
                  onTap: () => experience.value = e,
                  onClose: () => experience.value = null,
                  child: AppText(e),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
