import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/features/support/widgets/support_screen.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_link_button.dart';

class SupportButton extends StatelessWidget {
  const SupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLinkButton(
      text: 'Нужна помощь? (Чат поддержки)',
      onTap: () async {
        final udid = await flutterUdid;
        context.ext.push(SupportScreen(name: 'Пользователь POLKA', email: 'user-${udid}@polka.com'));
      },
    );
  }
}
