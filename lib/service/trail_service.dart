// lib/service/trail_service.dart
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class TrailService {
  // Esta é a lista principal de todos os cursos, com progresso zerado
  static final List<Trail> _allTrails = [
    const Trail(
      id: 'java',
      title: 'Formação Java',
      icon: Icons.coffee,
      level: 'Intermediário',
      progress: 0.0, // <-- Progresso zerado
      lessons: [
        Lesson(
          id: 'l1',
          title: 'Introdução ao Java',
          isCompleted: false,
          questions: [
            Question(
              id: 'q1',
              text: 'Qual a principal característica do Java?',
              answers: [
                Answer(id: 'a1', text: 'É uma linguagem estática', isCorrect: false),
                Answer(id: 'a2', text: 'É uma linguagem interpretada', isCorrect: false),
                Answer(id: 'a3', text: 'É uma linguagem de alto nível', isCorrect: false),
                Answer(id: 'a4', text: 'É uma linguagem orientada a objetos', isCorrect: true),
              ],
            ),
          ],
        ),
      ],
      iconColor: Colors.orange,
    ),
    const Trail(
      id: 'python',
      title: 'Python do Básico',
      icon: Icons.code,
      level: 'Iniciante',
      progress: 0.0, // <-- Progresso zerado
      lessons: [
        Lesson(
          id: 'l2',
          title: 'Conceitos Básicos',
          isCompleted: false,
          questions: [
            Question(
              id: 'q2',
              text: 'O que é uma variável?',
              answers: [
                Answer(id: 'a1', text: 'Um valor que nunca muda', isCorrect: false),
                Answer(id: 'a2', text: 'Um espaço de memória para guardar dados', isCorrect: true),
                Answer(id: 'a3', text: 'Uma palavra-chave reservada', isCorrect: false),
              ],
            ),
          ],
        ),
        Lesson(
          id: 'l3',
          title: 'Tipos de Dados',
          isCompleted: false,
          questions: [],
        ),
      ],
      iconColor: Colors.deepPurple,
    ),
    const Trail(
      id: 'data_structures',
      title: 'Estrutura de dados',
      icon: Icons.share,
      level: 'Intermediário',
      progress: 0.0, // <-- Progresso zerado
      lessons: [],
      iconColor: Colors.blue,
    ),
  ];

  /// Retorna TODAS as trilhas (para a seção "Trilhas Recomendadas" e "Suas Trilhas")
  static List<Trail> getRecommendedTrails() {
    return _allTrails;
  }

  /// <-- MÉTODO ADICIONADO -->
  /// Retorna APENAS as trilhas que o usuário começou (progresso > 0)
  static List<Trail> getInProgressTrails() {
    // No seu serviço mockado, o progresso está sempre 0.0.
    // Esta função filtra corretamente, mas só retornará algo
    // se você mudar o valor de 'progress' em _allTrails para > 0.0
    // para fins de teste.
    return _allTrails.where((trail) => trail.progress > 0.0).toList();
  }
}