
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/reminder_service.dart';

class EventDetailView extends StatefulWidget {
  final String eventId;

  const EventDetailView({super.key, required this.eventId});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  bool _reminderActive = false;

  @override
  void initState() {
    super.initState();
    _loadReminderStatus();
  }

  Future<void> _loadReminderStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final isActive = await ReminderService().hasReminder(widget.eventId, uid);
    setState(() {
      _reminderActive = isActive;
    });
  }

  Future<void> _toggleReminder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_reminderActive) {
      await ReminderService().removeReminder(widget.eventId, uid);
    } else {
      await ReminderService().addReminder(widget.eventId, uid);
    }
    _loadReminderStatus();
  }

  Future<Map<String, dynamic>?> getEventData() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateAttendance(bool attending) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('attendees')
        .doc(uid)
        .set({'attending': attending});
    Get.snackbar('Aanwezigheid geregistreerd', attending ? 'Je bent aanwezig' : 'Je bent afwezig');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(_reminderActive ? Icons.notifications_active : Icons.notifications_none),
            onPressed: _toggleReminder,
            tooltip: _reminderActive ? 'Reminder uitzetten' : 'Reminder aanzetten',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getEventData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text('Event niet gevonden'));
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(data['description'] ?? ''),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Aanwezig'),
                      onPressed: () => updateAttendance(true),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Afwezig'),
                      onPressed: () => updateAttendance(false),
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
