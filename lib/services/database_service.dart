import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateUserLastSeen(String userId) async {
    try {
      await _db.collection('users').doc(userId).set(
        {
          'last_seen': FieldValue.serverTimestamp(),
          'is_anonymous': true,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUserPhotos(String userId) async {
    try {
      final query = await _db
          .collection('photos')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return query.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print("Error fetching photos: $e");
      return [];
    }
  }
}