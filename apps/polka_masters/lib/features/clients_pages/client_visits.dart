import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ClientVisitsPage extends StatefulWidget {
  const ClientVisitsPage({
    super.key,
    required this.client,
    required this.visits,
  });

  final Client client;
  final List<Booking> visits;

  @override
  State<ClientVisitsPage> createState() => _ClientVisitsPageState();
}

class _ClientVisitsPageState extends State<ClientVisitsPage> {
  final Map<int, bool> _expandedVisits = {};

  void _toggleVisitExpansion(int visitId) {
    setState(() {
      _expandedVisits[visitId] = !(_expandedVisits[visitId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Визиты клиента'),
      backgroundColor: AppColors.backgroundDefault,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // 🔹 Header из первого кода (горизонтальный)
            _ClientHeader(
              client: widget.client,
              visitsCount: widget.visits.length,
              visits: widget.visits,
            ),
            _AllVisitsSection(),
            _VisitsByYear(
              visits: widget.visits,
              expandedVisits: _expandedVisits,
              onToggle: _toggleVisitExpansion,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- All Visits Section ----------------
class _AllVisitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Все визиты', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        AppText(
          'Здесь собраны все посещения клиента',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------- Visits By Year ----------------
class _VisitsByYear extends StatelessWidget {
  const _VisitsByYear({
    required this.visits,
    required this.expandedVisits,
    required this.onToggle,
  });

  final List<Booking> visits;
  final Map<int, bool> expandedVisits;
  final Function(int) onToggle;

  @override
  Widget build(BuildContext context) {
    final Map<int, List<Booking>> visitsByYear = {};
    for (final visit in visits) {
      final year = visit.date.year;
      visitsByYear[year] = [...(visitsByYear[year] ?? []), visit];
    }

    final sortedYears = visitsByYear.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedYears.map((year) {
        final yearVisits = visitsByYear[year]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(year.toString(), style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ...yearVisits.map(
              (visit) => _ExpandableVisitTile(
                visit: visit,
                isExpanded: expandedVisits[visit.id] ?? false,
                onToggle: () => onToggle(visit.id),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

// ---------------- Expandable Visit Tile ----------------
class _ExpandableVisitTile extends StatelessWidget {
  const _ExpandableVisitTile({
    required this.visit,
    required this.isExpanded,
    required this.onToggle,
  });

  final Booking visit;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final hours = visit.duration.inHours;
    final minutes = visit.duration.inMinutes % 60;
    final durationLabel = minutes == 0
        ? '$hours ч'
        : '${hours > 0 ? '$hours ч ' : ''}$minutes м';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageClipped(
                width: 48,
                height: 48,
                borderRadius: 10,
                imageUrl: visit.serviceImageUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      visit.serviceName,
                      style: AppTextStyles.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AppIcons.clock.icon(
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          durationLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          '|',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          '₽${visit.price}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onToggle,
                      child: AppText(
                        isExpanded ? 'Свернуть' : 'Узнать больше',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 105,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppText(
                      visit.date.toDateString('.'),
                      style: AppTextStyles.bodyMedium,
                    ),
                    AppText(
                      visit.status.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: visit.status.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            _ExpandedContent(visit: visit),
          ],
        ],
      ),
    );
  }
}

// ---------------- Expanded Content ----------------
class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({required this.visit});
  final Booking visit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Твое примечание',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        AppText(
          visit.masterNotes.isNotEmpty
              ? visit.masterNotes
              : 'Примечание не добавлено',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 16),
        AppText(
          'Фото',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 168,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 168,
                height: 168,
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  color: AppColors.backgroundHover,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: AppText(
                    'Фото ${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ---------------- Client Header (горизонтальный, первый код) ----------------
class _ClientHeader extends StatelessWidget {
  const _ClientHeader({
    required this.client,
    required this.visitsCount,
    required this.visits,
  });

  final Client client;
  final int visitsCount;
  final List<Booking> visits;

  @override
  Widget build(BuildContext context) {
    final clientStatus = _determineClientStatus(visits);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlotAvatar(avatarUrl: client.avatarUrl, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppText(
                  client.fullName,
                  style: AppTextStyles.headingSmall.copyWith(height: 1),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (clientStatus.icon.isNotEmpty)
                      AppText(
                        clientStatus.icon,
                        style: AppTextStyles.bodyLarge,
                      ),
                    const SizedBox(width: 4),
                    AppText(
                      clientStatus.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppText(
                  '${client.city} | $visitsCount ${_pluralizeVisits(visitsCount)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Client Status ----------------
enum ClientStatus {
  newClient('Новый клиент', '🟢'),
  regularClient('Постоянный клиент', '⚪'),
  inactiveClient('Клиент давно не был', '🟠'),
  lostClient('Потерявшийся клиент', '🔘'),
  blacklistedClient('Черный список', '🔴'),
  regular('Клиент', '');

  const ClientStatus(this.label, this.icon);
  final String label;
  final String icon;
}

ClientStatus _determineClientStatus(List<Booking> visits) {
  if (visits.isEmpty) return ClientStatus.newClient;

  final now = DateTime.now();
  final completed = visits
      .where((v) => v.status == BookingStatus.completed)
      .toList();
  if (completed.isEmpty) return ClientStatus.newClient;

  completed.sort((a, b) => b.date.compareTo(a.date));
  final lastVisit = completed.first.date;
  final days = now.difference(lastVisit).inDays;
  final total = completed.length;

  if (total > 3 && completed.length >= 2) {
    final diff = completed[0].date.difference(completed[1].date).inDays;
    if (diff <= 45) return ClientStatus.regularClient;
  }

  if (days >= 30 && days <= 60) return ClientStatus.inactiveClient;
  if (days > 60) return ClientStatus.lostClient;
  if (total == 1) return ClientStatus.newClient;

  return ClientStatus.regular;
}

String _pluralizeVisits(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return 'посещение';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'посещения';
  }

  return 'посещений';
}
