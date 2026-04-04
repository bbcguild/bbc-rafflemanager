# Session Log

Use this file as the durable memory for active work so we do not rely on chat history alone.

## Project Overview
- This is 10+ year old raffle software being modernized with a new UI and new features.
- The software runs raffles for two trading guilds in Elder Scrolls Online.
- Existing data connections and configuration have already been carried forward into the redesigned UI.
- The public-facing page has already been updated for desktop and mobile.
- The admin page is the current active focus.
- Recent completed admin work includes adding the profile menu in the top-right, cleaning up the header, and then moving into the middle content sections.

## Product Vision
- Keep iterating the UI until the whole experience feels modern and cohesive.
- Add new features, including a real `Prize Value` field once it is designed and wired end-to-end.
- Move hardcoded guild references such as guild name, short name, and logo URLs into a control panel or settings system.
- Add a seasonal template system, already reserved in the profile menu, that can swap in themed visuals such as Christmas, Halloween, and anniversary treatments.
- Make the system easier to deploy for additional guilds without hardcoding per-guild behavior.
- Add a deeper access/permissions model so super admins can deploy and manage all sites while normal users only access assigned sites.
- Add a richer WYSIWYG editor for freeform notes areas; the legacy system had a limited plain text / HTML editor and the redesign expects two such editable content areas.

## Current Goal
- Refine the admin page layout in `mako_templates/admin_index.mako`.
- Improve the three-column layout, prize card UI, and ticket table usability.
- Preserve session context in this file so VS Code/chat restarts do not erase working memory.
- Resolve layout conflicts between the center winner/prize cards and the right-side ticket list/table.
- Adjust the winner card layout so `Prize Value` sits under the prize description, with `Winning Number` and `Winner` sharing the bottom row.

