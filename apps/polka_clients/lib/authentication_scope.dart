import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/auth/widgets/welcome_page.dart';
import 'package:polka_clients/features/booking/controller/completed_bookings_cubit.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:polka_clients/features/booking/controller/pending_bookings_cubit.dart';
import 'package:polka_clients/features/booking/controller/upcoming_bookings_cubit.dart';
import 'package:polka_clients/features/favorites/controller/favorites_cubit.dart';
import 'package:polka_clients/features/feed/controller/feed_cubit.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/onboarding/pages/onboarding_flow.dart';
import 'package:polka_clients/features/search/controller/feed_search_cubit.dart';
import 'package:provider/provider.dart';
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
          AuthStateUnauthenticated() => const AppNavigator(
            key: ValueKey('auth'),
            initialPages: [MaterialPage(child: WelcomePage())],
          ),
          AuthStateOnboarding state => AppNavigator(
            key: const ValueKey('onboarding'),
            initialPages: [MaterialPage(child: OnboardingFlow(phoneNumber: state.authResult.phoneNumber))],
          ),
          AuthStateAuthenticated<Client> state => MultiBlocProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ClientViewModel(phoneNumber: state.authResult.phoneNumber, client: state.user.value),
              ),
              BlocProvider(create: (_) => FeedCubit(Dependencies().clientRepository), lazy: false),
              BlocProvider<CitySearchCubit>(create: (_) => CitySearchCubit(Dependencies().dio)),
              BlocProvider<FeedSearchCubit>(create: (_) => FeedSearchCubit()),
              BlocProvider<HomeNavigationCubit>(create: (_) => HomeNavigationCubit()),
              BlocProvider<OldBookingsCubit>(create: (_) => OldBookingsCubit()),
              BlocProvider<PendingBookingsCubit>(
                create: (_) => PendingBookingsCubit(
                  repo: Dependencies().bookingsRepo,
                  websockets: Dependencies().webSocketService,
                ),
                lazy: false,
              ),
              BlocProvider<UpcomingBookingsCubit>(
                create: (_) => UpcomingBookingsCubit(
                  repo: Dependencies().bookingsRepo,
                  websockets: Dependencies().webSocketService,
                ),
                lazy: false,
              ),
              BlocProvider<CompletedBookingsCubit>(
                create: (_) => CompletedBookingsCubit(
                  repo: Dependencies().bookingsRepo,
                  websockets: Dependencies().webSocketService,
                ),
                lazy: false,
              ),
              BlocProvider<FavoritesCubit>(create: (_) => FavoritesCubit(), lazy: false),
              BlocProvider<MapFeedCubit>(
                create: (ctx) => MapFeedCubit(context: ctx, repo: Dependencies().mapRepo),
              ),
              BlocProvider<MapMarkersPaginator>(
                create: (ctx) => MapMarkersPaginator(context: ctx, repo: Dependencies().mapRepo),
              ),
              BlocProvider<ChatsCubit>(
                create: (ctx) => ChatsCubit(
                  userId: state.user.value.id,
                  websockets: Dependencies().webSocketService,
                  chatsRepo: Dependencies().chatsRepo,
                  profileRepository: Dependencies().profileRepository,
                ),
                lazy: false,
              ),
            ],
            child: child!,
          ),
        };

        return AuthenticationScope(controller: controller, child: navigator);
      },
    );
  }
}
