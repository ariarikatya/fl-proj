import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/master_onboarding.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: switch (Theme.brightnessOf(context)) {
          Brightness.light => Colors.white,
          Brightness.dark => Colors.black,
        },
        body: FadeInTransition(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFFFEBF4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 96),
                Center(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.all(64),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints.loose(const Size.fromWidth(220)),
                          child: Image.asset('assets/logo/logo.png'),
                        ),
                        const Positioned(right: -46, top: -26, child: Text('Pro', style: AppTextStyles.headingLarge)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Text(
                    'Помогаем тебе расти,\nа не просто записывать клиентов',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF52443E)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
