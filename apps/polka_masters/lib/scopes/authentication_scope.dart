import 'package:calendar_view/calendar_view.dart' hide WeekDays;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/auth/pages/welcome_page.dart';
import 'package:polka_masters/features/calendar/controllers/events_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_groups_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/features/onboarding/pages/onboarding_flow.dart';
import 'package:polka_masters/features/profile/controller/services_cubit.dart';
import 'package:polka_masters/features/online_booking/controller/online_booking_cubit.dart';
import 'package:polka_masters/features/schedules/controller/schedules_cubit.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:polka_masters/scopes/master_model.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

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
        final dependencies = Dependencies();
        final eventController = EventController<Booking>();

        final navigator = switch (value) {
          AuthStateUnauthenticated() => const AppNavigator(
            key: ValueKey('auth'),
            initialPages: [MaterialPage(child: WelcomePage())],
          ),
          AuthStateOnboarding state => AppNavigator(
            key: const ValueKey('onboarding'),
            initialPages: [MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber))],
          ),
          AuthStateAuthenticated<Master> state => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => CalendarScope(eventController: eventController)),
              ChangeNotifierProvider<MasterModel>(
                create: (_) => MasterModel(master: state.user.value, phoneNumber: state.authResult.phoneNumber),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ContactSearchCubit(dependencies.contactsRepo)),
                BlocProvider(
                  create: (_) => ChatsCubit(
                    websockets: dependencies.webSocketService,
                    chatsRepo: dependencies.chatsRepo,
                    profileRepository: dependencies.profileRepository,
                    userId: state.user.value.id,
                  ),
                ),
                BlocProvider(
                  create: (ctx) => EventsCubit(
                    context: ctx,
                    repo: dependencies.bookingsRepository,
                    websockets: dependencies.webSocketService,
                    controller: eventController,
                  ),
                ),
                BlocProvider(create: (_) => SchedulesCubit(Dependencies().schedulesRepo)),
                BlocProvider(create: (_) => OnlineBookingCubit(Dependencies().onlineBookingRepo)),
                BlocProvider(
                  create: (_) => ContactGroupsCubit(dependencies.contactsRepo, dependencies.webSocketService),
                ),
                BlocProvider(
                  create: (_) => PendingBookingsCubit(dependencies.bookingsRepository, dependencies.webSocketService),
                ),
                BlocProvider(create: (_) => ServicesCubit(repo: dependencies.masterRepository)),
              ],
              child: CalendarControllerProvider(controller: eventController, child: child!),
            ),
          ),
        };

        return AuthenticationScope(controller: controller, child: navigator);
      },
    );
  }
}
