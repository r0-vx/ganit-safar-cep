import 'localized_text.dart';

/// Contextual classroom wording for Classes 1–3. Original drafts, identities,
/// English text and mathematical glossary links remain available for review.
Words classroomWording(
  Words original,
  String marathi, {
  required int grade,
  String? english,
}) {
  assert(grade >= 1 && grade <= 3);
  return Words(
    english ?? original.en,
    original.marathiDraft,
    id: original.id,
    marathiDraft: original.marathiDraft,
    marathiSpoken: marathi,
    translationProvider: 'class$grade-contextual-edit',
    translationStatus: 'draft',
    mathGlossaryTerms: original.mathGlossaryTerms,
    reviewNotes:
        'Class $grade contextual Marathi edit: plain classroom wording; English meaning and mathematical values preserved. Original wording retained as draft.',
  );
}

String marathiDigits(Object value) {
  const digits = '०१२३४५६७८९';
  return value.toString().split('').map((character) {
    final number = int.tryParse(character);
    return number == null ? character : digits[number];
  }).join();
}
