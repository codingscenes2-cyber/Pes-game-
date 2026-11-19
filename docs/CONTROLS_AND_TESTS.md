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

Close-control dribbling is assisted automatically when the controlled player moves with the ball close to the forward foot area. It applies a small physics impulse at a short interval rather than attaching or teleporting the ball. Most kicks still require the player to be within 2 metres of the ball.

## M1 / M2 manual test checklist

- [ ] Import the project in Godot 4.x without parse/import errors.
- [ ] Run the main scene and confirm the pitch, both goals, 22 players, ball, camera and HUD appear.
- [ ] Walk, change direction and sprint; verify the player does not slide excessively or fall through the pitch.
- [ ] Move close to the ball and test ground pass and normal shot from keyboard and touch controls.
- [ ] Test through pass with a teammate ahead; confirm the ball travels into space rather than directly to the receiver's feet.
- [ ] Test finesse and chip shots from keyboard and touch controls; compare their trajectories with the normal shot.
- [ ] Move while the ball is close to the controlled player's feet; verify close-control nudges are small and do not launch the ball away.
- [ ] Press switch-player while teammates are at different distances; verify control transfers to the home player nearest the ball.
- [ ] Test a tackle near an opponent; verify it has a cooldown and only deflects the ball when the challenge is close enough.
- [ ] Confirm the ball collides with players and the pitch, rolls to a stop and responds to kicks.
- [ ] Score in either goal and confirm the score increments and kickoff positions reset.
- [ ] Test a narrow/tall Android viewport; verify the controls remain reachable and do not cover the score.
- [ ] Profile on a physical Android device and check frame pacing, heat and memory use.

## Known prototype limitations

- Capsule players and procedural pitch are greybox geometry, not final art.
- Movement is arcade-assisted and has no authored locomotion animation yet.
- AI is intentionally simple: it uses formation anchors and basic ball pursuit, not tactical decision trees.
- Player switching selects the home player nearest to the ball; no manual cycling or role-aware selection yet.
- Through-pass selection is heuristic and has no receiver targeting indicator.
- Finesse and chip shots are early parameter variations, not tuned PES-grade ball curves.
- Close-control touches are a simple proximity impulse; there is no persistent possession state, trapping animation or shielding yet.
- Tackling is a proximity-based knockback/deflection prototype, not a timed tackle animation or foul-aware challenge system.
- Shooting currently targets the negative-Z goal; match-side switching and full match rules are not implemented.
- No goalkeeper-specific behaviour, fouls, offside, set pieces, match clock/halves, audio or save system yet.
- This repository has not been opened in the Godot editor or exported to Android in this environment. Complete the checklist before calling M1/M2 verified.
