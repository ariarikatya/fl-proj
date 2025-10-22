import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';

class MbsBase extends StatelessWidget {
  const MbsBase({super.key, required this.child, this.showGrabber = true, this.expandContent = true});

  final Widget child;
  final bool showGrabber;
  final bool expandContent;

  @override
  Widget build(BuildContext context) {
    var content = expandContent ? Expanded(child: child) : child;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      decoration: BoxDecoration(
        color: AppColors.backgroundDefault,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showGrabber)
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }
}
