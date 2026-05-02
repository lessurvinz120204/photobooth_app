import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Auth Error: $e");
    }
  }

  static Future<String?> uploadPhotoBoothImage({
    required File imageFile,
    required String userId,
    required int gridCount,
    required int rows,
    required int cols,
    required String backgroundCategory,
    required bool usedFrontCamera,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photobooth_${userId}_$timestamp.jpg';
      final storageRef = _storage.ref().child('photo_booths/$userId/$fileName');

      // Upload file to Firebase Storage
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get file size
      final fileSize = await imageFile.length();

      // Save metadata to Firestore
      final docRef = await _db.collection('photos').add({
        'user_id': userId,
        'storage_path': 'photo_booths/$userId/$fileName',
        'download_url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'grid_count': gridCount,
        'grid_rows': rows,
        'grid_cols': cols,
        'background_category': backgroundCategory,
        'used_front_camera': usedFrontCamera,
        'file_size': fileSize,
        'filter_applied': '',
        'resolution': '1080x1080',
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint("Photo saved: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  static Future<bool> deletePhoto(String photoId) async {
    try {
      await _db.collection('photos').doc(photoId).delete();
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }

  static String getCurrentUserId() {
    return _auth.currentUser?.uid ?? 'unknown_user';
  }
}