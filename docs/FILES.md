# Project Files — ASHVALE: THE THIRTEENTH BELL (Phase 0)

## Active Game Files

- `project.godot`: Engine config, `ASHVALE: THE THIRTEENTH BELL` title, input actions, display scaling, and startup scene (`res://scenes/sjt_exterior.tscn`).
- `scenes/sjt_exterior.tscn`: Main Bellhaven Village Square scene (`BellhavenVillage`).
- `scenes/campus_prototype.tscn`: Secondary medieval courtyard scene using updated fantasy assets.
- `scenes/characters/player.tscn`, `scripts/characters/player.gd`, `scripts/characters/pixel_camera.gd`: Aren protagonist controller, medieval outfit drawing, collider, and integer-snapped follow camera.
- `scenes/environment/sjt_building.tscn`, `scripts/world/sjt_building.gd`, `scripts/world/sjt_art.gd`: Bellhaven northern village row (Cottage, Bellhaven Belfry Bell Tower, Blacksmith Workshop, timber porch canopy).
- `scenes/environment/terminal.tscn`, `scripts/interactables/terminal.gd`: Stone Rune Pedestal (primary interaction) and Village Signpost (`notice_board = true`).
- `scenes/ui/hud.tscn`, `scripts/ui/hud.gd`: Warm medieval HUD and dismissible message panel.
- `scripts/world/sjt_region.gd`, `scripts/world/sjt_landscape.gd`, `scripts/world/sjt_landmark.gd`, `scripts/world/campus_furniture.gd`, `scripts/world/prop.gd`, `scripts/world/ground_details.gd`, `scripts/world/campus.gd`: Bellhaven props, cobblestones, lantern light pools, Village Well, Anvil Plinth, oak benches, lanterns, planters, barrels, and medieval trees/cottages.
- `scripts/tools/generate_tiles.gd`, `assets/tiles/courtyard.png`, `assets/tiles/courtyard.tres`: Procedural 64×32 medieval grass & cobblestone isometric TileSet.
- `scripts/tools/generate_font.gd`, `assets/fonts/after_hours.*`, `assets/fonts/pixel_theme.tres`: Procedural 5×7 bitmap font and medieval UI theme.
- `tests/validate.gd`, `tests/validate_sjt.gd`, `tests/validate_zone.gd`, `tests/capture.gd`, `tests/capture_sjt.gd`: Headless behavioral test suites and graphical screenshot capture scripts.

## Documentation

- `docs/GAME_DESIGN.md`: Authoritative GDD (premise, 5 regions, characters, chapters, quests, minigames, progression, final ending, phases).
- `docs/ARCHITECTURE.md`, `docs/VALIDATION.md`, `docs/FILES.md`, `README.md`, `assets/README.md`, `data/README.md`.

## Archived (Pre-Reboot)

- `archive/vit_after_hours/`: Archived VIT/SJT campus reference images (`MAP/`, `sjt/`), legacy docs (`SJT_*.md`, `PHASE_1_5.md`), and `sjt_manifest.json` (excluded from Godot scanning via `archive/.gdignore`).
