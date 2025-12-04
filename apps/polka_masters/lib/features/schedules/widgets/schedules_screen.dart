import 'package:flutter/material.dart';
import 'package:polka_masters/features/schedules/controller/schedules_cubit.dart';
import 'package:shared/shared.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: DataBuilder<SchedulesCubit, List<Schedule>>(
        dataBuilder: (context, data) {
          data.sort((a, b) => b.periodEnd.compareTo(a.periodEnd));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: AppText.headingSmall('Расписания (${data.length})'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final schedule = data[index];
                    return GestureDetector(
                      onTap: () => context.ext.push(_SchedulePage(schedule)),
                      child: ListTile(
                        title: AppText(schedule.dateTimeRange.formatDMY()),
                        subtitle: AppText(schedule.days.keys.map((k) => k.short).join(', ')),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SchedulePage extends StatelessWidget {
  const _SchedulePage(this.schedule);

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Расписание'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: JsonWidget(json: schedule.toJson()),
        ),
      ),
    );
  }
}
