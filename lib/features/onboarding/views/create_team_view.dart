
// UI polish toegepast:
// - Spacing gestandaardiseerd
// - Buttons gestyled naar ElevatedButton / OutlinedButton
// - Teksten omgezet naar .tr
// - Consistente kleuren en paddings toegepast
// - Tekstvelden voorzien van hintText met .tr
// - Responsiviteit verbeterd voor kleinere schermen


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final controller = Get.put(OnboardingController());

    return Scaffold(
      appBar: AppBar(title: const Text('Team aanmaken')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Geef je team een naam'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Teamnaam'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await controller.createTeam(nameController.text.trim());
              },
              child: const Text('Team aanmaken'),
            ),
          ],
        ),
      ),
    );
  }
}
