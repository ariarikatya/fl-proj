import 'package:flutter/material.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/features/auth/widgets/welcome_page.dart';
import 'package:polka_clients/features/onboarding/pages/onboarding_flow.dart';
import 'package:shared/shared.dart';

class AuthenticationScopeWidget extends StatelessWidget {
  const AuthenticationScopeWidget({required this.controller, required this.child, super.key});

  final AuthController<Client> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      child: child,
      builder: (context, value, child) {
        final navigator = switch (value) {
          AuthStateUnauthenticated() => const AppNavigator(initialPages: [MaterialPage(child: WelcomePage())]),
          AuthStateOnboarding state => AppNavigator(
            initialPages: [MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber))],
          ),
          AuthStateAuthenticated<Client> state => ValueListenableBuilder(
            valueListenable: state.user,
            builder: (_, user, __) => ClientScope(
              clientData: ClientData(
                phoneNumber: state.authResult.phoneNumber,
                tokens: state.authResult.tokens,
                client: user,
                onClientUpdate: (upd) => state.user.value = upd,
              ),
              child: child!,
            ),
          ),
        };

        return AuthenticationScope(controller: controller, child: navigator);
      },
    );
  }
}
