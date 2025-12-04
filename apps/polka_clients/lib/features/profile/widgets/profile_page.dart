import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/favorites/widgets/favorites_page.dart';
import 'package:polka_clients/features/profile/widgets/categories_page.dart';
import 'package:polka_clients/features/profile/widgets/profile_info_page.dart';
import 'package:polka_clients/features/profile/widgets/settings_screen.dart';
import 'package:polka_clients/splash_screen.dart';
import 'package:shared/shared.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _tapsToOverrideDevMode = 0;

  void _onAvatarPicked(BuildContext context, XFile xfile) async {
    logger.debug('updating profile avatar');
    final result = await Dependencies().clientRepository.uploadClientAvatar(xfile);
    result.maybeWhen(
      ok: (avatarUrl) {
        final viewModel = context.read<ClientViewModel>();
        viewModel.updateClient(viewModel.client.copyWith(avatarUrl: () => avatarUrl));
      },
      err: (error, stackTrace) => handleError(error, stackTrace),
    );
  }

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
          child: const AppText('Личный кабинет'),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Header(),
            AddPhotoBtn(onImagePicked: (xfile) => _onAvatarPicked(context, xfile)),
            const SizedBox(height: 16),
            ProfileButton(
              icon: FIcons.user,
              title: 'Мой профиль',
              onTap: () => context.ext.push(const ProfileInfoPage()),
            ),
            ProfileButton(
              icon: FIcons.star,
              title: 'Мои Категории',
              onTap: () => context.ext.push(const CategoriesPage()),
            ),
            ProfileButton(icon: FIcons.heart, title: 'Избранное', onTap: () => context.ext.push(const FavoritesPage())),
            ProfileButton(icon: FIcons.message_circle, title: 'Чаты', onTap: () => context.ext.push(const ChatsPage())),
            ProfileButton(
              icon: FIcons.message_square,
              title: 'Поддержка',
              onTap: () {
                final client = context.read<ClientViewModel>().client;
                context.ext.push(
                  SupportScreen(name: client.fullName, email: client.email ?? 'client-${client.id}@polka.com'),
                );
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
                  getFcmToken: FirebaseMessaging.instance.getToken,
                ),
              ),
              ProfileButton(icon: FIcons.home, title: 'Splash', onTap: () => context.ext.push(const SplashScreen())),
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
    final client = context.watch<ClientViewModel>().client;
    return DebugWidget(
      model: client,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Row(
          spacing: 16,
          children: [
            BlotAvatar(avatarUrl: client.avatarUrl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    client.fullName,
                    style: AppTextStyles.headingLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    client.city,
                    style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
