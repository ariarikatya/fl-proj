import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/favorites/widgets/favorites_page.dart';
import 'package:polka_clients/features/profile/widgets/categories_page.dart';
import 'package:polka_clients/features/profile/widgets/profile_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Личный кабинет'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(),
            _AddPhotoBtn(),
            SizedBox(height: 16),
            ProfileButton(icon: AppIcons.user, title: 'Мой профиль', onTap: () => context.ext.push(ProfileInfoPage())),
            ProfileButton(
              icon: AppIcons.saved,
              title: 'Мои Категории',
              onTap: () => context.ext.push(CategoriesPage()),
            ),
            ProfileButton(icon: AppIcons.favorite, title: 'Избранное', onTap: () => context.ext.push(FavoritesPage())),
            ProfileButton(icon: AppIcons.chats, title: 'Чаты', onTap: () => context.ext.push(ChatsPage())),
            ProfileButton(icon: AppIcons.support, title: 'Поддержка', onTap: () => logger.debug('tap')),
            ProfileButton(icon: AppIcons.settings, title: 'Настройки', onTap: () => context.ext.push(SettingsPage())),
            if (devMode) ...[
              ProfileButton(icon: AppIcons.filter, title: 'Для разработчиков', onTap: () => openTalkerScreen(context)),
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

class _AddPhotoBtn extends StatelessWidget {
  const _AddPhotoBtn();

  Future<void> changePhoto(BuildContext context) async {
    logger.debug('updating profile avatar');
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logger.info('Image picked: ${image.path}, size: ${await image.length() ~/ 1024} KB');
      final result = await Dependencies().clientRepository.uploadClientAvatar(image);
      result.maybeWhen(
        ok: (avatarUrl) =>
            ClientScope.of(context).updateClient((client) => client.copyWith(avatarUrl: () => avatarUrl)),
        err: (error, stackTrace) => handleError(error, stackTrace),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changePhoto(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(color: AppColors.backgroundHover, borderRadius: BorderRadius.circular(16)),
        child: Row(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcons.camera.icon(size: 16),
            AppText('Добавить', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
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
