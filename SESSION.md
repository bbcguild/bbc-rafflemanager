# Session Log

Use this file as the source of truth for the active work session. If chat dies, resume from this file first.

## Current Goal
- Continue the raffle manager modernization with focus on the admin UI.
- Most immediate active area: general live QA, UX polish, and small follow-up bugs from real browser testing.
- Current paused theme: GA4 reporting setup is installed and validated at the tag level, but the user got understandably frazzled while trying to build first-pass Explorations inside the shared `bbcguild.com` property.

## Current Status
- Working tree status should be checked before resuming; this file was refreshed as a recovery checkpoint after the latest analytics pass.
- GA4 is deployed live using measurement ID `G-8C00Y7WF9G`.
- The project was recently in a heavy admin/public UI iteration cycle, mostly on 2026-04-04 through 2026-04-05.
- This file is now intentionally structured for crash recovery, not just narrative notes.

## What Changed Recently
- Auth/permissions groundwork follow-up on 2026-04-07: began replacing the old "any logged-in user is full admin" assumption with stored roles. Added a new `auth_user_roles` table plus startup migration/backfill so existing admin accounts automatically become `superadmin` instead of losing access on deploy.
- Auth/permissions groundwork follow-up on 2026-04-07: `AuthUser` and the Pyramid ACL groupfinder/root factory now understand global `superadmin` and guild-scoped `guild_admin` roles. Existing admin route checks now resolve through a neutral `admin_access` permission instead of the old `akaviri` name, while still preserving the same behavior.
- Auth/permissions groundwork follow-up on 2026-04-07: admin-user creation paths (`init_db.py` default admin bootstrap and `create_admin.py`) now seed `superadmin` automatically. Admin UI for managing per-guild roles is not built yet; this pass is schema/auth plumbing only.
- Auth/permissions management follow-up on 2026-04-07: added a first live superadmin-only `User Access` modal in the admin profile menu. Current pass supports listing users, creating accounts, toggling `superadmin`, assigning/removing per-guild `guild_admin` access, and deleting users with guardrails to keep at least one superadmin and prevent deleting the currently logged-in account.
- Password management follow-up on 2026-04-07: building the next auth slice so end users can change their own passwords and superadmins can reset another user's password without ever seeing the old one. Passwords remain one-way hashed in the DB; retrieval is not possible by design.
- Password management follow-up on 2026-04-07: added `auth_must_change_password` to `auth_users`, startup migration coverage for older DBs, self-service `Change Password` UI in the admin profile menu, confirm/show-password support in `User Access`, and temporary-password flows that mark newly created or reset accounts to choose a new password after login.
- Auth UX follow-up on 2026-04-07: the admin login path should no longer dump one-guild admin users onto the generic guild chooser. The home/select flow now filters visible guilds based on admin role scope and auto-enters the single allowed guild for non-superadmin admin users, which also lets the forced password-change modal appear immediately after first login.
- Auth UX follow-up on 2026-04-07: the standalone login template now renders flash messages again so bad credentials show an actual visible error instead of silently clearing the password field.
- Auth UX follow-up on 2026-04-07: `/{guild}/auth/login` is now being collapsed into the same real `/login` system instead of maintaining a second guild-scoped login page. The guild route should redirect into `/login` with a `came_from` target for that guild, so there is one canonical admin login surface.
- Permissions follow-up on 2026-04-07: found and fixed a deeper auth-role bug in the DB helpers. Because the helper parameter name was `guild_id`, the decorator layer was implicitly injecting the current request guild into global role operations, which caused broken superadmin add/remove/count behavior and stray guild-scoped `superadmin` rows. Auth-role helpers now use neutral parameter names so global roles stay truly global.
- Permissions follow-up on 2026-04-07: introduced a global `owner` role. Current live intent is `Hiyde = owner`; owner implies admin access, can manage superadmins, and cannot be demoted/deleted/edited by another user. Superadmins remain below owner.
- Ticket metadata follow-up on 2026-04-07: `tickets` now carries an additive `ticket_updated_by_auth` column plus startup migration coverage for older DBs. Ticket-changing admin actions record the currently logged-in auth user alongside the update timestamp.
- Ticket metadata follow-up on 2026-04-07: public and admin `Last Updated` displays now stay blank when a raffle has never had ticket activity, and otherwise render as `Last Updated <timestamp> by <username>` when the updater is known.
- Import safety follow-up on 2026-04-08: created a separate GitHub repo for the ESO addon at `https://github.com/bbcguild/RaffleManager` and imported the corrected LibHistoire-enabled baseline there. Recent addon commits add export provenance metadata for `mail` and `bank`, ignore `.bak` / `.hold` files, and change the default bank export window to 8 days.
- Import safety follow-up on 2026-04-08: the website importer now reads additive `export_metadata` from `RaffleManager.lua`. Bank rows whose exported source guild does not match the current raffle guild are skipped automatically with a warning in the import review modal. Mail rows still import, but the modal warns when the export source account does not match the expected account(s) for that guild.
- Launch DB prep follow-up on 2026-04-07: imported the raw old production copy `raffle-canon.db` into a separate working file `raffle-working.db` and kept the raw source untouched.
- Launch DB prep follow-up on 2026-04-07: audited raffle numbering across the canon DB and confirmed three broad buckets: current `YYWW`, older `GYWW`, and a small manual-review set of duplicate/suffix recovery rows.
- Launch DB prep follow-up on 2026-04-07: cleaned the working DB so raffle codes are now all four-digit numeric values with no duplicates or suffixes left. Canonical raffles were chosen by "keep the fuller raffle" first, then newer `raffle_id` as a tiebreaker, with special handling for Santa's Sack to keep guild-only ticket sets rather than merged cross-guild variants.
- Launch DB prep follow-up on 2026-04-07: applied the newer raffle/prize schema additions to `raffle-working.db`, including `raffle_title`, `raffle_status`, `raffle_notes_admin`, `raffle_notes_public_2`, `prize_value`, `prize_style`, and `prize_sort`.
- Launch DB prep follow-up on 2026-04-07: set all closed raffles in the working DB to status `COMPLETE` and finalized historical prizes only where a winning ticket already existed, so old archive winner names should render without inventing results for unfinished prizes.
- Launch DB prep follow-up on 2026-04-07: current launch-candidate DB state in `raffle-working.db` is 261 raffles, 3800 prizes, 44130 ticket rows, 2 open raffles (`2614` for both guilds), zero non-4-digit raffle codes, zero duplicate raffle codes within a guild, and zero prizes with a winner ticket but unlocked state.
- Archive follow-up on 2026-04-07: removed the public "last X raffles only" depth cap from archive navigation so older cleaned historical raffles remain directly browseable again.
- Staging follow-up on 2026-04-07: created Fly staging app `bbcguilds-staging`, moved it to region `ewr` after capacity failures in `iad` and `ord`, uploaded `raffle-working.db` to `/data/raffle.db`, and verified `/health`, both current `2614` raffle JSON endpoints, and an older converted archive (`/bbc1/2331/`) against the migrated DB.
- Staging follow-up on 2026-04-07: deep archive verification showed no `depth=` limiter in the rendered page, archive navigation still present, home-return control present, archived prize winner names rendering from JSON again, and historical entrant data loading from the cleaned DB.
- Admin page was moved toward a CSS-grid-based layout with prize cards and a tighter right ticket panel.
- The ticket panel gained a `Copy Names + Totals` workflow for easier Google Sheets pasting.
- Public-facing prize cards and entrants tables were also modernized during the same iteration wave.
- Domain routing work was added so the public/admin hosts behave differently on Fly.
- On 2026-04-04 after DreamHost DNS setup, Fly verification showed all four custom hosts with issued certificates: `raffles.bbcguild.com`, `raffle.bbcguild.com`, `tickets.bbcguild.com`, and `raffle-admin.bbcguild.com`.
- DNS lookup from this machine showed all four subdomains resolving to Fly edge addresses `66.241.125.77` and `2a09:8280:1::ec:6211:0`.
- Login routing follow-up on 2026-04-04: `raffle-admin.bbcguild.com` was correctly redirecting to `/login`, but that bare auth route was rendering the stale `auth/mako_templates/login_simple.mako` template while `/{guild}/auth/login` used the newer root `mako_templates/login_simple.mako`. The auth-package template has now been updated to match the newer design so both entry points stay visually consistent.
- Login routing follow-up on 2026-04-04: the template-unification fix was committed as `f240a93` (`auth: unify admin login template`) and deployed to Fly.
- Login routing follow-up on 2026-04-04: bare admin-host login still appeared to do nothing after submit because successful `/login` defaulted to the `home` route, while the admin-host `home` view redirected to `/login` unconditionally. The `home` route now only redirects unauthenticated admin-host requests to login; authenticated admin-host requests can fall through to the guild selector instead of looping back to `/login`.
- Layout follow-up on 2026-04-04: after the browser zoom was restored from 80% to 100%, the admin layout exposed that recent right-side ticket-panel sizing had effectively been tuned against the zoomed-out view. Current fix backs out the extra right-side gutter compensation, narrows the forced ticket-column footprint, slightly tightens Handsontable column widths, and stacks the three-column layout earlier on smaller desktops so the admin page behaves more naturally at standard zoom.
- Layout follow-up on 2026-04-04: top action-bar stacking was still happening far too early because the CSS used hard jumps from 6 columns to 3 to 2 to 1. Current fix switches the action bar to a fluid `auto-fit/minmax` grid with smaller minimum button widths and ellipsis behavior, so the bar drops columns only when it truly runs out of room instead of collapsing at arbitrary breakpoints.
- Admin shell redesign follow-up on 2026-04-04: began the first intentional "de-stupid the design" pass for the admin page, kept as an isolated/reversible change set. Current changes shrink the guild title, move `Total Tickets` and `Participants` into a cleaner right-side stats block, remove the `ADMIN` bug, and convert the oversized hero-style action pills into a denser admin-tools strip. `Raffle Lookup` remains available but is visually demoted.
- Admin shell redesign follow-up on 2026-04-04: next pass moves the global/profile control out of the header into a thin utility topbar, keeps `Last Updated` as the left-side anchor there, and turns the profile menu into a more rectangular connected control-panel style surface with lookup inside the panel. This keeps the main header visually open for future theme art while reducing the old "circles and pills jammed into the header" problem.
- Admin shell redesign follow-up on 2026-04-04: after user feedback that the first topbar pass was still too tall/prominent, the utility strip and menu trigger were tightened further. The visible `Control Panel` label was removed so the BBC logo plus caret can stand on its own, the header height was reduced, stat cards were compacted, and the visible `Manual Refresh` button was removed from the admin tools row.
- Cleanup follow-up on 2026-04-04: repaired the text-encoding regressions introduced during the recent admin template restructuring. The broken status dropdown labels and other mojibake text were normalized back to clean readable labels so the page can be evaluated on layout/design again instead of being distracted by corrupted glyphs.
- Admin shell redesign follow-up on 2026-04-04: default admin mode now uses a shorter everyday header so the page does not waste vertical space when no special theme art is active. The longer/taller hero treatment is still a good idea for future seasonal templates, but the base experience should optimize for routine use first.
- Admin shell redesign follow-up on 2026-04-04: continued trimming the everyday top chrome. The utility strip, profile trigger, dropdown panel, stat cards, and base header proportions were all tightened again so the non-themed default view wastes less vertical space while preserving the cleaner “header is for identity + stats, menu lives above” structure.
- Admin shell redesign follow-up on 2026-04-04: the profile trigger is now moving toward a split logo-plus-caret treatment instead of one chunky combined block, and the dropdown is being restructured around actual long-term menu needs: raffle lookup, templates/theme switching, guild links, help, and logout. Future destinations like help/template management are placeholder affordances for now until those pages exist.
- Admin shell redesign follow-up on 2026-04-04: after live review of the split trigger, the logo shell is being stripped back further so the BBC mark can visually float while only the caret keeps a pill treatment. This keeps the lookup/menu structure the user liked while removing the remaining unnecessary chunk around the trigger.
- Admin shell redesign follow-up on 2026-04-04: the detached caret control is now being pushed even lighter by shrinking it into a tighter circular affordance with a dark neutral background instead of a bright blue mini-pill. If it still feels too visible after live review, the next experiment is removing the framing almost entirely.
- Admin shell redesign follow-up on 2026-04-04: the default admin header now has a subtle Elder Scrolls Online ouroboros watermark layered into the right side of the header card. The intent is to give the everyday non-seasonal header some world flavor and purpose without forcing a tall “template hero” treatment or harming text readability.
- Admin shell redesign follow-up on 2026-04-04: the first sourced ouroboros art was visually wrong for the site. The header watermark asset has now been swapped to the user-provided transparent ESO ouroboros file, with the existing subtle watermark treatment left in place so art choice can be judged before further opacity/placement tuning.
- Admin shell redesign follow-up on 2026-04-04: experimenting with the header watermark at the art's original/native size instead of scaling it to fit. The goal of this pass is to see whether a cropped portion of the ouroboros feels more atmospheric and less “logo stamp” than the fully contained version.
- Admin workflow/layout follow-up on 2026-04-04: the old left-side setup strip beside the prize cards is being retired as a permanent column. `Status` is moving into the right side of the tool strip so it stays visible during crunch time, while the rarely changed raffle setup fields move into an `Edit Raffle` popover from the tool strip. `Import` and `Re-Show` are also being grouped into toolbar dropdowns so the page reclaims width without hiding the stuff admins touch constantly.
- Admin workflow/layout follow-up on 2026-04-04: the first toolbar pass incorrectly split `Status` into a separate live indicator plus dropdown. The intended behavior is one all-in-one status control like the earlier good version, with the visual indicator living inside the dropdown/select itself. Current fix restores that model while keeping the new right-side toolbar placement.
- Regression repair follow-up on 2026-04-04: after the toolbar migration, the status control still looked broken because native select chrome was leaking through and the inline markers had been lost. The prize-card action controls were also still stuck on temporary `L / R / X` placeholders from the earlier encoding cleanup. Current repair restores inline status markers inside the control and brings the prize-card actions back to icon-based visuals via CSS pseudo-icons.
- Status polish follow-up on 2026-04-04: after the regression repair, the right-side status control was still unclear as an interactive dropdown and the explicit `Status` label was colliding visually with it. Current polish removes the redundant label and adds a clearer down-caret to the control itself so the affordance reads more naturally.
- Status polish follow-up on 2026-04-04: a final bug remained where the selected `CLOSED`/`ROLLING` state could inherit the wrong text color and the caret still failed to render reliably. Current fix moves the caret to a wrapper-owned affordance instead of relying on native select chrome and corrects the state-specific color mapping.
- Status bug fix follow-up on 2026-04-04: the selected status text color could still lag behind the actual chosen value because the status-state class was only being refreshed when raffle data reloaded. Current fix updates the status styling immediately in the `change` handler so the closed control reflects the newly selected state without waiting for a refresh.
- Legacy cleanup follow-up on 2026-04-04: confirmed that the old `bonus_tickets` feature is no longer referenced by any active template. The remaining request subscriber/backend helper in `tasks.py` has been removed so that dead path cannot keep confusing future cleanup work.
- Tool-strip refinement follow-up on 2026-04-04: with the workflow pieces now stable enough again, the admin tools strip is being restyled to feel more like a true toolbar and less like a row of chunky pills. This pass tightens the label treatment, slightly squares off the controls, calms the fill/border styling, and gives the status control cleaner spacing so the strip reads more intentional without changing the agreed workflow model.
- Tool-strip refinement follow-up on 2026-04-04: pushed the toolbar further away from loose pill buttons and toward grouped control clusters. `Open New Raffle` is now the one clearly emphasized action, while `Import`, `Re-Show`, and `Edit Raffle` sit inside a shared quieter control group. As part of that QoL cleanup, the `Edit Raffle` popover now puts `Raffle Name` first because that is the field admins actually update during the week.
- Tool-strip refinement follow-up on 2026-04-04: user feedback on the first grouped-cluster pass was that the orange `Open New Raffle` emphasis felt too loud and the clustering logic was off. Current adjustment pairs `Open New Raffle` with `Edit Raffle`, keeps `Import` with `Re-Show`, and tones the primary styling back into the shared blue admin palette so the toolbar will coexist better with future seasonal themes.
- Notes-panel refinement follow-up on 2026-04-04: the notes area is now moving away from an always-open mini word processor. Current pass adds an explicit `Edit Notes` toggle, defaults the notes panel into a calmer read mode, hides the formatting toolbar until editing is opened, and keeps the save button visible only while editing or when unsaved changes exist. The edit toggle now uses a small paper-and-pen style icon treatment instead of plain text alone.
- Notes-panel refinement follow-up on 2026-04-04: after live review, the editor-open header actions were still too chunky and duplicated the meaning of `Saved`. Current cleanup demotes the notes actions into lighter utility-style controls, keeps `Saved` as the status indicator, and only surfaces `Save All` as an actual action when there are unsaved edits across the note tabs.
- Utility-band refinement follow-up on 2026-04-05: notes and import are being kept as matched sibling panels, but the import header is being toned down so the dropzone itself can reclaim visual focus. Current pass shortens both panel title bars in sync, cools the import accent away from loud orange, and softens the dropzone treatment so the center band feels more coordinated and less like two competing slabs.
- New-raffle workflow follow-up on 2026-04-05: `Open New Raffle` is no longer just a browser prompt plus confirm. Current pass turns it into a proper setup modal with suggested raffle number, carried-forward drawing time and ticket cost, blank raffle name, status shown as `LIVE`, and all three note sections prefilled and editable in one place. Creating the raffle now submits exactly what is visible in that modal, so admins can leave notes alone, tweak them, or clear them before the new week starts.
- New-raffle workflow follow-up on 2026-04-05: first live polish moved each notes-section `Clear` action down into the formatting row so it is visible where the editor controls already live. The toolbar `Open New Raffle` trigger was also de-lit so it rests in the same normal/off state as the other admin controls until used.
- Workflow-enforcement follow-up on 2026-04-05: prize actions and weekly rollover now have backend status rules instead of relying on admin memory. Rolling, entering/changing winning ticket numbers, and locking prizes now require raffle status `ROLLING`; opening a new raffle now requires the current raffle to already be `CLOSED`/`COMPLETE`. Finalized prizes are no longer permanently irreversible: they stay locked for normal use, keep a visible lock control, can be unlocked with confirmation, and expose an open-lock icon when reversible. After the final remaining prize is locked, the UI now prompts admins to switch raffle status to `CLOSED`.
- Autosave bug follow-up on 2026-04-05: editing prize text/value while the winner field was blank could still trip the ROLLING-only guard because autosave treated blank winner state as a winner change. The backend now normalizes blank `prize_winner` values to `0` before the status-gate logic runs, so text/value edits no longer falsely require a rolling raffle.
- Admin testing follow-up on 2026-04-05: live testing confirmed prize values and public prize display are working, but several workflow friction points surfaced. Current pass keeps prize-card autosave and action refreshes from bouncing the page to the top, blocks `Open New Raffle` before the setup modal opens unless status is already `COMPLETE`, normalizes lingering `CLOSED` wording/handling toward `COMPLETE`, and flips the prize lock iconography so open lock means unlocked while closed lock means locked.
- Admin testing follow-up on 2026-04-05: a second verification pass confirmed the scroll-jump fix and early new-raffle guard are working. Remaining gaps found during that pass were that unlocked prizes still leaked their ticket number on the public page, and the visible admin status dropdown still said `CLOSED`. Current follow-up fixes the public ticket display so only finalized prizes expose winner ticket numbers, changes the visible admin status label to `COMPLETE`, and gives the lock pill a clearer green-unlocked / red-locked state treatment.
- Public entrants follow-up on 2026-04-05: when the raffle status was not `LIVE`, the public entrants table correctly exposed the extra `Range` column but populated it with the wrong numeric field instead of the computed ticket ranges. Root cause was the range renderer using a hard-coded index that matched the paid-ticket slot in non-barter rows. Current fix reads the appended trailing range field directly so `Range` shows the actual ticket spans again.
- Archive navigation follow-up on 2026-04-05: added a dedicated public `Home` return control for archive browsing so users can jump back to the current raffle without stepping forward raffle-by-raffle. The control is styled in the same family as the existing archive arrows, appears only when viewing an older raffle, and uses a slight accent to distinguish the “return to current” action from previous/next archive movement.
- Archive navigation icon follow-up on 2026-04-05: the first `Home` glyph read too abstractly, so the control is now moving to an inline SVG house outline with a roof, chimney, and door for clearer recognition while keeping the same pill/button footprint.
- Analytics follow-up on 2026-04-05: GA4 integration scaffolding is now in place for public, admin, and login pages using one configurable `GA4_MEASUREMENT_ID` app setting. The shared snippet sends page-level context (`site_area`, `raffle_view`, `raffle_number`, `guild_slug`, `host_name`) and tracks outbound clicks to Google Sheets URLs. The real measurement ID has now been supplied as `G-8C00Y7WF9G`, so the next step is activation via deploy and post-deploy verification in GA4 Realtime/DebugView.
- Analytics follow-up on 2026-04-05: the first activation pass threw a 500 because the analytics snippet tried to JSON-encode undefined Mako values. That crash has been fixed by normalizing undefined context safely inside the shared snippet.
- Analytics follow-up on 2026-04-05: a second activation bug meant the live page was outputting broken/escaped GA JavaScript and blank raffle context. The snippet now derives context directly from `request`, and live verification confirmed valid GA output on the public raffle page with populated values like `site_area=public`, `raffle_view=current`, `guild_slug=bbc1`, and `host_name=raffles.bbcguild.com`.
- Analytics follow-up on 2026-04-05: user verification in GA4 Realtime confirmed `BBC Raffle` pageviews are now being seen, so the tag is alive. GA4 custom definitions for `Site Area`, `Raffle View`, `Raffle Number`, `Guild Slug`, and `Host Name` were also created successfully. We paused before finishing the first Exploration report because the shared-property reporting view was mixing in main-site traffic and the user wanted to stop before getting more frazzled.
- Prize spotlight follow-up on 2026-04-06: started a universal prize-emphasis system instead of a BBC-specific jackpot flag. Current implementation adds a per-prize `prize_style` field with `standard`, `featured`, and `flagship` tiers, stores it in the DB as an additive schema change, exposes a small `Spotlight` selector on admin prize cards, and applies distinct but reusable styling/badges on both admin and public prize cards.

