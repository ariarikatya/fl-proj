import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.simplified = false,
    this.action,
  }) : assert(
         (title != null && titleWidget == null) || (title == null && titleWidget != null),
         'You should provide either title or titleWidget',
       );

  final String? title;
  final Widget? titleWidget;
  final bool simplified;
  final Widget? action;

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
                child: AppIcons.chevronBack.icon(),
              ),
            ),
          )
        : SizedBox(width: 56);

    return Material(
      color: simplified ? Colors.transparent : AppColors.backgroundSubtle,
      child: SafeArea(
        child: Container(
          decoration: simplified
              ? null
              : BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.backgroundHover)),
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
  const ModalAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final closeButton = canPop
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: AppIcons.close.icon(),
              ),
            ),
          )
        : SizedBox(width: 56);

    return Material(
      color: AppColors.backgroundSubtle,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.backgroundHover)),
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
