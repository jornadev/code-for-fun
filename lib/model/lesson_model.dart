class Answer {
  final String id;
  final String text;
  final bool isCorrect;

  const Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  // Tradutor de JSON para Objeto Answer
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

  const Question({
    required this.id,
    required this.text,
    required this.answers,
  });

  // Tradutor de JSON para Objeto Question
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      answers: (map['answers'] as List<dynamic>?)
          ?.map((x) => Answer.fromMap(x))
          .toList() ??
          [],
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

  // --- ESTE ERA O MÉTODO QUE FALTAVA ---
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