import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

extension DateTimeX on DateTime {
  static final _formatter = DateFormat('d MMMM, HH:mm', 'ru');
  static final _shortFormatter = DateFormat('E, d MMM', 'ru');
  static final _formatterDateOnly = DateFormat('EEEE, d MMMM', 'ru');
  static final _formatterTimeOnly = DateFormat('HH:mm', 'ru');
  static final _formatterDMY = DateFormat('dd/MM/yy', 'ru');

  String format(String format) => DateFormat(format, 'ru').format(this);
  String formatFull() => _formatter.format(this);
  String formatDateOnly() => _formatterDateOnly.format(this).capitalized;
  String formatShort() => _shortFormatter.format(this).replaceAll('.', '');
  String formatTimeOnly() => _formatterTimeOnly.format(this);
  String formatDMY() => _formatterDMY.format(this);
  String formatDateRelative() {
    final now = DateUtils.dateOnly(DateTime.now());
    final diff = now.difference(DateUtils.dateOnly(this));
    return diff.inDays == 0
        ? 'Сегодня'
        : diff.inDays == 1
        ? 'Вчера'
        : formatDateOnly();
  }

  String toDateString([String separator = '-', bool invert = false]) => invert
      ? '$year$separator${month.toString().padLeft(2, '0')}$separator${day.toString().padLeft(2, '0')}'
      : '${day.toString().padLeft(2, '0')}$separator${month.toString().padLeft(2, '0')}$separator$year';

  static DateTime fromDateString(String time, [String separator = '-']) {
    final parts = time.split(separator);
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String toJson() => toUtc().toIso8601String();
  // String toJson() => toDateString('-', true);

  String get weekdayName => WeekDays.values[weekday - 1].label;

  DateTime get dateOnly => DateTime(year, month, day);
  DateTime get withoutMinutes => DateTime(year, month, day, hour);
}
