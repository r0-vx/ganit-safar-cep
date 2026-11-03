import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ganit_safar/chapter_catalogue.dart';

void main() {
  test(
    'runtime chapter titles and page references match approved research rows',
    () {
      final rows = File(
        'docs/stage1/chapter-index.tsv',
      ).readAsLinesSync().skip(1).where((line) => line.isNotEmpty).toList();
      expect(rows.length, schoolChapters.length);
      for (var i = 0; i < rows.length; i++) {
        final columns = rows[i].split('\t');
        final chapter = schoolChapters[i];
        expect(chapter.grade, int.parse(columns[0]));
        expect(chapter.number, int.parse(columns[1]));
        expect(chapter.pageStart, int.parse(columns[2]));
        expect(chapter.pageEnd, int.parse(columns[3]));
        expect(chapter.title.mr, columns[4]);
        expect(chapter.title.en, columns[5]);
      }
    },
  );

  test(
    'arithmetic audit evaluates complete sums and parenthesized perimeter formulas',
    () {
      expect(_evaluateArithmetic('1000 + 0 + 0 + 0'), 1000);
      expect(_evaluateArithmetic('2000 + 300 + 40 + 5'), 2345);
      expect(_evaluateArithmetic('2 × (4 + 3)'), 14);
      expect(_evaluateArithmetic('5 + 3 × 2'), 11);
      expect(_evaluateArithmetic('12 ÷ 3'), 4);
      expect(_evaluateArithmetic('100 − 37'), 63);
    },
  );

  test('worked arithmetic equations agree in English and Marathi variants', () {
    var equationsChecked = 0;
    const atom = r'(?:\d+(?:\.\d+)?|\(\s*\d+(?:\s*[+−×÷]\s*\d+)*\s*\))';
    final expression = RegExp(
      '($atom(?:\\s*[+−×÷]\\s*$atom)+)\\s*=\\s*(\\d+(?:\\.\\d+)?)',
    );
    String latinDigits(String text) {
      const digits = '०१२३४५६७८९';
      return text.split('').map((c) {
        final index = digits.indexOf(c);
        return index < 0 ? c : '$index';
      }).join();
    }

    for (final chapter in schoolChapters) {
      expect(
        () => chapter.questions(count: 10),
        returnsNormally,
        reason: chapter.id,
      );
      for (final question in chapter.questions(count: 10)) {
        for (final text in [
          question.explanation.en,
          latinDigits(question.explanation.mr),
        ]) {
          for (final match in expression.allMatches(text)) {
            final arithmetic = match[1]!;
            final result = double.parse(match[2]!);
            final expected = _evaluateArithmetic(arithmetic);
            // Euclidean division's quotient/remainder template is checked by
            // its own generator tests, rather than asserting ordinary equality.
            if (arithmetic.contains('÷') &&
                expected != expected.truncateToDouble() &&
                (text.contains('remainder') || text.contains('बाकी')))
              continue;
            expect(
              result,
              closeTo(expected, 1e-9),
              reason: '${question.id}: ${match[0]}',
            );
            equationsChecked++;
          }
        }
      }
    }
    expect(equationsChecked, greaterThan(100));
  });
}

// Small arithmetic parser for audit expressions. Keeping precedence and complete
// expressions avoids accepting a suffix of a multi-term place-value expansion.
double _evaluateArithmetic(String text) {
  final input = text.replaceAll(RegExp(r'\s+'), '');
  var at = 0;
  late double Function() sum, product, atom;
  atom = () {
    if (at < input.length && input[at] == '(') {
      at++;
      final value = sum();
      if (at >= input.length || input[at++] != ')')
        throw FormatException('Unclosed arithmetic group: $text');
      return value;
    }
    final start = at;
    while (at < input.length && RegExp(r'[0-9.]').hasMatch(input[at])) {
      at++;
    }
    if (start == at) throw FormatException('Missing arithmetic value: $text');
    return double.parse(input.substring(start, at));
  };
  product = () {
    var value = atom();
    while (at < input.length && (input[at] == '×' || input[at] == '÷')) {
      final op = input[at++], right = atom();
      value = op == '×' ? value * right : value / right;
    }
    return value;
  };
  sum = () {
    var value = product();
    while (at < input.length && (input[at] == '+' || input[at] == '−')) {
      final op = input[at++], right = product();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  };
  final value = sum();
  if (at != input.length)
    throw FormatException('Unexpected arithmetic suffix: $text');
  return value;
}
