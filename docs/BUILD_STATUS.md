# Build and verification record

Date: 14 October 2026 (UTC). Host: Linux ARM64.

- Flutter SDK: 3.47.7 stable; Dart 3.13.5.
- Static analysis: no issues found.
- Automated tests: 14 passing tests covering all four classes / fourteen topic question generators, arithmetic, at least ten distinct question variants per class/topic bank, persistence, profile isolation, backup rejection/restore, instant language switching, the full seven-stage mango lesson, tap/drag answer input, score and mistake recording, PIN protection, teacher-created bilingual quizzes, team scoring and landscape layouts with larger bilingual text at 1024×768 and 1280×720.
- Browser release: builds successfully with local rendering resources (`--no-web-resources-cdn`); inspected in the browser at landscape sizes. Also checked the Full HD 1920×1080 whiteboard layout and saved home/lesson screenshots in this directory. Local preview: `http://localhost:8080` while the preview server is running.
- Windows runner and build script are included. Windows binary compilation and Windows device testing are **not performed**: this host is Linux. The Windows CI job is prepared but has not been remotely run.
- External HTTPS requests were blocked during a fresh browser load: English, Marathi, local emoji, illustrations and controls rendered successfully after explicitly fixing standalone font fallbacks. Network blocking was removed after the check.
- Android native release: **successfully built** a universal optimized release APK, 61,318,222 bytes (61.3 MB as reported by Flutter). Includes ARMv7, ARM64 and x86_64 app libraries. Android minimum API 24, target API 36.
- APK verification: Android `apksigner verify --verbose` passed with APK Signature Scheme v2; ZIP integrity passed; all three local font files and their SIL OFL license files are present. Release manifest has no INTERNET permission.
- APK: `build/deliverables/ganit-safar-android.apk`. SHA-256: `2756d74290426e9a8187c8c9a8265f3dc53d00af8370d39297e44c1a6a107856`.
- Final source archive: `build/deliverables/ganit-safar-source.zip`.
- Native build used QEMU on this ARM64 host for the x64 SDK snapshot and resource tools; that is build-tool emulation, not an Android device test. Font asset licenses are also installed with the Windows bundle by CMake.
- No Android device or emulator is connected. Physical whiteboard touch, audio output, Android backup picker, device back behavior and Windows file dialogs require native device acceptance testing even when compilation succeeds.

## Native acceptance checklist

1. Install APK / copy the complete Windows release directory.
2. Disconnect network access; complete Class 1 → Addition → mango lesson → quiz → result → progress.
3. Switch all three language modes mid-lesson and mid-quiz.
4. Try tap, mouse, keyboard and drag input; verify 1024×600 or the board’s native landscape resolution.
5. Verify full screen, Escape / Android Back, mute and sound.
6. Change Teacher PIN, lock/unlock, save a custom quiz, play a two/three-team round.
7. Export a backup, change progress, restore it and restart the app to check persistence.
8. Check larger text / contrast / slower animations with the school’s viewing distance.

Recorded spoken narration is not bundled; bilingual audio-ready scripts are included. Sample content is introductory, not a reviewed full curriculum. APK signing is for demonstration sideloading; use a stable private signing key for an ongoing managed rollout.
