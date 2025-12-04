import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:shared/shared.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeNavigationCubit, ({int index, Object? data})>(
      builder: (context, state) {
        final controller = context.read<HomeNavigationCubit>();
        return PopScope(
          canPop: state.index == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && controller.state.index != 0) {
              controller.openHome();
            }
          },
          child: AppPage(
            child: Column(
              children: [
                Expanded(
                  child: LazyIndexedStack(index: state.index, children: HomeNavigationCubit.pages),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  color: context.ext.colors.white[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavigationBarItem(
                        icon: FIcons.home.icon(context),
                        onTap: () => controller.openHome(),
                        selected: state.index == 0,
                      ),
                      _NavigationBarItem(
                        icon: FIcons.search.icon(context),
                        onTap: () => controller.openMapSearch(),
                        selected: state.index == 1,
                      ),
                      _NavigationBarItem(
                        icon: FIcons.clipboard.icon(context),
                        onTap: () => controller.openBookings(),
                        selected: state.index == 2,
                      ),
                      _NavigationBarItem(
                        icon: Builder(
                          builder: (ctx) => AppAvatar(
                            avatarUrl: ctx.watch<ClientViewModel>().client.avatarUrl,
                            size: 24,
                            borderColor: context.ext.colors.black[900],
                            shadow: false,
                          ),
                        ),
                        onTap: () => controller.openProfile(),
                        selected: state.index == 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            safeAreaBuilder: (child) => SafeArea(bottom: false, top: false, child: child),
          ),
        );
      },
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