## Known Facts
- `SESSION.md` was introduced after an earlier crash because conversation state had been lost.
- A recovered transcript confirmed the older sync commit `ca4304c` (`admin: sync deployed admin layout changes`) happened after verifying local `admin_index.mako` matched the live Fly copy at that time.
- That older "live matches local but not git HEAD" note is historical only; later commits moved the repo forward from there.
- A visual `Prize Value` field exists in the admin/public UI direction, but it is not yet known from repo notes to be fully wired end-to-end in the backend/schema.
- `FREE` was hidden in UI paths as a band-aid and is still a likely cleanup candidate.
- The app routing code currently expects:
- `raffles.bbcguild.com` as canonical public host
- `raffle.bbcguild.com` and `tickets.bbcguild.com` as public aliases that redirect to the canonical public host
- `raffle-admin.bbcguild.com` as the admin host
- The user currently verifies changes on Fly live rather than through a comfortable local preview loop, so "done" generally means changed and deployed unless they explicitly ask to hold.

## Unknowns
- Which layout issues were fully resolved in-browser versus only partially improved in code.
- Whether `Prize Value` was meant to stay visual-only temporarily or was already intended for real persistence next.
- Whether the next intended task was layout polish, `FREE` removal, or backend support for `Prize Value`.
- Which verbal decisions from the lost chat never made it into the repo.

