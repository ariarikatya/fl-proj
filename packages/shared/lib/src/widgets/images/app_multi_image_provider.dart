import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AppMultiImageProvider extends MultiImageProvider {
  AppMultiImageProvider(super.imageProviders, {super.initialIndex});

  @override
  Widget progressIndicatorWidgetBuilder(BuildContext context, int index, {double? value}) {
    return LoadingIndicator(value: value);
  }
}
