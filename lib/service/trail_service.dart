import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class TrailService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Trail>> getTrailsStream() {
    return _db.collection('trails').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trail.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Lesson>> getLessons(String trailId) {
    return _db
        .collection('trails')
        .doc(trailId)
        .collection('lessons')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<Trail>> getTrailsOnce() async {
    final snapshot = await _db.collection('trails').get();
    return snapshot.docs.map((doc) {
      return Trail.fromMap(doc.data(), doc.id);
    }).toList();
  }
}