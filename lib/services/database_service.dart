import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> saveTemporaryImage(Uint8List imageData) async {
    try {
      String base64Image = base64Encode(imageData);
      DocumentReference doc = await _db.collection('temp_booth').add({
        'image_data': base64Image,
        'created_at': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteImage(String docId) async {
    await _db.collection('temp_booth').doc(docId).delete();
  }
}