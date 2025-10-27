import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends OnboardingPageState<SchedulePage, OnboardingController, ScheduleData?> {
  late final days = {
    for (var i in WeekDays.values)
      i: useNotifier('day-$i', ScheduleDay(start: Duration(hours: 10), end: Duration(hours: 18), active: i.isWorkday)),
  };
  late final startTime = useNotifier('start', Duration(hours: 10));
  late final endTime = useNotifier('end', Duration(hours: 18));
  late final startDate = useNotifier('start-date', DateTime.now());
  late final endDate = useNotifier('end-date', startDate.value.add(Duration(days: 30)));

  @override
  List<Listenable> get dependencies => [...days.values];

  @override
  String? get continueLabel => 'Создать расписание';

  @override
  void complete(OnboardingController controller, ScheduleData? data) => controller.completeSchedulePage(data);

  @override
  ScheduleData? validateContinue() {
    // At least one weekday should be enabled
    if (days.values.every((n) => !n.value.active)) return null;

    final schedule = Schedule(
      periodStart: startDate.value,
      periodEnd: endDate.value,
      days: {for (var i in days.entries.where((e) => e.value.value.active)) i.key: i.value.value},
    );
    return schedule;
  }

  @override
  List<Widget> content() => [
    AppText('Создай расписание', style: AppTextStyles.headingLarge),
    SizedBox(height: 16),
    AppText('Выбери период', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
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
                      endDate.value = startDate.value.add(Duration(days: 1));
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    ),
    SizedBox(height: 16),
    AppText('Выбери время', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
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
    SizedBox(height: 16),
    AppText('Выбери время', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
    AppText('Отключая день, ты делаешь \nего выходным', style: AppTextStyles.bodyMedium),
    SizedBox(height: 16),
    for (var i in days.entries) _DayToggle(name: i.key.short, notifier: i.value),
  ];
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
                padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
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
                      TextSpan(text: ' - '),
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
