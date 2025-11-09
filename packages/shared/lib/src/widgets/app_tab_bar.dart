import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.controller, required this.tabs, this.color, this.backgroundColor});

  final TabController controller;
  final List<Tab> tabs;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: TabBar(
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 16),
        splashFactory: NoSplash.splashFactory,
        tabAlignment: TabAlignment.start,
        dividerHeight: 1,
        dividerColor: context.ext.theme.backgroundHover,
        overlayColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
        isScrollable: true,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: color ?? context.ext.theme.textPrimary, height: 2.5),
        unselectedLabelColor: context.ext.theme.textPlaceholder,
        indicatorAnimation: TabIndicatorAnimation.linear,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: color ?? context.ext.theme.textSecondary)),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.zero,
        tabs: tabs,
        controller: controller,
      ),
    );
  }
}
