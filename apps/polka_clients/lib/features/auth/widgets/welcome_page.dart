import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      safeAreaBuilder: (child) => SafeArea(top: false, child: child),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                height: constraints.maxHeight - 200,
                child: Image.asset('assets/images/client_onboarding.png', fit: BoxFit.cover),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 380,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, .3],
                      colors: [
                        context.ext.colors.white[100].withValues(alpha: 0.0), // no blur
                        context.ext.colors.white[100].withValues(alpha: 1.0), // no blur
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 24,
                left: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      'Твой личный\nбьюти-гид',
                      style: context.ext.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      'Здесь мастера, которым можно доверять, и пространство, где всё о красоте — удобно, спокойно и по-настоящему про тебя.',
                      style: context.ext.textTheme.bodyLarge?.copyWith(color: context.ext.colors.black[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 56),
                    AppTextButton.large(
                      text: 'Познакомиться с POLKA',
                      onTap: () async {
                        final deps = Dependencies();
                        context.ext.push(
                          AuthFlow<Client>(
                            sendCode: (phone) => deps.authRepository.sendCode(phone),
                            verifyCode: (phone, code) => deps.authRepository.verifyCode<Client>(phone, code, deps.udid),
                            onSuccess: (result) => AuthenticationScope.of(context).setAuth(result),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AppLinkButton(
                      text: 'Я мастер',
                      style: context.ext.textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      underlineThickness: 1.0,
                      onTap: () => launchUrl(Uri.parse(AppLinks.stores.fromCurrentPlatform().masters)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
