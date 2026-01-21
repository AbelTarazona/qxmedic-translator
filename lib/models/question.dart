import 'package:questions_translator/models/option.dart';

class Question {
  final String title;
  final List<Option> options;
  final String correctAnswer;

  Question({
    required this.title,
    required this.options,
    required this.correctAnswer,
  });
}
