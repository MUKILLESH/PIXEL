# Created and modified files

The latest [SJT zone polish](SJT_ZONE_POLISH.md) adds local campus furnishings and overlap tests, and updates the existing interaction/HUD and SJT presentation code. See that document for the exact scope and decorative-versus-verified distinction.

## SJT exterior addition

See [SJT file summary](SJT_IMPLEMENTATION.md). A new region/building, five scene-specific drawing/layout scripts, provenance manifest, planning/validation docs and SJT tests/captures were added. The startup setting now selects SJT; Phase 1.5 gameplay files remain unchanged.

## Phase 1.5 delta

Modified existing project settings, player/camera scene and script, world generation and prop drawing, terminal scene/script, HUD scene/script, tile generator/resources, validation/capture scripts, README, and architecture.

New: `scripts/characters/pixel_camera.gd`, `scripts/world/ground_details.gd`, `scripts/tools/generate_font.gd`, `assets/fonts/after_hours.png`, `assets/fonts/after_hours.fnt`, `assets/fonts/after_hours.tres`, `assets/fonts/pixel_theme.tres`, and `docs/PHASE_1_5.md`. Evidence adds `tests/edge_0.png` through `edge_3.png`, `tests/player_poses.png`, and `tests/ui_960x720.png` / `ui_1440x810.png`. Existing courtyard/terminal previews were refreshed.

## New project files

- `project.godot`: engine, startup scene, display, physics, input, and renderer settings.
- `scenes/campus_prototype.tscn`: first playable scene.
- `scenes/characters/player.tscn`, `scripts/characters/player.gd`: reusable controller, drawing, collider, camera.
- `scenes/environment/terminal.tscn`, `scripts/interactables/terminal.gd`: reusable solid terminal and proximity interaction.
- `scenes/ui/hud.tscn`, `scripts/ui/hud.gd`: controls and message panel.
- `scripts/world/campus.gd`: ground, props, boundary, signal connections.
- `scripts/world/prop.gd`: building/tree drawing and collision footprints.
- `scripts/tools/generate_tiles.gd`: dependency-free reproducible tile generator.
- `assets/tiles/courtyard.png`, `assets/tiles/courtyard.tres`: generated tile resources.
- `tests/validate.gd`, `tests/capture.gd`: behavioral validation and graphical capture.
- `tests/courtyard_preview.png`, `tests/terminal_preview.png`: rendered evidence.
- `README.md`, `docs/ARCHITECTURE.md`, `docs/VALIDATION.md`, `docs/FILES.md`, `assets/README.md`, `data/README.md`: usage, design, evidence, and folder notes.
- `LibreSprite-master/.gdignore`, `agent/.gdignore`, `skills/.gdignore`: keep unrelated source collections out of Godot's resource scan.

Godot also creates `.uid`/`.import` metadata and its ignored `.godot/` cache. Existing folder placeholders, skill files, executables, LibreSprite source, and `.gitignore` were preserved. No existing game implementation was present to overwrite.
