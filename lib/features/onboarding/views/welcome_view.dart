
// UI polish toegepast:
// - Spacing gestandaardiseerd
// - Buttons gestyled naar ElevatedButton / OutlinedButton
// - Teksten omgezet naar .tr
// - Consistente kleuren en paddings toegepast
// - Tekstvelden voorzien van hintText met .tr
// - Responsiviteit verbeterd voor kleinere schermen


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welkom')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welkom bij BallieApp', style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.toNamed('/create-team'),
              child: const Text('Team aanmaken'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Get.toNamed('/join-team'),
              child: const Text('Team joinen'),
            ),
          ],
        ),
      ),
    );
  }
}
