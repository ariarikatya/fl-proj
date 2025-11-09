import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/add_contact_button.dart';
import 'package:polka_masters/features/contacts/widgets/all_contacts_screen.dart';
import 'package:polka_masters/features/contacts/widgets/group_screens/contacts_groups_view.dart';
import 'package:polka_masters/features/contacts/widgets/pending_bookings_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: 'Твои клиенты',
      future: Dependencies().contactsRepo.searchContacts,
      builder: (data) => _LoadedView(hasContacts: data.isNotEmpty),
    );
  }
}

class _LoadedView extends StatefulWidget {
  const _LoadedView({required this.hasContacts});

  final bool hasContacts;

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  late bool hasContacts = widget.hasContacts;

  @override
  Widget build(BuildContext context) {
    return hasContacts ? const _ContactsView() : _EmptyView(onContactCreated: () => setState(() => hasContacts = true));
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
            color: context.ext.theme.accent,
            backgroundColor: context.ext.theme.backgroundSubtle,
            tabs: [
              Tab(
                // text: 'Новые заявки',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, child) {
                          return AppText(
                            'Новые заявки',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _controller.index == 0
                                  ? context.ext.theme.accent
                                  : context.ext.theme.textPlaceholder,
                              height: 2.5,
                            ),
                          );
                        },
                      ),
                    ),
                    BlocBuilder<PendingBookingsCubit, PagingState<int, BookingInfo>>(
                      bloc: blocs.get<PendingBookingsCubit>(context),
                      builder: (context, state) {
                        if (state.items == null || state.items!.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, left: 4),
                          child: CounterWidget(count: state.items!.length, color: context.ext.theme.accent),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onContactCreated});

  final VoidCallback onContactCreated;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText('Пока у тебя нет\nклиентов', style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  AppText.secondary(
                    'Добавь первого, чтобы начать вести историю визитов и напоминаний',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AddContactButton(onContactCreated: (_) => onContactCreated()),
          ),
        ],
      ),
    );
  }
}
