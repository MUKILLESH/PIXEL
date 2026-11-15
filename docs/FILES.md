# Active Files — ASHVALE: THE THIRTEENTH BELL (Phases 0–3)

## Project Configuration & Docs
- `project.godot`: Godot 4.7.2 settings (`640x360`, Compatibility renderer, input actions, bitmap theme)
- `README.md`: Controls, Prologue, Chapter 1 & Chapter 2 progression guide, save/resume behavior, and CLI test commands
- `docs/GAME_DESIGN.md`: Canonical story bible for Ashvale
- `docs/ARCHITECTURE.md`: Prologue, Chapter 1, and Chapter 2 architecture
- `docs/VALIDATION.md`: Automated test suites (`validate*.gd`), screenshot captures, and manual playtesting checklist
- `docs/FILES.md`: Active file inventory

## Quest Data
- `data/prologue_quest.json`: Bellhaven prologue objectives, `MOON`/`SUN`/`STAR` cipher, villager dialogues, and story events
- `data/chapter1_quest.json`: Briarwood Chapter 1 objectives, `BridgeRepair` & `MirrorPuzzle` solutions, Historian Lyra stage dialogues, inscriptions, and Elena's Echo
- `data/chapter2_quest.json`: Floodmill Chapter 2 objectives, `WatermillRepair`, `SluicePuzzle` & `LedgerPuzzle` solutions, Lyra dialogues, Archive records, and Second Beacon Elena recording

## Scenes
- `scenes/sjt_exterior.tscn`: Playable Bellhaven Village Square scene (Prologue & startup entry)
- `scenes/briarwood_forest.tscn`: Playable Briarwood Forest scene (Chapter 1)
- `scenes/floodmill_village.tscn`: Playable Floodmill: The Drowned Village scene (Chapter 2)
- `scenes/campus_prototype.tscn`: Baseline isometric courtyard harness validated by `tests/validate.gd`
- `scenes/characters/player.tscn`: Protagonist (`Aren`) scene with pixel-snapped camera
- `scenes/characters/npc.tscn`: Reusable NPC scene
- `scenes/environment/sjt_building.tscn`: Medieval Bellhaven buildings and porch geometry
- `scenes/environment/terminal.tscn`: Multi-role Bellhaven story interactable scene
- `scenes/ui/hud.tscn`: HUD, paginated dialogue panel, `RunePuzzle`, dynamic minigame/menu/satchel host, and completion overlay

