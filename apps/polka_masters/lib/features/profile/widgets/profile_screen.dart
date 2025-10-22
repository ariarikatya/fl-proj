import 'package:flutter/material.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Личный кабинет'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            _Header(),
            SizedBox(height: 40),
            if (devMode) AppTextButton.medium(text: 'Для разработчиков', onTap: () => openTalkerScreen(context)),
            AppTextButton.medium(text: 'Logout', onTap: () => AuthenticationScope.of(context).logout()),
            AppTextButton.medium(
              text: 'Delete Account',
              onTap: () async {
                await AuthenticationScope.of(context).authRepository.deleteAccount();
                if (context.mounted) AuthenticationScope.of(context).logout();
              },
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
    final master = MasterScope.of(context).master;
    return DebugWidget(
      model: master,
      child: Row(
        spacing: 16,
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  master.fullName,
                  style: AppTextStyles.headingLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppText(
                  master.city,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
