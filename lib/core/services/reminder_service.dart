
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReminder(String eventId, Duration before) async {
    final timestamp = Timestamp.fromDate(DateTime.now().add(before));
    await _db.collection('events').doc(eventId).collection('reminders').add({
      'type': 'presence',
      'timestamp': timestamp,
      'sent': false,
    });
  }

  Future<bool> hasUpcomingReminder(String eventId) async {
    final now = Timestamp.now();
    final reminders = await _db
        .collection('events')
        .doc(eventId)
        .collection('reminders')
        .where('timestamp', isGreaterThan: now)
        .where('sent', isEqualTo: false)
        .get();

    return reminders.docs.isNotEmpty;
  }
}
