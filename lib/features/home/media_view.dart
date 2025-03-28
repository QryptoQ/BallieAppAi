
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaView extends StatefulWidget {
  final String eventId;
  const MediaView({super.key, required this.eventId});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  final List<String> mediaUrls = [];

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('events/${widget.eventId}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('media')
        .add({'url': url, 'timestamp': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('media')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Nog geen media toegevoegd'));
          return GridView.count(
            crossAxisCount: 3,
            children: docs
                .map((doc) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(doc['url'], fit: BoxFit.cover),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
