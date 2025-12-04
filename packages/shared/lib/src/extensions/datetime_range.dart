import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

extension DateTimeRangeX on DateTimeRange {
  String formatDMY() =>
      DateUtils.isSameDay(start, end) ? start.formatDMY() : '${start.formatDMY()} - ${end.formatDMY()}';

  String format(String format) =>
      DateUtils.isSameDay(start, end) ? start.format(format) : '${start.format(format)} - ${end.format(format)}';

  String toJson() => '${start.toJson()}-${end.toJson()}';

  bool containsDate(DateTime date) => !date.dateOnly.isAfter(end.dateOnly) && !date.dateOnly.isBefore(start.dateOnly);
}
