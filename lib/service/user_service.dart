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

      if (doc.exists && doc.data() != null) {
        return doc.data()?['score'] ?? 0;
      } else {

        print("Aviso: Documento do usuário não encontrado em getUserScore. (Isso é normal se o usuário acabou de se registrar e a tela de home carregou rápido)");
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
      await docRef.update({'score': newScore}); // Só atualiza
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

      if (doc.exists && doc.data() != null && doc.data()!.containsKey('completedLessons')) {
        final data = doc.data()!['completedLessons'] as List<dynamic>;
        return data.map((id) => id.toString()).toList();
      }
    } catch (e) {
      print("Erro ao buscar lições completas: $e");
    }
    return [];
  }
}