## Decisions Made
- Keep durable project state in repo files instead of trusting chat history.
- Split recovery data into:
- `SESSION.md` for current active state and next step.
- `DECISIONS.md` for decisions that should not need to be rediscovered after a crash.
- `notes/transcripts/` for raw saved chat dumps when available.
- `RECOVERY_PROCESS.md` for the operating procedure.
- Update and commit recovery notes regularly instead of leaving them local-only for long stretches.
- The eventual source-of-truth data will be the copied production SQLite DB from the old live raffle site, not the throwaway data currently in this test environment.
- DB cleanup/audit should happen near launch cutover, not now, so we do not waste effort cleaning data that may diverge again if the old site has to stay live longer.
- `Prize Value` should be a real persisted DB field if implemented, and the schema change should be additive/migration-safe so the production DB can absorb it cleanly later.
- Old raffle/prize history should be preserved, not wiped, unless a later audit proves specific rows are broken and safe to remove.
- Old blank `Prize Value` rows should stay blank/null rather than being backfilled with fake values.
- Duplicate raffle numbers across different guilds are acceptable; duplicate raffle codes within the same guild are probably undesirable long-term, but we should audit the real DB before enforcing uniqueness.
- Historical `2620b` / `2620c` style raffle codes are treated as emergency recovery artifacts, not a preferred workflow to optimize around.
- Archived raffles often contain winner ticket numbers without finalized prizes; whether to bulk-finalize those old archives is a later cleanup decision, not something to do during active feature work.
- `Prize Value` should be implemented now as a nullable numeric DB field, not fake-filled for old rows and not bundled with broader historical DB cleanup.
- `NULL` is the correct blank-state for `Prize Value`; `0` would incorrectly mean "this prize is worth zero."

