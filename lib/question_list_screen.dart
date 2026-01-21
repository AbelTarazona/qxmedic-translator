import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:questions_translator/constants.dart';
import 'package:questions_translator/csv_generator.dart';
import 'package:questions_translator/document_parser.dart';
import 'package:questions_translator/models/question.dart';
import 'package:questions_translator/text_to_image_generator.dart';
import 'package:questions_translator/widgets/about_me.dart';

enum DocumentType { word, excel }

class QuestionListScreen extends StatefulWidget {
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<Question> questions = [];
  bool isLoading = false;
  DocumentType? documentType;

  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();

  Future<void> _pickAndProcessDocumentWord() async {
    try {
      setState(() => isLoading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        List<Question> parsedQuestions = await DocumentParser.parseWord(
          result.files.first.bytes!,
        );

        setState(() {
          questions = parsedQuestions;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error picking document: ${e.toString()}');
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndProcessDocumentExcel() async {
    try {
      setState(() => isLoading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        List<Question> parsedQuestions = await DocumentParser.parseExcel(
          result.files.first.bytes!,
        );

        setState(() {
          questions = parsedQuestions;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Procesador de Preguntas (QxMedic)',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff1a1e1f),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Acerca de'),
                                        content: const AboutMe(),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cerrar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.info,
                                  color: Color(0xff1a1e1f),
                                ))
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('¿Qué tipo de documento deseas procesar?'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(
                                    () => documentType = DocumentType.excel);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: documentType == DocumentType.excel
                                      ? const Color(0xff1a1e1f)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xff1a1e1f)
                                        .withOpacity(0.5),
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Excel',
                                  style: TextStyle(
                                    color: documentType == DocumentType.excel
                                        ? Colors.white
                                        : const Color(0xff1a1e1f),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(
                                    () => documentType = DocumentType.word);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: documentType == DocumentType.word
                                      ? const Color(0xff1a1e1f)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xff1a1e1f)
                                        .withOpacity(0.5),
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Word',
                                  style: TextStyle(
                                    color: documentType == DocumentType.word
                                        ? Colors.white
                                        : const Color(0xff1a1e1f),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Visibility(
                          visible: documentType != null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  documentType == DocumentType.word
                                      ? Constants.wordRecommendations
                                      : Constants.excelRecommendations,
                                  style: const TextStyle(
                                    color: Color(0xff1a1e1f),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : documentType == DocumentType.word
                                            ? _pickAndProcessDocumentWord
                                            : _pickAndProcessDocumentExcel,
                                    icon: const Icon(
                                      Icons.upload_file_rounded,
                                      size: 50,
                                      color: Color(0xff1a1e1f),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Subir documento',
                                    style: TextStyle(
                                      color: Color(0xff1a1e1f),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (questions.isNotEmpty) ...[
                    TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Curso',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _professorController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Profesor',
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        _generateCSV();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff1a1e1f),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Generar CSV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xfff3f2f7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xff1a1e1f),
                      )
                    : questions.isNotEmpty
                        ? ListView.separated(
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              Question question = questions[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pregunta ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xff1a1e1f),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            question.title,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        if (question.title.length > 255) ...[
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  TextToImageGenerator
                                                      .generateAndDownloadImage(
                                                    question.title,
                                                    index + 1,
                                                    maxWidth: 500,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.picture_in_picture,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                  'Requiere generar imagen',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  )),
                                            ],
                                          )
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...question.options.map((option) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: option.isCorrect
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.grey
                                                          .withOpacity(0.1),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    option.label,
                                                    style: TextStyle(
                                                      color: option.isCorrect
                                                          ? Colors.green
                                                          : Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  option.text,
                                                  style: TextStyle(
                                                    color: option.isCorrect
                                                        ? Colors.green
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 16);
                            },
                          )
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.file_open_rounded,
                                size: 50,
                                color: Color(0xff1a1e1f),
                              ),
                              SizedBox(height: 16),
                              Text('Preguntas')
                            ],
                          ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _generateCSV() {
    try {
      CsvGenerator.downloadCsv(
        questions,
        _courseController.text,
        _professorController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descargando CSV...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
