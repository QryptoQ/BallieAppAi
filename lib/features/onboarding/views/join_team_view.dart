
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class JoinTeamView extends StatelessWidget {
  const JoinTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();
    final controller = Get.put(OnboardingController());

    return Scaffold(
      appBar: AppBar(title: const Text('Team joinen')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Voer de teamcode in die je hebt ontvangen'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Teamcode'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await controller.joinTeam(codeController.text.trim());
              },
              child: const Text('Team joinen'),
            ),
          ],
        ),
      ),
    );
  }
}
