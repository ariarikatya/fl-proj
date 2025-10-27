import 'package:shared/src/extensions/int.dart';

extension DurationX on Duration {
  String toTimeString() =>
      '${inHours.remainder(24).toString().padLeft(2, '0')}:${inMinutes.remainder(60).toString().padLeft(2, '0')}';

  String toDurationString() {
    final hours = inHours.pluralMasculine('час');
    final minutes = inMinutes.remainder(60).pluralFeminine('минут');
    if (inHours == 0) return minutes;
    if (inMinutes.remainder(60) == 0) return hours;
    return '$hours $minutes';
  }

  String toJson() => toTimeString();

  String toDurationStringShort() {
    final hours = '$inHours ч';
    final minutes = '${inMinutes.remainder(60)} мин';
    if (inHours == 0) return minutes;
    if (inMinutes.remainder(60) == 0) return hours;
    return '$hours $minutes';
  }

  static Duration fromTimeString(String time) {
    final parts = time.split(':');
    return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
  }
}
