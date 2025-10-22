// lib/service/trail_service.dart
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class TrailService {
  // Lista de todas as trilhas disponíveis no app
  static final List<Trail> _allTrails = [
    const Trail(
      id: 'java',
      title: 'Formação Java',
      icon: Icons.coffee,
      level: 'Intermediário',
      progress: 0.75,
      lessons: [
        Lesson(
          id: 'l1',
          title: 'Introdução ao Java',
          isCompleted: true,
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
      id: 'logic',
      title: 'Lógica de Programação',
      icon: Icons.lightbulb_outline,
      level: 'Iniciante',
      progress: 0.25,
      lessons: [
        Lesson(
          id: 'l1',
          title: 'O que é um algoritmo?',
          isCompleted: true,
          questions: [
            Question(
              id: 'q1',
              text: 'Qual o principal objetivo de um algoritmo?',
              answers: [
                Answer(id: 'a1', text: 'Criar designs', isCorrect: false),
                Answer(id: 'a2', text: 'Resolver um problema', isCorrect: true),
                Answer(id: 'a3', text: 'Compor músicas', isCorrect: false),
              ],
            ),
          ],
        ),
        Lesson(
          id: 'l2',
          title: 'Variáveis e Constantes',
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
      progress: 0.0,
      lessons: [],
      iconColor: Colors.blue,
    ),
  ];

  // Método para a seção "Recomendados"
  static List<Trail> getRecommendedTrails() {
    // No futuro, você pode adicionar uma lógica aqui para recomendar trilhas
    return _allTrails;
  }

  // MÉTODO CORRIGIDO QUE ESTAVA FALTANDO
  // Método para a seção "Suas Trilhas"
  static List<Trail> getYourTrails() {
    // No futuro, você pode filtrar para mostrar apenas as trilhas que o usuário começou
    return _allTrails.where((trail) => trail.progress > 0).toList();
  }
}