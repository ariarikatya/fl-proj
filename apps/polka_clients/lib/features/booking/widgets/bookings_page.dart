import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/controller/completed_bookings_cubit.dart';
import 'package:polka_clients/features/booking/controller/pending_bookings_cubit.dart';
import 'package:polka_clients/features/booking/controller/upcoming_bookings_cubit.dart';
import 'package:polka_clients/features/booking/widgets/empty_booking_view.dart';
import 'package:polka_clients/features/booking/widgets/booking_card.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:shared/shared.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with TickerProviderStateMixin {
  late final _controller = TabController(length: 3, vsync: this);
  bool _opened = false;

  void _openTabbar(int index) {
    _opened = true;
    _controller.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твои посещения'),
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Column(
        children: [
          AppTabBar(
            tabs: [
              const Tab(text: 'Ждут подтверждения'),
              const Tab(text: 'Предстоящие'),
              const Tab(text: 'Прошедшие'),
            ],
            controller: _controller,
          ),
          Expanded(
            child: BlocConsumer<OldBookingsCubit, BookingsState>(
              listener: (context, state) {
                if (context.read<OldBookingsCubit>().newBookingId != null) {
                  // Opens pending tabbar to see new booking
                  // TODO: Scroll to new booking
                  _openTabbar(0);
                } else if (state.upcoming != null && state.upcoming!.isNotEmpty && !_opened) {
                  // Opens tabbar on upcoming if not empty
                  _openTabbar(1);
                }
              },
              builder: (context, state) {
                return TabBarView(
                  controller: _controller,
                  children: [
                    PaginationBuilder<PendingBookingsCubit, Booking>(
                      emptyBuilder: (_) => EmptyBookingView(action: context.read<HomeNavigationCubit>().openHome),
                      itemBuilder: (_, __, item) => BookingCard(booking: item),
                    ),
                    PaginationBuilder<UpcomingBookingsCubit, Booking>(
                      emptyBuilder: (_) => EmptyBookingView(action: context.read<HomeNavigationCubit>().openHome),
                      itemBuilder: (_, __, item) => BookingCard(booking: item),
                    ),
                    PaginationBuilder<CompletedBookingsCubit, Booking>(
                      emptyBuilder: (_) => EmptyBookingView(action: context.read<HomeNavigationCubit>().openHome),
                      itemBuilder: (_, __, item) => BookingCard(booking: item),
                    ),
                    // _buildBookingsView(state.pending),
                    // _buildBookingsView(state.upcoming),
                    // _buildBookingsView(state.completed),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsView(Map<int, Booking>? bookings) => switch (bookings?.length) {
    null => const Center(child: LoadingIndicator()),
    > 0 => _BookingsView(bookings!, newBookingId: context.read<OldBookingsCubit>().newBookingId),
    _ => EmptyBookingView(action: context.read<HomeNavigationCubit>().openHome),
  };
}

class _BookingsView extends StatefulWidget {
  const _BookingsView(this.bookings, {this.newBookingId});

  final Map<int, Booking> bookings;
  final int? newBookingId;

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  final _controller = ScrollController();
  late Map<int, GlobalObjectKey> _keys = {};

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(_BookingsView oldWidget) {
    if (widget.newBookingId != oldWidget.newBookingId && widget.newBookingId != null) {
      _scrollToItem(widget.newBookingId!);
    }
    _updateKeys();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateKeys() {
    _keys = {for (final id in widget.bookings.keys) id: GlobalObjectKey('booking-card-$id')};
  }

  void _scrollToItem(int id) {
    final scrollOffset = Offset(_controller.position.pixels, 0);
    final item = _keys[id]?.currentContext?.findRenderObject() as RenderBox?;
    print('scrollOffset: $scrollOffset');
    print(
      'item.globalToLocal: ${item?.globalToLocal(Offset.zero)}, item.localToGlobal: ${item?.localToGlobal(Offset.zero)}',
    );
    print(
      'item.globalToLocal from offset: ${item?.globalToLocal(scrollOffset)}, item.localToGlobal: ${item?.localToGlobal(scrollOffset)}',
    );
    _controller.animateTo(
      item?.localToGlobal(scrollOffset).dy ?? 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty) {
      return EmptyBookingView(action: context.read<HomeNavigationCubit>().openHome);
    }
    // Scrollable.ensureVisible(
    //     key.currentContext!,
    //     duration: Duration(milliseconds: 500),
    //     curve: Curves.easeInOut,
    //     alignment: 0.1, // Scroll to 10% from top
    //   );

    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: _controller,
      itemCount: widget.bookings.length,
      itemBuilder: (context, index) {
        final booking = widget.bookings.values.elementAt(index);
        return BookingCard(booking: booking, key: _keys[booking.id]);
      },
    );
  }
}
