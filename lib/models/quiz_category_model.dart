// filepath: lib/models/quiz_category_model.dart
import 'package:flutter/material.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'package:hand_speak/features/learn/data/quiz_data.dart';

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

// Define quiz categories with complete data
final List<QuizCategory> quizCategories = QuizData.getAllCategories();