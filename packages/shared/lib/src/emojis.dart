import 'package:flutter/material.dart';
import 'package:shared/src/models/service_categories.dart';

enum AppEmojis {
  eye,
  hair,
  lipstick,
  nails,
  razor,
  star,
  scissors,
  lollipop;

  Widget icon({Size? size}) =>
      Image.asset('assets/icons/$name.png', package: 'shared', width: size?.width ?? 24, height: size?.height ?? 24);

  static AppEmojis fromMasterService(ServiceCategories service) => switch (service) {
    ServiceCategories.nailService => nails,
    ServiceCategories.hairStyling => hair,
    ServiceCategories.eyebrowStyling => eye,
    ServiceCategories.makeup => lipstick,
    ServiceCategories.hairRemoval => razor,
    ServiceCategories.other => nails,
  };
}
