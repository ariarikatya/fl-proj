import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.ext.colors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value ? 1 : 0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          return Container(
            width: 56,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Color.lerp(colors.white[200], colors.pink[500], t),
              border: Border.all(color: colors.black[900], width: 1, strokeAlign: BorderSide.strokeAlignInside),
            ),
            child: Align(
              alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, t)!,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: colors.black[900], width: 1, strokeAlign: BorderSide.strokeAlignInside),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
