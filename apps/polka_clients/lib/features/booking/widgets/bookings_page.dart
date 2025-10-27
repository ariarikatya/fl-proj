import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/widgets/empty_booking_view.dart';
import 'package:polka_clients/features/booking/widgets/booking_card.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
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
      appBar: CustomAppBar(title: 'Твои посещения'),
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Column(
        children: [
          TabBar(
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            splashFactory: NoSplash.splashFactory,
            tabAlignment: TabAlignment.start,
            dividerHeight: 1,
            dividerColor: context.ext.theme.backgroundDisabled,
            isScrollable: true,
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textPrimary, height: 2.5),
            unselectedLabelColor: context.ext.theme.textPlaceholder,
            indicatorAnimation: TabIndicatorAnimation.linear,
            indicator: UnderlineTabIndicator(borderSide: BorderSide(color: context.ext.theme.textSecondary)),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.zero,
            tabs: [
              Tab(text: 'Ждут подтверждения'),
              Tab(text: 'Предстоящие'),
              Tab(text: 'Прошедшие'),
            ],
            controller: _controller,
          ),
          Expanded(
            child: BlocConsumer<BookingsCubit, BookingsState>(
              bloc: blocs.get<BookingsCubit>(context),
              listener: (context, state) {
                if (blocs.get<BookingsCubit>(context).newBookingId != null) {
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
                    _buildBookingsView(state.pending),
                    _buildBookingsView(state.upcoming),
                    _buildBookingsView(state.completed),
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
    null => Center(child: LoadingIndicator()),
    > 0 => _BookingsView(bookings!, newBookingId: /* blocs.get<BookingsCubit>(context).newBookingId */ 28),
    _ => EmptyBookingView(action: blocs.get<HomeNavigationCubit>(context).openHome),
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
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty) {
      return EmptyBookingView(action: blocs.get<HomeNavigationCubit>(context).openHome);
    }

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
