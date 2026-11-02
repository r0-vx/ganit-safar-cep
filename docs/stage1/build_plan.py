"""Produce research planning artefacts from the manually checked 2025/26 TOCs.

This script does not feed the application. Its outputs are design proposals,
not publishable lesson or question content. Run: python3 docs/stage1/build_plan.py
"""

from __future__ import annotations

import csv
import json
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
with (HERE / "chapter-index.tsv").open(encoding="utf-8") as handle:
    chapters = list(csv.DictReader(handle, delimiter="\t"))

SOURCE = {
    1: ("https://books.ebalbharati.in/pdfs/101050004.pdf", "2025 first edition; 2026 reprint", 10, "PDF p. 8"),
    2: ("https://books.ebalbharati.in/pdfs/201060004.pdf", "2026 first edition", 12, "PDF pp. 10–11"),
    3: ("https://books.ebalbharati.in/pdfs/301060004.pdf", "2026 first edition", 12, "PDF pp. 8–11"),
    4: ("https://books.ebalbharati.in/pdfs/401060004.pdf", "2026 first edition", 12, "PDF pp. 8–11"),
}

# Concept-specific proposals. Each chapter row below also has its own page,
# ability and subtopic metadata; these patterns specify interaction grammar.
FAMILY = {
    "spatial": ("village objects and a walking path", "move a character relative to a tree, bridge and classroom", "place the character at the named position", "reverse near/far or before/behind", "choice,drag,match"),
    "sequence": ("a school train with numbered stops", "show the next event or number in sequence", "put two or three cards in order", "confuse event order with number size", "order,fill,match"),
    "shape": ("toys, boxes and school objects", "rotate or reveal sides of a drawn object", "sort or build the named shape", "name a solid from only one flat face", "choice,match,drag,construct"),
    "number": ("mango baskets at a village stall", "add objects one by one and pair each with a numeral", "count, build or place numeral cards", "skip or double-count an object", "count,choice,fill,order,numberline"),
    "place": ("pencils bundled in tens", "bundle ten loose pencils, then reveal digit positions", "form the number from tens and ones", "swap tens and ones", "drag,match,fill,model"),
    "addition": ("two children combine fruit baskets", "move objects into one group, then reveal an equation", "join sets or move along a number line", "count the first set twice", "count,choice,fill,numberline,drag,story"),
    "subtraction": ("bananas are taken from a classroom tray", "move selected objects away or step back on a line", "mark what remains and enter the number", "count removed objects as remaining", "count,choice,fill,numberline,drag,story"),
    "operations": ("a school library lends and receives books", "use place-value blocks to show each operation", "choose the operation and work a matching example", "use the inverse operation", "choice,fill,drag,story,model"),
    "multiplication": ("equal fruit trays at a market", "copy one group into equal rows then show repeated addition", "make equal groups or an array", "count the groups instead of the objects", "count,choice,fill,drag,match,story"),
    "division": ("share pencils fairly among children", "deal one object per recipient in repeated rounds", "drag objects into equal groups", "leave unequal groups", "drag,choice,fill,match,story"),
    "fraction": ("a paper roti or fruit is shared", "partition one whole into equal parts and shade some", "select or colour the requested equal parts", "use unequal-size parts", "colour,choice,match,fill,drag"),
    "measurement": ("classroom rulers, bags and balance pans", "align ends or show a balanced comparison", "measure or estimate and then check", "start a ruler away from zero or mix units", "drag,choice,fill,match,story"),
    "capacity": ("water is poured into classroom containers", "fill equal-sized units, displaying level changes", "compare or measure container capacity", "confuse tallness with capacity", "drag,choice,fill,match"),
    "money": ("a local toy and stationery shop", "lay out ₹ coins/notes and add values", "select coins to make a price", "count coins rather than their values", "coins,choice,fill,match,story"),
    "time": ("a school-day schedule and clock", "turn a clock hand or advance calendar cards", "set or read time and order events", "mix up hour and minute hands", "clock,choice,fill,order,match"),
    "pattern": ("rangoli tiles or train-carriage colours", "extend a short repeat or growth sequence", "place the missing shape or number", "copy the last item without finding the rule", "drag,choice,fill,order,match"),
    "data": ("classroom fruits or transport survey", "move tokens into a chart one at a time", "read and compare category counts", "read the height without checking the scale", "graph,choice,fill,match,story"),
    "map": ("a route between school, well and market", "trace a route and reveal landmarks", "follow or draw directions on a simple map", "reverse left and right", "drag,choice,match,order"),
    "symmetry": ("paper kites and folded leaves", "fold or reflect a shape on its axis", "complete the mirrored half", "treat any dividing line as symmetry", "construct,drag,choice,match"),
    "area": ("a village garden fence and floor tiles", "trace boundary, then fill inside with equal squares", "count boundary units or square units", "confuse perimeter with area", "count,fill,drag,choice,construct"),
    "application": ("a children's school fair", "reveal quantities as the story unfolds", "solve one contextual choice with manipulatives", "choose an operation from a keyword alone", "story,coins,choice,fill,match"),
    "puzzle": ("a school treasure trail", "reveal clues one at a time", "solve a number or shape constraint", "guess without checking all clues", "choice,fill,order,match,drag"),
}