## What We Ruled Out
- Relying on chat history alone is not safe enough.
- A single unstructured narrative log is not enough to reconstruct state after repeated interruptions.

## Files To Check First
- `mako_templates/admin_index.mako`
- `mako_templates/index.mako`
- `tasks.py`
- `SESSION.md`
- `DECISIONS.md`

## Exact Next Step
- Before any live DB swap, verify `raffle-working.db` in a staging/local run of the current app so archive lookup, public winner display, and the active `2614` raffles behave correctly against the cleaned migrated data.
- That staging verification is now done on `https://bbcguilds-staging.fly.dev`; the next launch-prep step is to decide the exact cutover process from Jenifer's old live Fly deployment to the new system and which final smoke checks to run immediately before the swap.
- After verification, promote `raffle-working.db` rather than the temporary local `raffle.db`; keep both `raffle-canon.db` and `raffle-working-precleanup.db` untouched as rollback checkpoints.
- On resume, start by checking `git status --short` and `git log --oneline -10` so the repo/deploy state is current.
- If returning to analytics, do not redo GA installation. Start from GA4 reporting only:
- use `Reports -> Realtime` as the sanity check that raffle traffic is arriving
- remember the custom definitions already exist for `Site Area`, `Raffle View`, `Raffle Number`, `Guild Slug`, and `Host Name`
- expect shared-property/main-site noise in Explorations, especially `(not set)` rows from WordPress traffic
- build the first useful Exploration gradually, filtering tightly instead of trying to solve everything at once
- Otherwise continue with the next live QA bug or UI polish item the user wants to tackle
- If resuming the prize spotlight work, verify the new `Spotlight` selector behaves correctly on live admin prize cards and confirm the public featured/flagship treatments feel strong enough without overwhelming the default cards

