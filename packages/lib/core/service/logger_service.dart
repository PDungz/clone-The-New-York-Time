import 'dart:developer' as developer;

void printE(String text) {
  const red = '\x1b[31m';
  const reset = '\x1b[0m';

  final lines = text.split('\n');
  final coloredLines = lines.map((line) => '$red│ $line').join('\n');

  final fullText =
      '$red┌${'=' * 100}\n'
      '$coloredLines\n'
      '$red├${'=' * 100}$reset';

  developer.log(fullText);
}

void printI(String text) {
  const cyan = '\x1b[36m';
  const reset = '\x1b[0m';

  final lines = text.split('\n');
  final coloredLines = lines.map((line) => '$cyan│ $line').join('\n');

  final fullText =
      '$cyan┌${'=' * 100}\n'
      '$coloredLines\n'
      '$cyan├${'=' * 100}$reset';

  developer.log(fullText);
}

void printW(String text) {
  const yellow = '\x1b[33m';
  const reset = '\x1b[0m';

  final lines = text.split('\n');
  final coloredLines = lines.map((line) => '$yellow│ $line').join('\n');

  final fullText =
      '$yellow┌${'=' * 100}\n'
      '$coloredLines\n'
      '$yellow├${'=' * 100}$reset';

  developer.log(fullText);
}

void printS(String text) {
  const green = '\x1b[32m';
  const reset = '\x1b[0m';

  final lines = text.split('\n');
  final coloredLines = lines.map((line) => '$green│ $line').join('\n');

  final fullText =
      '$green┌${'=' * 100}\n'
      '$coloredLines\n'
      '$green├${'=' * 100}$reset';

  developer.log(fullText);
}