DEFINITION_MR = {
    "spatial": "जागा व दिशा", "sequence": "क्रम", "shape": "आकार", "number": "संख्या",
    "place": "स्थानिक किंमत", "addition": "बेरीज", "subtraction": "वजाबाकी",
    "operations": "संख्यांवरील क्रिया", "multiplication": "गुणाकार", "division": "भागाकार",
    "fraction": "अपूर्णांक", "measurement": "मापन", "capacity": "धारकता",
    "money": "नाणी व नोटा", "time": "कालमापन", "pattern": "आकृतिबंध",
    "data": "माहितीचे व्यवस्थापन", "map": "नजरी नकाशा", "symmetry": "सममिती",
    "area": "परिमिती व क्षेत्रफळ", "application": "उपयोग", "puzzle": "गणितीय कोडी",
}

LIMITS = {1: "objects first; 0–99 according to chapter; additions capped at 9 or 18 where named",
          2: "0–99 and grade-appropriate regrouping; verify each chapter-specific limit",
          3: "0–999 for number concepts; verify operation and measurement limits by cited page",
          4: "0–9999 for core number outcomes; verify all operation and measurement limits by cited page"}

ORIGINAL_EXAMPLES = {
    "spatial": "Move the toy beside the desk", "sequence": "Arrange bus → school → home",
    "shape": "Build a triangle from three sticks", "number": "Count 8 mangoes once each",
    "place": "32 = 3 tens + 2 ones", "addition": "3 + 2 = 5",
    "subtraction": "5 − 2 = 3", "operations": "24 + 13 = 37 and 37 − 13 = 24",
    "multiplication": "3 groups of 2 = 6", "division": "Share 6 pencils between 2 children = 3 each",
    "fraction": "Shade 3 of 4 equal pieces", "measurement": "Compare two lengths with one ruler",
    "capacity": "Two half-litre pours fill one litre", "money": "₹5 + ₹2 = ₹7",
    "time": "Move the hour hand from 2 to 3", "pattern": "red, blue, red, blue, …",
    "data": "Count 4 mango tokens and 3 banana tokens",
    "map": "Trace school → well → market", "symmetry": "Fold a square through its centre",
    "area": "A 3-by-2 tile rectangle covers 6 square units",
    "application": "Two ₹5 toys cost ₹10", "puzzle": "Find the missing number in 2, 4, 6, □",
}

GRADE_EXAMPLES = {
    (1, 10): "3 + 2 = 5", (1, 17): "5 + 3 = 8 by counting on",
    (1, 25): "8 + 7 = 15 using objects", (1, 11): "5 − 2 = 3",
    (1, 18): "7 − 4 = 3 by counting back",
    (2, 8): "23 + 14 = 37", (2, 14): "36 + 27 = 63 with one ten regrouped",
    (2, 9): "36 − 14 = 22", (2, 15): "45 − 27 = 18 by unbundling one ten",
    (3, 3): "245 + 132 = 377; 377 − 132 = 245",
    (4, 3): "2345 + 1264 = 3609; 3609 − 1264 = 2345",
    (3, 8): "23 × 4 = 92", (4, 8): "123 × 12 = 1476",
    (3, 9): "84 ÷ 4 = 21", (4, 9): "125 ÷ 5 = 25",
    (3, 4): "Shade 3 of 4 equal pieces",
    (4, 4): "Show one whole and three quarters using equal pieces",
}

