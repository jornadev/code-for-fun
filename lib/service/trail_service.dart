// lib/service/trail_service.dart
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class TrailService {
  static List<Trail> getRecommendedTrails() {
    return [
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
              Question(
                id: 'q2',
                text: 'Qual o comando para imprimir "Olá Mundo" em Java?',
                answers: [
                  Answer(id: 'a1', text: 'print("Olá Mundo")', isCorrect: false),
                  Answer(id: 'a2', text: 'System.out.println("Olá Mundo")', isCorrect: true),
                  Answer(id: 'a3', text: 'console.log("Olá Mundo")', isCorrect: false),
                  Answer(id: 'a4', text: 'echo "Olá Mundo"', isCorrect: false),
                ],
              ),
            ],
          ),
          Lesson(
            id: 'l2',
            title: 'Classes e Objetos',
            isCompleted: false,
            questions: [
              // perguntas
            ],
          ),
          Lesson(
            id: 'l3',
            title: 'Herança e Polimorfismo',
            isCompleted: false,
            questions: [
              // perguntas
            ],
          ),
        ],
        iconColor: Colors.red,
      ),
      const Trail(
        id: 'algorithms',
        title: 'Algoritmos',
        icon: Icons.psychology,
        level: 'Iniciante',
        progress: 0.40,
        lessons: [
          Lesson(
            id: 'l1',
            title: 'Introdução a Algoritmos',
            isCompleted: true,
            questions: [],
          ),
          Lesson(
            id: 'l2',
            title: 'Estruturas de Dados',
            isCompleted: true,
            questions: [],
          ),
          Lesson(
            id: 'l3',
            title: 'Análise de Complexidade',
            isCompleted: false,
            questions: [],
          ),
        ],
        iconColor: Colors.blue,
      ),
    ];
  }

  static List<Trail> getUserTrails() {
    return [
      const Trail(
        id: 'beginner_programming',
        title: 'Iniciante em programação',
        icon: Icons.code,
        level: 'Iniciante',
        progress: 0.25,
        lessons: [
          Lesson(
            id: 'l1',
            title: 'Primeiros Passos',
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
        progress: 0.41,
        lessons: [],
        iconColor: Colors.black,
      ),
    ];
  }
}