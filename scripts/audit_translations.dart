import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:ganit_safar/content.dart';
import 'package:ganit_safar/translation_catalogue.dart';

void main(List<String> args) {
  final output = args.isEmpty ? 'build/translation-review.json' : args.first;
  final records = <String, Map<String, dynamic>>{};
  void add(Map<String, dynamic> record) {
    final words = Words.fromJson(record);
    final prior = records[words.id];
    if (prior != null &&
        jsonEncode(Words.fromJson(prior).toJson()) !=
            jsonEncode(words.toJson())) {
      throw StateError('Conflicting translation ID: ${words.id}');
    }
    records.putIfAbsent(words.id, () => record);
  }

  for (final record in learningTranslationRecords()) {
    add(record);
  }
  final files =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.dart') &&
                !file.path.endsWith('localized_text.dart'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final result = parseString(
      content: file.readAsStringSync(),
      path: file.path,
      throwIfDiagnostics: false,
    );
    result.unit.accept(
      _InterfaceTextVisitor((en, mr, offset, template) {
        if (en.trim().isEmpty || mr.trim().isEmpty) return;
        final words = Words(en, mr);
        add({
          ...words.toJson(),
          'usage': template ? 'source.template' : 'source.text',
          'sourceLocation':
              '${file.path}:${result.lineInfo.getLocation(offset).lineNumber}',
          'isTemplate': template,
        });
      }),
    );
  }
  final sorted = records.values.toList()
    ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  final statuses = <String, int>{};
  for (final record in sorted) {
    statuses.update(
      record['translationStatus'] as String,
      (n) => n + 1,
      ifAbsent: () => 1,
    );
  }
  final summary = {
    'schemaVersion': 1,
    'recordCount': sorted.length,
    'reviewStatuses': statuses,
    'chapterCount': 79,
    'chapterQuestionVariants': 790,
    'sampleVariantsPerType': 1,
    'externalTranslationRequests': 0,
    'notes': [
      'Existing text is needs-review, not automatically editor-reviewed.',
      'Source templates retain {Dart expression} placeholders for editorial review; they are not executable translation templates.',
      'One sample numerical variant per supported legacy type is exported; all generated variants use the same rich Words model.',
      'The mango provider/review metadata was supplied by the user; no provider was called or independently attested.',
    ],
  };
  File(output)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      const JsonEncoder.withIndent(
        '  ',
      ).convert({...summary, 'records': sorted}),
    );
  File('docs/validation/translation-audit.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(summary)}\n',
  );
  stdout.writeln(
    '${sorted.length} translation records validated: $statuses. Written to $output.',
  );
}

class _InterfaceTextVisitor extends RecursiveAstVisitor<void> {
  final void Function(String, String, int, bool) collect;
  _InterfaceTextVisitor(this.collect);

  String? text(Expression expression) => switch (expression) {
    SimpleStringLiteral() => expression.value,
    AdjacentStrings() => expression.strings.map(text).join(),
    StringInterpolation() =>
      expression.elements
          .map(
            (element) => switch (element) {
              InterpolationString() => element.value,
              InterpolationExpression() => '{${element.expression.toSource()}}',
            },
          )
          .join(),
    _ => null,
  };

  void pair(List<Expression> arguments, int offset) {
    if (arguments.length < 2) return;
    final en = text(arguments[0]), mr = text(arguments[1]);
    if (en != null && mr != null) {
      collect(
        en,
        mr,
        offset,
        arguments
            .take(2)
            .any(
              (arg) =>
                  arg is StringInterpolation ||
                  (arg is AdjacentStrings &&
                      arg.strings.any((item) => item is StringInterpolation)),
            ),
      );
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'tr')
      pair(node.argumentList.arguments, node.offset);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme == 'Words')
      pair(node.argumentList.arguments, node.offset);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    if (node.fields.length >= 2) {
      final pairFields = node.fields.sublist(node.fields.length - 2);
      final mr = text(pairFields.last);
      if (mr != null && RegExp(r'[\u0900-\u097f]').hasMatch(mr))
        pair(pairFields, node.offset);
    }
    super.visitRecordLiteral(node);
  }
}
