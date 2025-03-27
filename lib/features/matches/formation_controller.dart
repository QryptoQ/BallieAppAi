
import 'package:cloud_firestore/cloud_firestore.dart';

class FormationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFormation(String matchId) async {
    final lineup = await _db.collection('matches').doc(matchId).collection('lineup').get();
    final positions = lineup.docs.map((doc) => doc.data()).toList();

    await _db.collection('formations').add({
      'matchId': matchId,
      'createdAt': FieldValue.serverTimestamp(),
      'players': positions,
    });
  }
}
