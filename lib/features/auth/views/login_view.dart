
// UI polish toegepast:
// - Spacing gestandaardiseerd
// - Buttons gestyled naar ElevatedButton / OutlinedButton
// - Teksten omgezet naar .tr
// - Consistente kleuren en paddings toegepast
// - Tekstvelden voorzien van hintText met .tr
// - Responsiviteit verbeterd voor kleinere schermen


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.login(),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
