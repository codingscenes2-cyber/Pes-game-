# Development roadmap and acceptance criteria

## M1 — playable match foundation

**Implemented in source:** Godot 4 project configuration, generated pitch and goals, 22 capsule players in a basic 4-4-2-like layout, one user-controlled player, basic team movement, a rigid-body ball, follow camera, score HUD, touch buttons and keyboard fallback.

**Verified:** GitHub Actions imported the project with Godot 4.3 and booted the main scene headlessly on the latest committed source. **Still not verified:** interactive gameplay feel, collision tuning, touch layout on physical Android aspect ratios, Android export.

**Acceptance:** headless import and scene boot pass in CI (done); interactive movement, ball response, passing/shooting, goal/reset, touch controls and Android export still require manual/device verification.

## M2 — ball mastery and actions

**Implemented in source (early pass):** nearest-to-ball player switching, ground pass, heuristic through pass, normal/finesse/chip shot variants, proximity-based close-control nudges, a cooldown-based proximity tackle/ball deflection, low-speed soft possession acquisition, spring-force ball carrying, and hold-to-shield side carry, and a short pass/shot input buffer while approaching the ball. Keyboard and touch HUD inputs are wired.

**Still missing:** robust contested possession/ownership transitions, directional first-touch control, shielding collision/strength mechanics, timed tackle outcomes, interceptions, headers/volleys, pass/shot input buffering, animation-linked contact windows, pass target UI, tuned shot curves, and verified input-buffer edge cases.

**Acceptance:** repeatable tests demonstrate controllable first touch, predictable dribble touches at multiple speeds, accurate ground/lofted/through passing, distinct shot trajectories, tackles and possession transitions without ball teleporting or excessive impulse. Run on device before marking complete.

## M3 — team AI and goalkeeper

**Initial foundation committed:** corrected home/away formation orientation and scoring direction; both teams now designate a goalkeeper, track the ball laterally along the goal line, step forward when the ball enters the box, and attempt a basic clearance at close range.

**Still to implement:** formation-aware spacing, support runs, defensive line, pressing triggers, marking, interceptions, transitions, keeper dives, catches/parries, goal kicks, corners and throw-ins. Acceptance: both teams maintain shape and react to possession changes without clustering around the ball; goalkeepers make reliable saves and distribute safely.

## M4 — animation and physicality

Add licensed/original locomotion, acceleration, deceleration, turns, foot planting, kick wind-up/contact/follow-through, tackles, falls, keeper actions and celebrations. Use AnimationTree, blend spaces and IK/procedural correction where available. Acceptance: no obvious foot sliding during standard movement and animation timing matches ball contact.

## M5 — complete match rules

Add match clock, halves, kickoff, out-of-bounds, throw-ins, corners, goal kicks, fouls, cards, offside (after core rules), substitutions and pause/resume. Acceptance: a complete match can be played from kickoff to full time.

## M6 — product experience

Add title screen, team selection, formations/tactics, settings, training drills, penalties/free kicks and career-mode foundation with fixtures, player progression and save data. Acceptance: settings persist and the user can navigate into and out of each implemented mode.

## M7 — release readiness

Add stadium art, crowd/audio, licensed or original kits, broadcast presentation, accessibility, graphics settings, Android profiling, thermal/memory checks, ARM64 export, install testing and crash-free QA. Acceptance: release build installs and completes a full match on target Android hardware.

## Engineering rules

- Do not mark a milestone complete based on source files alone; run the project and verify acceptance criteria.
- Keep gameplay logic independent from HUD presentation.
- Prefer deterministic, inspectable tuning values over scattered magic numbers.
- Use original or licensed assets only.
- Never commit signing keys, passwords, private tokens or unlicensed commercial game assets.
