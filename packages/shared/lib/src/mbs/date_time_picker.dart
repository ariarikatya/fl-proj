import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';

/// Abstract class with static method for showing the duration picker
abstract class DateTimePickerMBS {
  static Future<Duration?> pickDuration(BuildContext context, {Duration? initValue, String? title}) {
    return showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DurationPickerBottomSheet(initValue: initValue, title: title),
    );
  }

  static Future<DateTime?> pickDate(BuildContext context, {DateTime? initValue}) async {
    final result = await _showCalendar(context, calendarType: CalendarDatePicker2Type.single, initValue: [initValue]);
    return result?.firstOrNull;
  }

  static Future<DateTimeRange?> pickDateRange(BuildContext context, {DateTimeRange? initValue}) async {
    final result = await _showCalendar(
      context,
      calendarType: CalendarDatePicker2Type.range,
      initValue: [initValue?.start, initValue?.end],
    );
    return result != null ? DateTimeRange(start: result.first, end: result.last) : null;
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
        selectedDayHighlightColor: AppColors.accent,
        dayTextStyle: textStyle,
        weekdayLabels: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
        monthTextStyle: textStyle,
        yearTextStyle: textStyle,
        controlsTextStyle: textStyle,
        selectedMonthTextStyle: textStyle,
        selectedDayTextStyle: textStyle,
        disableModePicker: true,
        weekdayLabelTextStyle: textStyle.copyWith(color: AppColors.textSecondary),
        daySplashColor: Colors.transparent,
      ),
      value: initValue ?? [],
      dialogBackgroundColor: AppColors.backgroundDefault,
      dialogSize: Size.fromHeight(400),
    ))?.nonNulls.toList();
  }
}

/// Bottom sheet widget with Cupertino pickers
class DurationPickerBottomSheet extends StatefulWidget {
  final Duration? initValue;
  final String? title;

  const DurationPickerBottomSheet({super.key, this.initValue, this.title});

  @override
  State<DurationPickerBottomSheet> createState() => _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  late int _selectedHours;
  late int _selectedMinutes;

  final List<int> hours = List.generate(24, (i) => i); // 0-23 hours
  final List<int> minutes = [0, 15, 30, 45]; // quarter steps

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initValue?.inHours ?? 0;
    _selectedMinutes = widget.initValue?.inMinutes.remainder(60) ?? 0;

    if (!minutes.contains(_selectedMinutes)) {
      // snap to closest valid minute
      _selectedMinutes = minutes.reduce((a, b) => (a - _selectedMinutes).abs() < (b - _selectedMinutes).abs() ? a : b);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onSelectedItemChanged: (index) => _selectedHours = hours[index],
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
                      scrollController: FixedExtentScrollController(initialItem: minutes.indexOf(_selectedMinutes)),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => _selectedMinutes = minutes[index],
                      children: minutes
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
