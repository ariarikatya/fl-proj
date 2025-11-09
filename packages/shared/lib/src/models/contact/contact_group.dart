import 'package:collection/collection.dart';

enum ContactGroup {
  neW('Новые', 'Новый', '🟢', 'new'),
  scheduledTomorrow('Запись на завтра', 'Запись на завтра', '🟡', 'scheduled_tomorrow'),
  regular('Постоянные', 'Постоянный', '⚪', 'regular'),
  needReappointment('Нужен повторный визит', 'Давно не были', '🟠', 'need_reappointment'),
  lost('Потерявшиеся', 'Потерявшиеся', '🔘', 'lost'),
  blacklist('Черный список', 'Черный список', '🔴', 'blacklist');

  static ContactGroup? fromJson(String key) => values.firstWhereOrNull((e) => e.jsonKey == key);
  Object? toJson() => jsonKey;

  String get description => switch (this) {
    ContactGroup.neW => 'Услуга оказана впервые',
    ContactGroup.scheduledTomorrow => 'Клиенты, записанные на завтра',
    ContactGroup.regular => 'Больше 3 посещений и последний визит не позже 4 недели назад',
    ContactGroup.needReappointment => 'Последний визит 3 недели назад',
    ContactGroup.lost => 'Нет визитов больше 1 месяца',
    ContactGroup.blacklist => 'Заблокированные клиенты',
  };

  const ContactGroup(this.label, this.labelSingleVariant, this.blob, this.jsonKey);
  final String jsonKey;
  final String label;
  final String labelSingleVariant;
  final String blob;
}
