import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ScheduleEditScreen extends StatefulWidget {
  const ScheduleEditScreen({super.key, required this.initialSchedule});

  final Schedule? initialSchedule;

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  // late final _today = DateTime.now().dateOnly;
  // late DateTimeRange? dateTimeRange =
  //     widget.initialSchedule?.dateTimeRange ?? DateTimeRange(start: _today, end: _today.add(_defaultDuration));

  // late final _durationValues = <({String text, DateTimeRange range})>[
  //   (text: 'Завтра', range: DateTimeRange(start: _today, end: _today.add(const Duration(days: 1)))),
  //   (text: '3 дня', range: DateTimeRange(start: _today, end: _today.add(const Duration(days: 3)))),
  //   (text: 'Неделя', range: DateTimeRange(start: _today, end: _today.add(const Duration(days: 7)))),
  //   (text: 'Месяц', range: DateTimeRange(start: _today, end: _today.add(const Duration(days: 30)))),
  // ];

  // static const _defaultDuration = Duration(days: 7);

  late final days = {
    for (var i in WeekDays.values)
      i: ValueNotifier(
        ScheduleDay(start: const Duration(hours: 10), end: const Duration(hours: 18), active: i.isWorkday),
      ),
  };
  late final startTime = ValueNotifier(const Duration(hours: 10));
  late final endTime = ValueNotifier(const Duration(hours: 18));
  late final startDate = ValueNotifier(DateTime.now());
  late final endDate = ValueNotifier(startDate.value.add(const Duration(days: 30)));

  void _save() {
    if (days.values.every((n) => !n.value.active)) {
      return showErrorSnackbar('Хотя бы один день должен быть активным');
    } else if (startDate.value.isAfter(endDate.value)) {
      return showErrorSnackbar('Дата начала не может быть позже даты конца');
    }

    final schedule = Schedule(
      periodStart: startDate.value,
      periodEnd: endDate.value,
      days: {for (var i in days.entries.where((e) => e.value.value.active)) i.key: i.value.value},
    );
    // TODO: Save schedule to API
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Расписание'),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.headingLarge('Моё расписание'),
                const SizedBox(height: 8),
                const AppText.secondary(
                  'Установи расписание, чтобы клиенты могли легко к тебе записаться',
                  style: AppTextStyles.bodyMedium500,
                ),
                const SizedBox(height: 16),
                const AppText.headingSmall('Выбери период'),
                const SizedBox(height: 8),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: startDate,
                        builder: (context, value, child) {
                          return AppTextButtonSecondary.large(
                            text: value.formatDMY(),
                            onTap: () async {
                              final date = await DateTimePickerMBS.pickDate(context, initValue: value);
                              if (date != null) {
                                if (date.isAfter(DateTime.now())) {
                                  startDate.value = date;
                                } else {
                                  startDate.value = DateTime.now();
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: endDate,
                        builder: (context, value, child) {
                          return AppTextButtonSecondary.large(
                            text: value.formatDMY(),
                            onTap: () async {
                              final date = await DateTimePickerMBS.pickDate(context, initValue: value);
                              if (date != null) {
                                if (date.isAfter(DateTime.now())) {
                                  endDate.value = date;
                                } else {
                                  endDate.value = startDate.value.add(const Duration(days: 1));
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppText('Выбери рабочее время', style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: startTime,
                        builder: (context, value, child) {
                          return AppTextButtonSecondary.large(
                            text: 'c ${value.toTimeString()}',
                            onTap: () async {
                              final duration = await DateTimePickerMBS.pickDuration(context, initValue: value);
                              if (duration != null && duration < endTime.value) {
                                startTime.value = duration;
                                for (var i in days.values) {
                                  i.value = i.value.copyWith(start: () => duration);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: endTime,
                        builder: (context, value, child) {
                          return AppTextButtonSecondary.large(
                            text: 'до ${value.toTimeString()}',
                            onTap: () async {
                              final duration = await DateTimePickerMBS.pickDuration(context, initValue: value);
                              if (duration != null && duration > startTime.value) {
                                endTime.value = duration;
                                for (var i in days.values) {
                                  i.value = i.value.copyWith(end: () => duration);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppText('Выбери время', style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                const AppText('Отключая день, ты делаешь \nего выходным', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                for (var i in days.entries) _DayToggle(name: i.key.short, notifier: i.value),
                const SizedBox(height: 80),
                // const SizedBox(height: 32),
                // const AppText.headingSmall('Выбери период'),
                // const SizedBox(height: 8),
                // Wrap(
                //   spacing: 8,
                //   runSpacing: 8,
                //   children: _durationValues
                //       .map(
                //         (e) => AppChip(
                //           enabled: e.range == dateTimeRange,
                //           onTap: () => setState(() => dateTimeRange = e.range),
                //           onClose: () => setState(() => dateTimeRange = null),
                //           child: AppText(e.text),
                //         ),
                //       )
                //       .toList(),
                // ),
                // const SizedBox(height: 16),
                // const AppText.headingSmall('Свой промежуток'),
                // const SizedBox(height: 8),
                // AppTextButtonSecondary.large(
                //   text: dateTimeRange?.formatDMY() ?? 'Выбери дату',
                //   onTap: () async {
                //     final range = await DateTimePickerMBS.pickDateRange(context, initValue: dateTimeRange);
                //     if (range != null) {
                //       setState(() => dateTimeRange = range);
                //     }
                //   },
                // ),
                // Row(
                //   spacing: 16,
                //   children: [
                //     Expanded(
                //       child: AppTextButtonSecondary.large(
                //         text: dateTimeRange?.formatDMY() ?? 'Выбери дату',
                //         onTap: () async {
                //           final date = await DateTimePickerMBS.pickDate(context, initValue: dateTimeRange.start);
                //           if (date != null) {
                //             if (date.isAfter(DateTime.now())) {
                //               dateTimeRange = DateTimeRange(
                //                 start: date,
                //                 end: dateTimeRange?.end ?? date.add(_defaultDuration),
                //               );
                //             } else {
                //               startDate.value = DateTime.now();
                //             }
                //           }
                //         },
                //       ),
                //     ),
                //     Expanded(
                //       child: AppTextButtonSecondary.large(
                //         text: dateTimeRange?.formatDMY() ?? 'Выбери дату',
                //         onTap: () async {
                //           final date = await DateTimePickerMBS.pickDate(context, initValue: dateTimeRange.end);
                //           if (date != null) {
                //             if (date.isAfter(DateTime.now())) {
                //               endDate.value = date;
                //             } else {
                //               endDate.value = startDate.value.add(const Duration(days: 1));
                //             }
                //           }
                //         },
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: AppTextButton.large(text: 'Сохранить изменения', onTap: _save),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({required this.notifier, required this.name});

  final ValueNotifier<ScheduleDay> notifier;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, day, child) {
            return Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: context.ext.theme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      // We use WidgetSpan because every weekday text has to have exact same width
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: SizedBox(
                          width: 30,
                          height: 22,
                          child: AppText(
                            name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: context.ext.theme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: GestureDetector(
                          onTap: () async {
                            final duration = await DateTimePickerMBS.pickDuration(
                              context,
                              initValue: day.start,
                              title: 'Выбери время начала',
                            );
                            if (duration != null) notifier.value = notifier.value.copyWith(start: () => duration);
                          },
                          child: SizedBox(
                            height: 22,
                            child: AppText(
                              day.start.toTimeString(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: context.ext.theme.textPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' - '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: GestureDetector(
                          onTap: () async {
                            final duration = await DateTimePickerMBS.pickDuration(
                              context,
                              initValue: day.end,
                              title: 'Выбери время конца',
                            );
                            if (duration != null) notifier.value = notifier.value.copyWith(end: () => duration);
                          },
                          child: SizedBox(
                            height: 22,
                            child: AppText(
                              day.end.toTimeString(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: context.ext.theme.textPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, value, child) {
            return AppSwitch(
              value: value.active,
              onChanged: (value0) => notifier.value = notifier.value.copyWith(active: () => value0),
            );
          },
        ),
      ],
    );
  }
}
