import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/initialization.dart';

class MbsBase extends StatelessWidget {
  const MbsBase({super.key, required this.child, this.showGrabber = true, this.expandContent = true});

  final Widget child;
  final bool showGrabber;
  final bool expandContent;

  @override
  Widget build(BuildContext context) {
    var content = expandContent ? Expanded(child: child) : child;
    double bottomPadding = 32;
    if (navigatorKey.currentContext case BuildContext ctx) bottomPadding = MediaQuery.of(ctx).padding.bottom + 8;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      decoration: BoxDecoration(
        color: context.ext.theme.backgroundDefault,
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
                  decoration: BoxDecoration(
                    color: context.ext.theme.textPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }
}
