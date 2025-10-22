enum ServiceCategories {
  nailService('Ногтевой сервис'),
  hairStyling('Волосы & укладка'),
  eyebrowStyling('Ресницы & брови'),
  makeup('Макияж'),
  hairRemoval('Удаление волос'),
  other('Другое');

  static const List<ServiceCategories> categories = [nailService, makeup, hairStyling, eyebrowStyling, hairRemoval];

  const ServiceCategories(this.label);

  static ServiceCategories fromJson(String value) =>
      ServiceCategories.categories.firstWhere((e) => e.label == value, orElse: () => other);

  Object? toJson() => label;

  final String label;
}
