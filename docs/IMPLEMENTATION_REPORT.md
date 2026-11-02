# Ganit Safar extension — local web implementation report

20 October 2026. This phase extends the existing Flutter app. **No deployment was performed. No Windows or Android build or compatibility testing was performed.** The existing Vercel release and native deliverables were not republished. The Android APK's SHA-256 remains `2756d74290426e9a8187c8c9a8265f3dc53d00af8370d39297e44c1a6a107856`.

## 1. Implemented features

- Responsive blue/light-blue activity shell with readable text, rounded bordered cards and consistent Material navigation icons. Original fonts, English/Marathi translations, storage key and learning records are retained.
- Sidebar: desktop show/hide, persisted desktop preference, mobile overlay, visible open and close controls, scrim dismissal, Escape dismissal, Ctrl+B toggle and return focus. The overlay is transient on mobile; it does not force itself open because the desktop preference was open.
- New student-facing lesson renderer replaces the old stage-chip interface. Five scenes combine the requested teaching elements: story; animated explanation and worked example; guided interaction; quick check; recap/reward. No Discover/Watch/Your Turn tabs. Replay, Back, Hint, optional steps, retry and teacher pause/answer visibility/skip controls are present.
- Class-dependent story introductions, grade-scaled examples, recommended ordering and bilingual learning plans. All four classes and fourteen topic entry points remain available. Advanced Class 1 topics are explicitly exploratory.
- Multi-topic Practice setup: class, one or more topics, difficulty, question count and types. One question at a time, positive rewards, progress indicator and completion result. Draft configuration persists.
- Learning Help: definition, vocabulary, mathematical number sentence, small visual, worked explanation, hint, common mistake and review notice. It appears beside the question on wide screens and below it on narrow screens. Opening/closing help preserves the active activity and typed response.
- New functioning question interactions: destination on a number line; select a visual model; set a whole-hour clock by drag or numbered controls; make a rupee price from coins; colour equal fraction parts; construct straight sides with drag/tap; select a matching two-category graph.
- Existing choice, true/false, numeric entry, counting, ordering, numeric answer drag, dot matching and visual stories remain available. A tap alternative accompanies numeric dragging.
- Quiz setup adds 30/50-question selections and show/hide answer choices. Hidden choices use numeric entry for the relevant selection-based types; specialized visual construction tasks retain their own controls.
- Quiz scoring, optional timer, repeatable/random variants, review, retry and practice links retained. Revision links preselect the quiz topic in the new Practice flow.
- Quick positive mascot/star feedback, optional system click, gentle corrective explanations; larger celebrations on completion. Reduced motion is a saved setting, alongside slow animation and speed adjustment.
- Real local central-management API and dashboard, described below.

## 2. Partial features and content limits

| Area | Present | Remaining scope |
|---|---|---|
| Curriculum alignment | 56 documented class/topic rows, sources, objectives, prerequisites, vocabulary, examples and review status | Current official grade/outcome-code review and curriculum completeness |
| Story lessons | Reusable short scenes with class-specific introductions and topic models | Individually authored, extensively illustrated stories for every chapter |
| Question banks | Safe parameter templates and finite numerical variants | Broad reviewed subtopic banks; 45,360 audited cases are not 45,360 unique questions |
| Place value | Tens and ones | Full larger-number progression, especially Class 4 |
| Time | Whole hours | Minutes, half/quarter hours, elapsed time |
| Money | ₹1/₹2/₹5/₹10 coin-value construction | Notes, change, multi-step shopping |
| Geometry | Triangle, square, circle and side construction | Free drawing, richer geometry and construction validation |
| Measurement | Preset centimetre ruler examples | Freely movable rulers, mixed units and other measures |
| Data | Two-category graphs and graph selection | Rich editable datasets and graph-building tools |
| Hints | Topic-specific guidance and optional explanation | Individually authored hint ladders for every template |
| Central health | Heartbeat, last-seen, total activity count, version, health field | Comprehensive diagnostics and central per-skill analytics |
| Typed models | Model vocabulary and active question/session/API boundaries | Some catalogue DTOs remain a foundation, rather than a complete content-authoring repository |

