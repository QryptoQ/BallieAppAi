
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

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
              onPressed: () {
                // TODO: Team aanmaken logica koppelen
                Get.snackbar('Team aangemaakt', 'Team: \${nameController.text}');
                Get.offAllNamed('/home');
              },
              child: const Text('Team aanmaken'),
            ),
          ],
        ),
      ),
    );
  }
}
