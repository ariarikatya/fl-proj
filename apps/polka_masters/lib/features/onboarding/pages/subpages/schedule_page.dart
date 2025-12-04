import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:polka_masters/features/schedules/widgets/schedule_edit_screen.dart';
import 'package:polka_masters/features/schedules/widgets/schedule_mbs.dart';
import 'package:shared/shared.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends OnboardingPageState<SchedulePage, OnboardingController, ScheduleData?> {
  late final scheduleNotifier = useNotifier<Schedule?>('schedule', null);
  late final breaksNotifier = useNotifier<List<ScheduleBreak>>('breaks', []);

  @override
  List<Listenable> get dependencies => [scheduleNotifier, breaksNotifier];

  @override
  String? get continueLabel => 'Создать расписание';

  @override
  void complete(OnboardingController controller, ScheduleData? data) => controller.completeSchedulePage(data);

  @override
  ScheduleData? validateContinue() {
    if (scheduleNotifier.value != null) {
      return (schedule: scheduleNotifier.value!, breaks: breaksNotifier.value);
    }
    return null;
  }

  @override
  List<Widget> content() => [
    AppText('Настрой, когда ты принимаешь клиентов', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Укажи дни и время, когда ты работаешь. Так ты контролируешь свой график и избегaешь накладок',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 24),
    ScheduleEditView(
      initialSchedule: null,
      onStateUpdates: (schedule, breaks) {
        scheduleNotifier.value = schedule;
        breaksNotifier.value = List.from(breaks);
      },
    ),
  ];
}
