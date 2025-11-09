import 'package:flutter/material.dart';
import 'package:polka_clients/features/onboarding/pages/controller.dart';
import 'package:shared/shared.dart';

class OnboardingPage$About extends StatefulWidget {
  const OnboardingPage$About({super.key});

  @override
  State<OnboardingPage$About> createState() => _OnboardingPage$AboutState();
}

class _OnboardingPage$AboutState extends OnboardingPageState<OnboardingPage$About, OnboardingController, UserData> {
  late final name = useController('name');
  late final city = useController('city');

  @override
  void complete(controller, data) => controller.completeAboutPage(data);

  @override
  List<Listenable> get dependencies => [name, city];

  @override
  UserData? validateContinue() {
    final parts = name.text.trim().split(' ');
    if (parts.length != 2) return null;
    final $name = parts.first;
    final $lastName = parts.last;

    final $city = city.text.trim();
    if ($name.isEmpty || $city.isEmpty) return null;
    return (firstName: $name, lastName: $lastName, city: $city);
  }

  Future<void> _pickCity() async {
    final $city = await context.ext.push<City>(CityPage(initialCity: city.text));
    if ($city != null && mounted) {
      city.text = $city.name;
    }
  }

  @override
  List<Widget> content() => [
    const AppText('Расскажи о себе', style: AppTextStyles.headingLarge),
    const SizedBox(height: 24),
    AppTextFormField(labelText: 'Имя Фамилия', controller: name, validator: Validators.fullName),
    const SizedBox(height: 16),
    GestureOverrideWidget(
      onTap: _pickCity,
      child: AppTextFormField(labelText: 'Твой город', controller: city, readOnly: true),
    ),
  ];
}
