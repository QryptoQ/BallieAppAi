
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<Map<String, dynamic>?> getNextEventData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final teamId = userDoc.data()?['teamId'];
    if (teamId == null) return null;

    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('teamId', isEqualTo: teamId)
        .orderBy('date')
        .limit(1)
        .get();

    if (eventsQuery.docs.isEmpty) return null;
    return eventsQuery.docs.first.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getNextEventData(),
        future: getNextEventData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Geen aankomend programma'));
          }

          final event = snapshot.data!;
            final hasReminder = event['reminder'] == true;
          final date = event['date'] != null
              ? (event['date'] as Timestamp).toDate().toLocal().toString()
              : 'Datum onbekend';

          return Column(
          children: [
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Volgende activiteit: ${event['type'] ?? 'Onbekend'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Datum: $date'),
                if (event['location'] != null) Text('Locatie: ${event['location']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
