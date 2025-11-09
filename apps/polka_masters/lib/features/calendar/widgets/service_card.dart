import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard(this.service, {super.key, this.enabled = false});

  final Service service;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: enabled ? context.ext.theme.accentLight : context.ext.theme.backgroundHover,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: enabled ? context.ext.theme.accent : Colors.transparent),
      ),
      child: Row(
        spacing: 16,
        children: [
          ImageClipped(width: 48, height: 48, borderRadius: 10, imageUrl: service.resultPhotos.firstOrNull),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(service.title, overflow: TextOverflow.ellipsis),
                Row(
                  spacing: 4,
                  children: [
                    AppIcons.clock.icon(context, size: 16, color: context.ext.theme.textSecondary),
                    AppText.secondary(service.duration.toDurationStringShort(), style: AppTextStyles.bodyMedium500),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
