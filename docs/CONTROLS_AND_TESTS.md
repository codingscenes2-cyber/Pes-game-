# Prototype controls and verification checklist

## Controls

| Action | Keyboard | Touch HUD |
|---|---|---|
| Move | WASD / arrow keys | Direction pad |
| Sprint | Shift | SPRINT button |
| Pass | J | PASS button |
| Shoot | K | SHOOT button |

Pass and shoot currently require the controlled player to be within 2 metres of the ball. The prototype is designed to make the player-ball interaction easy to test; action selection and possession assistance will be refined in the next gameplay milestone.

## M1 manual test checklist

- [ ] Import the project in Godot 4.x without parse/import errors.
- [ ] Run the main scene and confirm the pitch, both goals, 22 players, ball, camera and HUD appear.
- [ ] Walk, change direction and sprint; verify the player does not slide excessively or fall through the pitch.
- [ ] Move close to the ball and test pass and shoot from keyboard and touch controls.
- [ ] Confirm the ball collides with players and the pitch, rolls to a stop and responds to kicks.
- [ ] Score in either goal and confirm the score increments and kickoff positions reset.
- [ ] Test a narrow/tall Android viewport; verify the controls remain reachable and do not cover the score.
- [ ] Profile on a physical Android device and check frame pacing, heat and memory use.

## Known prototype limitations

- Capsule players and procedural pitch are greybox geometry, not final art.
- Movement is arcade-assisted and has no authored locomotion animation yet.
- AI is intentionally simple: it uses formation anchors and basic ball pursuit, not tactical decision trees.
- Passing selects a nearby forward-ish teammate; there is no pass receiver targeting indicator.
- Shooting currently targets the negative-Z goal; match-side switching and full match rules are not implemented.
- No goalkeeper-specific behaviour, fouls, offside, set pieces, match clock/halves, audio or save system yet.
- This repository has not been opened in the Godot editor or exported to Android in this environment. Complete the checklist before calling M1 verified.
