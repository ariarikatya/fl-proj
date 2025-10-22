import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:polka_clients/features/favorites/controller/favorites_cubit.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/search/controller/search_cubit.dart';
import 'package:shared/shared.dart';
import 'package:polka_clients/features/feed/controller/feed_cubit.dart';

class ClientBlocsProvider extends BlocsProvider {
  ClientBlocsProvider()
    : super(
        factories: {
          FeedCubit: (_) => FeedCubit(),
          CitySearchCubit: (_) => CitySearchCubit(Dependencies().dio),
          SearchCubit: (_) => SearchCubit(),
          HomeNavigationCubit: (_) => HomeNavigationCubit(),
          BookingsCubit: (_) => BookingsCubit(),
          FavoritesCubit: (_) => FavoritesCubit(),
          MapFeedCubit: (ctx) => MapFeedCubit(context: ctx, repo: Dependencies().mapRepo),
          MapMarkersPaginator: (ctx) => MapMarkersPaginator(context: ctx, repo: Dependencies().mapRepo),
          ChatsCubit: (ctx) => ChatsCubit(
            userId: ClientScope.of(ctx, listen: false).client.id,
            websockets: Dependencies().webSocketService,
            chatsRepo: Dependencies().chatsRepo,
            profileRepository: Dependencies().profileRepository,
          ),
        },
      );
}