## Decisions
- Includes reconstructed notes plus user recap on 2026-04-04.
- Switched the main admin table layout to CSS grid for tighter column control.
- Restyled prize entries into a card-style layout with clearer action buttons.
- Added a `Copy Names + Totals` action for the ticket table.
- Reduced ticket table column widths and set dynamic table height.
- Limited prize autosave binding to inputs with a `name` attribute so the new visual-only `#prize_value` input does not post to `json/set/prize`.
- The right-side ticket table is a Handsontable, and its sizing/styling behavior was a major factor in the layout conflicts.
- The `FREE` ticket field/column was only hidden as a band-aid; it still exists in code paths and data handling.
- The copy button was added so users no longer need to drag-select two Handsontable columns to paste name and total ticket counts into Google Sheets.
- Long-term cleanup idea: fully remove `FREE` from the codebase if it is confirmed obsolete.
- Winner card follow-up on 2026-04-04: move `Prize Value` into its own row below the prize description and simplify the bottom row to `Winning Number` plus `Winner`.
- Winner card follow-up on 2026-04-04: change the ticket placeholder text to `Ticket #` and add frontend-only numeric/comma formatting for `Prize Value`.
- Winner card follow-up on 2026-04-04: square off the main prize card and its content bubbles, while keeping the action buttons rounded and replacing `f`/`R`/`x` with lock, dice, and trash icons.
- Winner card follow-up on 2026-04-04: soften the locked/finalized winner highlight to a subdued green treatment that is friendlier on HDR displays.
- Ticket table follow-up on 2026-04-04: restyle the Handsontable to match the admin theme, using one shared color treatment for column/row labels and a second treatment for value cells, while removing the old black/white border look.
- Left settings panel follow-up on 2026-04-04: move the `Status` dropdown to the top of the left column.
- Left settings panel follow-up on 2026-04-04: color the `Status` dropdown to match the header/public status palette and rename the visible `COMPLETE` option label to `CLOSED` while keeping the backend value unchanged.
- Left settings panel follow-up on 2026-04-04: make the `Status` dropdown text bold and add inline status markers to the visible labels (`● LIVE`, `🎲 ROLLING`, `● CLOSED`).
- Left settings panel follow-up on 2026-04-04: switch the dropdown markers to emoji so they match the dice better (`🟢 LIVE`, `🎲 ROLLING`, `🔴 CLOSED`).
- Header follow-up on 2026-04-04: remove the redundant live/rolling/closed status bug from the admin header and leave only the centered `ADMIN` bug with the orange bar, while keeping the left-side status dropdown as the primary status display.
- Header follow-up on 2026-04-04: shorten the top-right raffle lookup placeholder from `Enter raffle #` to `Raffle #`.
- Layout follow-up on 2026-04-04: add a new full-width utility band between the button bar and the three-column admin layout, with a large notes panel on the left and the ticket-file drag/drop uploader moved into a dedicated panel on the right.
- Layout follow-up on 2026-04-04: restyle the drag/drop import zone with a darker muted interior and a brighter blue dotted outline to better match the mockup direction.
- Layout follow-up on 2026-04-04: update the import-zone copy to explicitly call for `RaffleManager.lua` instead of generic ticket files.
- Modal follow-up on 2026-04-04: restyle the import/confirm/paid/barter popups with darker gray surfaces that still keep black text readable, raise their stacking above the ticket table, add a backdrop, and make the modal bodies internally scroll so long imports stay inside the popup instead of floating over the page.
- Modal follow-up on 2026-04-04: the paid-import popup needed an extra specificity override because legacy `div#paid_template` CSS was still forcing it under the new modal stack and making it appear greyed out/inactive.
- Profile menu follow-up on 2026-04-04: align the `Logout` row the same way as the `Template` row and remove the hover gap between the main menu and the template flyout so the submenu stays open while moving the mouse across.
- Notes system follow-up on 2026-04-04: expand the single legacy note field into three editable note surfaces managed from one admin box with tabs (`ADMIN`, `PUBLIC 1`, `PUBLIC 2`), keep the existing `raffle_notes` content as `PUBLIC 1` for continuity, and render the two public notes side by side on the public-facing page.
- Notes system follow-up on 2026-04-04: hide the public note bodies until raffle JSON arrives so the old hardcoded placeholder/help text does not flash for a split second on page refresh.
- Notes system follow-up on 2026-04-04: remove the remaining hardcoded public fallback/help copy so both public note boxes render only saved note content or stay blank.
- Prize follow-up on 2026-04-04: harden the `Add prize` control by making it an explicit button and wiring it directly to `addPrizeCard()` instead of relying only on the jQuery click binding.
- Prize follow-up on 2026-04-04: `Add Prize` still appeared broken on Bleakrock and Blackbriar even though Fly logs showed successful `prize_add` calls and growing `/json/get/prizes` payloads. Root cause was a new frontend regression in `get_prize_info()`: recently added prize cards were generating DOM IDs/selectors from `prize_text2`, and new prizes start with `?`, producing invalid selectors like `#prize_?_value` during redraw. The fix switches prize-card DOM IDs to stable `prize_id` values and scrolls the newly added card into view after a successful add.
- New raffle follow-up on 2026-04-04: replace the blind `Open New Raffle` rollover with a guided prompt that suggests the next raffle number from the current raffle number first. For the BBC `YYWW` pattern, `2614` suggests `2615`, and `2652` rolls to `2701`. The prompt remains editable, and backend creation carries forward raffle time and ticket cost, clears the raffle title, resets status to `LIVE`, and uses the approved/edited raffle number instead of hardcoded `0`.
- Additional new raffle follow-up on 2026-04-04: the hidden admin control behind `Open New Raffle` was still a `type="submit"` input, which likely allowed the legacy form-submit behavior to interfere with the new prompted rollover flow. It is now converted to `type="button"` and the click handler explicitly prevents default submission so the prompted creation path is the only action that runs.
- Additional new raffle follow-up on 2026-04-04: Fly logs showed the prompted `open_raffle` route was still failing with HTTP 500 because `tasks.py` was calling `.get(...)` on a `sqlite3.Row` object. That meant no new raffle was being created at all. The route now converts the current raffle row to a plain dict before building the new raffle payload.
- Prize follow-up on 2026-04-04: after the raffle rollover fixes, `Add Prize` began creating cards in pairs. Root cause was duplicate frontend wiring: the button still had both an inline `onclick="return addPrizeCard()"` and a jQuery `click` binding. The inline handler has been removed so only one add call fires per click.
- Follow-up layout feedback on 2026-04-04: the right-side ticket table still showed a black empty strip on the right, and the scrollbar returned because range values started wrapping around row 44 and increased row height.
- Corrected follow-up fix in `admin_index.mako`: the ticket table should not stretch to consume extra width; instead, the right column should size to the table's needed width while the center winner-card area receives the leftover space, with the range column kept on one line.
- Additional follow-up on 2026-04-04: after deploying the width fix, the black strip was nearly gone and row wrapping was resolved, but a small internal table scrollbar still remained; next adjustment changed the ticket table to `height: "auto"` so Handsontable can grow to full content height instead of using a guessed pixel height.
- Additional follow-up on 2026-04-04: after `height: "auto"`, the nested scrollbar disappeared but the final populated row and the usual blank manual-entry row were still not fully visible. Root cause appears to be legacy global Handsontable wrapper CSS (`.wtHolder { height: 100%; }`) fighting auto-height.
- The ticket table also visibly slid in from the right on page load; the current fix hides `#ticket_info` until Handsontable has fully initialized, then reveals it without animation.
- Additional follow-up on 2026-04-04: the prior fix still did not change the visible behavior. A stronger likely cause is panel-level clipping from `#right { overflow:hidden; }`, and the visible slide-in may be the whole right column reflowing as ticket content arrives rather than just the table node itself.
- Current local fix changes `#right` to `overflow:visible` and toggles readiness on the whole right ticket panel instead of only on `#ticket_info`.
- Additional follow-up on 2026-04-04: after deploying the panel-level fix, the final purchaser row and spare blank row became visible, but the table could extend beyond the rounded panel and the page-load slide-in effect still remained.
- Current local fix returns the right panel to clipping its contents, overrides legacy fixed-height layout rules so the panel can grow naturally with the table, and reserves the ticket panel width up front to reduce reflow on initial load.
- Additional follow-up on 2026-04-04: the latest deploy fixed the table containment and removed the main table animation, but the `Copy Names + Totals` button still animated to the right on load.
- Longstanding scroll artifact note: users see white ghost boxes flicker at the top/bottom during scroll; after the recent layout changes, that artifact became much larger and more obvious.
- Current local fix overrides legacy `body` absolute/100%-height rules from `static/css/main.css`, pins the page background color at the document level, and sets a stable fixed width for the ticket panel so the copy button does not shift during load.
- Additional follow-up on 2026-04-04: the latest deploy successfully removed the white strobe/flicker effect. Remaining issues are right-edge spacing: the header leaves an odd gap before the right edge, the far-right button sits against the browser edge, and the ticket section can exceed the chrome window and partially cut off the copy button.
- Current local fix normalizes box-sizing at the template level, makes the page shell explicitly border-box and full-width, removes the header's extra right margin, and makes the main sections respect the shell width consistently.
- Additional follow-up on 2026-04-04: edge alignment is now consistent and the copy button is fully visible, but the whole layout still appears flush to the browser on the right while a visible gutter remains on the left.
- Current local fix adds a stable scrollbar gutter and relaxes `.page-shell` away from forced `width:100%` so the browser scrollbar does not visually consume the right-side outer padding.
- Additional follow-up on 2026-04-04: the scrollbar-gutter tweak did not create a visible right-side gap.
- Current local fix stops relying on shell padding for the outer gutter and instead makes `.page-shell` physically narrower than the viewport with `width:min(1880px, calc(100% - 36px))`, which should force a real 18px margin on both sides.
- Additional follow-up on 2026-04-04: the narrower shell width still did not create a visible right gutter in practice.
- Current local fix moves the horizontal gutter to the `body` itself with `padding: 0 18px` and returns `.page-shell` to a normal `width:100%` centered container, so the browser viewport always reserves the same left/right outer spacing.
- Additional follow-up on 2026-04-04: equal left/right body padding still did not look equal on screen, because the browser scrollbar visually consumed the right-side gutter.
- Current local fix compensates for the scrollbar explicitly by adding extra right padding on `body`, aiming for equal visible gutter rather than equal raw CSS padding.

