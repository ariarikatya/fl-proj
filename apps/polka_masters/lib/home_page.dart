import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/appointments/widgets/appointments_screen.dart';
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
    AppointmentsScreen(repo: Dependencies().masterRepository),
    ProfileScreen(),
  ];

  int _index = 3;

  @override
  void initState() {
    super.initState();
    // By calling this cubit we create and initialize it
    blocs.get<ChatsCubit>(context);
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
                color: AppColors.backgroundSubtle,
                border: Border(top: BorderSide(color: AppColors.backgroundDisabled, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavigationBarItem(
                    icon: AppIcons.calendar.icon(),
                    onTap: () => setState(() => _index = 0),
                    selected: _index == 0,
                  ),
                  _NavigationBarItem(
                    icon: AppIcons.chats.icon(),
                    onTap: () => setState(() => _index = 1),
                    selected: _index == 1,
                  ),
                  _NavigationBarItem(
                    icon: AppIcons.file.icon(),
                    onTap: () => setState(() => _index = 2),
                    selected: _index == 2,
                  ),
                  _NavigationBarItem(
                    icon: Builder(
                      builder: (ctx) => AppAvatar(
                        avatarUrl: MasterScope.of(ctx).master.avatarUrl,
                        size: 24,
                        borderColor: AppColors.textPrimary,
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
          AppIcons.blot.icon(size: 36, color: AppColors.accent),
          child,
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
