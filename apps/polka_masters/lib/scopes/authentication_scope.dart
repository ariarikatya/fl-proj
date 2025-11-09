import 'package:flutter/material.dart';
import 'package:polka_masters/features/auth/pages/welcome_page.dart';
import 'package:polka_masters/features/onboarding/pages/onboarding_flow.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

Navigator defaultNavigator(List<Page> pages) =>
    Navigator(pages: pages, onDidRemovePage: (page) => logger.info('page removed: ${page.runtimeType}'));

class AuthenticationScopeWidget extends StatelessWidget {
  const AuthenticationScopeWidget({required this.controller, required this.child, super.key});

  final AuthController<Master> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      child: child,
      builder: (context, value, child) {
        final navigator = switch (value) {
          AuthStateUnauthenticated() => defaultNavigator([const MaterialPage(child: WelcomePage())]),
          AuthStateOnboarding state => defaultNavigator([
            MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber)),
          ]),
          AuthStateAuthenticated<Master> state => ChangeNotifierProvider<MasterScope>(
            create: (context) => MasterScope(
              master: state.user.value,
              phoneNumber: state.authResult.phoneNumber,
              schedule: _mockSchedule(), // TODO: How can we load it...
            ),
            child: child!,
          ),
        };

        return AuthenticationScope(controller: controller, child: navigator);
      },
    );
  }
}

Schedule _mockSchedule() => Schedule(
  periodStart: DateTime.now(),
  periodEnd: DateTime.now().add(const Duration(days: 30)),
  days: {
    WeekDays.monday: const ScheduleDay(start: Duration(hours: 9), end: Duration(hours: 17), active: true),
    WeekDays.tuesday: const ScheduleDay(start: Duration(hours: 10), end: Duration(hours: 18), active: true),
    WeekDays.wednesday: const ScheduleDay(
      start: Duration(hours: 11),
      end: Duration(hours: 19, minutes: 30),
      active: true,
    ),
    WeekDays.thursday: const ScheduleDay(start: Duration(hours: 10), end: Duration(hours: 18), active: true),
    WeekDays.friday: const ScheduleDay(start: Duration(hours: 12), end: Duration(hours: 20, minutes: 30), active: true),
    WeekDays.saturday: const ScheduleDay(
      start: Duration(hours: 12),
      end: Duration(hours: 15, minutes: 30),
      active: true,
    ),
  },
);