## Reconstructed Context
- Recent committed work before the interruption was focused on the admin page in `mako_templates/admin_index.mako`.
- Commit `5674ab0` on 2026-04-03 removed unused left-column controls such as `Clear dupes` and the CSV export link.
- Commit `c842a84` on 2026-04-04 adjusted the admin header to prevent desktop overflow and added a `max-width:1450px` wrap breakpoint.
- Commit `764b37c` on 2026-04-04 narrowed the left guild-info column from `420px` to `210px` and constrained left-side controls like raffle notes and the upload dropzone.
- The current uncommitted diff appears to continue that same cleanup by redistributing space across all three columns instead of only tightening the left side.
- The uncommitted diff converts `#main_table` into a CSS grid, likely to make the center and right columns denser and more predictable.
- The prize editor has been reworked from a table-row layout into a card layout with larger inputs and stacked action buttons.
- The ticket pane now includes a `Copy Names + Totals` button that copies tab-separated name/total lines from the Handsontable data.
- Ticket table sizing was also tuned with narrower column widths and dynamic height based on row count.
- The latest local/live `admin_index.mako` change set was intended as a layout test pass after adding the copy button and tightening the layout.
- A new `Prize Value` input exists in the prize card markup, but it is not persisted by the backend schema or the current save route.
- On 2026-04-04, a direct Fly checksum check indicated the live `/app/mako_templates/admin_index.mako` matches the current local working tree, not the committed `HEAD` version.

