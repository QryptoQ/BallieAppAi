
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  Future<Map<String, dynamic>> fetchStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final mvpVotes = await FirebaseFirestore.instance
        .collectionGroup('mvp_votes')
        .where('vote', isEqualTo: uid)
        .get();

    final events = await FirebaseFirestore.instance
        .collectionGroup('attendees')
        .where(FieldPath.documentId, isEqualTo: uid)
        .get();

    final attended = events.docs.where((e) => e.data()['attending'] == true).length;

    return {
      'mvpCount': mvpVotes.docs.length,
      'presenceCount': attended,
      'totalEvents': events.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn statistieken')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏅 MVP-stemmen ontvangen: ${stats['mvpCount']}'),
                const SizedBox(height: 12),
                Text('✅ Aanwezig geweest: ${stats['presenceCount']} keer'),
                const SizedBox(height: 12),
                Text('📅 Totaal aantal events: ${stats['totalEvents']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
