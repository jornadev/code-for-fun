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
        // Removemos photoUrl pois usaremos photoBase64 se existir
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

  // --- 8. SALVAR FOTO DE PERFIL (Solução Base64 / Gratuita) ---
  // Substitui o uploadProfilePicture que precisava de Storage pago
  Future<void> saveProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Lê o arquivo da imagem como bytes
      final bytes = await imageFile.readAsBytes();

      // 2. Converte para um texto gigante (Base64)
      final String base64Image = base64Encode(bytes);

      // 3. Salva esse texto direto no documento do usuário no Firestore
      await _db.collection('users').doc(user.uid).set({
        'photoBase64': base64Image,
      }, SetOptions(merge: true));

    } catch (e) {
      print("Erro ao salvar imagem base64: $e");
      throw Exception("Não foi possível salvar a foto.");
    }
  }
}