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
    AppText('Расскажи о себе', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Это поможет клиентам лучше понять, что ты — специалист, которому можно доверять',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 16),
    AppTextFormField(labelText: 'Имя и Фамилия', controller: _controllers[0], validator: Validators.fullName),
    const SizedBox(height: 16),
    AppTextFormField(labelText: 'Твоя профессия (Стилист по волосам)', controller: _controllers[1]),
    const SizedBox(height: 24),
    AppText('Выбери свой стаж', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    ExperiencePicker(experience: exp),
    const SizedBox(height: 24),
    AppText('Расскажи о своей работе', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppTextFormField(
      hintText: 'Например, что любишь в своей работе и как проводишь встречи с клиентами',
      maxLines: 4,
      controller: _controllers[2],
    ),
  ];
}
