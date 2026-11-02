import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Offline bilingual text plus its translation/review provenance.
///
/// The two positional arguments remain compatible with all existing content.
/// A provider name records provenance only: rendering never calls a service.
class Words {
  final String en;
  final String _marathi;
  final String? _id, _draft, _spoken, _bilingual;
  final String translationProvider, translationStatus, reviewNotes;
  final List<String> mathGlossaryTerms;

  const Words(
    this.en,
    this._marathi, {
    String? id,
    String? marathiDraft,
    String? marathiSpoken,
    String? bilingual,
    this.translationProvider = 'local-authored',
    this.translationStatus = 'needs-review',
    this.mathGlossaryTerms = const [],
    this.reviewNotes = '',
  }) : _id = id,
       _draft = marathiDraft,
       _spoken = marathiSpoken,
       _bilingual = bilingual;

  String get english => en;
  String get marathiDraft => _draft ?? _marathi;
  String get marathiSpoken => _spoken ?? _marathi;
  String get mr => marathiSpoken.trim().isEmpty ? marathiDraft : marathiSpoken;
  String get bilingual => _bilingual ?? '$en\n$mr';
  bool get isEditorReviewed => translationStatus == 'editor-reviewed';

  /// Stable content identity when older call sites have no semantic ID yet.
  String get id =>
      _id ??
      'text_${sha256.convert(utf8.encode(jsonEncode([en, marathiDraft, marathiSpoken]))).toString().substring(0, 24)}';

  String inLanguage(int language) => switch (language) {
    0 => en,
    1 => mr,
    _ => bilingual,
  };

  Map<String, String> get audioReady => {'en': en, 'mr': mr};
  Map<String, String> get accessibilityReady => {
    'en': en,
    'mr': mr,
    'bilingual': bilingual,
  };

  Words identified(String contextId, {List<String> glossaryTerms = const []}) =>
      Words(
        en,
        _marathi,
        id: _id ?? contextId,
        marathiDraft: marathiDraft,
        marathiSpoken: marathiSpoken,
        bilingual: _bilingual,
        translationProvider: translationProvider,
        translationStatus: translationStatus,
        mathGlossaryTerms: List.unmodifiable({
          ...mathGlossaryTerms,
          ...glossaryTerms,
        }),
        reviewNotes: reviewNotes,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'english': en,
    'marathiDraft': marathiDraft,
    'marathiSpoken': marathiSpoken,
    'bilingual': bilingual,
    'translationProvider': translationProvider,
    'translationStatus': translationStatus,
    'mathGlossaryTerms': List<String>.of(mathGlossaryTerms),
    'reviewNotes': reviewNotes,
  };

  /// Accepts the new review record or a legacy {en, mr} text pair.
  factory Words.fromJson(Map<String, dynamic> data) {
    String read(String key, [Object? fallback]) {
      final value = data[key] ?? fallback;
      if (value is! String) throw FormatException('Invalid text field: $key');
      return value;
    }

    final en = read('english', data['en']);
    final draft = read('marathiDraft', data['mr']);
    final spoken = read('marathiSpoken', draft);
    final status = read('translationStatus', 'needs-review');
    if (!const {
      'needs-review',
      'draft',
      'machine-draft',
      'editor-reviewed',
    }.contains(status)) {
      throw const FormatException('Invalid translation review status');
    }
    final provider = read('translationProvider', 'local-authored');
    final terms = data['mathGlossaryTerms'] ?? const <String>[];
    if (en.trim().isEmpty ||
        draft.trim().isEmpty ||
        provider.trim().isEmpty ||
        (status == 'editor-reviewed' && spoken.trim().isEmpty) ||
        terms is! List ||
        terms.any((term) => term is! String || term.trim().isEmpty)) {
      throw const FormatException('Incomplete translation record');
    }
    final id = data['id'];
    final bilingual = data['bilingual'];
    if ((id != null && (id is! String || id.trim().isEmpty)) ||
        (bilingual != null &&
            (bilingual is! String ||
                !bilingual.contains(en) ||
                !bilingual.contains(spoken.trim().isEmpty ? draft : spoken)))) {
      throw const FormatException('Invalid translation identity/display');
    }
    return Words(
      en,
      draft,
      id: id as String?,
      marathiDraft: draft,
      marathiSpoken: spoken,
      bilingual: bilingual as String?,
      translationProvider: provider,
      translationStatus: status,
      mathGlossaryTerms: List<String>.unmodifiable(terms),
      reviewNotes: read('reviewNotes', ''),
    );
  }
}

/// The wording and provenance supplied by the user, not a new API translation.
const reviewedMangoCounting = Words(
  'Count the mangoes.',
  'आंब्यांची गणना करा.',
  id: 'class1_addition_mango_001',
  marathiSpoken: 'आंबे मोजून पाहा.',
  bilingual: 'Count the mangoes. आंबे मोजून पाहा.',
  translationProvider: 'bhashini-indictrans2',
  translationStatus: 'editor-reviewed',
  mathGlossaryTerms: ['counting'],
  reviewNotes:
      'Changed literal formal wording to child-friendly classroom Marathi',
);

/// Canonical records are additive; old quiz/backup aliases remain readable.
Map<String, dynamic> normalizeCustomQuestion(Map<String, dynamic> data) {
  Words read(String field, String en, String mr) {
    final value = data[field];
    if (value != null && value is! Map) {
      throw FormatException('Invalid custom translation: $field');
    }
    return value == null
        ? Words.fromJson({
            'en': data[en],
            'mr': data[mr],
            'translationProvider': 'teacher-local',
          })
        : Words.fromJson(Map<String, dynamic>.from(value as Map));
  }

  final prompt = read('prompt', 'en', 'mr');
  final explanation = read('explanation', 'hintEn', 'hintMr');
  return {
    ...data,
    'prompt': prompt.toJson(),
    'explanation': explanation.toJson(),
    'en': prompt.en,
    'mr': prompt.mr,
    'hintEn': explanation.en,
    'hintMr': explanation.mr,
    'audioEn': prompt.audioReady['en'],
    'audioMr': prompt.audioReady['mr'],
  };
}

List<String> glossaryTermsFor(String topic) => switch (topic) {
  'count' || 'number' => const ['counting', 'numbers'],
  'add' || 'addition' => const ['addition', 'counting'],
  'subtract' || 'subtraction' => const ['subtraction'],
  'multiply' || 'multiplication' => const ['multiplication', 'equal-groups'],
  'divide' || 'division' => const ['division', 'equal-sharing'],
  'place' => const ['place-value'],
  'fraction' => const ['fractions', 'equal-parts'],
  'shape' || 'symmetry' || 'area' => const ['geometry'],
  'measure' || 'measurement' || 'capacity' => const ['measurement'],
  'time' => const ['time'],
  'money' => const ['rupees', 'money'],
  'pattern' || 'sequence' => const ['patterns'],
  'data' => const ['data', 'graphs'],
  'word' || 'application' => const ['word-problems'],
  'spatial' || 'map' => const ['position'],
  'operations' => const ['addition', 'subtraction'],
  'puzzle' => const ['reasoning'],
  _ => const [],
};
