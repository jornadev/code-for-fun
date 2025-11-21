import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserDocument(User user, String name) async {
    final docRef = _db.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      print("Aviso: Documento já existia, pulando criação.");
      return;
    }

    try {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': name,
        'score': 0,
        'completedLessons': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("ERRO CRÍTICO ao criar documento: $e");
      throw Exception("Falha ao salvar perfil no banco de dados.");
    }
  }

  Future<int> getUserScore() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['score'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print("Erro ao buscar pontuação: $e");
      return 0;
    }
  }

  Future<void> updateUserScore(int newScore) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _db.collection('users').doc(user.uid);
      await docRef.update({'score': newScore});
    } catch (e) {
      print("Erro ao ATUALIZAR pontuação: $e");
      throw Exception("Falha ao salvar pontuação: $e");
    }
  }

  Future<void> completeLesson(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _db.collection('users').doc(user.uid);
      await docRef.update({
        'completedLessons': FieldValue.arrayUnion([lessonId])
      });
    } catch (e) {
      print("Erro ao COMPLETAR lição: $e");
      throw Exception("Falha ao salvar progresso: $e");
    }
  }

  Future<List<String>> getCompletedLessons() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('completedLessons')) {
          List<dynamic> completed = data['completedLessons'] ?? [];
          return completed.map((item) => item.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print("Erro ao buscar lições completas: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .orderBy('score', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erro ao buscar ranking: $e");
      throw Exception("Não foi possível carregar o ranking.");
    }
  }

  Future<void> resetUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não logado.");

    try {
      final docRef = _db.collection('users').doc(user.uid);
      await docRef.update({
        'score': 0,
        'completedLessons': [],
      });
    } catch (e) {
      print("Erro ao resetar progresso no Firestore: $e");
      throw Exception("Falha ao resetar seu progresso no banco de dados.");
    }
  }
}