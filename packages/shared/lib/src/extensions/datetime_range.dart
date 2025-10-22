import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

extension DateTimeRangeX on DateTimeRange {
  String formatDMY() =>
      start.toJson() == end.toJson() ? start.formatDMY() : '${start.formatDMY()} - ${end.formatDMY()}';

  String toJson() => '${start.toJson()}-${end.toJson()}';
}
