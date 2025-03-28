
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }
}
