import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/datetime.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';

/// Abstract class with static method for showing the duration picker
abstract class DateTimePickerMBS {
  static Future<Duration?> pickDuration(
    BuildContext context, {
    Duration? initValue,
    Duration? minValue,
    Duration? maxValue,
    String? title,
    bool canEditHours = true,
  }) {
    return showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: context.ext.colors.white[100],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DurationPickerBottomSheet(
        initValue: initValue,
        title: title,
        canEditHours: canEditHours,
        maxValue: maxValue,
        minValue: minValue,
      ),
    );
  }

  static Future<DateTime?> pickDate(BuildContext context, {DateTime? initValue}) async {
    final result = await _showCalendar(context, calendarType: CalendarDatePicker2Type.single, initValue: [initValue]);
    return result?.firstOrNull?.dateOnly;
  }

  static Future<DateTimeRange?> pickDateRange(BuildContext context, {DateTimeRange? initValue}) async {
    final result = await _showCalendar(
      context,
      calendarType: CalendarDatePicker2Type.range,
      initValue: [initValue?.start, initValue?.end],
    );
    return result != null ? DateTimeRange(start: result.first.dateOnly, end: result.last.dateOnly) : null;
  }

  static Future<List<DateTime>?> _showCalendar(
    BuildContext context, {
    required CalendarDatePicker2Type calendarType,
    List<DateTime?>? initValue,
  }) async {
    final textStyle = AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500);
    return (await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: calendarType,
        selectedDayHighlightColor: context.ext.colors.pink[500],
        dayTextStyle: textStyle,
        weekdayLabels: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
        monthTextStyle: textStyle,
        yearTextStyle: textStyle,
        controlsTextStyle: textStyle,
        selectedMonthTextStyle: textStyle,
        selectedDayTextStyle: textStyle,
        disableModePicker: true,
        weekdayLabelTextStyle: textStyle.copyWith(color: context.ext.colors.black[700]),
        daySplashColor: Colors.transparent,
      ),
      value: initValue ?? [],
      dialogBackgroundColor: context.ext.colors.white[100],
      dialogSize: Size.fromHeight(400),
    ))?.nonNulls.toList();
  }
}

/// Bottom sheet widget with Cupertino pickers
class DurationPickerBottomSheet extends StatefulWidget {
  final Duration? initValue;
  final String? title;
  final Duration? minValue;
  final Duration? maxValue;
  final bool canEditHours;

  const DurationPickerBottomSheet({
    super.key,
    this.initValue,
    this.title,
    this.minValue,
    this.maxValue,
    this.canEditHours = true,
  });

  @override
  State<DurationPickerBottomSheet> createState() => _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  late int _selectedHours;
  late int _selectedMinutes;

  late final List<int> hours = _generateAvailableHours();
  late final List<int> minutes = List.generate(12, (i) => i * 5);

  List<int> _generateAvailableHours() {
    if (!widget.canEditHours) {
      return [widget.initValue?.inHours ?? DateTime.now().hour];
    }

    final minHour = widget.minValue?.inHours ?? 0;
    final maxHour = widget.maxValue?.inHours ?? 23;

    return List.generate(24, (i) => i).where((h) => h >= minHour && h <= maxHour).toList();
  }

  List<int> _getAvailableMinutes(int hour) {
    final minMinutes = _isMinHour(hour) ? (widget.minValue?.inMinutes.remainder(60) ?? 0) : 0;
    final maxMinutes = _isMaxHour(hour) ? (widget.maxValue?.inMinutes.remainder(60) ?? 59) : 59;

    return minutes.where((m) => m >= minMinutes && m <= maxMinutes).toList();
  }

  bool _isMinHour(int hour) => widget.minValue != null && hour == widget.minValue!.inHours;

  bool _isMaxHour(int hour) => widget.maxValue != null && hour == widget.maxValue!.inHours;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initValue?.inHours ?? 0;
    _selectedMinutes = widget.initValue?.inMinutes.remainder(60) ?? 0;

    if (!minutes.contains(_selectedMinutes)) {
      _selectedMinutes = minutes.reduce((a, b) => (a - _selectedMinutes).abs() < (b - _selectedMinutes).abs() ? a : b);
    }

    final availableMinutes = _getAvailableMinutes(_selectedHours);
    if (!availableMinutes.contains(_selectedMinutes)) {
      _selectedMinutes = availableMinutes.first;
    }
  }

  void _onHoursChanged(int index) {
    _selectedHours = hours[index];
    final availableMinutes = _getAvailableMinutes(_selectedHours);
    if (!availableMinutes.contains(_selectedMinutes)) {
      _selectedMinutes = availableMinutes.first;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final availableMinutes = _getAvailableMinutes(_selectedHours);

    return SafeArea(
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            const SizedBox(height: 12),
            AppText(
              widget.title ?? 'Выбери длительность',
              style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: hours.indexOf(_selectedHours)),
                      itemExtent: 40,
                      onSelectedItemChanged: _onHoursChanged,
                      children: hours
                          .map(
                            (h) => Center(
                              child: AppText(
                                h.toString().padLeft(2, '0'),
                                style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: availableMinutes.indexOf(_selectedMinutes),
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => _selectedMinutes = availableMinutes[index],
                      children: availableMinutes
                          .map(
                            (m) => Center(
                              child: AppText(
                                m.toString().padLeft(2, '0'),
                                style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: AppTextButton.large(
                  onTap: () {
                    Navigator.of(context).pop(Duration(hours: _selectedHours, minutes: _selectedMinutes));
                  },
                  text: 'Выбрать',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generated by Copilot
