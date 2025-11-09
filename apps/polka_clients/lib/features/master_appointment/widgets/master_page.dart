import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/master_appointment/widgets/reviews_page.dart';
import 'package:polka_clients/features/master_appointment/widgets/services_page.dart';
import 'package:polka_clients/features/master_appointment/widgets/review_widget.dart';
import 'package:polka_clients/features/master_appointment/widgets/service_widget.dart';
import 'package:shared/shared.dart';

class MasterPage extends StatelessWidget {
  const MasterPage({super.key, required this.masterId});

  final int masterId;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: 'Твой мастер',
      future: () => Dependencies().clientRepository.getMasterInfo(masterId),
      builder: (data) => MasterView(data: data),
    );
  }
}

class MasterView extends StatelessWidget {
  const MasterView({super.key, required this.data});

  final MasterInfo data;

  void _openServices(BuildContext context) => context.ext.push(ServicesPage(masterId: data.master.id));

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твой мастер'),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            ListView(
              children: [
                DebugWidget(
                  model: data,
                  child: _Header(master: data.master),
                ),
                _About(about: data.master.about),
                _ServicesWidget(
                  master: data.master,
                  services: data.services,
                  onExpandAll: () => _openServices(context),
                ),
                _PortfolioWidget(portfolio: data.master.portfolio),
                const SizedBox(height: 24),
                _WorkplaceWidget(workplace: data.master.workplace),
                _ReviewsWidget(
                  rating: data.master.rating,
                  lastReview: data.reviews.firstOrNull,
                  reviewsCount: data.master.reviewsCount,
                  master: data.master,
                ),
                const SizedBox(height: 72),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppTextButton.large(text: 'Записаться', onTap: () => _openServices(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioWidget extends StatelessWidget {
  const _PortfolioWidget({required this.portfolio});

  final List<String> portfolio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: AppText('Портфолио', style: AppTextStyles.headingSmall),
          ),
          const SizedBox(height: 16),
          if (portfolio.isEmpty)
            const AppPlaceholder(text: 'Мастер пока не добавил портфолио')
          else
            ImageScroll(imageUrls: portfolio),
        ],
      ),
    );
  }
}

class _WorkplaceWidget extends StatelessWidget {
  const _WorkplaceWidget({required this.workplace});

  final List<String> workplace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: AppText('Рабочее место', style: AppTextStyles.headingSmall),
          ),
          const SizedBox(height: 16),
          if (workplace.isEmpty)
            const AppPlaceholder(text: 'Мастер пока не добавил фото рабочего места')
          else
            ImageScroll(imageUrls: workplace),
        ],
      ),
    );
  }
}

class _ServicesWidget extends StatelessWidget {
  const _ServicesWidget({required this.services, required this.onExpandAll, required this.master});

  final Master master;
  final List<Service> services;
  final VoidCallback onExpandAll;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: AppText('Мои услуги', style: AppTextStyles.headingSmall),
          ),
          const SizedBox(height: 16),
          if (services.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: AppPlaceholder(text: 'Мастер пока не добавил услуги'),
            )
          else if (services.length > 1) ...[
            ServicesGridView(services: services.take(2).toList(), master: master, embedded: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppTextButtonSecondary.large(onTap: onExpandAll, text: 'Посмотреть все услуги'),
            ),
            const SizedBox(height: 16),
          ] else
            ServicesGridView(services: services, master: master, embedded: true),
        ],
      ),
    );
  }
}

class _ReviewsWidget extends StatelessWidget {
  const _ReviewsWidget({
    required this.rating,
    required this.lastReview,
    required this.master,
    required this.reviewsCount,
  });

  final double rating;
  final Master master;
  final Review? lastReview;
  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Отзывы', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            if (reviewsCount == 0) const AppPlaceholder(text: 'У мастера пока нет отзывов'),
            if (reviewsCount > 0 && lastReview != null) ...[
              _header(context),
              const SizedBox(height: 16),
              ReviewWidget(review: lastReview!),
              const SizedBox(height: 16),
              AppTextButtonSecondary.large(
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsPage(master: master))),
                text: 'Посмотреть все отзывы',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Row _header(BuildContext context) {
    return Row(
      children: [
        AppText('Общий рейтинг:', style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary)),
        const SizedBox(width: 4),
        AboutInfo.reviews(master: master),
      ],
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.about});

  final String about;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Обо мне', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            AppText(about, style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl, size: 160),
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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              AboutInfo.city(master: master),
              AboutInfo.reviews(master: master),
              AboutInfo.experience(master: master),
            ],
          ),
        ],
      ),
    );
  }
}
