# Ganit Safar — Stage 1 curriculum research and gated plan

> Update: the user subsequently [approved all 79 chapter names](APPROVAL.md) and requested implementation of the teacher chapter directory and smartboard touch UX. The gate text below records the state before that approval; candidate subtopic/outcome verification is still explicitly separate.

**Research date:** 23 October 2026. **Gate:** curriculum review pending; **Stage 2 has not begun**. This report is a concrete class-wise plan for review, not a claim that 79 new lessons already run in the app. The current Flutter demo and the previously deployed older web version are unchanged.

## What the official books support

| Class | Current Marathi book | Verified chapter count | Textbook teaching order and distinct focus |
|---:|---|---:|---|
| 1 | [2025 first edition, 2026 reprint](https://books.ebalbharati.in/pdfs/101050004.pdf) | **29** | Spatial vocabulary and shape behavior → numbers 0–99 in stages → concrete addition/subtraction → information, patterns, informal measure/time, money, multiplication preparation, equal sharing and puzzles. |
| 2 | [2026 first edition](https://books.ebalbharati.in/pdfs/201060004.pdf) | **22** | Solids and numbers to 99 → ones/tens and face/place value → operations and multiplication → measurement/flat shapes → regrouping, information, patterns, calendar, fair, division and puzzles. |
| 3 | [2026 first edition](https://books.ebalbharati.in/pdfs/301060004.pdf) | **14** | Shapes → number reasoning to 999 → three-digit operations → fractions → length/weight, data and sketch maps → multiplication/division → 2D shapes, symmetry, capacity, time and patterns. |
| 4 | [2026 first edition](https://books.ebalbharati.in/pdfs/401060004.pdf) | **14** | Numbers to 9999 → angles/shapes → operations → fractions → standard measures, pictographs and grid maps → multiplication/division → symmetry, perimeter/area, volume/capacity, time and patterns. |

These belong to their classes because the publisher's current Marathi textbooks place them there. The precise title, page range, edition and PDF link for **every chapter** are in the [topic and subtopic matrix](topic-subtopic-matrix.csv), with separate [Class 1](class-1-curriculum-plan.md), [Class 2](class-2-curriculum-plan.md), [Class 3](class-3-curriculum-plan.md) and [Class 4](class-4-curriculum-plan.md) catalogues. Chapter order follows each book. The [189 candidate subtopic rows](candidate-subtopic-matrix.csv) and prerequisites are clearly marked for review; they are not certified as an exhaustive transcription.

## How each verified chapter would work

The [79-row feature plan](feature-plan.json) and the class-wise [Learn](class-1-learn-plan.md), [Practice](class-1-practice-plan.md) and [Quiz](class-1-quiz-plan.md) files (with matching files for Classes 2–4) specify a short original story, concrete visual and animation, worked solution, one guided interaction, quick check and recap; Practice objective, allowed types, difficulty, concise contextual Help, likely mistake and retry; and Quiz objectives, question count, suitable direct/visual/story types, explanation and bilingual data. The [animation and visual plan](animation-visual-plan.md) gives objects, characters, motion, positive response, gentle hint, reduced-motion state and replay for each chapter.

For example, G1-C10 is the book's addition chapter on printed pp. 19–24, with answers to 9. The proposed Learn scene combines two small mango groups and checks a sum such as 3 + 2 = 5; Practice lets a child count/move objects and opens a short Help card; Quiz mixes visual counting, direct numeric, choice and an occasional original story. G2-C14 instead teaches regrouping with tens/ones, G3-C03 covers three-digit operations, and G4-C03 increases reasoning and number range within the book's outcomes. The same generic generator cannot safely serve all four.

All student-facing material in Stage 2 must be separately authored and reviewed in English and Marathi, then paired for English + Marathi display. This includes story, example, hint, answer, feedback, Help, options, narration-ready text and accessible labels. The [glossary](bilingual-terminology-glossary.csv) records source Marathi terms and proposed English equivalents. Instant language switching must keep lesson position, active question, typed answer and current result.

## Learning outcomes and prerequisites

The primary books' opening outcome tables are the source: Class 1 PDF p. 8; Class 2 PDF pp. 10–11; Classes 3–4 PDF pp. 8–11. The [outcome map](learning-outcome-map.csv) connects all 79 chapter abilities to candidate capacity rows, while the [prerequisite map](prerequisite-map.csv) gives a proposed dependency per chapter. These **candidate** links still need exact statement and subtopic review. The SCERT page's three booklet links were checked and returned 404, so no unavailable booklet code is claimed as verified. [Source details and page offsets](source-and-page-references.md) make the references auditable.

## Required change to existing app topics

The 14 global app topics are samples rather than this curriculum. The [crosswalk](current-app-crosswalk.md) identifies chapter-level renames, splits, moves and removals. In particular, Class 1 has multiplication **preparation** and equal-sharing activities, not a general multiplication/division syllabus; current Class 1/2 books have no independent fraction chapter; and word problems live inside supported chapters rather than forming a universal standalone chapter. The new catalogues add spatial vocabulary, face value, sketch maps, symmetry and Class 4 perimeter/area as supported by the books.

## Session-only result design

The [session scoreboard specification](session-scoreboard-spec.md) labels quiz results **Current Session Result**, keeps name/title/class/topics/answered/correct/incorrect/score/accuracy/stars/optional time/topic review in memory, and clears them at new quiz, reset or result exit. Review Mistakes and Go to Practice use only the active session. The current app still persists quiz results, mistakes and stars through `store.record` after finishing; this is an identified implementation gap, not a Stage 1 change. Existing stored history should not be destructively erased merely to stop future writes.

## Verification, limits and next gate

| Class | Textbook chapters verified for planning | Newly implemented verified chapters | Partially covered by old generic demo | Chapters awaiting exact subtopic/outcome review | Learn / Practice / Quiz / animation plan rows | Validated curriculum question templates |
|---:|---:|---:|---|---:|---:|---:|
| 1 | 29 | 0 | Counting, addition, subtraction and other samples; chapter alignment unapproved | 29 | 29 each | 0 |
| 2 | 22 | 0 | Arithmetic, shapes and other samples; chapter alignment unapproved | 22 | 22 each | 0 |
| 3 | 14 | 0 | Arithmetic, fraction and other samples; chapter alignment unapproved | 14 | 14 each | 0 |
| 4 | 14 | 0 | Arithmetic, fraction and other samples; chapter alignment unapproved | 14 | 14 each | 0 |

The 79 plans include bilingual authoring requirements, but **0** newly authored English/Marathi/bilingual chapter scripts or chapter-specific generated question banks were implemented in Stage 1. Existing sample generator validation from the prior app phase is not evidence that the 2025/2026 curriculum templates are correct. The session-only scoreboard is specified, not implemented.

- **Stage 1 checks passed:** 79 unique chapter rows; 29/22/14/14 class counts; continuous printed page ranges; 189 candidate subtopics; 79 Learn/Practice/Quiz/animation records; 79 prerequisite and outcome links; 240 OCR-derived page activity tags with page bounds. `python3 docs/stage1/build_plan.py` and `python3 docs/stage1/validate_plan.py` passed.
- **Stage 1 checks failed:** none in the structural validation. A structural pass is not a curriculum sign-off.
- **Pending:** exact subtopic completeness, precise outcome-row and prerequisite confirmation, page-specific number limits, older workbook relevance, Marathi/English editorial checks and Class 4 corrigendum application. The [verification report](content-verification-report.md) lists these openly.
- **Current implementation:** the prior app has sample bilingual lessons, practice, quizzes and permanent progress, but the 79 verified chapter plans have **not** been implemented or tested as app content. Its current quiz result behavior does not meet the requested session-only rule.
- **No deployment occurred in this Stage 1 pass.** No Flutter source, platform build, or production service was changed. An older version was already deployed in a previous task; this plan was not deployed.

The [Stage 2 checklist](stage2-implementation-checklist.md) gives the class-by-class implementation order and validation work. Stage 2 begins only after the complete subtopic/outcome plan and bilingual terminology are reviewed and the Stage 1 gate is explicitly closed.
