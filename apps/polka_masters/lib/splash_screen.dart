import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4A5B9), Color(0xFFF0DBE5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 96),
                Center(
                  child: Text(
                    'polka',
                    style: TextStyle(
                      fontSize: 72,
                      letterSpacing: 0.75,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Text(
                    'Маркетплейс красоты\nрядом с тобой',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFFBA808E), fontWeight: FontWeight.w600),
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
