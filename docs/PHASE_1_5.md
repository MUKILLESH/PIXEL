# Phase 1.5 — changes and validation

This pass polishes the existing Phase 1 project. The scene entry point, controls, speed, spawn, building/tree positions, and collision footprints remain intact. The layout is fictional, not a geographic model of VIT.

## Changes

- Extended ground to 49 × 49 cells around the original playable diamond, with a visible low stone boundary. Camera corners have ground coverage at every playable extreme.
- Reworked the player into a taller student with a backpack, ID card, eight facings, four walking poses, and a fixed foot shadow. Real movement drives animation; standing against a wall stops it.
- Added `scripts/characters/pixel_camera.gd`: exponential follow after physics movement with integer-pixel display coordinates and a teleport reset method.
- Regenerated six grass/paving variants. Added canopy clusters, window frames, door handles, steps, roof details, and a separate below-actors shadow layer (`scripts/world/ground_details.gd`).
- Added an original bitmap font generator (`scripts/tools/generate_font.gd`) and shared theme/resources under `assets/fonts/`. The 5×7 alphabet uses uppercase forms for both cases at native 8px or integer 16px font sizes.
- Restyled the existing HUD with consistent 16px outer margins, protected title/clock plates, objective text, proximity prompt, and readable dialogue. Dialogue state explicitly suppresses terminal re-entry and prompts.
- Expanded `tests/validate.gd` and `tests/capture.gd`. No new gameplay systems or dependencies were introduced.

## Camera and coverage

Camera2D remains under the reusable player but uses `top_level` so it does not inherit movement. It updates after the player at physics priority 10, easing a floating-point focus with `1 - exp(-rate * delta)` (default rate 9), then rounding its displayed position. Built-in smoothing is off because it retains fractional scroll. `snap_to_target()` resets the camera for teleport/respawn. Zoom remains 1; framing remains (0, -64).

The ground extends from cells -24 to +24 on both axes, while the original collision diamond stays unchanged. This scenery apron covers the full camera viewport at every reachable point. Integer viewport scaling keeps the internal canvas at 640 × 360. Outer window letterboxing is expected at other aspect ratios and is distinct from empty world areas.

Building/tree shadows render in a separate Node2D between ground and actors, so they never paint over the player. The player and props retain their existing ground-origin Y sorting and collision footprints.

## Validation

Installed engine: Godot 4.7.2 Standard, Compatibility, NVIDIA RTX 4050 / OpenGL 3.3.

- 63 automated checks passed, covering prior movement/collision/interaction behavior plus camera coverage, smooth monotonic camera movement, integer scroll, all eight directions and walking-pose progression, settling, and prompt state.
- All 11 scripts compiled. Default startup ran for 300 frames without script/resource errors.
- A separate temporary copy without a Godot cache imported and launched successfully. The initial font-import dependency found during development was fixed by embedding glyph data in the FontFile resource.
- Rendered and inspected the courtyard, terminal dialogue, all four boundary extremes, and a 32-pose character contact sheet.
- Rendered dialogue after requesting 960 × 720 and 1440 × 810 window sizes. The fixed internal viewport retains HUD margins and readable content. Outer letterboxing is intentional.

## Limitations

The drawing remains original placeholder art. Walking uses four procedural poses rather than a production sprite sheet. Camera motion is quantized to native pixels; long hands-on playtesting on the user's display remains useful for subjective feel. No sustained FPS benchmark or full OS display-scaling sweep was performed. Large future buildings may need split facade/roof sorting. No external assets, new dependencies, accurate campus mapping, quests, NPCs, or full dialogue systems were introduced.

Launch remains F5, or F6 with `scenes/campus_prototype.tscn` open. WASD moves, E interacts, E/Escape dismisses.
