import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/all_contacts_screen.dart';
import 'package:polka_masters/features/contacts/widgets/group_screens/contacts_groups_view.dart';
import 'package:polka_masters/features/contacts/widgets/pending_bookings_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ContactsView();
  }
}

class _ContactsView extends StatefulWidget {
  const _ContactsView();

  @override
  State<_ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<_ContactsView> with TickerProviderStateMixin {
  late final _controller = TabController(length: 3, vsync: this, initialIndex: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      appBar: const ModalAppBar(title: 'Твои клиенты', bottomBorder: false, canPopOverride: false),
      child: Column(
        children: [
          AppTabBar(
            controller: _controller,
            color: context.ext.colors.pink[500],
            backgroundColor: context.ext.colors.white[200],
            tabs: [
              Tab(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, child) {
                          return Text('Новые заявки', style: AppTextStyles.bodyMedium.copyWith(height: 2.5));
                        },
                      ),
                    ),
                    BlocBuilder<PendingBookingsCubit, PagingState<int, BookingInfo>>(
                      builder: (context, state) {
                        if (state.items == null || state.items!.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: CounterWidget(count: state.items!.length, color: context.ext.colors.pink[500]),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Tab(text: 'Все клиенты'),
              const Tab(text: 'Группы'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [PendingBookingsScreen(), AllContactsScreen(), ContactsGroupsView()],
            ),
          ),
        ],
      ),
    );
  }
}