## If Chat Dies, Resume By Doing This
1. Read `SESSION.md`.
2. Read `DECISIONS.md`.
3. Check `git status --short` and `git log --oneline -10`.
4. Open `mako_templates/admin_index.mako` and compare it to the `Exact Next Step` above.
5. Continue from the next unfinished concrete task instead of trying to reconstruct old chat from memory.

## Historical Context
- The app is 10+ year old raffle software being modernized for two Elder Scrolls Online trading guilds.
- The public page has already gone through a major redesign and mobile cleanup.
- The admin page became the main focus after the public pass.
- Recent large work areas included:
- profile menu/header cleanup
- utility band with notes plus import zone
- guided new-raffle rollover
- prize-card redesign
- public note split into `ADMIN`, `PUBLIC 1`, `PUBLIC 2`
- public entrants density/range/barter rendering
- admin/public ticket table styling cleanup
- Fly host/domain routing behavior

## Open Questions
- Is `Prize Value` now important enough to wire through schema/backend next, or should it stay visual until layout work is done?
- If `Prize Value` is added now, should it be stored as a nullable numeric column so future `Total Prize Value` math stays possible?
- Is `FREE` truly obsolete across the whole app?
- Are there still visible admin layout issues in the right gutter or ticket panel on the target screen size?
- Do we want to commit this recovery scaffolding immediately after setup?
- At cutover time, should we audit and possibly clean:
- duplicate same-guild raffle codes
- multiple open raffles in one guild
- obviously broken/empty recovery raffles
- old archive rows with winner numbers but unfinalized prizes
- Browser-level verification still needed:
- confirm `raffle.bbcguild.com` redirects to `raffles.bbcguild.com`
- confirm `tickets.bbcguild.com` redirects to `raffles.bbcguild.com`
- confirm `raffle-admin.bbcguild.com/login` now shows the new-style login page cleanly

