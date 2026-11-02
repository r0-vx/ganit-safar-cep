"""Local integrity checks for Stage 1 research artefacts; no app code is run."""

import csv
import json
from collections import Counter
from pathlib import Path

base = Path(__file__).resolve().parent
rows = list(csv.DictReader((base / "topic-subtopic-matrix.csv").open(encoding="utf-8")))
features = json.loads((base / "feature-plan.json").read_text(encoding="utf-8"))
prereqs = list(csv.DictReader((base / "prerequisite-map.csv").open(encoding="utf-8")))
outcomes = list(csv.DictReader((base / "learning-outcome-map.csv").open(encoding="utf-8")))
subtopics = list(csv.DictReader((base / "candidate-subtopic-matrix.csv").open(encoding="utf-8")))
evidence = list(csv.DictReader((base / "page-activity-evidence.csv").open(encoding="utf-8")))

assert Counter(int(x["class"]) for x in rows) == {1: 29, 2: 22, 3: 14, 4: 14}
assert len({x["id"] for x in rows}) == len(rows) == len(features) == len(prereqs) == len(outcomes) == 79
assert {x["id"] for x in rows} == {x["id"] for x in features}
assert {x["id"] for x in rows} == {x["id"] for x in prereqs}
assert {x["id"] for x in rows} == {x["id"] for x in outcomes}

valid_status = {"textbook-verified", "learning-outcome-verified", "cross-checked", "needs-human-review", "not-supported"}
for row in rows:
    assert all(row[k].strip() for k in ["chapter_title_mr", "chapter_title_en", "subtopics_candidate",
                                       "source_textbook", "edition_year", "source_url", "printed_pages",
                                       "pdf_pages", "learning_outcome", "candidate_capacity",
                                       "suggested_visual_model", "suggested_question_types"])
    assert row["verification_status"] in valid_status
    assert row["subtopic_verification_status"] in valid_status
    assert row["learning_outcome_verification_status"] in valid_status
    assert row["feature_plan_status"] in valid_status
    assert row["source_url"].startswith("https://books.ebalbharati.in/pdfs/")

for item in features:
    assert item["status"] in valid_status
    assert all(item[k] for k in ["learn", "practice", "quiz", "animation", "validation"])
    assert all(item["learn"][k] for k in ["story", "characters", "visual_explanation",
                                           "animated_example", "worked_solution", "guided_interaction",
                                           "quick_check", "recap", "english_version", "marathi_version",
                                           "bilingual_version"])
    assert all(item["practice"]["learning_help"][k] for k in ["definition", "rule_or_formula",
                                                         "vocabulary", "small_visual_example",
                                                         "worked_example", "hint", "common_mistake"])
    assert all(item["quiz"][k] for k in ["objectives", "default_questions", "question_types",
                                           "difficulty_levels", "visual_question", "story_question",
                                           "fill_blank", "multiple_choice", "true_false", "matching",
                                           "ordering", "counting", "explanation", "bilingual_question_answer"])

ids = {x["id"] for x in rows}
assert len({x["id"] for x in subtopics}) == len(subtopics)
assert all(x["chapter_id"] in ids and x["verification_status"] == "needs-human-review" for x in subtopics)
for row in prereqs:
    assert row["status"] in valid_status
    assert row["prerequisite"] == "none" or row["prerequisite"] in ids
for row in outcomes:
    assert row["status"] in valid_status
for row in evidence:
    assert row["id"] in ids and row["status"] == "needs-human-review"
    lo, hi = map(int, row["printed_page_range"].split("-"))
    assert all(lo <= int(p) <= hi for p in row["printed_pages_detected"].split(";"))

print(f"PASS: 79 class-specific chapter plans, {len(subtopics)} candidate subtopics, 79 outcome/prerequisite links, {len(evidence)} page activity tags; statuses and references valid")
