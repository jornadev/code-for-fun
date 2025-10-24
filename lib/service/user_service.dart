import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca a pontuação atual do usuário no Firestore
  Future<int> getUserScore() async {
    final user = _auth.currentUser;
    if (user == null) return 0; // Se não há usuário, pontuação é 0

    try {
      // Pega o documento do usuário na coleção 'users'
      final doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // Se o documento existe, retorna a pontuação
        return doc.data()?['score'] ?? 0;
      } else {
        // Se é um novo usuário e o documento não existe, cria um com 0 pontos
        await _db.collection('users').doc(user.uid).set({'score': 0});
        return 0;
      }
    } catch (e) {
      print("Erro ao buscar pontuação: $e");
      return 0;
    }
  }

  /// Atualiza a pontuação do usuário no Firestore
  Future<void> updateUserScore(int newScore) async {
    final user = _auth.currentUser;
    if (user == null) return; // Não pode atualizar se não há usuário

    try {
      await _db.collection('users').doc(user.uid).set({
        'score': newScore,
      }, SetOptions(merge: true)); // 'merge: true' evita sobrescrever outros dados do usuário
    } catch (e) {
      print("Erro ao atualizar pontuação: $e");
    }
  }
}