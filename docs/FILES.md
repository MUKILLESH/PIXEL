# Active Files — ASHVALE: THE THIRTEENTH BELL (Phase 1)

## Project Configuration & Root Docs
- `project.godot`: Godot 4.7.2 settings (`640x360`, Compatibility renderer, input map, bitmap theme)
- `README.md`: Phase 1 overview, controls, manual playtest walkthrough, and commands
- `docs/GAME_DESIGN.md`: Canonical narrative & design bible for Ashvale
- `docs/ARCHITECTURE.md`: Phase 1 system architecture overview
- `docs/VALIDATION.md`: Automated test suites, capture scripts, and playtest checklist
- `docs/FILES.md`: Active file inventory

## Data
- `data/prologue_quest.json`: Canonical objective definitions, `MOON`/`SUN`/`STAR` cipher, NPC stage dialogues, and story event scripts

## Scenes
- `scenes/sjt_exterior.tscn`: Main playable Bellhaven Village Square scene
- `scenes/campus_prototype.tscn`: Baseline isometric yard harness validated by `tests/validate.gd`
- `scenes/characters/player.tscn`: Protagonist (`Aren`) scene with pixel camera
- `scenes/characters/npc.tscn`: Reusable villager NPC scene
- `scenes/environment/sjt_building.tscn`: Medieval Bellhaven Belfry, Cottage, and Blacksmith Workshop
- `scenes/environment/terminal.tscn`: Multi-role story interactable scene (Pedestal, Signpost, Chest, Waystone)
- `scenes/ui/hud.tscn`: HUD, multi-page dialogue panel, Rune Puzzle host, and Prologue Complete overlay

## Scripts
- `scripts/systems/quest_manager.gd`: Sequential 6-objective quest tracker and dialogue state provider
- `scripts/characters/player.gd`: Movement, collision, facing, and Aren procedural pixel-art rendering
- `scripts/characters/pixel_camera.gd`: Pixel-snapped follow camera
- `scripts/characters/npc.gd`: Reusable NPC behavior, idle animation, and `caelen`/`mira`/`elara` art
- `scripts/interactables/terminal.gd`: Multi-role interactable logic and reactive stone/chest/waystone art
- `scripts/ui/hud.gd`: Priority interactable selection, paginated dialogue controller, puzzle & completion routing
- `scripts/ui/rune_puzzle.gd`: Concentric 3-ring Rune-Alignment minigame UI & input controller
- `scripts/world/sjt_region.gd`: Bellhaven ground tiles, props, NPCs, story interactables, and quest wiring
- `scripts/world/sjt_landscape.gd`: Cobble roads, warm light pools, and awakened pedestal-to-Briarwood beacon beam
- `scripts/world/sjt_building.gd`, `scripts/world/sjt_art.gd`: Timber-and-stone belfry buildings and porch Y-sorting
- `scripts/world/sjt_landmark.gd`, `scripts/world/campus_furniture.gd`, `scripts/world/prop.gd`: Village well, anvil plinth, furnishings, and trees
- `scripts/world/campus.gd`, `scripts/world/ground_details.gd`: Baseline yard helpers used by `scenes/campus_prototype.tscn`
- `scripts/tools/generate_tiles.gd`, `scripts/tools/generate_font.gd`: Procedural tileset & bitmap font generators

## Assets
- `assets/tiles/courtyard.png`, `assets/tiles/courtyard.tres`: 64×32 isometric grass and cobblestone tiles
- `assets/fonts/after_hours.png`, `after_hours.fnt`, `after_hours.tres`: 8px pixel bitmap font (80 glyphs)
- `assets/fonts/pixel_theme.tres`: Default UI font theme

## Automated Tests & Captures
- `tests/validate.gd`: Baseline isometric/collision/movement/UI checks
- `tests/validate_sjt.gd`: Bellhaven facade sliding, canopy columns, landmarks, routes, and scenery coverage checks
- `tests/validate_zone.gd`: Priority-based overlapping prompt selection, furnishings, seating loop, and HUD bounds checks
- `tests/validate_phase1.gd`: Full Phase 1 sequential quest, anti-skip, multi-line dialogue, keyboard rune puzzle, waystone, banner, and NPC checks
- `tests/capture_sjt.gd`, `tests/capture.gd`: Automated graphical screenshot renderers (`tests/*.png`)
