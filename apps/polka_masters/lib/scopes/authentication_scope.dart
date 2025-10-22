import 'package:flutter/material.dart';
import 'package:polka_masters/features/auth/pages/welcome_page.dart';
import 'package:polka_masters/features/onboarding/pages/onboarding_flow.dart';
import 'package:polka_masters/scopes/master_scope.dart';
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
          AuthStateUnauthenticated() => defaultNavigator([MaterialPage(child: WelcomePage())]),
          AuthStateOnboarding state => defaultNavigator([
            MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber)),
          ]),
          AuthStateAuthenticated<Master> state => ValueListenableBuilder(
            valueListenable: state.user,
            builder: (_, user, __) => MasterScope(
              masterData: MasterData(
                phoneNumber: state.authResult.phoneNumber,
                tokens: state.authResult.tokens,
                master: user,
                onMasterUpdate: (upd) => state.user.value = upd,
                schedule: _mockSchedule(),
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

Schedule _mockSchedule() => Schedule(
  periodStart: DateTime.now(),
  periodEnd: DateTime.now().add(Duration(days: 30)),
  days: {
    WeekDays.monday: ScheduleDay(start: Duration(hours: 9), end: Duration(hours: 17), active: true),
    WeekDays.tuesday: ScheduleDay(start: Duration(hours: 10), end: Duration(hours: 18), active: true),
    WeekDays.wednesday: ScheduleDay(start: Duration(hours: 11), end: Duration(hours: 19, minutes: 30), active: true),
    WeekDays.thursday: ScheduleDay(start: Duration(hours: 10), end: Duration(hours: 18), active: true),
    WeekDays.friday: ScheduleDay(start: Duration(hours: 12), end: Duration(hours: 20, minutes: 30), active: true),
    WeekDays.saturday: ScheduleDay(start: Duration(hours: 12), end: Duration(hours: 15, minutes: 30), active: true),
  },
);
