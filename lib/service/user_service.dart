import 'dart:convert'; // Necessário para converter a foto em texto
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // 1. Criação inicial do perfil
  Future<void> createUserDocument(User user, String name) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) return;

    try {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': name,
        'score': 0,
        'completedLessons': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastVisitedTrail': null, // Inicializa o campo de rastreamento
      });
    } catch (e) {
      print("ERRO CRÍTICO: $e");
      throw Exception("Falha ao salvar perfil.");
    }
  }

  // 2. Buscar Pontuação
  Future<int> getUserScore() async {
    if (_userId == null) return 0;
    try {
      final doc = await _db.collection('users').doc(_userId).get();
      return (doc.data()?['score'] as num?)?.toInt() ?? 0;
    } catch (e) { return 0; }
  }

  // 3. Atualizar Pontuação
  Future<void> updateUserScore(int newScore) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).set({'score': newScore}, SetOptions(merge: true));
  }

  // 4. Completar Lição
  Future<void> completeLesson(String lessonId) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).set({
      'completedLessons': FieldValue.arrayUnion([lessonId])
    }, SetOptions(merge: true));
  }

  // 5. Buscar Lições Completas
  Future<List<String>> getCompletedLessons() async {
    if (_userId == null) return [];
    try {
      final doc = await _db.collection('users').doc(_userId).get();
      return List<String>.from(doc.data()?['completedLessons'] ?? []);
    } catch (e) { return []; }
  }

  // 6. Ranking Global
  Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final q = await _db.collection('users').orderBy('score', descending: true).limit(50).get();
      return q.docs.map((d) => d.data()).toList();
    } catch (e) { return []; }
  }

  // 7. Resetar Progresso
  Future<void> resetUserProgress() async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).set(
        {'score': 0, 'completedLessons': []}, SetOptions(merge: true)
    );
  }

  // 8. SALVAR FOTO DE PERFIL (Base64)
  Future<void> saveProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await _db.collection('users').doc(user.uid).set({
        'photoBase64': base64Image,
      }, SetOptions(merge: true));

    } catch (e) {
      print("Erro ao salvar imagem base64: $e");
      throw Exception("Não foi possível salvar a foto.");
    }
  }

  // --- NOVOS MÉTODOS PARA UX (Rastreamento de Trilha) ---

  // 9. Salva o ID da última trilha visitada no documento do usuário
  Future<void> saveLastVisitedTrail(String trailId) async {
    if (_userId == null) return;

    try {
      await _db.collection('users').doc(_userId).set(
        {'lastVisitedTrail': trailId},
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Erro ao salvar última trilha visitada: $e");
    }
  }

  // 10. Busca o ID da última trilha visitada
  Future<String?> getLastVisitedTrail() async {
    if (_userId == null) return null;

    try {
      final doc = await _db.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['lastVisitedTrail'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}