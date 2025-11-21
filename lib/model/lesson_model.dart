import 'dart:convert'; // Necessário para JSON

class Answer {
  final String id;
  final String text;
  final bool isCorrect;

  const Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;
  final String? hintText; // <-- NOVO CAMPO ADICIONADO

  const Question({
    required this.id,
    required this.text,
    required this.answers,
    this.hintText, // <-- ADICIONADO AO CONSTRUTOR
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      answers: (map['answers'] as List<dynamic>?)
          ?.map((x) => Answer.fromMap(x))
          .toList() ??
          [],
      hintText: map['hintText'] as String?, // <-- LENDO O CAMPO
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Question> questions;

  const Lesson({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.questions,
  });

  factory Lesson.fromMap(Map<String, dynamic> map, String documentId) {
    return Lesson(
      id: documentId,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      questions: (map['questions'] as List<dynamic>?)
          ?.map((x) => Question.fromMap(x))
          .toList() ??
          [],
    );
  }
}