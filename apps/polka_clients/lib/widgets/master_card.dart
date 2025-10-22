import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/favorites/controller/favorites_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_page.dart';
import 'package:polka_clients/features/master_appointment/widgets/services_page.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';

class MasterCard extends StatelessWidget {
  const MasterCard({super.key, required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    var card = Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImagePageView(imageUrls: [master.avatarUrl, ...master.portfolio], height: 220),
          SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: AppText(
                    '${master.firstName}\n${master.lastName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    AppText('⭐ ${master.ratingFixed}', style: AppTextStyles.bodyMedium),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              AppEmojis.fromMasterService(
                master.categories.firstOrNull ?? ServiceCategories.nailService,
              ).icon(size: Size(14, 14)),
              SizedBox(width: 4),
              Flexible(
                child: AppText(
                  master.profession,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          SizedBox(
            height: 38,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: AppIcons.location.icon(size: 16)),
                SizedBox(width: 6),
                Flexible(
                  child: AppText(
                    master.address,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          AppTextButton.medium(
            text: 'Записаться',
            onTap: () => context.ext.push(ServicesPage(masterId: master.id)),
          ),
        ],
      ),
    );

    return DebugWidget(
      model: master,
      child: GestureDetector(
        onTap: () => context.ext.push(MasterPage(masterId: master.id)),
        child: Stack(
          children: [
            card,
            Positioned(
              right: 8,
              top: 8,
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                bloc: blocs.get<FavoritesCubit>(context),
                builder: (context, state) {
                  final favoriteStatus = state.statusOf(master.id);
                  return GestureDetector(
                    onTap: () => switch (favoriteStatus) {
                      FavoriteStatus.liked => blocs.get<FavoritesCubit>(context).unlike(master.id),
                      FavoriteStatus.loading => null,
                      FavoriteStatus.notLiked => blocs.get<FavoritesCubit>(context).like(master.id),
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.favorite,
                        size: 24,
                        color: switch (favoriteStatus) {
                          FavoriteStatus.liked => AppColors.accent,
                          FavoriteStatus.loading => AppColors.accentLight,
                          FavoriteStatus.notLiked => AppColors.backgroundDefault,
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
