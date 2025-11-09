import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_header.dart';
import 'package:polka_clients/features/master_appointment/widgets/review_widget.dart';
import 'package:shared/shared.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key, required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().clientRepository.getMasterReviews(master.id),
      builder: (data) => ReviewsView(master: master, reviews: data),
    );
  }
}

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key, required this.master, required this.reviews});

  final Master master;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Услуги мастера'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: MasterHeader(master: master),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: AppText(
              master.reviewsCount.pluralMasculine('отзыв'),
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, index) {
                return ReviewWidget(review: reviews[index]);
              },
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