Ordering and number/dot matching remain foundation activities that can be selected across topics; they are not deep topic-specific activities. Content scope is clearly a sample learning system rather than a fully reviewed curriculum.

## 3. Not implemented in this phase

- Official curriculum approval/accreditation, complete Class 1–4 chapter coverage or authoritative learning-outcome codes.
- Recorded narration, voice packs or text-to-speech playback. Audio-ready English/Marathi text remains available.
- Hosted central system, production identity-provider hardening, online account recovery or public user sign-up.
- Central storage/synchronization of student answers, custom quizzes or individual progress. Only aggregate activity count is sent by the heartbeat.
- Web UI to create teacher/admin accounts; local setup CLI provisions accounts. Classroom associations are managed in the dashboard.
- Automatic resume of an unfinished quiz/practice question after page refresh. Completed records/settings and practice setup persist.
- Installable/offline-cached PWA guarantee, formal screen-reader/WCAG certification or physical whiteboard testing.
- Deployment, native build or native compatibility work.

## 4. Official curriculum sources consulted

- [SCERT learning outcomes](https://maa.ac.in/english/index.php?tcf=learningoutcomes): the linked English booklet and Standards 1–5 PDF requests returned 404. Exact outcome identifiers were therefore not claimed.
- [SCERT curriculum department/resources](https://maa.ac.in/english/index.php?tcf=curriculum): curriculum/framework and teacher-resource listings. An overview listing is not treated as a topic-by-class syllabus.
- [Balbharati portal](https://ebalbharati.in/).
- [Balbharati Mathematics workbooks](https://books.ebalbharati.in/ebookmwb.aspx), including the official Class 1–4 scanned PDF downloads.

Workbook PDF page 4 in all four classes was inspected for teacher guidance. Page 5 examples corroborate Class 2 number practice, Class 3 place value and Class 4 number representation. Class 1 page 5 comparison vocabulary is an identified gap. These are older scanned workbook editions; they do not establish current syllabus completeness. No scanned pages or copied textbook question banks ship with the app.

See [research notes](curriculum/RESEARCH.md), [alignment matrix](curriculum/alignment-matrix.csv) and [machine-readable coverage](curriculum/coverage.json).

## 5. Alignment results

- 56 class/topic records: every new generated question records a class, topic, skill, application outcome ID and source reference.
- All 56 records retain **needs curriculum review**. Three have observed topic corroboration; none is described as officially approved.
- Template audit: **45,119 valid cases**, **241 oversized visual-counting cases rejected**, **zero unexpected validation failures**, across 45,360 parameter/type/difficulty cases.
- Checks cover arithmetic, bilingual text presence, appropriate model parameters, exact division, fractions, answer options, metadata and outcome references. Human bilingual wording/readability and current grade appropriateness still need curriculum review.
- Examples, definitions and stories are original paraphrases and parameterized constructions. Official sources inform alignment rather than supplying copied pages.

## 6. Data model extensions and preservation

`lib/models.dart` defines the versioned foundation for class plans, subtopics, source references, characters, animation specifications, scenes, lessons, help cards, templates, generation metadata, validation results, practice sessions, quizzes, progress, mistakes, teacher identities, classrooms, devices, statuses and central sessions. Existing `Words`, `Topic`, `Question` and `AppStore` remain the core models.

Question metadata is connected to generation and validation. Teacher identity/session data is used by the API client; dashboard records are decoded from the server response. Some catalogue DTOs are intentionally lightweight groundwork, not a claim of a full authoring database.

Existing saved progress remains under `ganit_safar_v1`. Backups keep version 1 with additive `extensionSchemaVersion: 2`, sidebar/reduced-motion preferences and practice setup. Old backups still restore. Device ID/secret are separate from learning backups, preventing a classroom progress restore from cloning an installation identity. Session tokens/passwords are excluded from learning backups.

## 7. Question generation

`lib/generator.dart` filters compatible specialized types, generates numerical variants using stable topic seeds, mixes short direct prompts with stories, validates each served generated quiz/practice question and rejects duplicate fingerprints within a session. Arithmetic and visual parameters share the same question object.

It rejects unsupported selections, invalid answers and oversized count displays rather than presenting a misleading truncated counting question. If a finite bank cannot satisfy a requested count, the UI asks the teacher to adjust the selection. It does not silently repeat questions to fill the session. Fixed sessions are reproducible; random sessions vary the seed. Custom teacher numeric questions also pass structural validation before a quiz starts; their mathematical wording remains the teacher's responsibility.

## 8. Teacher workflow

Practice → class → one/more topics → difficulty/count/types → Start → answer or open Learning Help → close help and continue the same activity → next question → session completion.

Teacher Mode's existing local PIN guard, custom bilingual numeric quizzes, profiles, archives and teams are retained. The PIN is a classroom convenience guard. Central management additionally requires a real local authenticated session; student-facing navigation hides its entry until Teacher Mode is unlocked.

## 9. Central-management workflow

The app starts with central sign-in and an explicitly labelled offline development option. The local API URL is configured with `GANIT_API_URL`; there is no production endpoint in source.

Administrator: provision local account → sign in → add classroom/school/class → assign teacher → register this installation → inspect devices → rename/reassign/activate/deactivate/revoke → inspect audit → open learning → sign out.

Teacher: sign in → see assigned classrooms/devices only → register/sync an assigned installation → open learning. Administrative mutations are rejected server-side for teacher tokens.

Security foundation: salted scrypt passwords, hashed bearer tokens, eight-hour expiry, memory-only client session tokens, logout revocation, device-secret validation, role/assignment authorization, bounded sign-in throttling, audit actions, origin-restricted CORS and `no-store` responses. Loopback service only; no real credentials are committed.

Status rules: active within 90 seconds of a heartbeat; offline afterward; never connected before first sync; attention for inactive/revoked/non-ok health. Heartbeats run every 30 seconds; dashboard records refresh manually. See [server setup/API documentation](../server/README.md).

## 10. Accessibility checks

Automated/browser checks cover large bilingual text, contrast, saved reduced motion, keyboard sidebar control, Escape dismissal, labelled close/help/check controls, wrapped Marathi labels, positive feedback and tap alternatives. Keyboard ArrowRight changed animation speed from 1× to 1.5× in the browser.

This is not a formal accessibility certification. Sound-output quality, assistive-technology reading order, every visual control's screen-reader semantics and colour-vision simulations have not been comprehensively audited. Recorded narration remains absent.

## 11. Browser and viewport tests

- Widget/layout tests at widths **375, 768, 1024 and 1440**, including large bilingual text scaling across home/shell, topics, practice setup, help, lesson, quiz setup, quiz, settings, progress, teams, teacher tools, login and disconnected management.
- Browser visual checks and screenshots at those widths; narrow overlay/scrim and keyboard closing verified.
- English → Marathi → bilingual switching preserved the active explanation and number sentence.
- Full lesson completed: story/explanation → guided number-line answer → quick check → badge.
- Mixed Addition/Subtraction Practice and help close/continue verified.
- Five-question hidden-options quiz completed with one intentional mistake: 4/5, review and saved result verified.
- Progress showed one lesson, one quiz, eight stars, 80% accuracy. Refresh preserved prior results/preferences; installation ID remained unchanged after signing in again.
- Central browser flow: login, classroom creation, teacher assignment, registration, active sync, deactivation/attention, reactivation and logout locking management data.
- Browser full-screen control was exercised and exited. The embedded browser did not expose an authoritative OS-fullscreen signal; resizing during that experiment produced a transient capture scaling issue, cleared by leaving fullscreen/resetting the viewport. Fullscreen/layout certification in another browser is not claimed.

## 12. CSS/UI alignment

The application is Flutter-rendered; there is no application CSS layout system to refactor. Checks were applied to widget constraints, wrapping, scroll containers, drawers, dialogs and theme tokens. Tests caught and corrected dropdown, topic-card, progress-row and team-selector overflow, plus ink/Material layering and help reparenting issues.

Final layout tests reported no render overflows. DOM document width matched viewport width at 375/768/1024/1440; this is supplementary evidence, not a substitute for Flutter render checks. Screenshots show readable Devanagari, wrapped labels, usable choices and help beside/below the question. Long content scrolls vertically instead of being clipped.

Hover/focus/pressed/disabled behaviour uses Material controls. Browser keyboard checks cover sidebar and speed; exhaustive state screenshots of every button have not been captured. No comprehensive pixel-diff, screen-reader or colour-contrast certification is claimed.

## 13. Known limitations and operational notes

- Curriculum/human language review remains the main content boundary. Some singular/plural Marathi wording needs editorial review.
- Basic numeric custom quiz authoring is retained; arbitrary picture/diagram authoring is absent.
- Practice awards stars and shows session results; it does not yet retain detailed per-question practice history or resume an active session after refresh.
- The API is a local development service, not production deployment infrastructure. Device secrets are in browser local preferences; production enrollment needs review/hardening.
- Completed learning data is browser-local. Clearing site data removes it and creates a new installation identity. Use existing backup/restore for learning records; central SQLite has a separate lifecycle.
- Template checks verify arithmetic/model invariants, not official pedagogical approval. Large requested counts may exceed finite elementary banks.
- The browser emitted a CPU-renderer fallback warning (`webGLVersion is -1`), including after refresh. Final checks captured no application error logs. This environment warning and these checks do not establish physical-device performance.
- No deployed/native artifact was refreshed with this phase's changes.

## 14. Validation commands and outcomes

From the repository root, with Flutter on PATH:

```sh
flutter analyze
flutter test
python3 -m unittest discover -s server -p 'test_*.py' -v
dart run scripts/audit_curriculum.dart
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --output build/local-web --dart-define=GANIT_API_URL=http://127.0.0.1:8787
```

The environment used `/tmp/ganit-flutter/bin/flutter` and `/tmp/ganit-flutter/bin/dart` (PATH prepended where shown). Results: **analysis clean; 40 Flutter tests passed; four backend integration tests passed; curriculum audit zero unexpected failures; release web build succeeded.** Logs are saved in [validation](validation/).

Local preview commands:

```sh
GANIT_DB=/tmp/ganit-central-preview.sqlite3 GANIT_ALLOWED_ORIGIN=http://localhost:8080 python3 server/app.py
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/local-web
```

The preview uses temporary development accounts/records. Create your own accounts using the documented setup command; passwords are not embedded in the app or report.

## 15. Screenshots

- [Final local home](extension-screenshots/final-home.png)
- [Local login, 375px](extension-screenshots/login-375.png)
- [Mobile sidebar](extension-screenshots/sidebar-375.png)
- [Home, 768px](extension-screenshots/home-768.png)
- [Quiz configuration, 1024px](extension-screenshots/quiz-setup-1024.png)
- [Quiz result](extension-screenshots/quiz-result-1024.png)
- [Animated lesson, 1440px](extension-screenshots/lesson-1440.png)
- [Marathi lesson](extension-screenshots/lesson-marathi.png)
- [Lesson completion](extension-screenshots/lesson-complete.png)
- [Practice with contextual help](extension-screenshots/practice-help-1440.png)
- [Progress](extension-screenshots/progress.png)
- [Connected central dashboard](extension-screenshots/central-dashboard.png)
- [Inactive device attention state](extension-screenshots/device-needs-attention.png)

## 16. Deployment confirmation

**No deployment was performed.** Only local web compilation, local API execution, automated tests and browser validation were performed. No Vercel deployment command, native build command or native-device compatibility test was run in this phase.
