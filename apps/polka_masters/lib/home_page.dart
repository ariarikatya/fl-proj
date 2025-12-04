import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/controllers/events_cubit.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_screen.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/contacts_screen.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:polka_masters/scopes/master_model.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _pages = [const CalendarScreen(), const ChatsPage(), const ContactsScreen(), const ProfileScreen()];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    Dependencies().requestNotificationPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // By calling these cubits we create and initialize them
    context.read<ChatsCubit>();
    context.read<EventsCubit>();
    context.read<PendingBookingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0);
        }
      },
      child: AppPage(
        child: Column(
          children: [
            Expanded(
              child: LazyIndexedStack(index: _index, children: _pages),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              decoration: BoxDecoration(
                color: context.ext.colors.white[200],
                border: Border(top: BorderSide(color: context.ext.colors.white[200], width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavigationBarItem(
                    icon: FIcons.calendar.icon(context, color: context.ext.colors.black[900]),
                    onTap: () => setState(() => _index = 0),
                    selected: _index == 0,
                  ),
                  _NavigationBarItem(
                    icon: FIcons.message_circle.icon(context, color: context.ext.colors.black[900]),
                    onTap: () => setState(() => _index = 1),
                    selected: _index == 1,
                  ),
                  _NavigationBarItem(
                    icon: FIcons.clipboard.icon(context, color: context.ext.colors.black[900]),
                    onTap: () => setState(() => _index = 2),
                    selected: _index == 2,
                  ),
                  _NavigationBarItem(
                    icon: Builder(
                      builder: (ctx) => AppAvatar(
                        avatarUrl: ctx.read<MasterModel>().master.avatarUrl,
                        size: 24,
                        borderColor: context.ext.colors.black[900],
                        shadow: false,
                      ),
                    ),
                    onTap: () => setState(() => _index = 3),
                    selected: _index == 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        safeAreaBuilder: (child) => SafeArea(bottom: false, top: false, child: child),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({required this.icon, required this.onTap, required this.selected});

  final Widget icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: Colors.transparent,
      child: Container(width: 48, height: 48, padding: const EdgeInsets.all(12), child: icon),
    );
    if (selected) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: context.ext.colors.pink[100], borderRadius: BorderRadius.circular(8)),
          ),
          child,
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
