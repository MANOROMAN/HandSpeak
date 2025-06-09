// filepath: lib/models/quiz_category_model.dart
import 'package:flutter/material.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';

class QuizExample {
  final String word;
  final String description;
  final String gestureDescription;
  final String difficulty; // 'easy', 'medium', 'hard'

  const QuizExample({
    required this.word,
    required this.description,
    required this.gestureDescription,
    required this.difficulty,
  });
}

class QuizCategory {
  final String id;
  final String nameKey; // Translation key for the category name
  final String descriptionKey; // Translation key for the description
  final IconData icon;
  final Color color;
  final List<String> questionTypes;
  final Map<SignLanguageType, List<QuizExample>>? examples;
  final int? estimatedQuestions;
  final String? difficultyLevel;
  final List<String>? skills; // What skills this category helps develop

  const QuizCategory({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.questionTypes,
    this.examples,
    this.estimatedQuestions,
    this.difficultyLevel,
    this.skills,
  });
}

// Define quiz categories
final List<QuizCategory> quizCategories = [
  QuizCategory(
    id: 'all',
    nameKey: 'quiz.category_all',
    descriptionKey: 'quiz.category_all_desc',
    icon: Icons.category,
    color: Colors.purple,
    questionTypes: ['letters', 'numbers', 'daily_words', 'greetings', 'time_expressions'],
  ),
  QuizCategory(
    id: 'letters',
    nameKey: 'quiz.category_letters',
    descriptionKey: 'quiz.category_letters_desc',
    icon: Icons.text_fields,
    color: Colors.blue,
    questionTypes: ['letters'],
  ),
  QuizCategory(
    id: 'numbers',
    nameKey: 'quiz.category_numbers',
    descriptionKey: 'quiz.category_numbers_desc',
    icon: Icons.pin,
    color: Colors.green,
    questionTypes: ['numbers'],
  ),
  QuizCategory(
    id: 'daily_words',
    nameKey: 'quiz.category_daily_words',
    descriptionKey: 'quiz.category_daily_words_desc',
    icon: Icons.chat_bubble,
    color: Colors.orange,
    questionTypes: ['daily_words'],
  ),
  QuizCategory(
    id: 'greetings',
    nameKey: 'quiz.category_greetings',
    descriptionKey: 'quiz.category_greetings_desc',
    icon: Icons.waving_hand,
    color: Colors.red,
    questionTypes: ['greetings'],
  ),
  QuizCategory(
    id: 'time_expressions',
    nameKey: 'quiz.category_time',
    descriptionKey: 'quiz.category_time_desc',
    icon: Icons.access_time,
    color: Colors.teal,
    questionTypes: ['time_expressions'],
  ),
];
