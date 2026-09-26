import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reel_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'reels';

  Future<void> saveReel(ReelModel reel) async {
    try {
      await _firestore.collection(collectionName).doc(reel.id).set(reel.toMap());
    } catch (e) {
      print('Firebase Error: $e');
      rethrow;
    }
  }

  Future<void> Like(String reelId, bool isLiking) async {
    try {
      await _firestore.collection(collectionName).doc(reelId).update({
        'likes': FieldValue.increment(isLiking ? 1 : -1),
      });
    } catch (e) {
      print('Firebase Like Error: $e');
    }
  }

  Stream<List<ReelModel>> getReels() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReelModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
