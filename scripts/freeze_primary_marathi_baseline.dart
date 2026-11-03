import 'dart:convert';
import 'dart:io';
import 'freeze_class4_baseline.dart' as baseline;

dynamic originalDrafts(dynamic value) {
  if (value is Map) {
    if (value.containsKey('marathiDraft')) {
      return {'id': value['id'], 'marathiDraft': value['marathiDraft']};
    }
    return {for (final key in value.keys) key: originalDrafts(value[key])};
  }
  if (value is List) return value.map(originalDrafts).toList();
  return value;
}

void main(List<String> args) {
  final data = jsonDecode(File(args.first).readAsStringSync()) as Map;
  final result = {
    'schemaVersion': 1,
    'beforeCommit': '23051235a266aef31750cf92af9463c66881c5f1',
    'unchangedClass4': baseline.fingerprint({
      for (final kind in ['chapters', 'legacy'])
        kind: (data[kind] as List).where((c) => c['grade'] == 4).toList(),
    }),
    'chapterSemantics': {
      for (final c in (data['chapters'] as List).where((c) => c['grade'] <= 3))
        c['id']: baseline.fingerprint(baseline.semantic(c)),
    },
    'legacySemantics': {
      for (final c in (data['legacy'] as List).where((c) => c['grade'] <= 3))
        c['id']: baseline.fingerprint(baseline.semantic(c)),
    },
    'originalDrafts': {
      for (final kind in ['chapters', 'legacy'])
        kind: {
          for (final c in (data[kind] as List).where((c) => c['grade'] <= 3))
            c['id']: baseline.fingerprint(originalDrafts(c)),
        },
    },
    'chaptersBefore': {
      for (final c in (data['chapters'] as List).where((c) => c['grade'] <= 3))
        c['id']: baseline.semantic(c),
    },
  };
  final output = File('test/fixtures/classes123_marathi_baseline.json');
  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(result)}\n',
  );
}
