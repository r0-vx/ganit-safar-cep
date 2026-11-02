# Immersive learning UI — feature preservation audit

This audit covers the existing Mathematics app while its learning interface is redesigned. The dashboard design, school-account model, database records, chapter IDs, local storage format and privacy boundaries are preservation requirements. Test results below are automated evidence, not physical Android smartboard or Windows acceptance.

## Verification status

- Backend API and HTTP/WSGI transport: **31 passed** in a local test database.
- PostgreSQL API and school-isolation suite: **24 passed**, using disposable local schemas.
- Flutter analysis: **no issues found**.
- Integrated Flutter suite: **118 passed**, with one managed-configuration test skipped in the ordinary configuration.
- Managed-gate configuration: **1 passed** separately with its API define.
- Sessions plus preserved rich activity/layout batch: **29 passed** (overlapping coverage, not an additional unique-test total).
- Learn-focused suite: **13 passed**, including nine full representative journeys for Classes 2–4 across English, Marathi and bilingual display; hint, replay, successful guided/independent checks, Back navigation and completion idempotence are exercised. These tests are included in the 118-test total.
- Browser acceptance: bilingual home and chapter entry, complete six-stage mango/pencil journey, counting once per object, combine/split groups, wrong-answer hint and correct-answer progression, quiz submission lock, skipped-question totals and Practice Help state preservation were exercised in the browser.
- Both Vercel releases and public authentication/bundle checks: [deployment records](validation/immersive-ui/deployments.json), [public checks](validation/immersive-ui/public-checks.json).

Evidence: [API suite](validation/immersive-ui/backend-tests.log), [PostgreSQL suite](validation/immersive-ui/postgres-tests.log), [Flutter analysis](validation/immersive-ui/flutter-analysis.log), [full Flutter suite](validation/immersive-ui/flutter-tests.log), [managed gate](validation/immersive-ui/managed-gate-tests.log), [session/legacy batch](validation/immersive-ui/sessions-legacy-tests.log), [Learn journeys](validation/immersive-ui/learn-tests.log).

## Feature matrix

| Feature group | Regression evidence | Required preserved behaviour |
|---|---|---|
| School sign-in and board enrollment | `school_accounts_test`, `portal_sign_in_test`, backend generated school-login tests | One school account, multiple independent boards; school-scoped rooms; independent logout; no separate pupil account |
| Administration and dashboard | `management_widget_test`, `management_workflow_test`, `dashboard_visuals_test`, backend role tests | Create school/classroom; optional generated school code; role-scoped editing and monitoring; stable charts and filters |
| Admin-only presentation preview | `presentation_mode_test`, backend presentation tests | Authenticated central admin dashboard only; read-only isolated samples; old demo sign-in routes unavailable |
| Offline authorization and event sync | `central_client_test`, backend enrollment/refresh tests | Signed offline grant verification, tamper/expiry rejection, stable event IDs on reconnect, no individual answers in telemetry |
| Curriculum and chapter navigation | `chapter_catalogue_test`, `chapter_math_audit_test` | 79 approved chapter placements, original sources/page references and class-specific data remain stable |
| Original question generators | `content_test`, `extension_test` | Valid arithmetic, bilingual prompts/hints, unique validated numerical variants, allowed question types and class limits |
| Six-stage learning flow | `chapter_screens_test`, `immersive_lessons_test` | Exactly six stages; optional prediction; exploration; representations; guided check; fresh independent check; recap and one completion award |
| Chapter Practice and Quiz | `chapter_screens_test`, `immersive_sessions_test` | Active answer survives language/help changes; submitted quiz answers lock; skip/retry/review work; no permanent individual score record |
| Rich existing activities | `extension_test`, `widget_test`, `web_flows_test` | Counting, matching, ordering, drag/tap, number lines, model selection, clocks, coins, fraction colouring, graphs and shape construction continue to work |
| Help, appreciation and rewards | `extension_test`, new lesson/session tests | Help preserves input; wrong answers remain supportive; solved-question resubmission cannot duplicate a star; lesson awards remain idempotent |
| Teacher PIN and local authoring | `widget_test`, `web_flows_test`, `translation_review_widget_test` | PIN guard; bilingual custom quiz creation, local saving, validation and completion |
| Classroom teams | `widget_test`, `web_flows_test` | Positive-only scores, alternate team turns, named teams and voting controls remain available |
| Progress, profiles and backups | `content_test`, `chapter_progress_test` | Profile isolation, completion persistence, old-backup compatibility, reset/archive, invalid-data rejection, PIN verifiers excluded from portable learning backups |
| Translation review model | `translation_review_test`, `translation_review_widget_test` | English/Marathi/combined display, classroom wording, review status and audio-ready metadata preserved |
| Smartboard and accessibility | `board_ui_test`, `extension_test`, `web_flows_test`, chapter/new UI tests | Large touch targets; strong keyboard focus; large text, contrast, reduced motion; responsive phone/landscape/wide screens; sidebar keyboard and touch operation |

