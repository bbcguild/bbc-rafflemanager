# Session Log

Use this file as the source of truth for the active work session. If chat dies, resume from this file first.

## Current Goal
- Continue the raffle manager modernization with focus on the admin UI.
- Most immediate active area: `mako_templates/admin_index.mako`.
- Current unresolved theme: admin layout polish around the center prize cards, the right-side ticket table, and outer page gutter alignment.

## Current Status
- Repo state at restart recovery: clean working tree when this crash-resistant workflow was set up on 2026-04-04.
- The project was recently in a heavy admin/public UI iteration cycle, mostly on 2026-04-04.
- This file is now intentionally structured for crash recovery, not just narrative notes.

## What Changed Recently
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
- Verify the bolder grouped-toolbar pass in-browser on the admin page.
- Specifically check:
- whether the clustered toolbar feels more like a control rail and less like floating pills
- whether the new cluster pairings feel more logical (`Open New Raffle` + `Edit Raffle`, `Import` + `Re-Show`)
- whether `Open New Raffle` now has the right level of emphasis without the loud orange
- whether the reordered `Edit Raffle` panel feels better with `Raffle Name` at the top
- whether the new `Edit Notes` open/close behavior makes the notes area feel calmer during normal tab switching
- whether the lighter-weight `Edit Notes` / `Save All` utilities feel cleaner than the earlier chunky buttons
- whether the toned-down import header still feels important enough without shouting orange
- whether the new raffle-setup modal feels like a smoother weekly workflow than the old prompt/dropdown combo
- whether the relocated `Clear` control is now easier to find in the notes editors
- whether the new status enforcement and reversible lock/unlock flow feel right in practice
- then decide whether to keep polishing the notes/import workspace or move down into broader center/right layout work

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
- Is `FREE` truly obsolete across the whole app?
- Are there still visible admin layout issues in the right gutter or ticket panel on the target screen size?
- Do we want to commit this recovery scaffolding immediately after setup?
- Browser-level verification still needed:
- confirm `raffle.bbcguild.com` redirects to `raffles.bbcguild.com`
- confirm `tickets.bbcguild.com` redirects to `raffles.bbcguild.com`
- confirm `raffle-admin.bbcguild.com/login` now shows the new-style login page cleanly
