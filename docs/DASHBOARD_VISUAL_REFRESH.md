# Dashboard visual refresh — 1 November 2026

The central dashboard now uses the quiz application's layout and colours while presenting monitoring data visually. This is a local web update; no deployment or native build was performed.

## Shared quiz-app design

- Reuses the existing `Panel` component: white surfaces, 24-pixel corners, the same borders and high-contrast treatment.
- Reuses `LogoMark`, including its blue background and yellow letter.
- Uses the existing primary blue (`green` in the original code, #2563EB), pale-blue `cream` background (#EFF6FF), dark text and orange attention colour.
- Uses the existing quiz green feedback and purple team colours for chart categories.
- Adds a white control bar with touch menu, language selector, live status and browser full-screen control. The desktop sidebar can be collapsed; narrow screens use a touch menu.
- Keeps the quiz app's fonts, bold headings, rounded controls and all three language modes.

## What is easier to see

The overview begins with four signals: classrooms online, current learning activity, sessions today and devices needing attention. The cards open the relevant management section.

A connection donut shows online versus offline/not-yet-connected classrooms. A stacked seven-day chart separates Learn, Practice and Quiz, with Started/Completed selection and touchable daily breakdowns. Missing days show zero. Numerical labels, legends and accessibility text accompany colours; no artificial trends or demonstration statistics are added.

The classroom map shows registered, disconnected, active and unregistered classrooms. Online/offline filters work, and tapping a classroom opens its details. A short activity feed and an attention list make recent activity and next actions visible. Extra monitoring data remains in an expandable section.

Analytics adds horizontal charts for chapter use/completion, class-wise Practice/Quiz activity, teacher activity, versions and error categories. The original detailed analytics, less-used chapters and estimated availability remain accessible in the expanded data section.

## Tables and cards

Schools, classrooms, accounts and devices support name/status/school search, name sorting, table/card switching and selected-record details. Tables use the shared quiz panels and pale-blue headings. Administrative actions remain in the expanded record. Viewer accounts retain read-only access and teachers remain barred from central administration.

Live snapshots retain the current search, chart metric, selected day and expanded record. Touch targets remain large; narrow charts scroll horizontally and initially show the most recent day. Reduced-motion and large-text modes are retained.

## Live data and freshness

The existing authenticated REST/SSE backend supplies every value. Charts update through SSE; they do not require manual refresh. The dashboard marks information stale after 15 seconds without a fresh snapshot, checked every five seconds, including when a connection silently stalls. Cached values remain visible with a paused/last-received label. A new snapshot restores live status.

No answer data, child names or individual quiz scores were added to monitoring. The learning application and its temporary scoreboard are unchanged.

## Verification

The final run passed 86 Flutter tests, one separate managed-login test, analysis and the web release build. See `docs/validation/dashboard-refresh/` for the logs.

Automated coverage includes daily aggregation/zero days, Started/Completed switching, classroom filters and drill-down, live updates without an extra REST load, preserved search/chart selection, read-only detail access, every management section, a bilingual narrow-screen touch menu, stale-stream recovery, zero-data charts, reduced motion and high contrast. Layout tests cover 375, 768 and 1920 pixel widths with bilingual text scaled to 140%.

Local browser checks used the actual PostgreSQL-backed demonstration data. The running classroom's lesson appeared in the dashboard; ending it changed the live activity count from one to zero without refreshing. Search narrowed 15 classrooms to one while live updates continued, and a table row opened the correct classroom's teacher/device details. Desktop and narrow layouts were inspected. Screenshots are under `docs/dashboard-screenshots/`.

Production hosting and physical smart-board acceptance remain outside this UI update. The existing database/API and authentication boundaries were retained.
