# Architecture — ASHVALE: THE THIRTEENTH BELL (Phases 0–3)

## Runtime & Viewport
- **Engine:** Godot 4.7.2 Standard (`GDScript`), Compatibility renderer, `640x360` base viewport (`1280x720` window), nearest-neighbor filtering, and `60 Hz` fixed physics.
- **Coordinate System:** 2:1 isometric diamond tiles (`64x32` px from `assets/tiles/courtyard.tres`) with `y_sort_enabled` actor containers so depth sorting uses feet origin.

## Scenes & Region Controllers
- **Prologue (`scenes/sjt_exterior.tscn`, `scripts/world/sjt_region.gd`):**
  - Renders Bellhaven Village Square, buildings (`sjt_building.gd`), landmarks (`sjt_landmark.gd`), furnishings (`campus_furniture.gd`), Bellhaven villagers (`MasterCaelen`, `Mira`, `SisterElara`), Elena's survey chest, the Stone Rune Pedestal, and the Briarwood Waystone.
  - Exposes `_sync_world_from_quest()`, `apply_saved_state()`, `reset_new_game()`, and `travel_to_briarwood()` (setting `QuestManager.carry_prologue_completed = true` before changing scene to `res://scenes/briarwood_forest.tscn`).
- **Chapter 1 (`scenes/briarwood_forest.tscn`, `scripts/world/briarwood_region.gd`):**
  - Populates Forest Edge, Whispering Fork, Carpenter's Worksite, Old Bridge & Stream, Ruined Camp, Mirror Grove, First Beacon Shrine, and Floodmill Trail Gate.
  - Consumes `carry_prologue_completed` or `pending_load_path` cleanly in `_ready()`, manages dynamic stream/bridge crossing (`RiverBarrier` + `BridgeBlocker/Shape`), relocates **Historian Lyra** across her three story checkpoints, and exposes `apply_saved_state()`, `travel_to_bellhaven()`, and `travel_to_floodmill()` (setting `carry_prologue_completed`, `carry_chapter1_completed`, and `carry_optional_discoveries` before changing scene to `res://scenes/floodmill_village.tscn`).
- **Chapter 2 (`scenes/floodmill_village.tscn`, `scripts/world/floodmill_region.gd`):**
  - Populates Floodmill Entrance, Abandoned Village Square & Census Stone, Weaver's Ruined Homestead (optional Silver Locket), Old Watermill & Millwright Worksite, Canal Sluice Console & Canal Depth Gauge, Cutaway Forgotten Archive Hall (`ArchiveBayVisual` per-bay Y-sorted bookshelves, mezzanine, stone pillars, and reading tables), Second Beacon Sanctuary, and Ironwatch Keep Gate (teaser unlock for Chapter 3).
  - Manages canal collisions and dynamic drainable causeway (`CanalBarrier` + `ArchiveFloodBlocker/Shape`), active rotating waterwheel animation (`floodmill_building.gd`), reactive wetland/sluice visuals (`floodmill_landscape.gd`), 7 wetland props (`floodmill_prop.gd`), Lyra's four Floodmill story checkpoints, and `apply_saved_state()`.

## Quest Progression & Atomic Save/Load (`scripts/systems/quest_manager.gd`)
- Supports data-driven quest files via `@export var quest_data_path` (`data/prologue_quest.json`, `data/chapter1_quest.json`, or `data/chapter2_quest.json`) and `reload_quest()`.
- Checks active-quest completion using `quest_id` (`chapter2_drowned_village` vs `chapter1_whispers_of_briarwood` vs `prologue_thirteenth_toll`) so carried prior-chapter flags never block active progression.
- **Prologue Sequence (`prologue_thirteenth_toll`, 6 objectives):** `investigate_bell` -> `speak_npcs` -> `find_mothers_letter` -> `solve_rune_puzzle` -> `discover_briarwood_path` -> `trigger_prologue_completion`.
- **Chapter 1 Sequence (`chapter1_whispers_of_briarwood`, 10 objectives):** `enter_briarwood` -> `meet_lyra` -> `investigate_bridge` -> `find_repair_materials` (`0/3 -> 3/3`) -> `repair_bridge` -> `discover_inscriptions` (`0/3 -> 3/3`) -> `solve_mirror_puzzle` -> `activate_first_beacon` -> `experience_elena_recording` -> `complete_chapter1`.
- **Chapter 2 Sequence (`chapter2_drowned_village`, 14 objectives):** `enter_floodmill` -> `speak_lyra_arrival` -> `explore_ruined_village` -> `discover_watermill` -> `find_watermill_parts` (`0/3 -> 3/3`) -> `restore_watermill` -> `investigate_sluice_gates` -> `redirect_water_flow` -> `enter_forgotten_archive` -> `reconstruct_village_ledger` (`0/3 -> 3/3`) -> `discover_villagers_truth` -> `restore_second_beacon` -> `witness_elena_message` -> `complete_chapter2`.
- **Atomic Persistence & Migration (`SAVE_VERSION := 2`):**
  - `capture_state()` records `region_scene`, `has_player_pose`, `player_x`, `player_y`, `player_facing`, plus all Prologue, Chapter 1, and Chapter 2 indices, flags, sluice gate states, and dictionaries.
  - `save_to_file()` writes `.tmp`, rotates prior save to `.bak`, and atomically promotes `.tmp` -> `.json`.
  - `apply_state()` and `peek_save_summary()` accept `version` 1 through `SAVE_VERSION` (2), safely defaulting new Chapter 2 fields when migrating `version == 1` Phase 2 saves, rejecting corrupt/invalid schemas, and falling back cleanly to `.bak` when valid.

## Characters, Interactables & UI
- **Player (`scripts/characters/player.gd`, `scripts/characters/pixel_camera.gd`):** Normalized 8-direction movement (`speed = 100.0`), 4-frame procedural walk animations, `movement_locked` modal guard, and integer-snapped `Camera2D`.
- **NPCs (`scripts/characters/npc.gd`):** Procedural pixel-art sprites for `caelen`, `mira`, `elara`, and `lyra`, 2-frame idle animation, solid `CircleShape2D` (`radius = 7.0`), and player-facing turn on dialogue open.
- **Briarwood & Floodmill Interactables (`briarwood_interactable.gd`, `floodmill_interactable.gd`):** Procedural interactables (10 Briarwood kinds, 12 Floodmill kinds) with reactive lit/inspected/repaired/collected/unlocked states.
- **HUD, System Menu, Field Satchel & Minigames (`hud.gd`, `title_menu.gd`, `inventory_panel.gd`, `rune_puzzle.gd`, `bridge_repair.gd`, `mirror_puzzle.gd`, `watermill_repair.gd`, `sluice_puzzle.gd`, `ledger_puzzle.gd`):**
  - Priority -> distance -> node-path single-prompt selection with zero flicker and viewport guards around asynchronous scene transitions.
  - `TitleMenu` (`M` / `F10`) provides **New Game**, **Continue Saved Game** (cross-region scene load + exact pose resume across Bellhaven, Briarwood, and Floodmill), **Save Progress** (`F5` shortcut also available), **Open Field Satchel**, and **Resume Exploration**.
  - `InventoryPanel` (`I` / `Tab`) tracks Bellhaven keys & ciphers, Briarwood bridge supplies/inscriptions/echo, and Chapter 2 Watermill components (`[FITTED IN MILL]`), Sluice Protocol clue, Archive Records (`0/3 -> 3/3`), optional Silver Locket (`homestead_locket`), Bound Floodmill Ledger truth, Second Beacon Elena echo note, and Ironwatch Keep unlock note.
