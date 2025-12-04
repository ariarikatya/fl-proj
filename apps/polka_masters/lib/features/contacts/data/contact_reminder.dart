import 'package:shared/shared.dart';

sealed class ContactReminder {
  ContactReminder();

  factory ContactReminder.empty() = _ContactReminder$Empty;
  factory ContactReminder.notSeenIn3Weeks() = _ContactReminder$NotSeenIn3Weeks;
  factory ContactReminder.lost() = _ContactReminder$Lost;
  factory ContactReminder.appointmentTomorrow(Booking booking) = _ContactReminder$AppointmentTomorrow;

  String get text;
}

final class _ContactReminder$Empty extends ContactReminder {
  @override
  String get text => '';
}

final class _ContactReminder$NotSeenIn3Weeks extends ContactReminder {
  @override
  String get text => 'Привет! Уже больше 3 недель прошло с последнего визита. Хочешь подберу время?';
}

final class _ContactReminder$Lost extends ContactReminder {
  @override
  String get text => 'Привет! Тебя давно не было. Если хочешь, могу подобрать для тебя окошко на новый визит';
}

final class _ContactReminder$AppointmentTomorrow extends ContactReminder {
  _ContactReminder$AppointmentTomorrow(this.booking);

  final Booking booking;

  @override
  String get text =>
      'Привет! Напоминаю, что завтра (${booking.date.format('d MMMM')}) у тебя запись на ${booking.datetime.formatTimeOnly()}. Подтверди, пожалуйста, визит';
}
