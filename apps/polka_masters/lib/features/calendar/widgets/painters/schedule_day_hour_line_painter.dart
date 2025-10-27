import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

CustomHourLinePainter scheduleDayHourLinePainter(BuildContext context, ScheduleDay? scheduleDay) =>
    (
      Color lineColor,
      double lineHeight,
      double offset,
      double minuteHeight,
      bool showVerticalLine,
      double verticalLineOffset,
      LineStyle lineStyle,
      double dashWidth,
      double dashSpaceWidth,
      double emulateVerticalOffsetBy,
      int startHour,
      int endHour,
    ) => ScheduleDayHourLinePainter(
      lineColor: lineColor,
      lineHeight: lineHeight,
      offset: offset,
      minuteHeight: minuteHeight,
      showVerticalLine: showVerticalLine,
      startHour: startHour,
      emulateVerticalOffsetBy: emulateVerticalOffsetBy,
      verticalLineOffset: verticalLineOffset,
      lineStyle: lineStyle,
      dashWidth: dashWidth,
      dashSpaceWidth: dashSpaceWidth,
      endHour: endHour,
      scheduleDay: scheduleDay,
      defaultColor: context.ext.theme.backgroundDefault,
      disabledColor: context.ext.theme.backgroundHover,
    );

/// Paints 24 hour lines, schedule-day specific.
class ScheduleDayHourLinePainter extends CustomPainter {
  /// Color of hour line
  final Color lineColor;

  /// Height of hour line
  final double lineHeight;

  /// Offset of hour line from left.
  final double offset;

  /// Height occupied by one minute of time stamp.
  final double minuteHeight;

  /// Flag to display vertical line at left or not.
  final bool showVerticalLine;

  /// left offset of vertical line.
  final double verticalLineOffset;

  /// Style of the hour and vertical line
  final LineStyle lineStyle;

  /// Line dash width when using the [LineStyle.dashed] style
  final double dashWidth;

  /// Line dash space width when using the [LineStyle.dashed] style
  final double dashSpaceWidth;

  /// First hour displayed in the layout
  final int startHour;

  /// Emulates offset of vertical line from hour line starts.
  final double emulateVerticalOffsetBy;

  /// This field will be used to set end hour for day and week view
  final int endHour;

  final ScheduleDay? scheduleDay;

  final Color disabledColor;
  final Color defaultColor;

  /// Paints 24 hour lines.
  ScheduleDayHourLinePainter({
    required this.lineColor,
    required this.lineHeight,
    required this.minuteHeight,
    required this.offset,
    required this.showVerticalLine,
    required this.startHour,
    required this.emulateVerticalOffsetBy,
    this.endHour = 24,
    this.verticalLineOffset = 10,
    this.lineStyle = LineStyle.solid,
    this.dashWidth = 4,
    this.dashSpaceWidth = 4,
    required this.scheduleDay,
    required this.defaultColor,
    required this.disabledColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dx = offset + emulateVerticalOffsetBy;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineHeight;

    canvas.drawRect(Rect.fromLTWH(dx, 0, size.width, size.height), Paint()..color = disabledColor);
    // Paint active hours area
    if (scheduleDay?.active == true) {
      final startY = scheduleDay!.start.inMinutes * minuteHeight;
      final height = scheduleDay!.end.inMinutes - scheduleDay!.start.inMinutes;
      canvas.drawRect(Rect.fromLTWH(dx, startY, size.width, height * minuteHeight), Paint()..color = defaultColor);
    }

    for (var i = startHour + 1; i < endHour; i++) {
      final dy = (i - startHour) * minuteHeight * 60;
      if (lineStyle == LineStyle.dashed) {
        var startX = dx;
        while (startX < size.width) {
          canvas.drawLine(Offset(startX, dy), Offset(startX + dashWidth, dy), paint);
          startX += dashWidth + dashSpaceWidth;
        }
      } else {
        canvas.drawLine(Offset(dx, dy), Offset(size.width, dy), paint);
      }
    }

    if (showVerticalLine) {
      if (lineStyle == LineStyle.dashed) {
        var startY = 0.0;
        while (startY < size.height) {
          canvas.drawLine(
            Offset(offset + verticalLineOffset, startY),
            Offset(offset + verticalLineOffset, startY + dashWidth),
            paint,
          );
          startY += dashWidth + dashSpaceWidth;
        }
      } else {
        canvas.drawLine(
          Offset(offset + verticalLineOffset, 0),
          Offset(offset + verticalLineOffset, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
