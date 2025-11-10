import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/profile/widgets/online_booking_screen.dart';
import 'package:polka_masters/features/profile/widgets/profile_edit_screen.dart';
import 'package:polka_masters/features/profile/widgets/schedule_edit_screen.dart';
import 'package:polka_masters/features/profile/widgets/services_edit_screen.dart';
import 'package:polka_masters/features/profile/widgets/settings_screen.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твой кабинет'),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, 16), child: _Header()),
            ProfileButton(
              icon: AppIcons.calendar,
              title: 'Расписание',
              onTap: () => context.ext.push(ScheduleEditScreen(initialSchedule: context.read<MasterScope>().schedule)),
            ),
            ProfileButton(
              icon: AppIcons.scissors,
              title: 'Услуги',
              onTap: () => context.ext.push(const ServicesEditScreen()),
            ),
            ProfileButton(
              icon: AppIcons.link,
              title: 'Онлайн - запись',
              onTap: () => context.ext.push(OnlineBookingScreen(masterId: context.read<MasterScope>().master.id)),
            ),
            ProfileButton(
              icon: AppIcons.chat,
              title: 'Поддержка',
              onTap: () {
                final master = context.read<MasterScope>().master;
                context.ext.push(SupportScreen(name: master.fullName, email: 'master-${master.id}@polka.com'));
              },
            ),
            ProfileButton(
              icon: AppIcons.settings,
              title: 'Настройки',
              onTap: () => context.ext.push(const SettingsScreen()),
            ),
            if (devMode) ...[
              ProfileButton(
                icon: AppIcons.filter,
                title: 'Для разработчиков',
                onTap: () => openTalkerScreen(context, getToken: Dependencies().authController.getAccessToken),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterScope>().master;

    return DebugWidget(
      model: master,
      child: Column(
        children: [
          const _BlotAvatar(),
          AppText(
            '${master.firstName} ${master.lastName}',
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),
          AppText(
            master.profession,
            style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              AppIcons.geoposition.icon(context, size: 16),
              Flexible(child: AppText.secondary(master.city, style: AppTextStyles.bodyMedium500)),
            ],
          ),
          const SizedBox(height: 16),
          const MasterInfoWidget(),
          const SizedBox(height: 21),
        ],
      ),
    );
  }
}

class MasterInfoWidget extends StatelessWidget {
  const MasterInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterScope>().master;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                AppText(master.ratingFixed.replaceAll('.', ','), style: AppTextStyles.bodyLarge700),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < (master.rating + 0.5).truncate(); i++)
                      AppIcons.star.icon(context, size: 8, color: context.ext.theme.textPrimary),
                  ],
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: context.ext.theme.backgroundDisabled),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(master.experience, style: AppTextStyles.bodyLarge700),
                const AppText('Опыта', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: context.ext.theme.backgroundDisabled),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(master.reviewsCount.toString(), style: AppTextStyles.bodyLarge700),
                AppText(
                  master.reviewsCount.pluralMasculine('отзыв').split(' ').last.capitalized,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlotAvatar extends StatelessWidget {
  const _BlotAvatar();

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterScope>().master;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Align(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppIcons.blotBigAlt.icon(context, size: 132, color: context.ext.theme.accentLight),
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppAvatar(avatarUrl: master.avatarUrl, size: 120),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: EditButton(
              onTap: () => context.ext.push(ProfileEditScreen(initialData: master)),
              child: Row(
                spacing: 2,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcons.edit.icon(context, size: 16),
                  const AppText.secondary('Редактировать', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: context.ext.theme.backgroundDefault,
          border: Border.all(color: context.ext.theme.backgroundHover),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