## Files Changed
- `mako_templates/admin_index.mako`
- `SESSION.md`

## Open Questions
- Confirm whether the new prize layout is complete or still needs spacing/alignment tweaks.
- Confirm whether the new `Prize Value` field should be removed, repurposed, or added properly to the backend.
- Confirm whether the ticket copy button output format is exactly what is wanted.
- Confirm whether the ticket table width/height changes feel right with real raffle data.
- Confirm whether the currently deployed live version was intentionally deployed from an uncommitted local state or from a later local build step outside git.
- Confirm whether `FREE` is truly obsolete so we can remove it from the codebase instead of continuing to hide it in the UI.
- Confirm that the new Handsontable stretch/no-wrap fix removes the black strip and prevents range wrapping for longer ticket ranges.
- Confirm that the corrected content-width right column removes the black strip while giving extra width back to the center winner cards.
- Confirm that using `height: "auto"` removes the last remaining internal scrollbar without creating a new layout problem.
- Confirm that overriding the legacy `.wtHolder` height restores visibility of the last real row plus the spare blank row.
- Confirm that hiding `#ticket_info` until initialization removes the table slide-in effect on page load.
- Confirm that removing `#right` clipping restores the final purchaser row and spare blank row.
- Confirm that hiding the whole right ticket panel until ready eliminates the apparent slide-in/reflow on page load.
- Confirm that restoring normal clipping after the height overrides keeps the full table inside the right-side panel.
- Confirm that reserving the right panel width up front removes the remaining load-time slide/reflow effect.
- Confirm that the fixed-width ticket panel stops the copy button from animating off to the right.
- Confirm that overriding the legacy `body` sizing removes the white flicker/strobe effect during scroll.
- Confirm that the right-edge spacing is now consistent across the header, button row, and ticket section.
- Confirm that the right-side outer gutter now visually matches the left side.
- Confirm that using a narrower shell width creates a real matching gutter on the right.
- Confirm that the body-level horizontal padding creates a visible matching right gutter.
- Confirm that explicit scrollbar compensation makes the visible right gutter match the left.

## Next Step
- Review `mako_templates/admin_index.mako` in the browser and verify the updated admin layout behaves correctly on the target screen size.
- Decide what to do with `#prize_value` before shipping this diff.
- Decide whether the next pass should focus on layout polish or on removing `FREE` end-to-end.
- Verify the ticket range column still behaves correctly with very large ranges such as `100000-1000001`.
- Keep this file updated whenever the task direction changes or we stop for the day.

## Resume Prompt
- Continue by reviewing the current layout interaction between the center prize cards and the right-side Handsontable, confirm the copy button still covers the Google Sheets workflow, then decide whether to polish layout further or remove `FREE` from the codebase.

## Checkpoint Habit
- Update this file when we start a session.
- Update it again after any meaningful change in direction.
- End each session with a clear `Next Step` and `Resume Prompt`.
