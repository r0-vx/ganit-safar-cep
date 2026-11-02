# Ganit Safar / गणित सफर

**One login per school (2 November 2026):** creating a school now generates a School ID and password. The same login works on both sites; each smartboard can create/select its classroom and connect directly without separate teacher accounts. Existing schools have a **Generate school login** action. [Workflow and verification](docs/SCHOOL_LOGIN_WORKFLOW.md).

**Sign-in and school workflow update (2 November 2026):** both sites use the same live accounts. The classroom app opens the full learning experience and has a right-aligned account avatar with account details, classroom connection and sign-out. School creation validates required fields and generates an optional code; each school has direct classroom creation and scoped monitoring. Demo data is a read-only, authenticated super-administrator preview in the dashboard only. There are no demo sign-in pages or classroom demo mode. [Changes and verification](docs/SIGN_IN_SCHOOL_WORKFLOW_FIX.md).

**Separate sign-in pages:** [Classroom app](https://ganit-safar-smartboard.vercel.app/sign-in) and [monitoring dashboard](https://ganit-safar-dashboard.vercel.app/sign-in) now open their respective workspaces with the same administrator credentials. [Presentation links and verification](docs/SEPARATE_SIGN_IN_PAGES.md).

**Live release (1 November 2026):** [Classroom app](https://ganit-safar-smartboard.vercel.app/) and [dashboard](https://ganit-safar-dashboard.vercel.app/) are deployed on Vercel with a dedicated free PostgreSQL database. Historical release: the original presentation switch and demo accounts described below have been superseded by the 2 November admin-only dashboard preview. [Access flow, isolation and verification](docs/PRESENTATION_AND_LIVE_DEPLOYMENT.md).

**Central monitoring (1 November 2026):** web/backend source was initially prepared locally and is now deployed; see the live release above. Managed PostgreSQL, role-based school/classroom administration, registered whiteboards, SSE, offline event sync and temporary quiz-score privacy are described in the [delivery report](docs/CENTRAL_MONITORING_REPORT.md) and [deployment guide](docs/CENTRAL_MONITORING_DEPLOYMENT.md). Windows and Android work is on hold for this phase. The initial local-only reports below are historical.

**Translation review model (30 October 2026):** built-in bilingual text and custom quizzes now support separate Marathi draft/classroom wording, bilingual display, provider/status, glossary terms and review notes. Existing wording remains `needs-review`. [Implementation and offline review export](docs/TRANSLATION_REVIEW.md). Published at [ganit-safar-smartboard.vercel.app](https://ganit-safar-smartboard.vercel.app); [deployment checks](docs/DEPLOYMENT.md) confirm the live assets match the tested build.

**New production project (24 October 2026):** the current chapter/smartboard build is live at [ganit-safar-smartboard.vercel.app](https://ganit-safar-smartboard.vercel.app). Select **Continue offline** on the initial screen. The earlier project remains unchanged. See [deployment verification and storage boundaries](docs/DEPLOYMENT.md).

**Chapter and smartboard update (23 October 2026):** the user approved all 79 chapter names. [The current implementation report](docs/CHAPTER_SMARTBOARD_REPORT.md) covers the teacher chapter directory, original chapter starter activities, touch controls and session-only quiz results. [Stage 1 research](docs/stage1/STAGE1_REPORT.md) remains the source register; detailed subtopic/outcome and Marathi editorial review remains open. No deployment occurred in this pass.

**Local web extension (20 October 2026):** see [the detailed implementation report](docs/IMPLEMENTATION_REPORT.md), [curriculum matrix](docs/curriculum/alignment-matrix.csv) and [local central-service setup](server/README.md). This phase was not deployed and did not build/test native platforms. Native build notes below describe the earlier delivery.

An offline Flutter Mathematics learning application for Classes 1–4, with a Windows runner, an Android runner, and a browser preview. All learning content, illustrations, fonts, question generation, scoring, and storage run locally. No account, advertisements, paid service, or Google Play Services integration.

## Run

Install Flutter stable (validated here with Flutter 3.47.7 / Dart 3.13.5), then:

```sh
flutter pub get
flutter run -d windows    # on a Windows development machine
flutter run -d <device>   # connected Android whiteboard or tablet
flutter run -d chrome    # optional browser preview
```

Dependencies are downloaded during development/build. Installed native applications do not need the internet. The native targets are Windows 10/11 (x64) and Android 7.0 / API 24 or later. Android opens in immersive landscape. Windows has a resizable window with a 960×640 minimum size. F11 toggles full screen, Escape leaves full screen, Backspace returns Home, and visible Back controls and Android Back also work. Touch, mouse, Tab, and standard Material keyboard controls are supported. Lessons scroll on smaller whiteboards.

## First complete demonstration

1. Select **English + मराठी** in the top bar.
2. Open **Learn → Class 1 → Chapter 10: Addition (answers to 9)**.
3. Read the original story, concept and worked example.
4. Tap the objects, answer the quick check, and complete the recap.
5. Open chapter Practice and use its compact Help panel without leaving the current question.
6. Open the five-question chapter quiz, then review its **Current Session Result**.
7. Review mistakes or return to Practice. The completed lesson appears in **Progress**; the quiz result clears when its session ends.

Language can change during a lesson or quiz without restarting it.

## Included functionality

- Four class choices with different themes and mascot characters; grade-scaled arithmetic.
- All 79 approved chapter titles are available in the main learning directory with original starter activities. The older 14-topic sample tools and richer interaction types remain in Teacher Mode. Neither bank is exhaustive coverage of every state-board subtopic.
- Animated object counting/merging/removal, equal groups, sharing baskets, fraction colouring, a draggable interactive hour clock with keyboard-friendly ± controls, a ruler, coin values, shapes, number patterns, farm graphs, and train stories.
- Core activity types: choice, true/false, number input, counting, ordering, dragging (also accepts tapping), number/dot pairs, and visual word problems. Ordering and matching are foundation number activities across topics.
- Gentle corrective feedback, explanations, hints, retries, stars and completion badges. The local system supplies a brief correct-answer click when sound is enabled.
- Configurable quiz count, types, difficulty, fixed/random sequence and optional per-question timer. The teacher sample tools retain these settings locally. New chapter quizzes use five multiple-choice questions; result totals, mistake explanations and practice links are available only during the current session.
- **Teacher Mode PIN: `1234` on first use.** Change it inside Teacher Mode. This is a simple local classroom guard, not an account security system. Lock the mode when leaving it.
- Teacher lesson launch, full screen, pause/replay/skip and answer visibility. Whole-class quizzes; local custom numeric multiple-choice quizzes with English/Marathi questions and explanations; deleting saved quizzes.
- Two/three named teams, alternating turns, class voting, participation/improvement rewards and positive-only scoring. Team stars save to the current profile when the teacher finishes the team adventure.
- Local profiles, lesson/topic/chapter completion, lesson stars, badges, progress bars and earlier archived quiz records. New quiz scores remain session-only. Archive/reset preserves an archive in the backup.
- JSON backup/restore. Windows uses a save dialog, Android uses the native Create Document picker, and browser preview downloads a JSON file. Restore validates data before replacing it. Backups contain profile/quiz/settings data; bundled lessons and drawings ship with the application itself.
- Larger text, stronger contrast, sound toggle and slower animation controls.

## Native builds

### Windows

On **Windows**, install Flutter and Visual Studio with the Desktop development with C++ workload. Run:

```powershell
.\scripts\build-windows.ps1
```

Distribute the **entire** `build/windows/x64/runner/Release/` directory, including DLLs and `data/`, not just the executable. A custom app icon is included. Windows compilation cannot run on this Linux host; no Windows executable is claimed as verified here.

### Android

Install Android SDK command-line tools / Android Studio and accept SDK licenses. Run:

```sh
./scripts/build-android.sh
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. The universal APK targets ARMv7, ARM64, and x86_64. The sample release uses Flutter’s development signing key for sideloading. Configure your own local signing key before a managed school rollout that needs stable updates; no paid service is needed. No storage permission is requested for the document picker.

`.github/workflows/build.yml` provides separate Android and Windows build jobs and downloadable artifacts when run in a GitHub repository. It has not been remotely executed from this workspace.

### Optional offline browser preview

```sh
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8080 --directory build/web
```

Visit `http://localhost:8080`. The web preview needs a local server; native Windows/Android installs are the primary completely offline delivery format.

## Content and implementation

- `lib/content.dart`: typed English/Marathi words, audio-ready scripts, topics, explanations and deterministic question generators.
- `lib/store.dart`: versioned local preferences, profile isolation, chapter progress, historical records, custom quizzes, validated backups and progress archives.
- `lib/main.dart`: navigation, local vector artwork, lessons, activities, teacher tools and settings.
- `android/.../MainActivity.kt`: scoped Android backup export through the system document picker.
- `lib/platform/`: conditional browser full-screen integration; native full screen uses Windows window management / Android system UI.
- `test/`: content/arithmetic, persistence, language switching, lesson completion, scoring, teacher PIN and whiteboard layout tests.

Narration scripts exist in both languages, but **recorded spoken narration is not included**. Replay repeats visual instruction. Artwork is locally drawn; emoji use bundled Noto Color Emoji. Noto Sans and Noto Sans Devanagari are bundled. Font licenses are in `assets/fonts/*OFL.txt` and are copied into the Android assets, Windows release folder and web output; app code is MIT licensed. No remote image or font request is necessary for native use.

This is a functional sample-content basic version. It does not claim curriculum accreditation, individually authored stories for every chapter, arbitrary visual custom-question authoring, student authentication, multiplayer networking, or pre-recorded audio. Graph lessons are introductory two-category examples; clock activities teach whole hours. Local profile names and teacher-authored questions are user-entered content and are shown as written.

## Validation

```sh
flutter analyze
flutter test
```

See `docs/IMPLEMENTATION_REPORT.md` for the latest local web checks and `docs/BUILD_STATUS.md` for the earlier native build record.

## Hosted browser version

Open [Ganit Safar on Vercel](https://ganit-safar.vercel.app). Deployment preparation, verification and browser-storage boundaries are documented in [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).
