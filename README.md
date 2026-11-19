# PES-Style Mobile Football (working title)

A Godot 4.x 3D football project targeting Android ARM64, with a focus on responsive PES-inspired gameplay, believable ball behaviour, readable animations and a polished mobile presentation.

## Current status

**Milestone 1 — playable foundation: initial source committed.** The project currently contains a procedural 3D pitch, player controller, rigid-body ball, simple opponent behaviour, follow camera and touch/keyboard controls. This is an early greybox prototype, not a finished football game. It has not yet been built or runtime-tested in Godot in this environment.

## Open the project

1. Install Godot 4.x (Forward+ or Mobile renderer; Mobile is the intended Android profile).
2. Clone this repository and import the folder containing `project.godot`.
3. Run the main scene.
4. Desktop prototype controls: WASD / arrow keys to move, Shift to sprint, J to pass, K to shoot.
5. On-screen controls are provided for touch testing.

## Roadmap

- [x] M1 — project skeleton and first playable greybox foundation
- [ ] M1.1 — run in Godot, fix engine/runtime issues, tune movement and ball response
- [ ] M2 — robust passing, shooting, trapping, dribbling, tackles and possession transitions
- [ ] M3 — team shape, off-ball runs, defensive pressure, goalkeeper and restart logic
- [ ] M4 — animation system, IK/procedural foot placement, player variety and impact reactions
- [ ] M5 — match rules, clock, score, fouls, set pieces, substitutions and match flow
- [ ] M6 — professional menus, team selection, tactics, training and career-mode foundation
- [ ] M7 — stadium/audio/visual polish, Android performance profiling, ARM64 export and device QA

## Design principles

- Gameplay feel before visual spectacle.
- Ball movement must be physics-driven, with controlled assistance only where it improves responsiveness.
- Readable player intent, stable camera framing and predictable touch controls.
- No placeholder claims: every roadmap item must be implemented and tested before being marked complete.
- Use original or properly licensed assets; do not bundle unlicensed commercial game assets, logos, kits or player likenesses.

## Project structure

- `scenes/` — Godot scenes
- `scripts/` — gameplay scripts
- `docs/` — design notes and milestone acceptance criteria

## Build note

Android export requires Godot's Android export templates, Android SDK/JDK configuration and a signing key. Keep release signing credentials private and out of Git.
