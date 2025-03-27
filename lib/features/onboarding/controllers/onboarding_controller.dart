
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/team_service.dart';

class OnboardingController extends GetxController {
  final teamService = TeamService();
  final auth = FirebaseAuth.instance;

  Future<void> createTeam(String name) async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Gebruiker niet ingelogd');
      return;
    }

    final teamId = await teamService.createTeam(name, user.uid);
    // TODO: gebruiker koppelen aan team
    Get.offAllNamed('/home');
  }
}
