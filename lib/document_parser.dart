import 'package:docx_to_text/docx_to_text.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questions_translator/models/option.dart';
import 'package:questions_translator/models/question.dart';

class DocumentParser {
  static Future<List<Question>> parseWord(Uint8List bytes) async {
    List<Question> questions = [];

    try {
      String text = docxToText(bytes);

      final questionBlocks = text
          .split(RegExp(r'\n[A-D]\n'))
          .where((block) => block.trim().isNotEmpty);
      final answers = RegExp(r'\n[A-D]\n')
          .allMatches(text)
          .map((m) => m.group(0)!.trim())
          .toList();

      int index = 0;
      for (var block in questionBlocks) {
        if (index >= answers.length) break;

        final lines = block.split('\n');
        final optionsIndex =
            lines.indexWhere((line) => line.trim().startsWith('a)'));
        if (optionsIndex == -1) continue;

        final title = lines.sublist(0, optionsIndex).join(' ').trim();
        final optionsLine = lines[optionsIndex];

        final optionMatches =
            RegExp(r'([a-d])\) ([^.]*)\.').allMatches(optionsLine + '.');

        final options = optionMatches.map((match) {
          final label = match.group(1)!.toUpperCase();
          final text = match.group(2)!.trim();
          return Option(text: text, label: label, isCorrect: false);
        }).toList();

        final correctAnswer = answers[index];

        if (title.isNotEmpty && options.isNotEmpty) {
          for (var option in options) {
            if (option.label == correctAnswer) {
              option.isCorrect = true;
            }
          }

          questions.add(Question(
              title: title, options: options, correctAnswer: correctAnswer));
        }

        index++;
      }
    } catch (e) {
      debugPrint('Error parsing document: $e');
    }

    return questions;
  }

  static Future<List<Question>> parseExcel(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.sheets.values.first;

    print(sheet.maxRows);

    final questions = <Question>[];

    for (int i = 0; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final question = (row[0]!.value as TextCellValue).value.text ?? '';
      final options = <Option>[];

      for (int j = 1; j < row.length - 1; j++) {
        final optionValue = row[j]!.value;
        String optionText = '';
        switch (optionValue) {
          case null:
            break;
          case FormulaCellValue():
            break;
          case IntCellValue():
            optionText = optionValue.value.toString();
            break;
          case DoubleCellValue():
            optionText = optionValue.value.toString();
            break;
          case DateCellValue():
            break;
          case TextCellValue():
            optionText = optionValue.value.text ?? '';
            break;
          case BoolCellValue():
            optionText = optionValue.value.toString();
            break;
          case TimeCellValue():
            break;
          case DateTimeCellValue():
            break;
        }

        final optionLabel = String.fromCharCode(j + 64); // A, B, C, etc.
        print(optionLabel);

        final isCorrect =
            (row[row.length - 1]!.value as TextCellValue).value.text! ==
                optionLabel;
        print(isCorrect);

        options.add(Option(
          text: optionText,
          label: optionLabel,
          isCorrect: isCorrect,
        ));
      }

      final correctAnswer =
          (row[row.length - 1]!.value as TextCellValue).value.text!;
      questions.add(Question(
        title: question,
        options: options,
        correctAnswer: correctAnswer,
      ));
    }

    return questions;
  }
}
