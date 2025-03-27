
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createTeam(String name, String createdBy) async {
    final doc = await _db.collection('teams').add({
      'name': name,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
