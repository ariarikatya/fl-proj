enum ServiceLocation {
  home('Дома', 'at_home'),
  studio('В салоне', 'studio');

  static ServiceLocation fromJson(String value) =>
      ServiceLocation.values.firstWhere((e) => e.jsonValue == value, orElse: () => studio);

  Object? toJson() => jsonValue;

  final String label;
  final String jsonValue;
  const ServiceLocation(this.label, this.jsonValue);
}
