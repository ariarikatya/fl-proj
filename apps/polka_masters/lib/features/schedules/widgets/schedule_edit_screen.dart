import 'package:flutter/material.dart';
import 'package:polka_masters/features/schedules/controller/schedules_cubit.dart';
import 'package:polka_masters/features/schedules/widgets/schedule_mbs.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class NewScheduleEditScreen extends StatefulWidget {
  const NewScheduleEditScreen({super.key});

  @override
  State<NewScheduleEditScreen> createState() => _NewScheduleEditScreenState();
}

class _NewScheduleEditScreenState extends State<NewScheduleEditScreen> {
  bool _saving = false;
  Schedule? _currentSchedule;
  var _breaks = <ScheduleBreak>[];

  void _save() async {
    final schedule = _currentSchedule;
    if (schedule == null) return;

    setState(() => _saving = true);
    await context.read<SchedulesCubit>().createSchedule(schedule, _breaks);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Расписание'),
      child: DataBuilder<SchedulesCubit, List<Schedule>>(
        dataBuilder: (context, data) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText.headingLarge('Моё расписание'),
                    const SizedBox(height: 8),
                    const AppText.secondary(
                      'Установи расписание, чтобы клиенты могли легко к тебе записаться',
                      style: AppTextStyles.bodyMedium500,
                    ),
                    const SizedBox(height: 16),
                    ScheduleEditView(
                      initialSchedule: data.firstOrNull,
                      onStateUpdates: (schedule, breaks) => setState(() {
                        _currentSchedule = schedule;
                        _breaks = List.from(breaks);
                      }),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: AppTextButton.large(
                    text: 'Сохранить изменения',
                    onTap: _save,
                    enabled: !_saving && _currentSchedule != null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScheduleEditView extends StatefulWidget {
  const ScheduleEditView({super.key, required this.initialSchedule, required this.onStateUpdates});

  final Schedule? initialSchedule;
  final void Function(Schedule? schedule, List<ScheduleBreak> breaks) onStateUpdates;

  @override
  State<ScheduleEditView> createState() => _ScheduleEditViewState();
}

class _ScheduleEditViewState extends State<ScheduleEditView> {
  late final _periodDurations = [
    (start: today, end: today, label: 'Сегодня'),
    (start: today.add(const Duration(days: 1)), end: today.add(const Duration(days: 1)), label: 'Завтра'),
    (start: today, end: today.add(const Duration(days: 2)), label: '3 дня'),
    (start: today, end: today.add(const Duration(days: 6)), label: 'Неделя'),
    (start: today, end: today.add(Duration(days: DateUtils.getDaysInMonth(today.year, today.month))), label: 'Месяц'),
  ];
  final today = DateTime.now().dateOnly;
  final breaks = <ScheduleBreak>[];

  late Duration startTime = widget.initialSchedule?.days.entries.firstOrNull?.value.start ?? const Duration(hours: 10);
  late Duration endTime = widget.initialSchedule?.days.entries.firstOrNull?.value.end ?? const Duration(hours: 18);
  late DateTime startDate = widget.initialSchedule?.periodStart.dateOnly ?? today.dateOnly;
  late DateTime endDate = widget.initialSchedule?.periodEnd.dateOnly ?? startDate.add(const Duration(days: 30));

  late final days = {
    for (var i in WeekDays.values)
      i: ScheduleDay(
        start: widget.initialSchedule?.days[i]?.start ?? startTime,
        end: widget.initialSchedule?.days[i]?.end ?? endTime,
        active: widget.initialSchedule?.days[i]?.active ?? false,
      ),
  };

  Schedule? _lastUpdatedValue;

  @override
  void didChangeDependencies() {
    _update();
    super.didChangeDependencies();
  }

  void _update() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final value = validate();
      if (_lastUpdatedValue != value) {
        _lastUpdatedValue = value;
        widget.onStateUpdates(value, breaks);
      }
    });
  }

  Schedule? validate() {
    Null returnWithError(String error) {
      if (widget.initialSchedule != null) {
        showErrorSnackbar(error);
      }
    }

    // At least one weekday should be enabled
    if (startDate.isAfter(endDate)) {
      return returnWithError('Дата начала не может быть позже даты конца');
    } else {
      final schedule = Schedule(
        periodStart: startDate,
        periodEnd: endDate,
        days: {for (var i in days.entries.where((e) => e.value.active)) i.key: i.value},
        createdAt: DateTime.now(),
      );
      return schedule;
    }
  }

  List<WeekDays> filteredWeekDays() {
    final start = startDate.dateOnly;
    final end = endDate.dateOnly;
    if (start.isAfter(end)) return [];

    final Set<WeekDays> found = {};
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      // DateTime.weekday: 1 = Monday, ... 7 = Sunday
      final index = d.weekday - 1;
      if (index >= 0 && index < WeekDays.values.length) {
        found.add(WeekDays.values[index]);
      }
    }

    return WeekDays.values.where((w) => found.contains(w)).toList();
  }

  void addBreak() async {
    final $break = await ScheduleMbs.addBreak(
      context,
      range: DateTimeRange(start: startDate, end: endDate),
    );
    if ($break != null) breaks.add($break);
    _update();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDays = filteredWeekDays();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Выбери период', style: context.ext.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: AppTextButtonSecondary.large(
                text: startDate.formatDMY(),
                onTap: () async {
                  final date = await DateTimePickerMBS.pickDate(context, initValue: startDate);
                  if (date != null) {
                    startDate = date;
                    _update();
                  }
                },
              ),
            ),
            Expanded(
              child: AppTextButtonSecondary.large(
                text: endDate.formatDMY(),
                onTap: () async {
                  final date = await DateTimePickerMBS.pickDate(context, initValue: endDate);
                  if (date != null) {
                    endDate = date;
                    _update();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: [
            for (var option in _periodDurations)
              AppChip(
                enabled: DateUtils.isSameDay(startDate, option.start) && DateUtils.isSameDay(endDate, option.end),
                onTap: () {
                  startDate = option.start;
                  endDate = option.end;
                  for (var day in days.entries) {
                    days[day.key] = day.value.copyWith(active: () => true);
                  }
                  _update();
                },
                onClose: () {},
                child: Row(
                  children: [
                    AppText(
                      option.label,
                      style: context.ext.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 36),
        AppText('Выбери рабочее время', style: context.ext.textTheme.headlineMedium),
        const SizedBox(height: 16),
        FromToDurationPicker(
          startTime: startTime,
          endTime: endTime,
          onStartTimeChanged: (duration) {
            startTime = duration;
            for (var e in days.entries) {
              days[e.key] = e.value.copyWith(start: () => duration);
            }
            _update();
          },
          onEndTimeChanged: (duration) {
            endTime = duration;
            for (var e in days.entries) {
              days[e.key] = e.value.copyWith(end: () => duration);
            }
            _update();
          },
        ),
        const SizedBox(height: 20),
        AppFloatingActionButton$Add(text: 'Добавить перерыв', onTap: addBreak),
        if (breaks.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (var $break in breaks)
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                spacing: 16,
                children: [
                  AppText('Перерыв', style: context.ext.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  AppText.rich(
                    style: context.ext.textTheme.bodyLarge?.copyWith(
                      color: context.ext.colors.black[900],
                      fontWeight: FontWeight.bold,
                    ),
                    [
                      TextSpan(
                        text: $break.start.toTimeString(),
                        style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ' - '),
                      TextSpan(
                        text: $break.end.toTimeString(),
                        style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      breaks.remove($break);
                      _update();
                    },
                    child: AppText(
                      'Удалить',
                      style: context.ext.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
        AppText('Настрой свои рабочие дни', style: context.ext.textTheme.headlineMedium),
        const SizedBox(height: 16),
        AppText(
          'Отключая день, ты делаешь его выходным',
          style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var e in days.entries)
              if (filteredDays.contains(e.key)) _dayToggle(name: e.key.short, dayEntry: e),
          ],
        ),
      ],
    );
  }

  Widget _dayToggle({required String name, required MapEntry<WeekDays, ScheduleDay> dayEntry}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.ext.colors.black[900],
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
                          color: context.ext.colors.black[900],
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
                          initValue: dayEntry.value.start,
                          title: 'Выбери время начала',
                        );
                        if (duration != null) {
                          days[dayEntry.key] = dayEntry.value.copyWith(start: () => duration);
                          _update();
                        }
                      },
                      child: SizedBox(
                        height: 22,
                        child: AppText(
                          dayEntry.value.start.toTimeString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: context.ext.colors.black[900],
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
                          initValue: dayEntry.value.end,
                          title: 'Выбери время конца',
                        );
                        if (duration != null) {
                          days[dayEntry.key] = dayEntry.value.copyWith(end: () => duration);
                          _update();
                        }
                      },
                      child: SizedBox(
                        height: 22,
                        child: AppText(
                          dayEntry.value.end.toTimeString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: context.ext.colors.black[900],
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
          AppSwitch(
            value: dayEntry.value.active,
            onChanged: (value0) {
              days[dayEntry.key] = dayEntry.value.copyWith(active: () => value0);
              _update();
            },
          ),
        ],
      ),
    );
  }
}
