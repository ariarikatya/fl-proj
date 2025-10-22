import 'package:flutter/material.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/features/auth/widgets/welcome_page.dart';
import 'package:polka_clients/features/onboarding/pages/onboarding_flow.dart';
import 'package:shared/shared.dart';

Navigator defaultNavigator(List<Page> pages) =>
    Navigator(pages: pages, onDidRemovePage: (page) => logger.info('page removed: ${page.runtimeType}'));

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
          AuthStateUnauthenticated() => defaultNavigator([MaterialPage(child: WelcomePage())]),
          AuthStateOnboarding state => defaultNavigator([
            MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber)),
          ]),
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