## 2026-04-08 Latest Work
- Added first-pass guild settings groundwork:
- `guilds` schema now includes `guild_eso_id` and `guild_expected_mail_accounts`
- `init_db.py` backfills those columns on older databases
- `db.py` now exposes `set_guild_settings(...)`
- `tasks.py` now exposes `/{guild}/json/set/guild_settings`
- `json/get/guild` now returns `guild_eso_id` and parsed `guild_expected_mail_accounts`
- `mako_templates/admin_index.mako` now has a `Guild Settings` profile-menu item and modal for:
- guild display name
- ESO guild ID
- expected mail-import account list
- The save-handler bug in `set_guild_settings` was fixed and `py -3 -m py_compile tasks.py db.py init_db.py` now passes.
- This first pass is intentionally modest and is the starting point for the broader sitewide config screen.
- Live import guardrails currently work like this:
- bank imports use wrong-guild detection and skip mismatched bank rows automatically
- mail imports warn on unexpected source account but still allow review/import
- matching is currently by normalized guild name, not stored ESO guild ID yet
- Live DB drift that restored `Company` in guild headers was corrected directly in production on 2026-04-08.
- Current live guild names are back to:
- `bbc1` = `Bleakrock Barter Co`
- `bbc2` = `Blackbriar Barter Co`

## Exact Next Step
- Deploy the first-pass `Guild Settings` modal/live backend changes.
- Then test on live:
- open `Guild Settings` from the profile menu
- confirm fields load and save
- confirm guild header name updates after save
- confirm Bleakrock bank imports on the Bleakrock page are accepted again
- After that, decide whether the next config slice should be:
- true `guild_eso_id`-based bank matching
- richer sitewide config UI
- or more guardrail polish

