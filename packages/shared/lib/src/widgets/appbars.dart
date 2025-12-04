import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/feather_icons.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.simplified = false,
    this.action,
    this.backButtonColor,
  }) : assert(
         (title != null && titleWidget == null) || (title == null && titleWidget != null),
         'You should provide either title or titleWidget',
       );

  final String? title;
  final Widget? titleWidget;
  final bool simplified;
  final Widget? action;
  final Color? backButtonColor;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final backButton = canPop
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: FIcons.arrow_left.icon(context, color: backButtonColor),
              ),
            ),
          )
        : SizedBox(width: 56);

    return Material(
      color: simplified ? Colors.transparent : context.ext.colors.white[200],
      child: SafeArea(
        child: Container(
          decoration: simplified
              ? null
              : BoxDecoration(
                  border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton,
              titleWidget ?? AppText(title ?? '', style: AppTextStyles.bodyLarge),
              SizedBox(width: 56, height: 56, child: action),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}

class ModalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModalAppBar({super.key, required this.title, this.bottomBorder = true, this.canPopOverride});

  final String title;
  final bool bottomBorder;
  final bool? canPopOverride;

  @override
  Widget build(BuildContext context) {
    final canPop = canPopOverride ?? Navigator.canPop(context);
    final closeButton = canPop
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Material(
              color: Colors.transparent,
              child: Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 12), child: AppIcons.close.icon(context)),
            ),
          )
        : SizedBox(width: 56);

    return Material(
      color: context.ext.colors.white[200],
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: bottomBorder ? Border(bottom: BorderSide(color: context.ext.colors.white[300])) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 56, height: 56),
              AppText(title, style: AppTextStyles.bodyLarge),
              closeButton,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
