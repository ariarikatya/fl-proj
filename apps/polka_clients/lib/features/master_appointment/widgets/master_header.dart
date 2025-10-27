import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MasterHeader extends StatelessWidget {
  const MasterHeader({super.key, required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(color: context.ext.theme.backgroundSubtle, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppText(
                  '${master.firstName} ${master.lastName}',
                  style: AppTextStyles.headingSmall.copyWith(height: 1),
                ),
                AppText(
                  master.profession,
                  style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                ),
                AppText(
                  '⭐ ${master.ratingFixed} | Опыт: ${master.experience}',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
