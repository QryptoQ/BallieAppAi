
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  Stream<QuerySnapshot> getUserChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: uid)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;
          if (chats.isEmpty) return const Center(child: Text('Geen actieve chats'));

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final lastMessage = data['lastMessage'] ?? '';
              final updated = (data['lastUpdated'] as Timestamp?)?.toDate();

              return ListTile(
                title: Text(data['name'] ?? 'Chat'),
                subtitle: Text(lastMessage),
                trailing: updated != null
                    ? Text('${updated.hour}:${updated.minute.toString().padLeft(2, '0')}')
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatView(chatId: chat.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
