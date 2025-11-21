import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter auxiliar para pegar o ID atual de forma limpa
  String? get _userId => _auth.currentUser?.uid;

  // 1. Criação inicial do perfil (usado no Registro)
  Future<void> createUserDocument(User user, String name) async {
    final docRef = _db.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      return; // Se já existe, não faz nada
    }

    try {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': name,
        'score': 0,
        'completedLessons': [], // Lista vazia inicial
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("ERRO CRÍTICO ao criar documento: $e");
      throw Exception("Falha ao salvar perfil no banco de dados.");
    }
  }

  // 2. Buscar Pontuação
  Future<int> getUserScore() async {
    if (_userId == null) return 0;

    try {
      final doc = await _db.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['score'] ?? 0;
      }
      return 0;
    } catch (e) {
      print("Erro ao buscar pontuação: $e");
      return 0;
    }
  }

  // 3. Atualizar Pontuação (CORRIGIDO COM MERGE)
  Future<void> updateUserScore(int newScore) async {
    if (_userId == null) return;

    try {
      // 'SetOptions(merge: true)' cria o documento se ele não existir
      await _db.collection('users').doc(_userId).set(
        {'score': newScore},
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Erro ao salvar pontuação: $e");
      throw Exception("Falha ao salvar pontuação.");
    }
  }

  // 4. Completar Lição (CORRIGIDO COM MERGE)
  Future<void> completeLesson(String lessonId) async {
    if (_userId == null) return;

    try {
      await _db.collection('users').doc(_userId).set(
        {
          // Adiciona à lista sem duplicar (arrayUnion)
          'completedLessons': FieldValue.arrayUnion([lessonId])
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Erro ao salvar progresso da lição: $e");
      throw Exception("Falha ao salvar progresso.");
    }
  }

  // 5. Buscar quais lições já foram feitas
  Future<List<String>> getCompletedLessons() async {
    if (_userId == null) return [];

    try {
      final doc = await _db.collection('users').doc(_userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['completedLessons'] != null) {
          // Converte a lista dinâmica do Firebase para List<String>
          return List<String>.from(data['completedLessons']);
        }
      }
      return [];
    } catch (e) {
      print("Erro ao buscar lições completas: $e");
      return [];
    }
  }

  // 6. Ranking Global
  Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .orderBy('score', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print("Erro ao buscar ranking: $e");
      return []; // Retorna vazio em vez de quebrar o app
    }
  }

  // 7. Resetar Progresso (Para testes ou configurações)
  Future<void> resetUserProgress() async {
    if (_userId == null) return;

    try {
      await _db.collection('users').doc(_userId).set(
        {
          'score': 0,
          'completedLessons': [],
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Erro ao resetar progresso: $e");
      throw Exception("Falha ao resetar dados.");
    }
  }
}