# Candidate mappings to the capacity rows printed in each textbook's opening
# outcome table. These are aids for a teacher's row-by-row review, not approval.
CAPACITY = {
    1: {"spatial": "8", "shape": "8", "sequence": "4/9", "number": "3/5",
        "addition": "6", "subtraction": "6", "multiplication": "7", "division": "7",
        "pattern": "2", "data": "1", "measurement": "9", "time": "9",
        "money": "6", "puzzle": "6"},
    2: {"shape": "8", "number": "3/4", "place": "5", "sequence": "3/4",
        "addition": "6", "subtraction": "6", "operations": "6", "multiplication": "7",
        "division": "7", "measurement": "9", "data": "1", "pattern": "2",
        "time": "10", "application": "11/12", "puzzle": "12/13"},
    3: {"shape": "C-2.1", "number": "C-1.1/C-5.1", "operations": "C-1.3",
        "fraction": "C-1.2", "measurement": "C-3.1/C-3.2", "data": "C-6.1",
        "map": "C-2.2", "multiplication": "C-1.3", "division": "C-1.3",
        "symmetry": "C-2.3", "capacity": "C-3.2/C-3.7", "time": "C-3.2",
        "pattern": "C-1.4/C-2.4"},
    4: {"number": "C-1.1/C-5.1", "shape": "C-2.1", "operations": "C-1.3",
        "fraction": "C-1.2", "measurement": "C-3.2/C-3.5", "data": "C-6.1",
        "map": "C-2.2", "multiplication": "C-1.3", "division": "C-1.3",
        "symmetry": "C-2.3", "area": "C-3.3/C-3.4/C-3.6",
        "capacity": "C-3.2/C-3.7", "time": "C-3.2", "pattern": "C-1.4/C-2.4"},
}

def prior_ids(grade: int, chapter: int, strand: str) -> str:
    # Proposed dependency graph, never asserted as a textbook prerequisite.
    same = [x for x in chapters if int(x["class"]) == grade and int(x["chapter"]) < chapter and x["strand"] == strand]
    if same:
        return f"G{grade}-C{int(same[-1]['chapter']):02d}"
    roots = {
        "addition": "number", "subtraction": "number", "operations": "addition",
        "place": "number", "multiplication": "addition", "division": "multiplication",
        "fraction": "division", "area": "measurement", "capacity": "measurement",
        "symmetry": "shape", "money": "number", "data": "number",
        "pattern": "sequence", "time": "sequence", "map": "spatial",
    }
    needed = roots.get(strand)
    if needed:
        candidates = [x for x in chapters if int(x["class"]) <= grade and
                      (int(x["class"]), int(x["chapter"])) < (grade, chapter) and
                      x["strand"] == needed]
        if candidates:
            x = candidates[-1]
            return f"G{int(x['class'])}-C{int(x['chapter']):02d}"
    if grade > 1:
        candidates = [x for x in chapters if int(x["class"]) == grade - 1 and x["strand"] == strand]
        if candidates:
            x = candidates[-1]
            return f"G{grade-1}-C{int(x['chapter']):02d}"
    return "none"

