import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../scripts/audit_class4_marathi.dart';
import '../scripts/freeze_class4_baseline.dart' as baseline;
import '../scripts/freeze_primary_marathi_baseline.dart' as primary;

void main() {
  test(
    'All 65 primary chapters preserve every original draft and mathematical model',
    () {
      final before = jsonDecode(
        File(
          'test/fixtures/classes123_marathi_baseline.json',
        ).readAsStringSync(),
      );
      final inventory = buildClass4AuditInventory();
      var chapters = 0, corrections = 0;
      for (final record in (inventory['chapters'] as List).where(
        (c) => c['grade'] <= 3,
      )) {
        chapters++;
        final id = record['id'] as String;
        expect(
          baseline.fingerprint(primary.originalDrafts(record)),
          before['originalDrafts']['chapters'][id],
          reason: '$id original drafts and model',
        );
        final old = jsonDecode(jsonEncode(before['chaptersBefore'][id]));
        final current = baseline.semantic(record);
        for (final entry in (current['lesson'] as Map).entries) {
          final previous = old['lesson'][entry.key];
          corrections += _approveEnglish(
            id,
            'lesson.${entry.key}',
            previous,
            entry.value,
          );
        }
        for (
          var index = 0;
          index < (current['questions'] as List).length;
          index++
        ) {
          for (final entry
              in (current['questions'][index]['text'] as Map).entries) {
            final previous = old['questions'][index]['text'][entry.key];
            corrections += _approveEnglish(
              id,
              'question.$index.${entry.key}',
              previous,
              entry.value,
            );
          }
        }
        expect(
          current,
          old,
          reason: '$id: no unapproved English, identity or model changes',
        );
      }
      expect(chapters, 65);
      expect(corrections, 135);
    },
  );
}

int _approveEnglish(String chapter, String field, Map previous, Map current) {
  final old = previous['english'] as String, now = current['english'] as String;
  if (old == now) return 0;
  var approved = false;
  if (['G1-C15', 'G2-C06'].contains(chapter) &&
      (field.contains('.option.') ||
          field.endsWith('.explanation') ||
          field == 'lesson.workedExample') &&
      old.contains('<')) {
    approved =
        now == old.replaceAll(RegExp(r'\s*<\s*'), ' → ') ||
        now == old.replaceAll('<', '→');
  }
  if (['G1-C14', 'G1-C15', 'G2-C05', 'G2-C06'].contains(chapter) &&
      field.contains('.option.')) {
    approved |= old == 'Option 1' && now == 'None of these choices';
    approved |= old == 'Option 2' && now == 'All numbers are equal';
  }
  if (chapter == 'G2-C14' &&
      RegExp(r'^question\.(2|3|4|7|8|9)\.explanation$').hasMatch(field)) {
    approved =
        now ==
        old.replaceFirst(
          'Regroup ten ones:',
          'No regrouping is needed because the ones total is less than ten:',
        );
  }
  if (chapter == 'G3-C05' &&
      (RegExp(r'^question\.(0|2|4|5|7|9)\.hint$').hasMatch(field) ||
          field == 'lesson.hint')) {
    approved =
        old == 'Choose the unit that measures mass at this scale.' &&
        now == 'Choose the unit that measures length at this scale.';
  }
  expect(approved, true, reason: '$chapter/$field: $old → $now');
  previous['english'] = now;
  return 1;
}
