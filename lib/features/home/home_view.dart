
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_detail_view.dart';
import '../../../core/services/reminder_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Map<String, dynamic>? _eventData;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final teamId = userDoc.data()?['teamId'];
    if (teamId == null) return;

    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('teamId', isEqualTo: teamId)
        .orderBy('date')
        .limit(1)
        .get();

    if (eventsQuery.docs.isEmpty) return;

    final event = eventsQuery.docs.first;
    final eventData = event.data();

    final reminder = await ReminderService().hasReminder(event.id, user.uid);

    setState(() {
      _eventData = {...eventData, 'eventId': event.id};
      _hasReminder = reminder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _eventData == null
          ? const Center(child: Text('Geen aankomende events'))
          : ListTile(
              title: Row(
                children: [
                  Expanded(child: Text(_eventData!['title'] ?? '')),
                  if (_hasReminder)
                    const Icon(Icons.notifications_active, size: 20, color: Colors.orange),
                ],
              ),
              subtitle: Text(_eventData!['description'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailView(eventId: _eventData!['eventId']),
                  ),
                );
              },
            ),
    );
  }
}
