import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../scripts/audit_class4_marathi.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;

void main() {
  final before =
      jsonDecode(
            File(
              'test/fixtures/class4_marathi_baseline.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final current = buildClass4AuditInventory();

  test('Classes 1–3 retain every original content and translation record', () {
    for (final grade in [1, 2, 3]) {
      final records = {
        for (final kind in ['chapters', 'legacy'])
          kind: (current[kind] as List)
              .where((record) => record['grade'] == grade)
              .toList(),
      };
      expect(
        baseline.fingerprint(records),
        before['unchangedGrades']['$grade'],
        reason: 'Class $grade must remain byte-for-byte equivalent',
      );
    }
  });

  test(
    'Class 4 legacy English, identities and mathematical models are intact',
    () {
      for (final record in (current['legacy'] as List).where(
        (record) => record['grade'] == 4,
      )) {
        expect(
          baseline.fingerprint(baseline.semantic(record)),
          before['legacySemantics'][record['id']],
          reason: record['id'],
        );
      }
    },
  );

  test(
    'Class 4 chapter changes have only the explicit English clarification exceptions',
    () {
      for (final record in (current['chapters'] as List).where(
        (record) => record['grade'] == 4,
      )) {
        final old = jsonDecode(
          jsonEncode(before['class4Before'][record['id']]),
        );
        final now = baseline.semantic(record);
        if (record['id'] == 'G4-C04') {
          for (final index in [1, 3, 5, 7, 9]) {
            for (final field in ['prompt', 'explanation', 'hint']) {
              final next = now['questions'][index]['text'][field]['english'];
              expect(
                next,
                isNot(old['questions'][index]['text'][field]['english']),
              );
              old['questions'][index]['text'][field]['english'] = next;
            }
          }
        }
        if (record['id'] == 'G4-C11') {
          for (var i = 0; i < 10; i++) {
            final text = old['questions'][i]['text']['prompt'];
            text['english'] = (text['english'] as String).replaceFirst(
              'square units long',
              'units long',
            );
          }
          final story = old['lesson']['story'];
          story['english'] = (story['english'] as String).replaceFirst(
            'square units long',
            'units long',
          );
        }
        expect(now, old, reason: record['id']);
      }
    },
  );
}