## Scope and practical limits

Passing widget and backend tests do not establish that every classroom device performs identically. Final acceptance still needs a physical smartboard check for touch calibration, viewing distance, audio settings, memory use and fullscreen/back handling. Native APK and Windows runners are not rebuilt merely by passing the web suite.

AI-generated background/character artwork is decorative. Exact quantities, equation values, equal partitions, clock hands and ruler/graph geometry must be rendered from validated question data. Artwork quality and bilingual classroom phrasing need visual/editorial review; mathematical object counts must not be inferred from a generated background image.

The approved chapter names are preserved. This UI pass does not claim that all textbook subtopics or Marathi editorial reviews are complete. Existing curriculum verification statuses must remain honest.

## Regressions found and corrected during integration

- Interactive mathematical counters initially measured 58×62dp. They were enlarged to 72×72dp and covered by a touch-target geometry test.
- A zero-duration `AnimatedSize` could invalidate its own layout while reduced motion was enabled and the object counter or language changed. Reduced-motion rendering now bypasses that animation wrapper; interactive state-preservation tests exercise the path.
- Standalone chapter directory cards used ink interactions without a `Material` ancestor. The shared learning surface now supplies the actual Material surface instead of relying on a surrounding page.
- The chapter header's unconstrained language dropdown overflowed a 375dp bilingual layout. The header now uses an adaptive two-row arrangement and a constrained dropdown on narrow screens.

These were implementation issues found by the tests. Assertions were retained and the underlying controls/layouts were fixed. Updated lesson tests follow the new six-stage behaviour and explicit quiz submission while retaining completion, scoring, language-state and privacy checks.

The supported numerical visual adapters were checked across all 790 chapter question variants. All 79 first-question scenes rendered in a narrow bilingual/large-text layout, and interactive object targets measured 72dp. Unsupported scene templates intentionally retain contextual symbols rather than an invented mathematical diagram. The main chapter learning route has six stages; legacy teacher topic demonstrations remain available through their existing tools.

## Delivered visual and teaching changes

The learner palette uses warm paper, deep green, blue and terracotta with consistent typography and locally bundled original artwork. The dashboard's management layouts, colours, API and storage implementations were not redesigned. Classroom sign-in uses the new illustration; dashboard sign-in keeps its existing visual treatment.

Learn has exactly six stages: Story & Predict, Explore, See the Maths, Guided Try, Independent Challenge, Recap & Celebrate. The guided and independent checks must be solved before their respective forward actions unlock. Completion awards the existing three lesson stars once. The Class 1 addition pilot uses three mangoes plus two mangoes and a fresh four-pencil plus two-pencil check. Graduated hints, replay and bilingual switching preserve the relevant answer state. Additional complete journeys were tested for Classes 2–4 in all three language modes.

Practice keeps the active answer and touched objects while a concise Help panel opens or the language changes. Quiz answers are explicitly submitted and locked, with explanations deferred to results. Score rings, symbolic stars, mistake review and navigation remain temporary session state; no permanent individual quiz history was added. The current five-question multiple-choice chapter bank remains; richer validated activity types and configurable teacher quiz tools remain in their existing routes.

New diagram adapters cover validated arithmetic, equal groups, sharing, fraction partitions, reference clocks, coin amounts, place value, number sequences and picture graphs. Reference diagrams do not imply every chapter has a fully draggable bespoke activity. Unsupported templates use original context symbols. Voice narration is not implemented; the existing sound controls and short feedback sound remain available.

Artwork was created with the built-in image-generation tool and saved to `assets/art/classroom_story.png`, `assets/art/mango.png` and `assets/art/mascot.png`. The [full prompt set and asset register](../assets/art/ARTWORK.md) document these project assets. No live AI/image API is required for lessons. Exact mathematical quantities and diagrams are rendered by the app rather than taken from the background illustration.

Browser proof: [home](validation/immersive-ui/home.png), [mango exploration](validation/immersive-ui/mango-explore.png), [six-stage completion](validation/immersive-ui/six-stage-complete.png), [practice help](validation/immersive-ui/practice-help.png), [temporary quiz result](validation/immersive-ui/quiz-result.png). These walkthrough screenshots use isolated local learning storage, without fabricating production classroom activity.
