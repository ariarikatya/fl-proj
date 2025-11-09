import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/favorites/widgets/favorites_page.dart';
import 'package:polka_clients/features/profile/widgets/categories_page.dart';
import 'package:polka_clients/features/profile/widgets/profile_info_page.dart';
import 'package:polka_clients/features/profile/widgets/settings_page.dart';
import 'package:shared/shared.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    final logout = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь выйти из аккаунта?',
      acceptText: 'Выйти',
      declineText: 'Отменить',
    );
    if (logout == true && context.mounted) AuthenticationScope.of(context).logout();
  }

  void _onAvatarPicked(BuildContext context, XFile xfile) async {
    logger.debug('updating profile avatar');
    final result = await Dependencies().clientRepository.uploadClientAvatar(xfile);
    result.maybeWhen(
      ok: (avatarUrl) => ClientScope.of(context).updateClient((client) => client.copyWith(avatarUrl: () => avatarUrl)),
      err: (error, stackTrace) => handleError(error, stackTrace),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Личный кабинет'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Header(),
            AddPhotoBtn(onImagePicked: (xfile) => _onAvatarPicked(context, xfile)),
            const SizedBox(height: 16),
            ProfileButton(
              icon: AppIcons.user,
              title: 'Мой профиль',
              onTap: () => context.ext.push(const ProfileInfoPage()),
            ),
            ProfileButton(
              icon: AppIcons.saved,
              title: 'Мои Категории',
              onTap: () => context.ext.push(const CategoriesPage()),
            ),
            ProfileButton(
              icon: AppIcons.favorite,
              title: 'Избранное',
              onTap: () => context.ext.push(const FavoritesPage()),
            ),
            ProfileButton(icon: AppIcons.chats, title: 'Чаты', onTap: () => context.ext.push(const ChatsPage())),
            ProfileButton(icon: AppIcons.chat, title: 'Поддержка', onTap: () => logger.debug('tap')),
            ProfileButton(
              icon: AppIcons.settings,
              title: 'Настройки',
              onTap: () => context.ext.push(const SettingsPage()),
            ),
            if (devMode) ...[
              ProfileButton(
                icon: AppIcons.filter,
                title: 'Для разработчиков',
                onTap: () => openTalkerScreen(context, getToken: Dependencies().authController.getAccessToken),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 32, 18, 32),
              child: AppLinkButton(text: 'Выйти', onTap: () => _logout(context)),
            ),
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
    final client = ClientScope.of(context).client;
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
                    style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
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
