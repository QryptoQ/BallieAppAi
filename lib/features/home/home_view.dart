
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<String?> getTeamName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final teamId = userDoc.data()?['teamId'];
    if (teamId == null) return null;

    final teamDoc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    return teamDoc.data()?['name'] ?? 'Team zonder naam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<String?>(
        future: getTeamName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final teamName = snapshot.data ?? 'Onbekend team';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welkom bij $teamName!', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                const Text('⚽ Hier komt het programma en aanwezigheidsoverzicht'),
              ],
            ),
          );
        },
      ),
    );
  }
}
