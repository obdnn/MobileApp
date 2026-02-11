import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const SurveyApp());
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Форма опитування',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SurveyPage(),
    );
  }
}

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final List<String> _questions = const [
    'Як вас звати?',
    'Скільки вам років?',
    'Яке ваше місто проживання?',
    'Які у вас хобі?',
    'Що ви очікуєте від цього курсу?'
  ];

  late final List<String> _answers;
  int _index = 0;

  final TextEditingController _controller = TextEditingController();

  String _status = '';
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _answers = List<String>.filled(_questions.length, '');
    _syncController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController() {
    _controller.text = _answers[_index];
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _saveCurrentAnswer() {
    _answers[_index] = _controller.text.trim();
  }

  bool _validateNotEmpty() {
    if (_controller.text.trim().isEmpty) {
      setState(() => _status = 'Будь ласка, введіть відповідь.');
      return false;
    }
    return true;
  }

  void _prev() {
    setState(() {
      _status = '';
      _finished = false;
      _saveCurrentAnswer();
      if (_index > 0) _index--;
      _syncController();
    });
  }

  void _nextOrFinish() {
0    if (!_validateNotEmpty()) return;

    setState(() {
      _status = '';
      _saveCurrentAnswer();

      if (_index < _questions.length - 1) {
        _index++;
        _syncController();
      } else {
        _finished = true;
        _status = 'Опитування завершено. Можна зберегти відповіді у файл.';
      }
    });
  }

  String _buildReport() {
    final sb = StringBuffer();
    sb.writeln('Опитування: Форма опитування');
    sb.writeln('Дата/час: ${DateTime.now()}');
    sb.writeln('========================================');
    for (int i = 0; i < _questions.length; i++) {
      final a = _answers[i].trim().isEmpty ? '(немає відповіді)' : _answers[i].trim();
      sb.writeln('${i + 1}. Питання: ${_questions[i]}');
      sb.writeln('   Відповідь: $a');
      sb.writeln('----------------------------------------');
    }
    return sb.toString();
  }

  Future<File> _saveToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/survey_results.txt');
    await file.writeAsString(_buildReport(), mode: FileMode.write, flush: true);
    return file;
  }

  Future<void> _onSave() async {
    _saveCurrentAnswer();

    try {
      final file = await _saveToFile();
      setState(() => _status = 'Збережено у файл: ${file.path}');
    } catch (_) {
      setState(() => _status = 'Помилка під час збереження файлу.');
    }
  }

  void _reset() {
    setState(() {
      for (int i = 0; i < _answers.length; i++) {
        _answers[i] = '';
      }
      _index = 0;
      _finished = false;
      _status = '';
      _syncController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final progress = (_index + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Форма опитування'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Питання ${_index + 1} з $total',
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _questions[_index],
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ваша відповідь',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_status.isNotEmpty) setState(() => _status = '');
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _index == 0 ? null : _prev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextOrFinish,
                    icon: Icon(_index == total - 1 ? Icons.check : Icons.arrow_forward),
                    label: Text(_index == total - 1 ? 'Завершити' : 'Далі'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Зберегти у файл'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Очистити'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (_status.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _finished ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
