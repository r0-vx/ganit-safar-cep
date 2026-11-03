# Class 4 Marathi classroom-language review

Date: 3 November 2026. Baseline: `b24f5038afa205680cbbbd2d4599fe21fea23b46`.

## Scope and approach

This release rewrites the built-in Class 4 Marathi in its teaching context. It
does not translate English word by word. Prompts state the actual task; hints
explain the next useful step; explanations connect the quantities to the answer.
Correct mathematical terms are retained and explained in everyday language.

Classes 1, 2 and 3 retain their complete original content records, including
translations, metadata and mathematical values. Custom teacher-authored questions
are not rewritten. Dashboard wording, authentication, databases, progress and
session-only scoreboard rules are unchanged. The shared account avatar now refreshes
its existing translated accessibility label immediately after a language change.

## Coverage

All 14 approved Class 4 chapters are covered:

| Chapter | Existing Marathi title |
| --- | --- |
| G4-C01 | संख्यांशी खेळू या |
| G4-C02 | आकारांची गंमत भारी |
| G4-C03 | बेरीज व वजाबाकी |
| G4-C04 | अपूर्णांक |
| G4-C05 | लांबी व वजन |
| G4-C06 | माहितीचे व्यवस्थापन |
| G4-C07 | नजरी नकाशा |
| G4-C08 | गुणाकार |
| G4-C09 | भागाकार |
| G4-C10 | सममिती |
| G4-C11 | परिमिती व क्षेत्रफळ |
| G4-C12 | आकारमान व धारकता |
| G4-C13 | कालमापन |
| G4-C14 | आकृतिबंध |

The approved chapter titles and curriculum references remain unchanged.

- 140 chapter-question variants: 980 prompt, hint, explanation and option records.
- 70 lesson fields: story, concept, worked example, hint and recap per chapter.
- All 14 existing topic-tool families, including generated numerical variants,
  interaction prompts, story names and 70 concise learning-help fields.
- 412 built-in interface labels plus bounded dynamic templates for instructions,
  models, feedback, quiz results, counters and accessibility descriptions, applied
  only while Class 4 is selected on the learning app.
- English, Marathi and bilingual displays remain available. Language changes
  preserve the current lesson, question, answer and temporary session state.

## Examples of contextual changes

| Earlier wording | New teaching approach |
| --- | --- |
| “अपूर्णांक आणि मिश्र संख्येची भाषा जोडा” | Explain equal parts, the shaded parts, and how one whole plus a remaining fraction forms a mixed number. |
| “प्रमाणित एकूणांची तुलना करा” | “चित्रालेखातील प्रत्येक चिन्ह किती वस्तू दाखवते, ते आधी वाचूया.” Then count and compare the groups. |
| “स्थानिक किंमतीच्या पायऱ्यांनी भागाकार…” | Explain equal sharing, what each group receives, what remains, and checking by multiplication. |
| Abstract perimeter definition | “आकाराच्या कडेने पूर्ण फेरीचे अंतर म्हणजे परिमिती.” Explain area separately using unit squares. |
| Formal instruction prefixes | “उत्तर तपास”, “स्वतः सोडवून पाहा”, “प्रश्नमंजुषा”, “छोटी मदत”, and supportive retry messages. |

Other corrections include singular/plural agreement, naturally inflected shape
names, explicit equal parts in fractions, proper ruler-zero instructions, and
elapsed-time hints that relate 45 minutes to three 15-minute steps. Place-value
help distinguishes the tens digit from the total number of complete tens.

## Mathematical invariants and narrow English corrections

Question identities, answer values, option ordering, correct indices, objects,
visual kinds and source identities remain intact. Two pre-existing English
ambiguities needed clarification for equivalent bilingual teaching:

1. Five improper-fraction variants described more shaded pieces than one whole
   could contain. Their prompt, hint and explanation now explicitly use equal
   parts across identical wholes, with the denominator referring to **one** whole.
2. Ten perimeter/area prompts called a length “square units long”. Length now
   uses “units long”; area still uses square units. The derived lesson story uses
   the same correction.

Exactly 26 English fields change; the remaining English data is preserved.

## Translation provenance and source limits

Original Marathi is retained as `marathiDraft`; improved wording is stored as
`marathiSpoken` and feeds Marathi/bilingual, audio-ready and accessibility-ready
aliases. Existing record IDs and glossary links are preserved. New content
provenance is `class4-contextual-edit`, with status `draft`: this records an
automated contextual edit, without claiming external Marathi educator approval.
No online translation service was called and no narration audio is added.

This is a language-quality pass over the existing approved curriculum. It does
not add chapters or assert new page-by-page textbook verification. The existing
references remain available in the app. Official reference material consulted:
[Balbharati Class 4 Marathi mathematics PDF](https://ebooks.ebalbharati.in/pdfs/401020004.pdf)
and [official workbook library](https://books.ebalbharati.in/ebookmwb.aspx).

## Reproducible verification

- `scripts/audit_class4_marathi.dart`: exports current chapter and legacy content.
- `test/fixtures/class4_marathi_baseline.json`: pre-edit semantic records and
  whole-record fingerprints for Classes 1–3.
- `test/class4_scope_integrity_test.dart`: exact cross-grade preservation and
  tightly limited Class 4 English exceptions.
- `test/class4_chapter_marathi_test.dart`: all 14 chapter fingerprints, quantities,
  options, bilingual metadata and improper-fraction/unit corrections.
- `test/class4_legacy_marathi_test.dart`: 1,890 baseline variants and 30,240 generated
  variants across three difficulties, plus help, grammar and draft preservation.
- `test/class4_interface_marathi_test.dart`: scoped interface wording, bounded
  dynamic templates, custom-content preservation, language/session-state checks,
  narrow layout and enlarged text.
- Existing translation, chapter-screen and mathematical-model tests continue to
  check the new wording and complete mathematical expressions.

Final local checks: **138 tests passed**, with the managed-only test skipped in
the default configuration and **1 managed sign-in test passed separately**.
Flutter analysis reports no issues; the production web build passed.

Release logs, scope counts, before/after samples, public deployment checks and
browser screenshots are in `docs/validation/class4-marathi-2026-11-03/`.

Physical smartboard and native Windows/Android device acceptance are separate
from these Flutter/web checks. An external Marathi primary-school teacher review
would provide additional editorial assurance; no such review is claimed here.
