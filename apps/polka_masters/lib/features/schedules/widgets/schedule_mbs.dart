import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

typedef ScheduleBreak = ({Duration start, Duration end});

abstract class ScheduleMbs {
  static Future<ScheduleBreak?> addBreak(
    BuildContext context, {
    required DateTimeRange range,
    Duration? initialStart,
    Duration? initialDuration,
  }) {
    return showModalBottomSheet<ScheduleBreak?>(
      context: context,
      backgroundColor: context.ext.colors.white[100],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _AddBreakMbs(range: range, initialDuration: initialDuration, initialStart: initialStart),
    );
  }
}

/// Bottom sheet widget with Cupertino pickers
class _AddBreakMbs extends StatefulWidget {
  final DateTimeRange range;
  final Duration? initialStart;
  final Duration? initialDuration;

  const _AddBreakMbs({required this.range, this.initialStart, this.initialDuration});

  @override
  State<_AddBreakMbs> createState() => _AddBreakMbsState();
}

class _AddBreakMbsState extends State<_AddBreakMbs> {
  Duration _startTime = const Duration(hours: 10);
  Duration _endTime = const Duration(hours: 12);

  void _addBreak() {
    final $break = (start: _startTime, end: _endTime);
    context.ext.pop($break);
  }

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Добавь перерыв', style: context.ext.textTheme.headlineMedium),
            const SizedBox(height: 8),
            AppText(
              'Выбери время, когда ты хочешь прерваться от работы',
              style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
            ),
            const SizedBox(height: 10),
            AppText(widget.range.format('EE, d MMMM').capitalized, style: context.ext.textTheme.headlineSmall),
            const SizedBox(height: 24),
            FromToDurationPicker(
              startTime: _startTime,
              endTime: _endTime,
              onStartTimeChanged: (duration) {
                setState(() => _startTime = duration);
              },
              onEndTimeChanged: (duration) {
                setState(() => _endTime = duration);
              },
            ),
            const SizedBox(height: 16),
            AppTextButton.large(text: 'Добавить перерыв', onTap: _addBreak),
          ],
        ),
      ),
    );
  }
}