## 2026-04-08 Account Settings Slice
- Added first-pass admin `Account Settings` for per-user preferences.
- `auth_users` schema now includes:
- `auth_timezone`
- `auth_datetime_format`
- `init_db.py` backfills those columns on older databases.
- New authenticated JSON routes:
- `/{guild}/json/get/account_settings`
- `/{guild}/json/set/account_settings`
- Admin profile menu now includes `Account Settings`.
- Current v1 preferences:
- `Time Zone`
- `Date / Time Format`
- `Use Browser Local Time` is supported as the no-explicit-timezone option.
- Admin-facing timestamps now respect the logged-in user preference:
- topbar `Last Updated`
- import-review `[Mail]` / `[Bank]` timestamps
- Public-facing time behavior was not changed by this slice.
- Live deployed on Fly version `335`.

## 2026-04-09 Guild Branding Slice
- Extended `Guild Settings` branding controls.
- `guilds` schema now includes:
- `guild_favicon_url`
- `guild_primary_color`
- `guild_accent_color`
- `init_db.py` backfills those columns on older databases.
- `json/get/guild` now returns favicon/color branding fields.
- `Guild Settings` now includes:
- `Guild Favicon URL`
- `Primary Color`
- `Accent Color`
- live favicon preview
- Branding now applies on both admin and public pages:
- configured favicon updates browser tab icons
- configured brand colors update CSS brand variables
- configured guild logo still drives admin/public logo image as before
- Live deployed on Fly version `336`.

## 2026-04-10 Staging Barter + Addon State
- Current active environment for barter work is `staging`, not live.
- Staging app: `bbcguilds-staging`
- Live app: `bbcguilds`
- Staging was refreshed from live earlier in the session and has prominent env-driven `STAGING` treatment.

### Website / Staging Status
- Barter UI/features built on staging include:
- `Barter Bounty List`
- public `View Barter List`
- raffle-level barter toggle
- `Barter Summary`
- import preview/source labels:
- `[Gold-Mail]`
- `[Gold-Bank]`
- `[Barter-Mail]`
- `[Barter-Bank]`
- Public barter list currently shows the live/current bounty list, not a frozen raffle snapshot.
- Intended model going forward:
- current bounty list = current policy
- accepted barter entries = historical truth/reporting
- `View Barter List` only appears when barter is on.
- Public barter list simplified to:
- `Qty | Item Name | = | Barter Rate`

### Confirm/Mailmerge Payload Status
- `<<4>>` work has now been coded locally but not distributed/deployed yet.
- Desired payload shape is:
- `@name,paid_this_tx,barter_this_tx,total_after_tx|`
- Example:
- `@name,50,0,200|`
- Meaning:
- `<<1>> = @name`
- `<<2>> = 50`
- `<<3>> = 0`
- `<<4>> = 200`
- Website-side local change:
- `tasks.py` now emits `name,paid,barter,total`
- Addon-side local change:
- `RaffleManager.lua` now unpacks 4 values and calls:
- `zo_strformat(body, recipient, tickets, barter, total)`
- Important:
- this was intentionally **not** pushed to users yet because `<<4>>` is not urgent and Susan should not be asked to reinstall repeatedly.
- Addon side is backward-tolerant:
- if total is missing, addon falls back to `tickets + barter`
- so newer addon should still behave against older live confirm strings.

### Addon Status
- Standalone addon repo path:
- `addon-repos/RaffleManager/`
- Current addon work is local and in progress; not all changes are pushed yet.
- Current tested truth:
- `Mail Barter` path works when operator clicks through all mails first so ESO marks them readable.
- Accepted workflow:
- open/read all mails
- click `Export Mailbox`
- `/reloadui`
- upload saved vars
- This appears to be an ESO/mail API limitation for item attachments rather than an intentional “read mails only” addon rule.
- Gold-only mail can still be scraped without manual open/read.

### Addon Mail Barter Validation
- Successful saved-vars export proved:
- `mail_barter_enabled = true`
- `export_metadata.mail.barter_enabled = true`
- `barter_row_count > 0`
- `barter_item_count > 0`
- actual `attachments` blocks present in `mail_data`
- Mail barter test on staging worked end-to-end after user temporarily removed blacklist conflict.
- Important funny/real validation:
- several missing barter mails were from blacklisted `@Hiyde`
- after unblacklisting, those barter mails appeared
- so blacklist is being honored for barter mail too, as intended.

### Addon Chat Spew
- Mail export chat message was improved locally to include:
- total mail events stored
- number of mails with barter attachments
- total attachment items
- Example target wording:
- `21 mail events stored (5 with barter attachments / 12 total attachment items). Reload your UI to updated SavedVariables.`
- This helps operator eyeball whether attachment-bearing mail was really captured without opening the `.lua` file.

### Addon UI Tweaks
- Local addon XML changes already made:
- window moved slightly left
- window made taller to fit new controls/confirmation area
- barter toggle buttons added:
- `Mail Barter: ON/OFF`
- `Bank Barter: ON/OFF`

### Bank Barter Status
- `Bank Barter` is wired up enough to test, but not validated enough to trust yet.
- Honest status:
- yes, testable
- no, not yet proven reliable end-to-end
- Mail barter is the trusted path right now.

