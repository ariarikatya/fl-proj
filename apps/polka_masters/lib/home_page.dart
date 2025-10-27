import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/appointments/widgets/appointments_screen.dart';
import 'package:polka_masters/features/calendar/controllers/events_cubit.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_screen.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _pages = [
    CalendarScreen(),
    ChatsPage(),
    AppointmentsScreen(repo: Dependencies().bookingsRepository),
    ProfileScreen(),
  ];

  int _index = 3;

  @override
  void didChangeDependencies() {
    // By calling these cubits we create and initialize them
    blocs.get<ChatsCubit>(context);
    blocs.get<EventsCubit>(context);
    super.didChangeDependencies();
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
                color: context.ext.theme.backgroundSubtle,
                border: Border(top: BorderSide(color: context.ext.theme.backgroundDisabled, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavigationBarItem(
                    icon: AppIcons.calendar.icon(context),
                    onTap: () => setState(() => _index = 0),
                    selected: _index == 0,
                  ),
                  _NavigationBarItem(
                    icon: AppIcons.chats.icon(context),
                    onTap: () => setState(() => _index = 1),
                    selected: _index == 1,
                  ),
                  _NavigationBarItem(
                    icon: AppIcons.file.icon(context),
                    onTap: () => setState(() => _index = 2),
                    selected: _index == 2,
                  ),
                  _NavigationBarItem(
                    icon: Builder(
                      builder: (ctx) => AppAvatar(
                        avatarUrl: MasterScope.of(ctx).master.avatarUrl,
                        size: 24,
                        borderColor: context.ext.theme.textPrimary,
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
          AppIcons.blot.icon(context, size: 36, color: context.ext.theme.accent),
          child,
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
