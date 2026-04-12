# Launch Checklist

## Goal
Switch from Jenifer's old live Fly deployment to the new `bbcguilds` app using the cleaned launch-candidate database in `raffle-working.db`.

## Known Good Inputs
- Raw historical source: `C:\Users\jeff\Documents\ChatGPT\Raffle Site\bbc-rafflemanager-main-from-github\raffle-canon.db`
- Pre-cleanup checkpoint: `raffle-working-precleanup.db`
- Launch candidate: `raffle-working.db`
- Verified staging app: `https://bbcguilds-staging.fly.dev`

## What Has Already Been Verified On Staging
- `/health` reports healthy database connectivity
- `bbc1` current raffle JSON returns `2614`
- `bbc2` current raffle JSON returns `2614`
- historical archive lookup works for converted raffles like `/bbc1/2331/`
- old archive winner names render from finalized historical prize data
- old "last X raffles only" depth cap is removed

## Pre-Cutover Checks
1. Confirm `raffle-working.db` is the approved launch database.
2. Confirm `bbcguilds` is healthy before touching its DB.
3. Confirm custom certs on `bbcguilds` are still issued for:
   - `raffles.bbcguild.com`
   - `raffle.bbcguild.com`
   - `tickets.bbcguild.com`
   - `raffle-admin.bbcguild.com`
4. Make one more local backup copy of `raffle-working.db` with a timestamped filename.
5. If Jenifer's old live system has changed since the copied canon DB was taken, stop and reassess before cutover.

## Production DB Swap
1. Run:
   `.\upload-db.ps1 prod -LocalDbPath .\raffle-working.db`
2. The script should:
   - ensure a machine is running
   - back up `/data/raffle.db`
   - move the previous live DB aside
   - upload `raffle-working.db`
   - fix permissions
   - verify remote file size
   - restart the app machine

## Immediate Post-Swap Smoke Checks
1. Check:
   `https://bbcguilds.fly.dev/health`
2. Check:
   `https://raffles.bbcguild.com/`
3. Check:
   `https://raffles.bbcguild.com/bbc1/`
4. Check:
   `https://raffles.bbcguild.com/bbc2/`
5. Check:
   `https://raffles.bbcguild.com/bbc1/2331/`
6. Check admin host:
   `https://raffle-admin.bbcguild.com/`
7. Confirm:
   - both guilds show current raffle `2614`
   - deep archive browsing works
   - archived winner names show on older completed raffles
   - admin login still loads

## Rollback
If the production swap misbehaves:
1. Identify the backed-up remote DB created by the upload script.
2. Move it back into place as `/data/raffle.db`.
3. Restart the `bbcguilds` machine.
4. Re-run the smoke checks.

## Notes
- `bbcguilds-staging` is a long-term safe test environment and should stay separate from production.
- The current local Python environment is still blocked by `cryptacular`, so Fly staging is the safer verification path for now.