catalogue, features, prereqs, outcomes, candidate_subtopics = [], [], [], [], []
for source_row in chapters:
    row = dict(source_row)
    grade, ch = int(row["class"]), int(row["chapter"])
    first, last = int(row["page_start"]), int(row["page_end"])
    source_url, edition, offset, outcome_pages = SOURCE[grade]
    strand = row["strand"]
    setting, visual, guided, mistake, types = FAMILY[strand]
    original_example = GRADE_EXAMPLES.get((grade, ch), ORIGINAL_EXAMPLES[strand])
    item_id = f"G{grade}-C{ch:02d}"
    prerequisite = prior_ids(grade, ch, strand)
    ability = f"Demonstrate {row['english_title'].lower()} using {row['subtopics_to_verify'].split(';')[0].strip()} in an original visual task."
    common = {
        "id": item_id, "class": grade, "chapter": ch,
        "chapter_title_mr": row["marathi_title"], "chapter_title_en": row["english_title"],
        "subtopics_candidate": row["subtopics_to_verify"],
        "terminology_mr": DEFINITION_MR[strand], "terminology_en": strand.replace("_", " "),
        "source_textbook": f"Balbharati Marathi Mathematics Class {grade}",
        "edition_year": edition, "source_url": source_url,
        "printed_pages": f"{first}–{last}" if first != last else str(first),
        "pdf_pages": f"{first+offset}–{last+offset}" if first != last else str(first+offset),
        "learning_outcome": ability,
        "learning_outcome_source": f"Textbook curriculum goals: {outcome_pages}; exact row mapping pending editorial check",
        "candidate_capacity": CAPACITY[grade].get(strand, "unmapped"),
        "learning_outcome_verification_status": "needs-human-review",
        "prerequisite_concept": prerequisite,
        "expected_student_ability": ability,
        "difficulty_level": f"Class {grade}; {LIMITS[grade]}",
        "suggested_visual_model": visual,
        "suggested_animation": f"Animate {visual}; one motion at a time",
        "suggested_story_setting": setting,
        "suggested_learn_activity": guided,
        "suggested_practice_activity": guided,
        "suggested_quiz_activity": f"Assess {row['english_title'].lower()} with {types}",
        "suggested_question_types": types,
        "bilingual_content_requirements": "Native Marathi and English scripts, hints, worked steps, answers, feedback and accessibility labels; bilingual combines reviewed equivalents. Audio-ready fields for both languages.",
        "verification_status": "textbook-verified",
        "subtopic_verification_status": "needs-human-review",
        "feature_plan_status": "needs-human-review",
    }
    if grade == 4 and ch in {5, 9, 13}:
        common["errata_reference"] = (
            "https://www.balbharati.co.in/pdfs/Math4_Errata_02072026.pdf "
            "(dated 2 July 2026): Marathi p.55 mass wording; English p.77 "
            "currency wording; Marathi/English p.109 historical date. "
            "Apply the correction before authoring any related task."
        )
    else:
        common["errata_reference"] = ""
    catalogue.append(common)
    for sub_number, subtopic in enumerate(row["subtopics_to_verify"].split(";"), 1):
        candidate_subtopics.append({
            "id": f"{item_id}-S{sub_number:02d}", "class": grade,
            "chapter_id": item_id, "chapter_title_mr": row["marathi_title"],
            "chapter_title_en": row["english_title"],
            "subtopic_en_candidate": subtopic.strip(),
            "subtopic_mr_exact": "PENDING native Marathi educator extraction from cited page",
            "source_textbook": common["source_textbook"], "edition_year": edition,
            "source_url": source_url, "printed_page_range": common["printed_pages"],
            "exact_printed_page": "PENDING page-level review",
            "learning_outcome_candidate": common["candidate_capacity"],
            "prerequisite_concept": prerequisite,
            "expected_student_ability": f"Demonstrate {subtopic.strip()} in an original chapter-aligned task.",
            "difficulty_level": common["difficulty_level"],
            "suggested_visual_model": visual,
            "suggested_animation": f"One small before/after animation for {subtopic.strip()}.",
            "suggested_story_setting": setting,
            "suggested_learn_activity": guided,
            "suggested_practice_activity": guided,
            "suggested_quiz_activity": f"Assess {subtopic.strip()} with a suitable type from {types}.",
            "suggested_question_types": types,
            "bilingual_content_requirements": common["bilingual_content_requirements"],
            "verification_status": "needs-human-review",
            "feature_plan": item_id,
        })
    prereqs.append({"id": item_id, "prerequisite": prerequisite, "status": "needs-human-review"})
    outcomes.append({"id": item_id, "expected_ability": ability,
                     "source": f"{source_url} printed pp. {common['printed_pages']}; curriculum table {outcome_pages}",
                     "candidate_capacity": common["candidate_capacity"],
                     "status": "needs-human-review",
                     "note": "Chapter pages verified; exact curriculum-table outcome row still needs review."})
    features.append({
        "id": item_id, "class": grade, "chapter": row["marathi_title"],
        "source": f"{source_url} printed pp. {common['printed_pages']}",
        "learn": {
            "story": f"Original short story set at {setting}, centered on {row['english_title'].lower()}.",
            "characters": "Mira, a classmate, and the Ganit mascot; adapt names in reviewed Marathi script.",
            "visual_explanation": visual,
            "animated_example": f"Animate an original example such as: {original_example}. Check it against the cited chapter range.",
            "worked_solution": f"For {original_example}, show each count, grouping or operation before revealing the conclusion. Verify every visual against its answer.",
            "guided_interaction": guided,
            "quick_check": f"One visual {types.split(',')[0]} question; gentle retry and a specific hint.",
            "recap": f"One spoken-ready sentence and icon recalling {row['english_title'].lower()}.",
            "english_version": "Write an original English story, explanation, prompt, answer and feedback.",
            "marathi_version": f"Write a separate original Marathi script using {row['marathi_title']} and {DEFINITION_MR[strand]}; teacher review required.",
            "bilingual_version": "Pair the reviewed English and Marathi units scene by scene; preserve position and answer on switch."
        },
        "practice": {
            "objective": ability,
            "allowed_question_types": types.split(","),
            "visual_interaction": guided,
            "difficulty_progression": f"Concrete single-step task, then reduced scaffolding, then a new context within {LIMITS[grade]}.",
            "hint_logic": "First highlight relevant objects or units; second show a partial worked step; never reveal a new question.",
            "learning_help": {
                "definition": f"One short sentence explaining {row['english_title'].lower()}.",
                "rule_or_formula": "State only the page-supported rule; omit a symbolic formula when the chapter teaches a visual relation.",
                "vocabulary": f"{DEFINITION_MR[strand]} / {strand.replace('_', ' ')}; complete the reviewed term list for this chapter.",
                "small_visual_example": visual,
                "worked_example": original_example,
                "hint": f"Highlight the first useful step in: {guided}.",
                "common_mistake": mistake,
            },
            "common_mistake": mistake,
            "retry_behaviour": "Keep the same question and typed/selected answer when Help opens; allow another attempt after feedback."
        },
        "quiz": {
            "objectives": ability,
            "default_questions": 5 if grade == 1 else 10,
            "question_types": types.split(","),
            "difficulty_levels": ["concrete", "guided", "independent"],
            "visual_question": visual,
            "story_question": f"One original {setting} situation when the chapter supports context questions.",
            "fill_blank": "Use only when a number, unit, sequence, or term can be entered unambiguously.",
            "multiple_choice": "Three or four mathematically distinct options with checked distractors.",
            "true_false": "Use only for statements with clear textbook-backed truth conditions.",
            "matching": "Match images, terms or quantities when equivalent pairs can be verified.",
            "ordering": "Use only for sequences, comparisons, or process steps.",
            "counting": "Use only when individual objects or units are visible and countable.",
            "explanation": "Explain the actual question's solution after answering, in both languages.",
            "bilingual_question_answer": "Separate en/mr text, hint, explanation, choice labels and accessibility names; reviewed bilingual rendering."
        },
        "animation": {
            "objects": visual, "characters": "Mira, classmate, Ganit mascot",
            "motion_sequence": "Introduce scene → animate one mathematical change → pause for interaction → reveal a checked result.",
            "user_interaction": guided,
            "correct_answer": "Brief star and mascot nod with encouraging bilingual feedback.",
            "incorrect_hint": f"Gently highlight the part connected to this mistake: {mistake}.",
            "reduced_motion": "Show before/after states with no moving objects, keeping every count and label.",
            "replay": "Reset visuals to the initial state without changing the saved lesson position or language."
        },
        "validation": [
            "source reference and edition", "class placement and chapter page",
            "learning outcome and prerequisite", "mathematical correctness and grade range",
            "Marathi wording by educator", "English translation by educator",
            "bilingual equivalence", "visual-answer consistency", "keyboard and touch accessibility",
            "large text, reduced motion, responsive sidebar", "Learn, Practice, Quiz and session-only result"
        ],
        "status": "needs-human-review"
    })

