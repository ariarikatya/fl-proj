enum WeekDays {
  monday('Пн', 'Понедельник', true),
  tuesday('Вт', 'Вторник', true),
  wednesday('Ср', 'Среда', true),
  thursday('Чт', 'Четверг', true),
  friday('Пт', 'Пятница', true),
  saturday('Сб', 'Суббота', false),
  sunday('Вс', 'Воскресенье', false);

  static WeekDays fromJson(String value) => WeekDays.values.firstWhere((e) => e.label == value, orElse: () => monday);
  static WeekDays fromDateTime(DateTime date) =>
      WeekDays.values.firstWhere((e) => e.index == date.weekday - 1, orElse: () => monday);

  Object? toJson() => label;

  final String label;
  final String short;
  final bool isWorkday;
  const WeekDays(this.short, this.label, this.isWorkday);
}
