import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

dynamic ordered(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: ordered(value[key])};
  }
  if (value is List) return value.map(ordered).toList();
  return value;
}

String fingerprint(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(ordered(value)))).toString();
Map<String, dynamic> semantic(dynamic entry) {
  final m = Map<String, dynamic>.from(entry as Map);
  if (m.containsKey('text'))
    m['text'] = {
      for (final e in (m['text'] as Map).entries)
        e.key: {'id': e.value['id'], 'english': e.value['english']},
    };
  if (m.containsKey('title'))
    m['title'] = {'id': m['title']['id'], 'english': m['title']['english']};
  if (m.containsKey('lesson'))
    m['lesson'] = {
      for (final e in (m['lesson'] as Map).entries)
        e.key: {'id': e.value['id'], 'english': e.value['english']},
    };
  if (m.containsKey('help'))
    m['help'] = {
      for (final e in (m['help'] as Map).entries)
        e.key: {'id': e.value['id'], 'english': e.value['english']},
    };
  if (m.containsKey('questions'))
    m['questions'] = (m['questions'] as List).map(semantic).toList();
  return m;
}

void main(List<String> args) {
  final data = jsonDecode(File(args.first).readAsStringSync()) as Map;
  final result = {
    'schemaVersion': 1,
    'beforeCommit': 'b24f5038afa205680cbbbd2d4599fe21fea23b46',
    'unchangedGrades': {
      for (final grade in [1, 2, 3])
        '$grade': fingerprint({
          'chapters': (data['chapters'] as List)
              .where((c) => c['grade'] == grade)
              .toList(),
          'legacy': (data['legacy'] as List)
              .where((c) => c['grade'] == grade)
              .toList(),
        }),
    },
    'chapterSemantics': {
      for (final c in (data['chapters'] as List).where((c) => c['grade'] == 4))
        c['id']: fingerprint(semantic(c)),
    },
    'legacySemantics': {
      for (final c in (data['legacy'] as List).where((c) => c['grade'] == 4))
        c['id']: fingerprint(semantic(c)),
    },
    'class4Before': {
      for (final c in (data['chapters'] as List).where((c) => c['grade'] == 4))
        c['id']: semantic(c),
    },
  };
  final out = File(
    args.length > 1 ? args[1] : 'test/fixtures/class4_marathi_baseline.json',
  );
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(result)}\n',
  );
}