### Known Staging/Barter Import Notes
- Hidden-field parsing bug that caused barter tickets to fall into paid and prevented `barter_entries` recording was fixed in `tasks.py`.
- Item-code normalization and nested-attachment normalization were also fixed on staging.
- If barter summary is blank after a new import, first suspect whether that import happened **before** the hidden-field fix.
- If addon export shows `barter_row_count = 0` and `barter_item_count = 0`, the problem is addon/mail export, not staging importer.

### What The User Cares About Operationally
- Do not make Susan reinstall addon every day.
- `<<4>>` is nice-to-have, not urgent.
- Legacy ticket running should keep working with older addon.
- New barter system will require updated addon when live is ready, but that rollout can wait.

## Exact Next Step
- User is about to restart the whole system.
- On resume:
1. Read this section of `SESSION.md`.
2. Confirm current repo/addon status with:
- `git status --short`
- `git -C addon-repos/RaffleManager status --short`
3. Ask what they want to do next, but the most likely next task is:
- run the first real `Bank Barter` exploratory test on staging
- or continue barter validation/reporting cleanup on staging
- Do **not** push `<<4>>` addon/site changes to users/live unless explicitly requested again.

## 2026-04-11 Addon UI + Ticket Accuracy Follow-Up
- Addon UI local work continued in `addon-repos/RaffleManager/` with a larger main window and a substantial export-tab redesign.
- Export tab now has clearer `Actions` / `Settings` / receipt-code sections, divider lines, and a right-side 4-toggle stack:
- `Mail Barter`
- `Bank Barter`
- `Mail-Gold`
- `Bank-Gold`
- First-pass color styling is in place:
- green addon title
- blue section headers
- red `Save/ReloadUI`
- toggle labels now attempt partial `ON/OFF` coloring via ESO inline color markup
- Mail Template / Confirm tab layout was also rebalanced for the larger frame:
- Message body area widened/tallened to match the new window size
- Confirm list now includes `GOLD | BARTER | TOTAL | STATUS`
- Confirm progress bar width bug was fixed by reading the actual control width instead of using the old hard-coded `500`
- Addon-side confirm payload support for `<<4>>` is now wired locally:
- addon parses `name,paid,barter,total`
- confirm list stores/shows the `TOTAL` column
- mail-merge send path passes `recipient, tickets, barter, total`
- Important addon truth after this pass:
- the addon UI/toggle work now feels visually stable enough for use
- `Bank Barter` is no longer just "theoretical UI"; real end-to-end mixed-path testing happened immediately after this pass

### 2026-04-11 Ticket Accuracy Scare / Importer Fix
- User caught a sacrosanct ticket-accuracy scare while validating Hiyde / tieberion totals and correctly treated it as a nightmare scenario.
- Investigation showed the import preview could visibly show one barter-ticket amount while the submit path still re-read hidden `barter_items_json`, recomputed barter, and silently used the larger value.
- That behavior lived in `tasks.py` in the main ticket import submit path and was judged unacceptable for a human-reviewed approval screen.
- Local fix now in `tasks.py`:
- accepted import rows trust the visible reviewed `barter_tickets` value
- hidden `barter_items_json` is still retained for item-detail recording
- if hidden computed barter and visible barter disagree, the server now logs a warning instead of silently importing the larger number
- Product principle confirmed explicitly with user:
- ticket counting is sacred
- visible reviewed import numbers must be the source of truth
- hidden data must never silently change ticket counts after approval

### 2026-04-11 Mixed-Path Validation That Passed
- User ran a clean sanity test using **every relevant ticket path in one batch** for both `Hiyde` and `tieberion`.
- Pre-import site totals captured from screenshots:
- `Hiyde`: total `4300`, barter `90`, paid `4210`
- `tieberion`: total `3136`, barter `90`, paid `3046`
- Import preview rows for **each** user:
- `+100` `Gold-Bank`
- `+150` `Barter-Bank` via `10x Dreugh Wax`
- `+300` `Barter-Bank` via `1x Aetherial Dust`
- `+160` `Gold+Barter-Mail` via `10x Dreugh Wax`
- `+10` `Gold-Mail`
- Expected added total per user:
- `100 + 150 + 300 + 160 + 10 = 720`
- Expected new grand totals:
- `Hiyde = 5020`
- `tieberion = 3856`
- Post-import site screenshots matched **exactly**:
- `Hiyde`: total `5020`, barter `210`, paid `4810`
- `tieberion`: total `3856`, barter `210`, paid `3646`
- This was the important peace-of-mind test after removing the hidden override path, and it passed exactly.

### Reporting / Hardening Direction
- User is now understandably interested in stronger ticket auditability/reporting.
- Likely next hardening feature:
- per-user ticket ledger / transaction history
- show every accepted transaction that contributed to the current total
- include source type, source UID, timestamp, paid added, barter added, and running total
- This is now a serious trust/operations feature, not just "nice to have UX."

## Exact Next Step
- On resume, read this 2026-04-11 section first instead of assuming the older "Bank Barter not yet trusted" notes are still the whole story.
- Most likely next task is one of:
- update the older staging/barter notes to reconcile with the newer successful validation
- build the per-user ticket ledger / transaction reporting
- commit and/or deploy the ticket-accuracy importer fix when the user is ready
