# Recovery Process

Use this process whenever a session starts, pauses, or crashes.

## Start Of Session
1. Read `SESSION.md`.
2. Read `DECISIONS.md`.
3. Run `git status --short`.
4. If context still feels unclear, read the most recent saved transcript in `notes/transcripts/`.
5. Update `SESSION.md` before doing substantial work.

## During Work
1. After each meaningful change in direction, update `SESSION.md`.
2. When a decision is settled and should not need to be rediscovered, add it to `DECISIONS.md`.
3. If a chat transcript is exported or pasted, save it under `notes/transcripts/` with a dated filename.
4. Make checkpoint commits regularly instead of waiting for a perfect stopping point.

## End Of Session
1. Update `SESSION.md`:
- current goal
- what changed
- exact next step
- known unknowns
2. Update `DECISIONS.md` with any newly settled decisions.
3. Commit the code plus recovery notes together.
4. Deploy to Fly by default after completed modifications unless a blocker or user question requires pausing first.
5. Push when appropriate.

## Crash Recovery
1. Do not rely on memory.
2. Read `SESSION.md` and `DECISIONS.md`.
3. Check git status and recent commits.
4. Resume from the explicit next step written in `SESSION.md`.

## Suggested Checkpoint Commit Messages
- `checkpoint: admin layout recovery state`
- `checkpoint: ticket panel sizing investigation`
- `checkpoint: prize value wiring status`
- `checkpoint: free cleanup analysis`
