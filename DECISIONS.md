# Decisions Log

Use this file for durable product and technical decisions that should survive crashes and session restarts.

## Confirmed Decisions

### Recovery Workflow
- Date: 2026-04-04
- Decision: Keep active state in `SESSION.md`, durable decisions in `DECISIONS.md`, process notes in `RECOVERY_PROCESS.md`, and any saved chat dumps in `notes/transcripts/`.
- Why: Repeated chat/editor interruptions made conversation-only context unreliable.

### Default Finish Workflow
- Date: 2026-04-04
- Decision: After finishing modifications, commit and deploy by default unless there is a real blocker or a question that needs user input first.
- Why: The user wants completed changes to reach the live Fly app without having to repeat that instruction each time.

### Admin Ticket Table Copy Workflow
- Date: 2026-04-04
- Decision: Add a `Copy Names + Totals` action for the admin ticket table.
- Why: Users should not need to drag-select Handsontable columns just to paste names and totals into Google Sheets.

### `FREE` Handling
- Date: 2026-04-04
- Decision: `FREE` was hidden in the UI as a short-term band-aid, not fully removed.
- Why: The codebase still appears to contain `FREE` handling paths, so full removal needs an intentional cleanup pass.
- Status: Not fully resolved.

### `Prize Value`
- Date: 2026-04-04
- Decision: A `Prize Value` field was introduced visually in the card design direction.
- Why: The UI is being prepared for richer prize metadata.
- Status: Repo notes indicate it is not yet confirmed as fully persisted through schema/backend/routes.

### New Raffle Rollover
- Date: 2026-04-04
- Decision: Replace the blind `Open New Raffle` behavior with a guided prompt that suggests the next raffle number first.
- Why: The rollover rules are pattern-based and should be editable before creation.

## Things Not Yet Decided
- Whether `Prize Value` should be the next backend task or remain visual-only for now.
- Whether `FREE` is truly obsolete enough to remove from the whole codebase.
- Which admin layout issue remains the highest-priority UI fix right now.

## Admin UI Priorities

### Admin Workflow Priorities
- Date: 2026-04-04
- Decision: Design the admin page around the actual weekly admin workflow rather than around decorative chrome.
- Why:
- Admins set up the next raffle roughly once per week.
- Admins import ticket files many times per week and watch `Total Tickets` and `Participants` as a live accuracy check.
- Admins copy data into Google Sheets frequently.
- On raffle night, admins record winning ticket numbers, finalize prizes, and open the next raffle.
- Old-raffle lookup is rare and should not consume prime header space.

### Header Information Priority
- Date: 2026-04-04
- Decision: `Last Updated`, `Total Tickets`, and `Participants` are important admin information and should remain prominent.
- Why:
- `Last Updated` tells both admins and end users how current the exported game data is.
- `Total Tickets` and `Participants` are used repeatedly as accuracy checks during imports.

### Header Information De-Priority
- Date: 2026-04-04
- Decision: `Raffle Lookup` is low-priority and can be demoted out of the main header area if needed.
- Why: Looking up older raffles is only occasional, unlike importing tickets and monitoring current raffle state.

### Admin Chrome Simplification
- Date: 2026-04-04
- Decision: The `ADMIN` bug can be removed, giant pill-heavy controls should be reduced, and the guild name can use a smaller font size.
- Why:
- The admin note area already makes the admin context clear enough.
- The current header/action presentation is too bulky and too decorative for an admin tool.
- The user explicitly wants fewer oversized pill controls and a calmer, more functional layout.
