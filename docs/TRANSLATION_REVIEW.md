# Translation and classroom-wording records

Implemented 30 October 2026. This extends the existing bilingual model; it does not replace Marathi with generated translations or enable an external translation service.

## Shared content structure

Every `Words` value now exposes the requested fields:

| Field | Behaviour |
| --- | --- |
| `id` | Semantic IDs for chapter titles/questions, sample questions, topic labels and Learning Help; deterministic content IDs for older text/UI pairs |
| `english` | Original English text; `en` remains a compatible alias |
| `marathiDraft` | Original Marathi wording, retained separately |
| `marathiSpoken` | Child-friendly classroom wording; existing content defaults to its existing Marathi text |
| `bilingual` | Explicit supplied bilingual text, or English plus the selected Marathi wording |
| `translationProvider` | Provenance label; existing built-in wording defaults to `local-authored` |
| `translationStatus` | `needs-review`, `draft`, `machine-draft` or `editor-reviewed` |
| `mathGlossaryTerms` | Topic/strand glossary IDs; non-mathematical UI labels may have an empty list |
| `reviewNotes` | Editorial notes, retained during serialization |

`mr`, Marathi display, audio-ready text and accessibility-ready text prefer classroom wording. An empty classroom field on an unfinished draft falls back to the original Marathi wording. The default bilingual layout remains two lines; an explicitly supplied bilingual string is preserved exactly. The existing English / Marathi / bilingual mode controls remain unchanged.

The shared model applies to chapter titles, lesson stories/concepts/examples/recaps, sample lessons, questions, option text, explanations, hints, Learning Help, feedback, controls and accessibility labels using `Words` or `tr`. Numbers and user-entered profile/team names remain language-neutral or appear as entered. Generated numerical variants receive review metadata individually; reviewing one record does not automatically approve another variant or its whole template.

## Review honesty and supplied example

Existing content is **not** bulk-labelled editor-reviewed. Defaults are `local-authored` / `needs-review`, with the existing wording preserved in both Marathi fields until an editor supplies a different classroom version.

The supplied `class1_addition_mango_001` record is retained exactly, including its draft, classroom text, bilingual display, glossary and review notes. It is used in the Class 1 Addition sample lesson. Its provider and review status are **user-supplied provenance**, not independently verified processing history. No Bhashini/IndicTrans2 service was called, no account or paid API was added, and no existing content was sent to a translation service.

This is a content/review schema expansion, not a completed editorial rewrite of every Marathi sentence. The existing curriculum and wording-review limitations still apply.

## Teacher custom quizzes and backups

The custom-quiz editor retains the existing required English question, Marathi question, numeric answer and bilingual explanations. It adds optional classroom Marathi wording for the question and explanation, optional review notes, and an explicit English/Marathi wording-review switch. The switch defaults off and resets after adding a question. Teacher-authored provenance is `teacher-local`; checked wording is an assertion by the local author, not a certification by an external reviewer.

Saved questions contain canonical `prompt` and `explanation` records plus the older `en`, `mr`, `hintEn`, `hintMr`, `audioEn` and `audioMr` aliases. Playback reads the canonical records and preserves explicit bilingual wording. Aliases follow the classroom wording so older readers remain consistent.

Learning backups keep `version: 1` and add `extensionSchemaVersion: 4`. Valid old custom-quiz text pairs migrate to the canonical records on load/save without discarding progress, settings, profiles or historical records. New metadata survives save/restart/backup/restore. Invalid review statuses, malformed text/glossary fields and bilingual records missing one of the supplied language strings are rejected before replacing store state.

Quiz scores remain session-only. The translation change does not introduce permanent quiz-score history or change the mathematical answer/model.

## Offline review inventory

Run from the repository root:

```sh
dart run scripts/audit_translations.dart
```

The exporter writes `build/translation-review.json` and the smaller `docs/validation/translation-audit.json` summary. It combines all chapter titles, lesson text, 790 chapter question variants, topic labels, Learning Help, one numerical variant per supported legacy question type and parsed source text/interface templates. It validates JSON round trips and detects conflicting content IDs.

The initial inventory contains **9,872 records: 9,871 needs-review and one user-supplied editor-reviewed record**. These include numerical variants and source templates; this is not a count of unique lessons, unique pedagogical questions or completed human reviews. Source entries retain file/line references and `{Dart expression}` placeholders for review. They are not executable translation templates.

The export is an editorial inventory, **not** a learning backup or a live translation-pack importer. Editing this file alone does not change shipped content. Accepted changes must be applied to the corresponding source/structured records and rebuilt. The `analyzer` dependency is development-only for source extraction; runtime display remains offline and does not depend on it.

## Verification

Validation outcomes are recorded in `docs/validation/translation-*`. Tests cover exact mango-record preservation, child-friendly display/audio/accessibility text, all learning-record fields, malformed metadata rejection, legacy backup migration, canonical custom-quiz playback, explicit teacher review, language switching, and the existing mathematics/lesson/practice/session-result regressions.

- **66 Flutter tests passed, zero failed:** [test log](validation/translation-flutter-tests.txt).
- **Flutter analysis: no issues found:** [analysis log](validation/translation-flutter-analyze.txt).
- **Release web build succeeded** with bundled rendering resources: [build log](validation/translation-web-build.txt).
- **9,872 review records validated** without conflicting IDs: [audit summary](validation/translation-audit.json). The full review inventory is generated at `build/translation-review.json`.

The first regression run identified an older test that entered form values by field position. It was updated to use the visible field labels after the optional classroom-wording fields were added. The complete suite then passed. No physical-device or browser acceptance check was repeated in this schema-focused pass; the new wording, custom editor and language changes were exercised through widget tests.

The implementation pass did not rebuild native installers, claim human editorial approval, or add recorded narration. At the user's subsequent request, this build was published to **ganit-safar-smartboard.vercel.app on 30 October 2026**. See [deployment verification](DEPLOYMENT.md). Startup and offline learning entry were checked in the public browser, and the served assets matched the tested local release.
