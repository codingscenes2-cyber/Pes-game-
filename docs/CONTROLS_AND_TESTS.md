# Prototype controls and verification checklist

## Controls

| Action | Keyboard | Touch HUD |
|---|---|---|
| Move | WASD / arrow keys | Direction pad |
| Sprint | Shift | SPRINT button |
| Ground pass | J | PASS button |
| Through pass | U | THROUGH button |
| Normal shot | K | SHOOT button |
| Finesse shot | I | FINESSE button |
| Chip shot | O | CHIP button |
| Switch controlled player | Q | SWITCH button |
| Tackle / challenge | P | TACKLE button |
| Shield / protect ball | Hold E | Hold SHIELD button |

Soft possession is now acquired automatically when a nearby player meets a low-speed ball. The ball is guided toward a moving carry point using a capped spring-like force; it is not parented to the player. The controlled player can hold shield to carry the ball slightly to the side. Automatic close-control nudges add a small touch while moving. Pass and shot inputs are buffered for up to 0.38 seconds while the controlled player closes the final distance to the ball; the kick itself still requires the player to be within 2 metres.

## M1 / M2 manual test checklist

- [x] GitHub Actions: import the project with Godot 4.3 and boot the main scene headlessly (passed on the latest commit).
- [ ] Open the project in the Godot editor and inspect the live scene; confirm the pitch, both goals, 22 players, ball, camera and HUD appear.
- [ ] Walk, change direction and sprint; verify the player does not slide excessively or fall through the pitch.
- [ ] Move close to the ball and test ground pass and normal shot from keyboard and touch controls.
- [ ] Press pass or shoot just outside kick range, move into range within the buffer window, and confirm the queued action fires once; confirm it expires if the player does not reach the ball in time.
- [ ] Test through pass with a teammate ahead; confirm the ball travels into space rather than directly to the receiver's feet.
- [ ] Test finesse and chip shots from keyboard and touch controls; compare their trajectories with the normal shot.
- [ ] Roll a slow ball toward a player; verify first-touch assistance settles it into soft possession without snapping it onto the player.
- [ ] Move in several directions while possessing the ball; verify the carry point follows smoothly and the ball can still be challenged.
- [ ] Hold shield while possessing the ball; verify the ball moves to the side and returns to normal carry when released.
- [ ] Move while the ball is close to the controlled player's feet; verify close-control nudges are small and do not launch the ball away.
- [ ] Press switch-player while teammates are at different distances; verify control transfers to the home player nearest the ball.
- [ ] Test a tackle near an opponent; verify it has a cooldown and only deflects the ball when the challenge is close enough.
- [ ] Confirm the ball collides with players and the pitch, rolls to a stop and responds to kicks.
- [ ] Confirm home players attack the negative-Z goal and away players attack the positive-Z goal; verify each goalkeeper stays near the correct goal.
- [ ] Test a slow ball entering each penalty area; verify the corresponding goalkeeper tracks it and attempts a clearance at close range.
- [ ] Score in either goal and confirm the correct score increments and kickoff positions reset.
- [ ] Test a narrow/tall Android viewport; verify the controls remain reachable and do not cover the score.
- [ ] Profile on a physical Android device and check frame pacing, heat and memory use.

## Known prototype limitations

- Capsule players and procedural pitch are greybox geometry, not final art.
- Movement is arcade-assisted and has no authored locomotion animation yet.
- AI is intentionally simple: it uses formation anchors and basic ball pursuit, not tactical decision trees.
- Player switching selects the home player nearest to the ball; no manual cycling or role-aware selection yet.
- Through-pass selection is heuristic and has no receiver targeting indicator.
- Finesse and chip shots are early parameter variations, not tuned PES-grade ball curves.
- Possession and first touch are early soft-force assistance; no authored trap animation, true foot contact, shielding collision volume or ownership UI yet.
- Tackling is a proximity-based knockback/deflection prototype, not a timed tackle animation or foul-aware challenge system.
- Shooting currently targets the negative-Z goal; match-side switching and full match rules are not implemented.
- Goalkeepers have only basic lateral/penalty-area tracking and close-range clearances; dives, catches, parries and realistic distribution remain unimplemented. Fouls, offside, set pieces, match clock/halves, audio and save system are also missing.
- CI has passed a Godot 4.3 headless import and scene boot, but the project has not yet had interactive editor/device QA or an Android export. Complete the remaining checklist before calling M1/M2 verified.
