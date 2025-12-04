enum ServiceCategories {
  nailService('Ногтевой сервис', 'nail_service'),
  hairStyling('Укладка и Волосы', 'hair_styling'),
  eyebrowStyling('Ресницы & брови', 'eyebrow_styling'),
  makeup('Макияж', 'makeup'),
  hairRemoval('Удаление волос', 'hair_removal'),
  other('Другое', 'other');

  @Deprecated('Use ServiceCategories.values instead')
  static const List<ServiceCategories> categories = [
    nailService,
    makeup,
    hairStyling,
    eyebrowStyling,
    hairRemoval,
    other,
  ];

  const ServiceCategories(this.label, this.imageName);

  static ServiceCategories fromJson(String value) =>
      ServiceCategories.values.firstWhere((e) => e.label == value, orElse: () => other);

  Object? toJson() => label;

  String get imagePath => 'assets/images/service_categories/$imageName.png';

  final String label;
  final String imageName;
}
