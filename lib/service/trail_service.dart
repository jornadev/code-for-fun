import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart'; // <--- Importante ter esse import

class TrailService {
  // Instância do banco de dados
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Busca TODAS as trilhas
  Stream<List<Trail>> getTrailsStream() {
    return _db.collection('trails').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trail.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. Busca as LIÇÕES (Aulas) de uma trilha específica
  // --- É ESTE MÉTODO QUE ESTAVA FALTANDO ---
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

  // 3. (Opcional) Busca apenas uma vez
  Future<List<Trail>> getTrailsOnce() async {
    final snapshot = await _db.collection('trails').get();
    return snapshot.docs.map((doc) {
      return Trail.fromMap(doc.data(), doc.id);
    }).toList();
  }
}