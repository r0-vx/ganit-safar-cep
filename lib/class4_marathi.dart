import 'localized_text.dart';

/// Class 4-only classroom wording. Keep the original draft and stable identity
/// available for comparison; this is not a claim of external human approval.
Words class4Wording(Words original, String marathi, {String? english}) => Words(
  english ?? original.en,
  original.marathiDraft,
  id: original.id,
  marathiDraft: original.marathiDraft,
  marathiSpoken: marathi,
  translationProvider: 'class4-contextual-edit',
  translationStatus: 'draft',
  mathGlossaryTerms: original.mathGlossaryTerms,
  reviewNotes:
      'Class 4 contextual Marathi edit: plain classroom wording; English meaning and mathematical values preserved. Original wording retained as draft.',
);

String class4Digits(Object value) {
  const digits = '०१२३४५६७८९';
  return value
      .toString()
      .split('')
      .map((c) => int.tryParse(c) == null ? c : digits[int.parse(c)])
      .join();
}
