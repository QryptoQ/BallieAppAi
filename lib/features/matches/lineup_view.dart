
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LineupView extends StatelessWidget {
  final String matchId;

  const LineupView({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController playerController = TextEditingController();
String? selectedPlayerId;
String? selectedPosition;
List<String> positions = ['Keeper', 'Verdediger', 'Middenveld', 'Spits'];

    return Scaffold(
      appBar: AppBar(title: const Text('Opstelling')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('matches')
                  .doc(matchId)
                  .collection('lineup')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final players = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final data = players[index].data() as Map<String, dynamic>;
                    final playerId = data['playerId'];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(playerId).get(),
                        builder: (context, snapshot) {
                          final playerName = snapshot.data?.data() != null
                              ? (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Naamloos'
                              : 'Laden...';
                          return ListTile(
                            title: Text(playerName),
                            subtitle: Text(data['position'] ?? 'Positie'),
                          );
                        },
                      );
                      title: Text(data['name'] ?? 'Naamloos'),
                      subtitle: Text(data['position'] ?? 'Positie'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('users').get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final players = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedPlayerId,
                      hint: const Text('Selecteer speler'),
                      items: players.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name'] ?? 'Naamloos'),
                        );
                      }).toList(),
                      onChanged: (value) => selectedPlayerId = value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPosition,
                  hint: const Text('Selecteer positie'),
                  items: positions.map((pos) {
                    return DropdownMenuItem(value: pos, child: Text(pos));
                  }).toList(),
                  onChanged: (value) => selectedPosition = value,
                ),
                  decoration: const InputDecoration(labelText: 'Naam speler (testinput)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedPlayerId != null && selectedPosition != null) {
                    await FirebaseFirestore.instance
                        .collection('matches')
                        .doc(matchId)
                        .collection('lineup')
                        .add({'playerId': selectedPlayerId, 'position': selectedPosition});
                    playerController.clear();
                  },
                  child: const Text('Speler toevoegen'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
