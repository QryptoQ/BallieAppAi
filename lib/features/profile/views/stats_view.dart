
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(tr.myStats)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatCard(
                  icon: Icons.star,
                  label: tr.mvpVotes,
                  value: stats['mvpCount'].toString(),
                ),
                StatCard(
                  icon: Icons.check_circle,
                  label: tr.attendance,
                  value: stats['presenceCount'].toString(),
                ),
                StatCard(
                  icon: Icons.event_note,
                  label: tr.totalEvents,
                  value: stats['totalEvents'].toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
