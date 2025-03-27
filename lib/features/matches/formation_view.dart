
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormationView extends StatelessWidget {
  final String matchId;

  const FormationView({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opstelling (Veld)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .doc(matchId)
            .collection('lineup')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final lineup = snapshot.data!.docs;
          final Map<String, List<String>> positionGroups = {
            'Keeper': [],
            'Verdediger': [],
            'Middenveld': [],
            'Spits': [],
          };

          for (var doc in lineup) async {
            final data = doc.data() as Map<String, dynamic>;
            final pos = data['position'] ?? 'Onbekend';
            final playerId = data['playerId'];
            String name = data['name'] ?? 'Naamloos';
            if (playerId != null) {
              final userSnap = await FirebaseFirestore.instance.collection('users').doc(playerId).get();
              name = userSnap.data()?['name'] ?? 'Naamloos';
            }
            if (positionGroups.containsKey(pos)) {
              positionGroups[pos]!.add(name);
            }
          }

          return Column(
            children: [
              for (final pos in ['Spits', 'Middenveld', 'Verdediger', 'Keeper'])
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pos, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: positionGroups[pos]!
                            .map((name) => Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(name),
                                ))
                            .toList(),
                      )
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
