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
    final teamDoc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    final teamCode = teamDoc.data()?['code'] ?? '';
    Get.defaultDialog(title: 'Team aangemaakt', middleText: 'Deel deze code met je team: \$teamCode');
    // TODO: gebruiker koppelen aan team
    Get.offAllNamed('/home');
  }
}

  Future<void> joinTeam(String code) async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar('Fout', 'Gebruiker niet ingelogd');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Team niet gevonden', 'Controleer de code en probeer opnieuw');
        return;
      }

      final teamId = snapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'teamId': teamId,
        'role': 'speler',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Fout', 'Er ging iets mis bij het joinen van het team');
    }
  }
