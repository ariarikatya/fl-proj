import 'dart:io';

import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/home/widgets/home_page.dart';
import 'package:shared/shared.dart';
import 'package:yandex_maps_mapkit_lite/init.dart' as init;

void $initializeMapKit() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    init.initMapkit(apiKey: Env.mapkitApiKey).then((_) => Dependencies().mapkitInit.complete());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    if (!Dependencies().mapkitInit.isCompleted) $initializeMapKit();

    // Ask notification permissions
    Dependencies().requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) => const HomePage();
}
