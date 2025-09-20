import 'package:flutter/material.dart';

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
}

class Answer {
  final String id;
  final String text;
  final bool isCorrect;

  const Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}