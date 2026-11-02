# Existing app topic crosswalk against the current Marathi textbooks

The current app has 14 global topic IDs in `lib/content.dart`. They are sample navigation and question families, not the class catalogues below. Stage 1 changes no runtime code. The chapter references are to the [2025/2026 textbook matrix](topic-subtopic-matrix.csv). Actions below are proposals for Stage 2 review; no stored progress key is changed yet.

| Existing ID | Existing display | Current textbook placement | Required Stage 2 action |
|---|---|---|---|
| `count` | Numbers & counting | G1-C07–09, C12–15, C19–21; G2-C02–07; G3-C02; G4-C01 | Split by class and textbook chapter, with the correct number range. |
| `place` | Place value | Early tens/ones in G1-C09/C12/C19/C20; G2-C03/C04; G3-C02; G4-C01 | Embed in these chapters. Class 1 should not receive a free-standing advanced place-value unit. |
| `add` | Addition | G1-C10/C17/C25; G2-C08/C14; G3-C03; G4-C03 | Split worked methods and limits by chapter. |
| `subtract` | Subtraction | G1-C11/C18; G2-C09/C15; G3-C03; G4-C03 | Separate concrete/count-back/regrouped methods. |
| `multiply` | Multiplication | G1-C27 is **preparation**; G2-C11/C20; G3-C08; G4-C08 | Rename Class 1 to equal-group preparation; unlock formal multiplication in Class 2 onward. |
| `divide` | Division | G1-C28 is **equal sharing/grouping**; G2-C21; G3-C09; G4-C09 | Class 1 must not use formal division notation as a generic quiz topic. |
| `fraction` | Fractions | G3-C04; G4-C04 | Remove from Class 1/2 topic selection until a current source supports it; teach Class 3/4 separately. |
| `shape` | Shapes & geometry | G1-C05/C06; G2-C01/C13; G3-C01/C10; G4-C02 | Split solids, flat shapes and grade-specific angle/shape construction. Add symmetry as its own current chapter. |
| `measure` | Measurement | G1-C23; G2-C12; G3-C05/C12; G4-C05/C11/C12 | Split informal measure, standard measure, capacity/volume and perimeter/area by class. |
| `time` | Time | G1-C24; G2-C18; G3-C13; G4-C13 | Match each book's event/calendar/clock depth. |
| `money` | Money | G1-C26. Later books use currency in contextual tasks, including G2-C19 and G3/G4 operation chapters. | Keep a standalone Class 1 chapter; make later uses contextual unless a current chapter explicitly supports a separate unit. |
| `pattern` | Patterns | G1-C22; G2-C17; G3-C14; G4-C14 | Use the correct visual and numeric progression for each class. |
| `data` | Data & graphs | G1-C16; G2-C16; G3-C06; G4-C06 | Rename to textbook information terms; reserve scaled pictograph/graph interpretation for supported later-class pages. |
| `word` | Word problems | Context tasks appear inside operations, fair and measurement chapters. | Remove it as a stand-alone syllabus chapter; retain original story questions inside their verified chapter. |

Current missing chapter families include Class 1 spatial language and sequencing, number song and puzzles; Class 2 face value, inverse relation and children's fair; Class 3/4 sketch maps and symmetry; Class 4 perimeter/area. These should be added only after the topic/subtopic and outcome review is complete.

Any Stage 2 data migration must preserve existing local progress, translations and backups. Existing permanent quiz score history must no longer receive new session scores under the requested session-only scoreboard; historical records need a non-destructive handling decision before implementation.