def write_csv(path: Path, rows: list[dict]):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader(); writer.writerows(rows)

write_csv(HERE / "topic-subtopic-matrix.csv", catalogue)
write_csv(HERE / "candidate-subtopic-matrix.csv", candidate_subtopics)
write_csv(HERE / "prerequisite-map.csv", prereqs)
write_csv(HERE / "learning-outcome-map.csv", outcomes)
(HERE / "feature-plan.json").write_text(json.dumps(features, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

by_class = defaultdict(list)
for row in catalogue:
    by_class[row["class"]].append(row)
for grade, rows in by_class.items():
    lines = [f"# Class {grade} curriculum catalogue and learning sequence", "",
             f"Source: [{SOURCE[grade][0]}]({SOURCE[grade][0]}), {SOURCE[grade][1]}. Printed page numbers are below; PDF page numbers are in [the matrix](topic-subtopic-matrix.csv).",
             "", "Chapter order is the textbook's order. Prerequisites, activities and feature designs are proposals for educator review. Subtopic candidates are not yet certified as an exhaustive page-by-page extraction.",
             "", "| Order | Marathi chapter | English translation | Printed pages | Subtopics to check | Proposed prerequisite |", "|---:|---|---|---|---|---|"]
    for r in rows:
        lines.append(f"| {r['chapter']} | {r['chapter_title_mr']} | {r['chapter_title_en']} | {r['printed_pages']} | {r['subtopics_candidate']} | {r['prerequisite_concept']} |")
    lines += ["", "For every row, the [feature plan](feature-plan.json) specifies a short Learn story, guided interaction, quick check, Practice and Help flow, allowed Quiz types, motion and reduced-motion behavior, bilingual authoring, and validation. The [outcome map](learning-outcome-map.csv) records ability targets and the outstanding exact outcome-row check.", ""]
    (HERE / f"class-{grade}-curriculum-plan.md").write_text("\n".join(lines), encoding="utf-8")

    planned = [f for f in features if f["class"] == grade]
    for area in ["learn", "practice", "quiz"]:
        details = [f"# Class {grade} {area.title()} plan", "",
                   "Design proposals keyed to the verified chapter sequence. Authored student-facing content and teacher language review belong to Stage 2. Exact chapter/source references are in [the matrix](topic-subtopic-matrix.csv).", ""]
        for f in planned:
            part = f[area]
            details += [f"## {f['id']} — {f['chapter']}", ""]
            for key, value in part.items():
                if isinstance(value, list):
                    value = ", ".join(value)
                elif isinstance(value, dict):
                    value = "; ".join(f"{k.replace('_', ' ')}: {v}" for k, v in value.items())
                details.append(f"- **{key.replace('_', ' ').capitalize()}:** {value}")
            details.append("")
        (HERE / f"class-{grade}-{area}-plan.md").write_text("\n".join(details), encoding="utf-8")

animation = ["# Class-wise animation and visual plan", "",
             "Every row is a proposed original 2D animation. The source supports the concept and class, while art and motion require Stage 2 design review.", ""]
for f in features:
    animation += [f"## {f['id']} — {f['chapter']}", ""]
    for key, value in f["animation"].items():
        animation.append(f"- **{key.replace('_', ' ').capitalize()}:** {value}")
    animation.append("")
(HERE / "animation-visual-plan.md").write_text("\n".join(animation), encoding="utf-8")

assert len(chapters) == 79
assert [len(by_class[g]) for g in range(1, 5)] == [29, 22, 14, 14]
for grade, rows in by_class.items():
    assert [r["chapter"] for r in rows] == list(range(1, len(rows) + 1))
    for previous, current in zip(rows, rows[1:]):
        assert int(previous["printed_pages"].split("–")[-1]) + 1 == int(current["printed_pages"].split("–")[0])
print(f"79 chapter rows, {len(candidate_subtopics)} candidate subtopics and 79 feature plans; counts 29/22/14/14; page ranges contiguous")
