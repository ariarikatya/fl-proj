import 'package:flutter/material.dart';
import 'package:shared/src/extensions/duration.dart';
import 'package:shared/src/mbs/date_time_picker.dart';
import 'package:shared/src/widgets/app_text_button.dart';

class DurationPicker extends StatelessWidget {
  const DurationPicker({super.key, required this.duration});

  final ValueNotifier<Duration> duration;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: duration,
      builder: (context, value, child) {
        return Row(
          spacing: 8,
          children: [
            Expanded(
              child: AppTextButtonSecondary.large(
                text: '${duration.value.inHours} час(ов)',
                onTap: () async {
                  final duration0 = await DateTimePickerMBS.pickDuration(context, initValue: duration.value);
                  if (duration0 != null) duration.value = duration0;
                },
              ),
            ),
            Expanded(
              child: AppTextButtonSecondary.large(
                text: '${duration.value.inMinutes % 60} минут',
                onTap: () async {
                  final duration0 = await DateTimePickerMBS.pickDuration(context, initValue: duration.value);
                  if (duration0 != null) duration.value = duration0;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FromToDurationPicker extends StatefulWidget {
  const FromToDurationPicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  final Duration startTime;
  final Duration endTime;
  final ValueChanged<Duration> onStartTimeChanged;
  final ValueChanged<Duration> onEndTimeChanged;

  @override
  State<FromToDurationPicker> createState() => _FromToDurationPickerState();
}

class _FromToDurationPickerState extends State<FromToDurationPicker> {
  late Duration _startTime = widget.startTime;
  late Duration _endTime = widget.endTime;

  @override
  void didUpdateWidget(covariant FromToDurationPicker oldWidget) {
    if (oldWidget.startTime != widget.startTime) _startTime = widget.startTime;
    if (oldWidget.endTime != widget.endTime) _endTime = widget.endTime;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: AppTextButtonSecondary.large(
            text: 'c ${_startTime.toTimeString()}',
            onTap: () async {
              final duration = await DateTimePickerMBS.pickDuration(
                context,
                initValue: _startTime,
                title: 'Выбери начало',
              );
              if (duration != null) {
                setState(() {
                  _startTime = duration;
                  widget.onStartTimeChanged(duration);
                  if (duration > _endTime) {
                    _endTime = _startTime;
                    widget.onEndTimeChanged(_endTime);
                  }
                });
              }
            },
          ),
        ),
        Expanded(
          child: AppTextButtonSecondary.large(
            text: 'до ${_endTime.toTimeString()}',
            onTap: () async {
              final duration = await DateTimePickerMBS.pickDuration(
                context,
                initValue: _endTime,
                title: 'Выбери окончание',
              );
              if (duration != null && duration > _startTime) {
                setState(() => _endTime = duration);
                widget.onEndTimeChanged(duration);
              }
            },
          ),
        ),
      ],
    );
  }
}
