# Phase 1 validation — 15 November 2026

**Historical baseline.** See [Phase 1.5 validation](PHASE_1_5.md) for the current 63-check suite and camera, font, scenery, and resizing evidence. The limitations below describe the original Phase 1 build.

## Executed

- Installed executable reports `4.7.2.stable.official.ed1daf0bf`.
- Fresh headless import succeeded without parsing, missing-resource, or reference errors.
- All game and test scripts compiled successfully using the inspected local skill compile checker.
- Default startup scene ran for 300 headless frames with no script/runtime errors.
- Behavioral suite: **25 checks, 0 failures**, exit code 0 after final framing changes.
- Runner failure path was verified with `-- --force-failure`: deliberately reported one failure and exited 1.
- Graphical Compatibility rendering succeeded using OpenGL 3.3 on NVIDIA GeForce RTX 4050 Laptop GPU. Inspected the generated courtyard and terminal-message captures; ground, buildings, trees, player, UI, and exact message render correctly.

Behavioral checks cover ground population and diamond geometry, Y-sort configuration, stable/unobstructed spawn, active camera, out-of-range interaction rejection, movement distance, normalized diagonal speed, diagonal facing, stopping without drift, building/tree/terminal collisions, nearby indicator, opening the exact message, ignoring keyboard repeat, movement lock, E dismissal without reopening, Escape dismissal, and map boundary collision.

## Remaining manual checks and limitations

- Keyboard actions were exercised through Godot's input API; a sustained hands-on WASD/E playtest in the editor was not performed.
- Camera framing was visually inspected in still captures. Long movement sessions, perceived jitter, all eight facing appearances, and dynamic occlusion around every side of every prop still benefit from manual review.
- Resizing uses Godot's integer viewport stretch, but arbitrary window sizes and multiple display scaling settings have not been manually exercised.
- 60 FPS is configured as the target/cap; no sustained performance benchmark was performed.
- Collision tests cover representative obstacles and one boundary direction, not every possible corner approach.
- Ground and props populate at runtime, so the editor preview is sparse until F6. Art is intentionally simple, and large future structures may need split pieces for more precise depth sorting.
- The clock is static; no countdown, accurate campus geography, full dialogue, quest, NPC, ECHO, inventory, or save system is included.

## Suggested two-minute playtest

Run F5. Walk in cardinal and diagonal directions; release keys to check stopping. Circle both buildings and several trees, checking depth as you pass behind and in front. Approach the cyan terminal, press/hold E, dismiss with E and Escape, then move away. Resize the window and confirm the image stays crisp and the message remains readable. Open `campus_prototype.tscn` and confirm F6 behaves the same way.
