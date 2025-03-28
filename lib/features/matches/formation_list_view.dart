
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormationListView extends StatelessWidget {
  final String matchId;
  const FormationListView({super.key, required this.matchId});

  Future<void> applyFormation(String formationId, BuildContext context) async {
    final formationSnap = await FirebaseFirestore.instance.collection('formations').doc(formationId).get();
    final players = List<Map<String, dynamic>>.from(formationSnap.data()?['players'] ?? []);

    final lineupRef = FirebaseFirestore.instance
        .collection('matches')
        .doc(matchId)
        .collection('lineup');

    final current = await lineupRef.get();
    for (var doc in current.docs) {
      await doc.reference.delete();
    }

    for (final player in players) {
      await lineupRef.add(player);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formatie toegepast')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kies bestaande formatie')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('formations').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final formations = snapshot.data!.docs;
          if (formations.isEmpty) return const Center(child: Text('Nog geen formaties opgeslagen'));

          return ListView.builder(
            itemCount: formations.length,
            itemBuilder: (context, index) {
              final formation = formations[index];
              return ListTile(
                title: Text('Formatie ${index + 1}'),
                subtitle: Text('Spelers: ${formation['players']?.length ?? 0}'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => applyFormation(formation.id, context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