## Scripts
- `scripts/systems/quest_manager.gd`: Chronological Prologue, Chapter 1 & Chapter 2 quest engine with atomic `SAVE_VERSION = 2` JSON persistence, `v1` compatibility, pose/region storage, and `.bak` recovery
- `scripts/characters/player.gd`: Normalized 8-directional movement, collision, facing, and Aren pixel art
- `scripts/characters/pixel_camera.gd`: Pixel-snapped follow camera
- `scripts/characters/npc.gd`: Reusable NPC behavior, idle bob animation, and procedural art (`caelen`, `mira`, `elara`, `lyra`)
- `scripts/interactables/terminal.gd`: Bellhaven multi-role interactable (`ready_to_travel` transition arming included)
- `scripts/interactables/briarwood_interactable.gd`: Briarwood interactive objects (including `floodmill_gate` `ready_to_travel` arming)
- `scripts/interactables/floodmill_interactable.gd`: Floodmill interactive objects (`entrance_arch`, `village_plaque`, `optional_lore`, `watermill_mechanism`, `mill_diagram`, `mill_part`, `sluice_console`, `canal_clue`, `archive_entrance`, `archive_record`, `ledger_table`, `second_beacon`, `ironwatch_gate`)
- `scripts/ui/hud.gd`: Priority interactable selection, paginated dialogue router, minigame orchestration, manual save/continue/new-game routing, and completion banners
- `scripts/ui/title_menu.gd`: System/Title Menu overlay (`New Game`, `Continue`, `Save Progress`, `Field Satchel`, `Resume`)
- `scripts/ui/inventory_panel.gd`: Aren's Field Satchel items, materials, inscriptions, Floodmill parts/records, and relic tracker
- `scripts/ui/rune_puzzle.gd`: Prologue 3-disc Rune-Alignment minigame (`MOON`, `SUN`, `STAR`)
- `scripts/ui/bridge_repair.gd`: Chapter 1 Minigame A (`LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`)
- `scripts/ui/mirror_puzzle.gd`: Chapter 1 Minigame B (`DAWN`, `ZENITH`, `DUSK`)
- `scripts/ui/watermill_repair.gd`: Chapter 2 Minigame A (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`)
- `scripts/ui/sluice_puzzle.gd`: Chapter 2 Minigame B (`DIVERT`, `DRAIN`, `OPEN`)
- `scripts/ui/ledger_puzzle.gd`: Chapter 2 Minigame C (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`)
- `scripts/world/sjt_region.gd`, `scripts/world/sjt_landscape.gd`: Bellhaven tiles, props, NPCs, roads, beacon beam, save/reset sync, and `travel_to_briarwood()`
- `scripts/world/briarwood_region.gd`, `scripts/world/briarwood_landscape.gd`, `scripts/world/briarwood_prop.gd`: Briarwood tiles, woodland/ruin props, dynamic `BridgeBlocker`, Lyra relocation, `travel_to_floodmill()`, and save state sync
- `scripts/world/floodmill_region.gd`, `scripts/world/floodmill_building.gd`, `scripts/world/floodmill_landscape.gd`, `scripts/world/floodmill_prop.gd`: Floodmill wetland terrain, 5 isometric buildings (including spinning waterwheel and cutaway Archive Hall), canal/causeway blockers, Lyra checkpoints, and save state sync
- `scripts/world/sjt_building.gd`, `scripts/world/sjt_art.gd`, `scripts/world/sjt_landmark.gd`, `scripts/world/campus_furniture.gd`, `scripts/world/prop.gd`: Bellhaven architecture, furnishings, and village foliage
- `scripts/world/campus.gd`, `scripts/world/ground_details.gd`: Baseline yard helpers used by `scenes/campus_prototype.tscn`
- `scripts/tools/generate_tiles.gd`, `scripts/tools/generate_font.gd`: Procedural tileset and bitmap font generators

## Assets
- `assets/tiles/courtyard.png`, `assets/tiles/courtyard.tres`: 64x32 isometric ground tiles
- `assets/fonts/after_hours.png`, `after_hours.fnt`, `after_hours.tres`: 8px pixel bitmap font (80 supported glyphs)
- `assets/fonts/pixel_theme.tres`: Default UI font theme

## Automated Tests & Captures
- `tests/validate.gd`: Baseline isometric/movement/collision/camera/UI suite (63 checks)
- `tests/validate_sjt.gd`: Bellhaven architectural collisions, routes, and scenery coverage suite (39 checks)
- `tests/validate_zone.gd`: Priority selection, overlap handoff, furnishings, seating loop, and HUD bounds suite (71 checks)
- `tests/validate_phase1.gd`: Prologue quest sequencing, clues, Rune Puzzle, Briarwood Waystone, banner, and NPC suite (77 checks)
- `tests/validate_phase2.gd`: Chapter 1 transition, Briarwood spots, 10-objective quest, both minigames, physical bridge crossing, Ruined Camp relic, Elena Echo, Floodmill gate, and save/load suite (108 checks)
- `tests/validate_phase2_5.gd`: End-to-end no-teleport walkthrough (Bellhaven -> Briarwood), Field Satchel & Title Menu checks, cross-region Save/Exit/Reopen/Continue, same-region Bellhaven resume, New Game reset, and corrupt-save / `.bak` fallback checks (88 checks)
- `tests/validate_phase3.gd`: Briarwood -> Floodmill transition, approach clearances, out-of-order lockouts, all 14 Floodmill objectives, optional Weaver Homestead Locket, `WatermillRepair`, `SluicePuzzle` + physical causeway drain crossing, Cutaway Archive 3 records, `LedgerPuzzle`, Second Beacon + canonical Elena/Aren/Lyra lines, Ironwatch Keep Gate unlock, Field Satchel Chapter 2 tracking, cross-region Floodmill Save/Continue resume, `v1` save backwards compatibility, and `.bak` recovery (129 checks)
- `tests/capture_sjt.gd`, `tests/capture_briarwood.gd`, `tests/capture_floodmill.gd`, `tests/capture.gd`: Automated PNG visual review generators (`tests/*.png`)
