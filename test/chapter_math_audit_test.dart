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

  test('worked arithmetic equations agree in English and Marathi variants', () {
    var equationsChecked = 0;
    final expression = RegExp(r'(\d+)\s*([+−×÷])\s*(\d+)\s*=\s*(\d+)');
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
            final a = int.parse(match[1]!);
            final b = int.parse(match[3]!);
            final result = int.parse(match[4]!);
            // Remainder notation is audited by its explicit quotient template;
            // this check covers equations that assert ordinary equality.
            if (match[2] == '÷' &&
                a % b != 0 &&
                (text.contains('remainder') || text.contains('बाकी')))
              continue;
            final expected = switch (match[2]) {
              '+' => a + b,
              '−' => a - b,
              '×' => a * b,
              '÷' => a / b,
              _ => throw StateError('Unknown operation'),
            };
            expect(result, expected, reason: '${question.id}: ${match[0]}');
            equationsChecked++;
          }
        }
      }
    }
    expect(equationsChecked, greaterThan(100));
  });
}
