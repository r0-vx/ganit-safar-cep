# Vercel web deployment

## Live monitoring and presentation release — 1 November 2026

Both the classroom site and new dashboard project are published with a shared dedicated free PostgreSQL database, an isolated presentation toggle and real backend updates. [Current release and validation](PRESENTATION_AND_LIVE_DEPLOYMENT.md). The entries below describe earlier deployments.

## Current translation-review build — 30 October 2026

Production: https://ganit-safar-smartboard.vercel.app

Published the already tested release from `build/translation-web` to the existing `ganit-safar-smartboard` project, at the user's request. This includes the rich bilingual review records, classroom Marathi wording, custom-quiz authoring and compatible backup migration described in [the translation report](TRANSLATION_REVIEW.md).

- Deployment: `dpl_FMHUHU5m6gxEdpTgSMxBJgymFxT2`, state `READY`, production target.
- [Vercel deployment details](https://vercel.com/rohitmoris854-6348s-projects/ganit-safar-smartboard/FMHUHU5m6gxEdpTgSMxBJgymFxT2).
- Public HTML, JavaScript and CanvasKit WASM returned HTTP 200 and matched the local release by SHA-256. [Asset verification](validation/vercel-translation-http.json).
- Browser verification: the public app opened, the Marathi offline-entry control opened Home, and no application error logs were captured. [Live screenshot](chapter-screenshots/vercel-translation-2026-10-30.png).
- Source validation: **66 tests passed**, Flutter analysis clean, release web build successful. These checks were completed before publishing; the deployment did not change app source.
- [Deployment log](validation/vercel-translation-deploy.txt), [build log](validation/translation-web-build.txt), [test log](validation/translation-flutter-tests.txt).

The local classroom backend remains unhosted. Use **Continue offline / ऑफलाइन पुढे जा** on the entry screen. Learning stays browser-local; the translation inventory is not uploaded as a live editable database. The earlier `ganit-safar` project was not redeployed. Native installers were not rebuilt.

## Initial smartboard deployment — 24 October 2026

Production: https://ganit-safar-smartboard.vercel.app

Created a **new** project, `ganit-safar-smartboard`, in the existing `rohitmoris854-6348s-projects` workspace at the user's request. The earlier `ganit-safar` project and URL were not redeployed.

- Deployment: `dpl_WgSKBuVeifT1n4KfgrYuz2W5rT2h`, state `READY`, production target.
- Built the current Flutter source into `build/vercel-smartboard` with local CanvasKit resources and without the local `GANIT_API_URL` value. Only compiled static assets and the hosting configuration were uploaded.
- Public HTML, JavaScript and CanvasKit WASM returned HTTP 200 and matched the local release files by SHA-256. [HTTP verification](validation/vercel-smartboard-http.json).
- Live browser check: the app loaded, **Continue offline** opened learning, and the bilingual chapter directory displayed the 29/22/14/14 class counts and current chapter names. No browser errors were reported; this verification browser warned that WebGL was unavailable and used CPU rendering.
- The last source validation passed all 58 tests and Flutter analysis. This publication did not change app source or repeat physical smartboard/native acceptance tests.
- [Build log](validation/vercel-smartboard-build.txt), [deployment log](validation/vercel-smartboard-deploy.txt), [live screenshot](chapter-screenshots/vercel-production-2026-10-24.png).

The initial screen still labels central sign-in as local development. Select **Continue offline • Development mode** to use the app. Central login is disabled because no hosted classroom API was configured or deployed. This is the existing build's behavior, not a hosted identity service.

Browser storage on this new domain is separate from the earlier domain. Use local backup/restore to transfer existing learning data. The full chapter-content and device-test limits remain in [the implementation report](CHAPTER_SMARTBOARD_REPORT.md).

## Earlier deployment — 20 October 2026

Earlier production: https://ganit-safar.vercel.app

Deployed on 20 October 2026 to the `ganit-safar` project in the `rohitmoris854-6348s-projects` Vercel Hobby workspace, authenticated with the requested account. No paid services or backend were added.

Latest production deployment: `dpl_EoeN4WKsdgPKX61vZSXGW8aseub2` (`READY`).

## Prepare and publish

With Flutter available in PATH:

```sh
scripts/prepare-vercel.sh
vercel deploy build/web --prod --project ganit-safar --yes --scope rohitmoris854-6348s-projects
```

The preparation script analyzes the app, runs its tests, compiles web assets with local CanvasKit resources, and copies the static hosting configuration into the output. Deploy `build/web`, not the Flutter source directory. Vercel authentication is handled by the CLI; credentials are not stored in this repository.

## Verification

- Flutter analysis passed and all 14 automated tests passed.
- Public production HTML, JavaScript, and local CanvasKit WASM returned HTTP 200.
- Hosted Class 1 Addition lesson: all seven stages, five-object counting, practice, assessment and badge completed.
- Instant English/Marathi switching preserved the active lesson.
- Five-question quiz: one deliberate mistake, four correct answers, 4/5 result and mistake review verified.
- Progress recorded one lesson, one quiz, seven stars and 80% accuracy; survived browser refresh.
- Teacher PIN entry, team setup, voting and correct-answer team scoring verified.
- No browser warning/error logs during the checked application flows.
- Corrected singular English mango wording found during the live check.

These checks cover representative flows and do not establish that every device and content combination is bug-free.

## Delivery boundaries

This URL serves the browser version. Windows/Android native builds remain separate deliverables. The browser needs an initial network connection to load the site; native installs are the primary fully offline distribution.

Profiles, custom quizzes, settings and results stay in the current browser on the current device. They do not synchronize between computers; clearing site data removes them. Use local backup/restore to transfer records. Teacher Mode's initial local PIN is `1234`; change it before classroom use. It is a classroom convenience lock, not a server security boundary. Recorded narration is not included.
