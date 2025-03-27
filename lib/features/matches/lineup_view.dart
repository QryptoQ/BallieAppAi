
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LineupView extends StatelessWidget {
  final String matchId;

  const LineupView({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController playerController = TextEditingController();

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
                    return ListTile(
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
                TextField(
                  controller: playerController,
                  decoration: const InputDecoration(labelText: 'Naam speler (testinput)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('matches')
                        .doc(matchId)
                        .collection('lineup')
                        .add({'name': playerController.text, 'position': 'Spits'});
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
