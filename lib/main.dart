
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_binding.dart';
import 'app_routes.dart';
import 'app_translations.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BallieApp());
}

class BallieApp extends StatelessWidget {
  const BallieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BallieApp',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
      translations: AppTranslations(),
      locale: const Locale('nl'),
      fallbackLocale: const Locale('en'),
    );
  }
}
