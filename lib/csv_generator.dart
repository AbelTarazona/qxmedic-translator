import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:questions_translator/models/question.dart';
import 'package:universal_html/html.dart' as html;

class CsvGenerator {
  static String generateCsv(List<Question> questions) {
    List<List<dynamic>> rows = [];

    for (int i = 0; i < questions.length; i++) {
      Question question = questions[i];
      List<dynamic> row = [];

      // Valores por defecto
      row.add('Poll');
      row.add('Multiple choice');

      // Título/Pregunta
      String title = question.title;
      if (title.length > 255) {
        title = 'Pregunta ${i + 1}';
      }
      row.add(title);

      // Opciones
      for (var option in question.options) {
        String optionText = option.text;
        if (option.isCorrect) {
          optionText = '***$optionText';
        }
        row.add(optionText);
      }

      rows.add(row);
    }

    // Convertir a CSV
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  // Método para guardar el CSV
  static void downloadCsv(
    List<Question> questions,
    String course,
    String professor,
  ) {
    try {
      // Generar el contenido del CSV
      final csvContent = generateCsv(questions);

      // Convertir a blob
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      String fileName = '';

      final date = DateFormat('ddMMyyyy').format(DateTime.now());

      if (course != '' && professor != '') {
        final courseFormatted = course.toLowerCase().replaceAll(' ', '_');
        final professorFormatted = professor.toLowerCase().replaceAll(' ', '_');
        fileName = '${date}_${courseFormatted}_$professorFormatted.csv';
      } else {
        fileName = '${date}_questions.csv';
      }

      // Crear elemento anchor para descargar
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;

      html.document.body?.children.add(anchor);

      // Trigger download
      anchor.click();

      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al generar CSV: $e');
      throw Exception('Error al generar el archivo CSV');
    }
  }
}
