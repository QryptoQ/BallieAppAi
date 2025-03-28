
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formation_controller.dart';

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
              if (!positionGroups[pos]!.contains(name)) {
              positionGroups[pos]!.add(name);
            }
            }
          }

          final controller = FormationController();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.saveFormation(matchId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opstelling opgeslagen als formatie')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Formatie opslaan'),
                ),
              ),
              Expanded(
                child: Container(
          color: Colors.green[100],
          child: Column(
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
                                    color: name == 'Naamloos' ? Colors.grey : Colors.green[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    name == 'Naamloos' ? 'Lege plek' : name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
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
