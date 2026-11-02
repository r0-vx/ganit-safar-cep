# Separate classroom and dashboard sign-in — 1 November 2026

> Historical report. Demo sign-in pages, classroom demo mode and `/api/presentation/*` have been removed. See [the 2 November workflow update](SIGN_IN_SCHOOL_WORKFLOW_FIX.md) for current behaviour.

Published entry points:

| Workspace | Live sign-in | Presentation sign-in |
| --- | --- | --- |
| Classroom Mathematics app | https://ganit-safar-smartboard.vercel.app/sign-in | https://ganit-safar-smartboard.vercel.app/sign-in?presentation=1 |
| Monitoring dashboard | https://ganit-safar-dashboard.vercel.app/sign-in | https://ganit-safar-dashboard.vercel.app/sign-in?presentation=1 |

The presentation URLs select the existing isolated demo dataset before signing in. The live links keep demo data OFF. Both accept the owner's previously requested shared administrator account; its credentials are in the private owner access note. Existing teacher, viewer and private owner administrator accounts remain available.

## Behaviour

The classroom page has blue teaching branding, Learn/Practice/Quiz cues and an **Open classroom app** button. The dashboard page has purple monitoring branding, Schools/Smartboards/Live activity cues and an **Open monitoring dashboard** button. Each has a visible link to the other sign-in page. User ID or email is accepted, including a short account ID. All labels, explanations, errors and links support English, Marathi and bilingual modes. Language switching preserves entered credentials.

An explicit `/sign-in` URL presents the correct form even when a prior session exists. Successful sign-in opens the requested workspace. The main app no longer sends an administrator straight to the monitoring dashboard. Dashboard teacher accounts and classroom viewer accounts receive a clear instruction to use the other portal.

The backend uses the trusted project runtime setting `GANIT_APP_SURFACE=classroom` or `dashboard`. The account's actual administrator role is preserved. In the classroom project, an administrator can register an authorized board and receive a server-signed learning lease bound to that device, administrator, classroom and expiry. Refresh preserves this grant. The dashboard project continues to open administration; its sessions do not gain a learning lease simply by signing in.

For presentation only, a classroom administrator without an enrolled board is enrolled into the first available demo class automatically, then opens the learning home. No new private PIN is silently created. The administrator can use existing account-password reauthentication for online Teacher Mode; a private local teaching PIN remains available for offline Teacher Mode. Standard teachers retain their existing initial PIN setup flow.

Live mode never creates sample schools or classrooms. If no real classroom exists, the classroom page explains the setup requirement and offers the dashboard link and demo switch. Create real school/classroom records in the dashboard to enroll a live board.

## Preservation and accessibility

- Existing bilingual curriculum, lessons, Practice, quizzes, temporary result privacy, teacher tools, progress and offline event queue behaviour remain in place.
- Independent presentation/live databases, cookie names and upload/storage namespaces are retained.
- Forms use the existing quiz application's rounded panels, logo and colours, generous input/button targets, keyboard submission, scrolling and responsive layouts.
- Bilingual forms were tested at 375 and 1280 pixels with 140% text scaling. Explicit sign-in deep links create one initial Navigator route; local offline-development entry remains available in development builds.

## Verification

- Full Flutter suite: **96 passed**, one managed-only test skipped by the default configuration.
- Separate managed-login configuration: **1 passed**.
- Backend suite: **30 passed**.
- PostgreSQL portal/dataset checks: **8 passed** using disposable local schemas.
- Final analysis clean and pinned release web build successful.
- Both deployed `/sign-in` routes, presentation routes, API portal settings and public compiled assets were checked.
- Public browser `admin` sign-in opened the classroom learning home in one tab and administrator monitoring in the other tab. A Class 1 Addition lesson was opened from the classroom's chapter directory.
- The already-open dashboard changed active lessons from zero to one and back to zero when that browser lesson started and was left, without a refresh. The same account password unlocked online Teacher Mode; it was locked again after verification.
- Screenshots and final deployment/check evidence are under `portal-screenshots/` and `validation/separate-portals/`.

This release uses the existing Vercel projects and existing PostgreSQL database/signing key. No accounts or learning records were removed. Native installers and physical-device acceptance were not repeated.
