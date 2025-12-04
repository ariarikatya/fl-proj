import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/appointments/widgets/appointments_screen.dart';
import 'package:polka_masters/features/auth/pages/welcome_page.dart';
import 'package:polka_masters/features/online_booking/widgets/online_booking_screen.dart';
import 'package:polka_masters/features/profile/widgets/profile_edit_screen.dart';
import 'package:polka_masters/features/schedules/widgets/schedule_edit_screen.dart';
import 'package:polka_masters/features/profile/widgets/services_edit_screen.dart';
import 'package:polka_masters/features/profile/widgets/settings_screen.dart';
import 'package:polka_masters/features/schedules/widgets/schedules_screen.dart';
import 'package:polka_masters/scopes/master_model.dart';
import 'package:polka_masters/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tapsToOverrideDevMode = 0;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(
        titleWidget: GestureDetector(
          onTap: () {
            setState(() {
              _tapsToOverrideDevMode = _tapsToOverrideDevMode + 1;
              if (_tapsToOverrideDevMode == 10) {
                devModeOverride = !devMode;
                _tapsToOverrideDevMode = 0;
                showInfoSnackbar('Режим разработчика ${devMode ? "включен" : "выключен"}');
              }
            });
          },
          child: const AppText('Твой кабинет'),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, 16), child: _Header()),
            ProfileButton(
              icon: FIcons.calendar,
              title: 'Моё расписание',
              onTap: () => context.ext.push(const NewScheduleEditScreen()),
            ),
            ProfileButton(
              icon: FIcons.scissors,
              title: 'Мои услуги',
              onTap: () => context.ext.push(const ServicesEditScreen()),
            ),
            ProfileButton(
              icon: FIcons.link,
              title: 'Онлайн - запись',
              onTap: () => context.ext.push(const OnlineBookingScreen()),
            ),
            ProfileButton(
              icon: FIcons.message_square,
              title: 'Поддержка',
              onTap: () {
                final master = context.read<MasterModel>().master;
                context.ext.push(SupportScreen(name: master.fullName, email: 'master-${master.id}@polka.com'));
              },
            ),
            ProfileButton(
              icon: FIcons.settings,
              title: 'Настройки',
              onTap: () => context.ext.push(const SettingsScreen()),
            ),
            if (devMode) ...[
              const Padding(padding: EdgeInsets.fromLTRB(32, 24, 32, 8), child: AppText('Для разработчиков')),
              ProfileButton(
                icon: FIcons.filter,
                title: 'Консоль',
                onTap: () => openTalkerScreen(
                  context,
                  getAccessToken: Dependencies().authController.getAccessToken,
                  getFcmToken: () => Future.value(null),
                ),
              ),
              ProfileButton(
                icon: FIcons.calendar,
                title: 'Управление расписаниями',
                onTap: () => context.ext.push(const SchedulesScreen()),
              ),
              ProfileButton(
                icon: FIcons.link,
                title: 'Управление записями',
                onTap: () => context.ext.push(AppointmentsScreen(repo: Dependencies().bookingsRepository)),
              ),
              ProfileButton(icon: FIcons.home, title: 'Splash', onTap: () => context.ext.push(const SplashScreen())),
              ProfileButton(icon: FIcons.home, title: 'Welcome', onTap: () => context.ext.push(const WelcomePage())),
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
    final master = context.watch<MasterModel>().master;

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
            style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
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
    final master = context.watch<MasterModel>().master;

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
                      FIcons.star.icon(context, size: 8, color: context.ext.colors.black[900]),
                  ],
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: context.ext.colors.white[400]),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(master.experience, style: AppTextStyles.bodyLarge700),
                const AppText('Опыта', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: context.ext.colors.white[400]),
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

  void _changePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logger.debug('updating profile avatar');
      final upload = await Dependencies().profileRepository.uploadPhotos([image]);
      final url = upload.unpack()?.values.first;
      if (url != null && context.mounted) {
        final master = context.read<MasterModel>().master.copyWith(avatarUrl: () => url);
        final result = await Dependencies().masterRepository.updateMaster(master);
        if (result.isOk && context.mounted) {
          context.read<MasterModel>().updateMaster(master);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterModel>().master;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Align(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppIcons.blotBigAlt.icon(context, size: 132, color: context.ext.colors.pink[100]),
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () => _changePhoto(context),
                child: AppAvatar(avatarUrl: master.avatarUrl, size: 120),
              ),
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
                  FIcons.edit.icon(context, size: 16),
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
          color: context.ext.colors.white[100],
          border: Border.all(color: context.ext.colors.white[300]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
