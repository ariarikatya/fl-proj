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
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            _ClientHeader(
              client: widget.client,
              visitsCount: widget.visits.length,
              visits: widget.visits,
            ),
            _AllVisitsSection(),
            _VisitsByYear(visits: widget.visits, expandedVisits: _expandedVisits, onToggle: _toggleVisitExpansion),
          ],
        ),
      ),
    );
  }
}


class _AllVisitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Все визиты',
          style: AppTextStyles.headingLarge,
        ),
        SizedBox(height: 8),
        AppText(
          'Здесь собраны все посещения клиента',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

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
    // Группируем визиты по годам
    final Map<int, List<Booking>> visitsByYear = {};
    for (final visit in visits) {
      final year = visit.date.year;
      visitsByYear[year] = [...(visitsByYear[year] ?? []), visit];
    }

    // Сортируем годы по убыванию
    final sortedYears = visitsByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedYears.map((year) {
        final yearVisits = visitsByYear[year]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              year.toString(),
              style: AppTextStyles.headingSmall,
            ),
            SizedBox(height: 8),
            ...yearVisits.map((visit) => _ExpandableVisitTile(
              visit: visit,
              isExpanded: expandedVisits[visit.id] ?? false,
              onToggle: () => onToggle(visit.id),
            )),
            SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

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
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    AppText(
                      visit.serviceName, 
                      style: AppTextStyles.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        AppIcons.clock.icon(
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        AppText(
                          durationLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        AppText(
                          '|',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        AppText(
                          '₽${visit.price}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
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
              Flexible(
                flex: 0,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: 8),
            _ExpandedContent(visit: visit),
          ],
        ],
      ),
    );
  }
}

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
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        AppText(
          visit.masterNotes.isNotEmpty ? visit.masterNotes : 'Примечание не добавлено',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        SizedBox(height: 16),
        AppText(
          'Фото',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16),
        // TODO: Добавить фотографии визита
        SizedBox(
          height: 168,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Заглушка
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
        SizedBox(height: 16),
      ],
    );
  }
}

// Вспомогательные функции из client_page.dart
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
  if (visits.isEmpty) {
    return ClientStatus.newClient;
  }

  final now = DateTime.now();
  final completedVisits = visits.where((v) => v.status == BookingStatus.completed).toList();
  
  if (completedVisits.isEmpty) {
    return ClientStatus.newClient;
  }

  // Сортируем по дате посещения (самые новые первыми)
  completedVisits.sort((a, b) => b.date.compareTo(a.date));
  
  final lastVisit = completedVisits.first.date;
  final daysSinceLastVisit = now.difference(lastVisit).inDays;
  final totalVisits = completedVisits.length;

  // Больше 3 посещений и визиты 1 раз в месяц
  if (totalVisits > 3) {
    // Проверяем регулярность посещений (примерно раз в месяц)
    if (completedVisits.length >= 2) {
      final secondLastVisit = completedVisits[1].date;
      final daysBetweenVisits = lastVisit.difference(secondLastVisit).inDays;
      if (daysBetweenVisits <= 45) { // примерно раз в месяц с небольшим допуском
        return ClientStatus.regularClient;
      }
    }
  }

  // Последний визит 1-2 месяца назад
  if (daysSinceLastVisit >= 30 && daysSinceLastVisit <= 60) {
    return ClientStatus.inactiveClient;
  }

  // Нет визитов больше 2 месяцев
  if (daysSinceLastVisit > 60) {
    return ClientStatus.lostClient;
  }

  // Первое посещение
  if (totalVisits == 1) {
    return ClientStatus.newClient;
  }

  return ClientStatus.regular;
}

String _pluralizeVisits(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'посещение';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'посещения';
  }
  return 'посещений';
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client, required this.visitsCount, required this.visits});

  final Client client;
  final int visitsCount;
  final List<Booking> visits;

  @override
  Widget build(BuildContext context) {
    final clientStatus = _determineClientStatus(visits);
    
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          BlotAvatar(avatarUrl: client.avatarUrl, size: 160),
          AppText(
            client.fullName,
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (clientStatus.icon.isNotEmpty) ...[
                AppText(
                  clientStatus.icon,
                  style: AppTextStyles.bodyLarge,
                ),
              ],
              AppText(
                clientStatus.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppEmojis.lollipop.icon(),
                  SizedBox(width: 4),
                  AppText(
                    client.city,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppEmojis.scissors.icon(),
                  SizedBox(width: 4),
                  AppText(
                    '$visitsCount ${_pluralizeVisits(visitsCount)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
