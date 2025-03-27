
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailView extends StatelessWidget {
  final String eventId;

  const EventDetailView({super.key, required this.eventId});

  Future<Map<String, dynamic>?> getEventData() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateAttendance(bool attending) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .doc(uid)
        .set({'attending': attending});
    Get.snackbar('Aanwezigheid geregistreerd', attending ? 'Je bent aanwezig' : 'Je bent afwezig');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evenement detail')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getEventData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          final date = data['date'] != null
              ? (data['date'] as Timestamp).toDate().toLocal().toString()
              : 'Onbekende datum';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['type'] ?? 'Onbekend', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text('Datum: $date'),
                if (data['location'] != null) Text('Locatie: ${data['location']}'),
                const SizedBox(height: 32),
                const Text('Ben je erbij?', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => updateAttendance(true),
                      child: const Text('Ja'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => updateAttendance(false),
                      child: const Text('Nee'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
