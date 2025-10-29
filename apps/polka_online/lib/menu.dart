import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ext.theme.backgroundDefault,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Steps list
              Text('Шаг 1', style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text('Выберите услугу', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 32),
              Text('Шаг 2', style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text('Выберите дату и время', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 32),
              Text('Шаг 3', style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text('Заполните личные данные', style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
