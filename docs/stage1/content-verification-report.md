# Content verification report and open curriculum questions

Checked 23 October 2026. Stage 1 has a verified **chapter spine**, not a signed-off student content bank. All 79 chapter titles, order and printed page ranges were read from the official current Marathi textbook contents pages. The class counts are 29 / 22 / 14 / 14. Each chapter has a source edition, exact PDF interval and a proposed Learn/Practice/Quiz/animation plan. The plans contain only original examples and design descriptions; no complete book page, illustration or question bank has been copied.

| Evidence level | Count / state | What it means |
|---|---:|---|
| `textbook-verified` | 79 chapter titles and printed ranges | Visually checked against the primary book TOCs; the books and edition statements were opened. |
| `learning-outcome-verified` | 0 individual chapter-to-outcome row mappings | Opening tables were inspected, but their individual outcome statements have not all been signed off against each chapter and subtopic. Candidate capacity IDs are in the matrix. |
| `cross-checked` | 3 Class 4 corrigendum locations inspected | G4-C05 p.55, G4-C09 p.77 (English only), G4-C13 p.109. This does not certify every question on those pages. |
| `needs-human-review` | 189 candidate subtopic rows, 79 prerequisite links, 79 feature plans and 240 OCR activity tags | They are useful implementation proposals, but are not an exhaustive certified transcription of every activity and subtopic. |
| `not-supported` | Stand-alone Class 1/2 fractions, formal Class 1 division, stand-alone word-problem chapter, Class 1/2 scaled graphs | No such independent chapter appears in the current TOCs; do not populate those topics by copying the old generic matrix. |

## What remains unclear before Stage 2

1. **Page-by-page concept completeness.** The four 2025/2026 textbooks contain 469 numbered teaching pages. Marathi OCR was run over all their teaching pages, but diagrams, small labels and some Devanagari glyphs were misread. A Maharashtra primary mathematics educator should review each chapter's printed pages, refine the 189 entries in [the candidate subtopic matrix](candidate-subtopic-matrix.csv) into a complete list with exact Marathi wording and exact page numbers, and resolve every activity tag in [page-activity-evidence.csv](page-activity-evidence.csv). The OCR texts are research scratch files outside the project, not app data.
2. **Exact learning outcomes.** The Class 1 and 2 books list numbered capacities and outcome statements; the Class 3 and 4 books provide C-coded capacities and printed-page mappings. [The outcome map](learning-outcome-map.csv) currently associates candidate capacities with chapters. Each subtopic needs an exact outcome row and any required grade limit checked by a teacher. The three linked SCERT booklet PDFs currently return 404.
3. **Workbook alignment.** The workbooks on the official publisher index are substantially older than the primary books. They may suggest practice formats, but their contents do not establish current grade placement. A teacher should decide whether any workbook activity remains suitable and document that decision page by page. No workbook material is copied into the app.
4. **Edition and corrections.** Class 1 is a 2025 book reprinted in 2026; Classes 2–4 are 2026 first editions. Apply the July 2026 Class 4 corrections before authoring affected tasks and check whether later corrections have appeared.
5. **Marathi and bilingual editing.** The glossary gives textbook terms, but scripts, inflection, gender/number agreement, hints, answer labels, audio-ready lines, and accessible descriptions require native-speaker and teacher review. Existing sample text has known singular/plural rough edges.
6. **Question ranges.** The outcome tables confirm Class 1 coverage up to 99, Class 2 up to 99, Class 3 core number work up to 999, and Class 4 core number work up to 9999. Not every operation uses the full range. Templates must be capped by the cited lesson page and outcome statement, not only by class.
7. **Visual mathematics.** Confirm that every chart scale, counted object, clock hand, coin value, shape unit and animation state matches the same stored correct answer. A quiz type is allowed only when the chapter genuinely supports that interaction.

## Stage gate

Stage 1 planning artefacts exist, but the exact subtopic and outcome review above is unfinished. Treat the plan as **ready for curriculum review**, not curriculum approved. Stage 2 remains blocked until those reviews are recorded and the user has reviewed the complete plan. This pass made no runtime implementation, build, native test or deployment change.
