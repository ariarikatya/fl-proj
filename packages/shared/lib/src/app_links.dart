import 'package:flutter/foundation.dart';

abstract class AppLinks {
  static const docs = _Docs._();
  static const stores = _Stores._();
}

final class _Docs {
  const _Docs._();

  final privacyPolicy = 'https://polka-bm.online/privacy-policy.html';
  final licenseAgreement = 'https://polka-bm.online/license-agreement.html';
  final termsOfUse = 'https://polka-bm.online/terms-of-use.html';
}

final class _Stores {
  const _Stores._();

  final googlePlay = const _StoreLinks$GooglePlay();
  final appStore = const _StoreLinks$AppStore();

  _StoreLinks fromCurrentPlatform() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => googlePlay,
      TargetPlatform.iOS => appStore,
      _ => throw UnsupportedError('Unsupported platform: $defaultTargetPlatform'),
    };
  }
}

sealed class _StoreLinks {
  const _StoreLinks();

  String get clients;
  String get masters;
}

final class _StoreLinks$GooglePlay extends _StoreLinks {
  const _StoreLinks$GooglePlay();

  @override
  String get clients => 'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace';

  @override
  String get masters => 'https://play.google.com/store/apps/details?id=com.mads.polkapro';
}

final class _StoreLinks$AppStore extends _StoreLinks {
  const _StoreLinks$AppStore();

  @override
  String get clients => 'https://apps.apple.com/ru/app/id6740820071';

  @override
  String get masters => 'https://apps.apple.com/ru/app/id6740822813';
}
