# Decisions Log

Use this file for durable product and technical decisions that should survive crashes and session restarts.

## Confirmed Decisions

### Permissions Direction
- Date: 2026-04-07
- Decision: Start the auth/permissions overhaul by adding stored roles under the existing login system rather than replacing authentication first.
- Why:
- The current app already has functioning cookie login and route protection plumbing.
- The missing piece is authorization scope, especially per-guild access, not basic password login.
- This lets the existing `permission="admin_access"` checks be reinterpreted through real roles with much lower migration risk.

### Password Handling
- Date: 2026-04-07
- Decision: Users should be able to change their own passwords, while superadmins can only set temporary replacement passwords for others and should never be able to view existing passwords.
- Why:
- Passwords are stored as one-way hashes and should remain morally and technically unreadable after account handoff.
- A simple admin-reset flow is enough for now; full email-style password recovery is not required for the first permissions pass.
- Newly created or reset accounts should be treated as temporary-password users and prompted to choose a permanent password after login.

### Import Safety Direction
- Date: 2026-04-08
- Decision: Add additive provenance metadata to the ESO addon export and use it on the website to guard against wrong-guild imports. Mail imports should warn based on source ESO account; bank imports should automatically skip rows exported from the wrong guild and show a warning.
- Why:
- Mail imports do not reliably reveal intended guild from sender or subject alone.
- Bank exports are guild-specific and are safe to enforce more strongly.
- The same SavedVariables file can hold fresh data for one category and stale data for another, so import provenance needs to be explicit rather than inferred.

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

### `Last Updated` Blank State and Attribution
- Date: 2026-04-07
- Decision: When a raffle has never had any ticket updates, the UI should show no `Last Updated` label at all. Once ticket activity exists, the line should render as `Last Updated <timestamp> by <username>` when the acting user is known.
- Why:
- A bare `Last Updated` label with no data looks broken on brand-new raffles.
- Showing the responsible username adds useful accountability now that real auth roles exist.

### Guild Import Safety Metadata
- Date: 2026-04-08
- Decision: Keep the raffle website and the ESO addon in separate repos, but treat the addon export format as a shared contract. Additive provenance metadata should flow from the addon into the website before any stricter enforcement is enabled.
- Why:
- The addon is becoming its own product boundary and should not live inside the website repo long-term.
- Export metadata lets the website surface warnings first without breaking current imports.
- This supports reusable multi-guild deployments instead of BBC-specific hardcoding.

### Bank vs Mail Import Guardrails
- Date: 2026-04-08
- Decision: Wrong-guild bank deposits should be skipped automatically with a warning, while mailed ticket imports from an unexpected source account should warn but still allow review for now.
- Why:
- Bank exports are objectively tied to a specific scanned guild, so mismatches are high-confidence bad data.
- Mail exports are less certain because the source account is a strong but not absolute signal.
- The user wants protection from catastrophic wrong-guild bank imports without prematurely blocking all mail cases.

### Guild Settings First Slice
- Date: 2026-04-08
- Decision: Start the future sitewide config screen with a small `Guild Settings` modal inside admin rather than waiting to design the whole configuration system at once.
- Why:
- We already need a home for guild display name, ESO guild ID, and expected mail-import accounts.
- These settings directly support the new import guardrails.
- A smaller first slice keeps risk low while establishing the config pattern.

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
