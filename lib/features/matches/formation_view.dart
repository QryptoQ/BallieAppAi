
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'formation_controller.dart';

class FormationView extends StatelessWidget {
  final String matchId;

  const FormationView({super.key, required this.matchId});

  Future<void> generatePdf(BuildContext context) async {
    try {
      final lineupSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('lineup')
          .get();

      final positionGroups = {
        'Keeper': <String>[],
        'Verdediger': <String>[],
        'Middenveld': <String>[],
        'Spits': <String>[],
      };

      for (var doc in lineupSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'Naam onbekend';
        final position = data['position'] ?? 'Onbekend';
        if (positionGroups.containsKey(position)) {
          positionGroups[position]!.add(name);
        } else {
          positionGroups['Onbekend'] = [...?positionGroups['Onbekend'], name];
        }
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Opstelling', style: pw.TextStyle(fontSize: 20)),
              ...positionGroups.entries.map((entry) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Text(entry.key,
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ...entry.value.map((name) => pw.Text('- $name')).toList(),
                      if (entry.value.isEmpty) pw.Text('- Geen spelers')
                    ],
                  ))
            ],
          ),
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File("\${output.path}/opstelling_\$matchId.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF opgeslagen: \${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij exporteren PDF: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opstelling (Veld)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => generatePdf(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .doc(matchId)
            .collection('lineup')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final lineup = snapshot.data!.docs;
          final Map<String, List<String>> positionGroups = {
            'Keeper': [],
            'Verdediger': [],
            'Middenveld': [],
            'Spits': [],
          };

          for (var doc in lineup) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Naam onbekend';
            final position = data['position'] ?? 'Onbekend';
            if (positionGroups.containsKey(position)) {
              positionGroups[position]!.add(name);
            } else {
              positionGroups['Onbekend'] = [...?positionGroups['Onbekend'], name];
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: positionGroups.entries
                .map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        ...entry.value.map((name) => Text('- $name')).toList(),
                        if (entry.value.isEmpty) const Text('- Geen spelers'),
                        const SizedBox(height: 12),
                      ],
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
