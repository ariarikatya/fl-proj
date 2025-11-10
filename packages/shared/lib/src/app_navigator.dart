import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

String describeStack(List<Page> pages) => '[${pages.map((p) => '${p.name}').join(', ')}]';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key, required this.initialPages});

  final List<Page> initialPages;

  static AppNavigatorState of(BuildContext context) => context.findAncestorStateOfType<AppNavigatorState>()!;

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  late final _pages = ValueNotifier<List<Page>>(List.from(widget.initialPages));

  void push(Page page) => _change((pages) => pages..add(page));

  void remove(Page page) => _change((pages) => pages..remove(page));

  void pop() => _change((pages) => pages..removeLast());

  void _change(List<Page> Function(List<Page> pages) fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final $pages = fn(List.from(_pages.value));
      log('changing navigation stack: ${describeStack(_pages.value)} => ${describeStack($pages)}');
      _pages.value = $pages;
    });
  }

  @override
  void initState() {
    super.initState();
    logger.warning('adding $this as observer');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    logger.warning('removing $this as observer');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    assert(mounted);
    final NavigatorState? navigator = _navigatorKey.currentState;
    if (navigator == null) return false;
    return navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _pages,
      builder: (context, pages, child) =>
          Navigator(key: _navigatorKey, pages: _pages.value, onDidRemovePage: (page) => remove(page)),
    );
  }
}
