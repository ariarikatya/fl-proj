import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.child, required this.enabled, required this.onTap, required this.onClose});

  final Widget child;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onClose : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: enabled ? 14 : 16, vertical: enabled ? 10 : 12),
        decoration: BoxDecoration(
          color: enabled ? AppColors.accentLight : AppColors.backgroundHover,
          borderRadius: BorderRadius.circular(24),
          border: enabled ? Border.all(color: AppColors.accent, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            child,
            if (enabled) Icon(Icons.close, size: 16, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}
