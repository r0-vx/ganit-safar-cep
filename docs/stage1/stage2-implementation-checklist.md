# Stage 2 checklist — blocked pending curriculum and user review

This is a future implementation checklist, not a record of completed app work.

## Gate before any app edit

- [ ] A Maharashtra primary mathematics educator checks **every** current textbook page range, all subtopics and activities, chapter order, grade-specific number/unit limits, and correct Marathi terminology in the [four catalogues](class-1-curriculum-plan.md).
- [ ] Record exact textbook outcome statement and printed page reference for every subtopic in the [outcome map](learning-outcome-map.csv); replace candidate capacity IDs with approved mappings. Mark unsupported proposals `not-supported` and omit them.
- [ ] Review the older workbooks only as supplementary practice evidence and apply the [Class 4 corrigendum](source-and-page-references.md).
- [ ] Review prerequisites and the original story/interaction/animation plans, then record approval or changes in the Stage 1 report. The user reviews the complete class-wise plan. **Do not start Stage 2 before this gate closes.**

## Implement in order: Class 1, then 2, then 3, then 4

- [ ] Introduce class-specific chapter IDs, order, subtopic/outcome/source metadata and verification status without destroying existing local store keys or backups.
- [ ] Give every verified subtopic an original short English lesson, separately authored Marathi lesson and reviewed bilingual arrangement; include story, visual explanation, worked solution, interaction, check, recap, hint, retry, replay and completion state.
- [ ] Author concise Practice Help per subtopic: definition, page-supported rule, vocabulary, small visual, worked example, hint and likely misconception. Opening and closing Help must preserve the current question and typed/selected answer.
- [ ] Implement validated direct, visual and contextual templates with the chapter-specific range, operation and unit. Store class, chapter, subtopic, outcome, source, type, difficulty, separate English/Marathi/bilingual display, correct answer, explanation, hint, visual data and validation status.
- [ ] Support only chapter-appropriate interaction types: choice, true/false, fill/numeric, count, match, order, drag, number line, fraction colour, clock, money, shape and graph. Do not pad finite banks with duplicate questions.
- [ ] Keep teacher Practice workflow: class → one/more verified chapters → difficulty → count → types → one question at a time → contextual Help → result.
- [ ] Keep the quiz scoreboard in memory for the current quiz only, labelled **Current Session Result / सध्याच्या सत्राचा निकाल**. Include optional name, title, class, topics, answered/correct/incorrect, score/accuracy/stars, optional time, per-topic performance, review set and result actions. Clear it on new quiz, result exit or reset. Do not write new per-student quiz scores or session stars into permanent progress. Preserve existing historical data non-destructively while deciding its later migration/export policy.
- [ ] Language changes must re-render all story, question, options, answer, hint, feedback, Help, result and accessibility text without resetting lesson position, current answer or temporary scoreboard. No automatic translation filler.
- [ ] Add lightweight original 2D motions and an equivalent reduced-motion state, replay, large touch targets, keyboard navigation, large text, contrast and screen reader labels in both languages.
- [ ] For each class, verify every lesson/practice/quiz path, mathematics, source/grade/outcome/prerequisite, Marathi and English editorial review, bilingual equivalence, visual-answer consistency, mistake review, retry, session-only result, sidebar, responsive viewports and accessibility settings.
- [ ] Run the appropriate automated and browser checks for the implemented platform, report passed/failed counts and every limitation. Do not deploy unless the user gives a new deployment instruction.
