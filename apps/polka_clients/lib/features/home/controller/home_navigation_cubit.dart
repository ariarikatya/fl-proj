import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/widgets/bookings_page.dart';
import 'package:polka_clients/features/feed/widgets/home_feed_page.dart';
import 'package:polka_clients/features/map_search/widgets/map_search_page.dart';
import 'package:polka_clients/features/profile/widgets/profile_page.dart';

class HomeNavigationCubit extends Cubit<({int index, Object? data})> {
  HomeNavigationCubit() : super((index: 0, data: null));

  static const pages = [HomeFeedPage(), MapSearchPage(), BookingsPage(), ProfilePage()];

  void openByIndex(int index) => emit((index: index, data: null));
  void openHome() => emit((index: 0, data: null));
  void openMapSearch() => emit((index: 1, data: null));
  void openBookings() => emit((index: 2, data: null));
  void openProfile() => emit((index: 3, data: null));
}
