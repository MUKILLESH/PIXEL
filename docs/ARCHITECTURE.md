# Architecture — ASHVALE: THE THIRTEENTH BELL (Phases 0–2.5)

## Runtime & Viewport
- **Engine:** Godot 4.7.2 Standard (`GDScript`), Compatibility renderer, `640x360` base viewport (`1280x720` window), nearest-neighbor filtering, and `60 Hz` fixed physics.
- **Coordinate System:** 2:1 isometric diamond tiles (`64x32` px from `assets/tiles/courtyard.tres`) with `y_sort_enabled` actor containers so depth sorting uses feet origin.

## Scenes & Region Controllers
- **Prologue (`scenes/sjt_exterior.tscn`, `scripts/world/sjt_region.gd`):**
  - Renders Bellhaven Village Square, buildings (`sjt_building.gd`), landmarks (`sjt_landmark.gd`), furnishings (`campus_furniture.gd`), Bellhaven villagers (`MasterCaelen`, `Mira`, `SisterElara`), Elena's survey chest, the Stone Rune Pedestal, and the Briarwood Waystone.
  - Exposes `_sync_world_from_quest()`, `apply_saved_state()`, `reset_new_game()`, and `travel_to_briarwood()` (setting `QuestManager.carry_prologue_completed = true` before changing scene to `res://scenes/briarwood_forest.tscn`).
- **Chapter 1 (`scenes/briarwood_forest.tscn`, `scripts/world/briarwood_region.gd`):**
  - Populates Forest Edge, Whispering Fork, Carpenter's Worksite, Old Bridge & Stream, Ruined Camp, Mirror Grove, First Beacon Shrine, and Floodmill Trail Gate.
  - Consumes `carry_prologue_completed` or `pending_load_path` cleanly in `_ready()`, manages dynamic stream/bridge crossing (`RiverBarrier` + `BridgeBlocker/Shape`), relocates **Historian Lyra** across her three story checkpoints, and exposes `apply_saved_state()` (restoring player position, facing, camera snap, NPC placement, bridge blocker, minigame lock flags, and visuals) and `travel_to_bellhaven()`.

## Quest Progression & Atomic Save/Load (`scripts/systems/quest_manager.gd`)
- Supports data-driven quest files via `@export var quest_data_path` (`data/prologue_quest.json` or `data/chapter1_quest.json`) and `reload_quest()`.
- Checks active-quest completion using `quest_id` (`chapter1_completed` for Briarwood vs `prologue_completed` for Bellhaven) so carried prologue flags never lock out Chapter 1 objectives.
- **Prologue Sequence (`prologue_thirteenth_toll`, 6 objectives):** `investigate_bell` -> `speak_npcs` -> `find_mothers_letter` -> `solve_rune_puzzle` -> `discover_briarwood_path` -> `trigger_prologue_completion`.
- **Chapter 1 Sequence (`chapter1_whispers_of_briarwood`, 10 objectives):** `enter_briarwood` -> `meet_lyra` -> `investigate_bridge` -> `find_repair_materials` (`0/3 -> 3/3`) -> `repair_bridge` -> `discover_inscriptions` (`0/3 -> 3/3`) -> `solve_mirror_puzzle` -> `activate_first_beacon` -> `experience_elena_recording` -> `complete_chapter1`.
- **Atomic Persistence & Recovery (`SAVE_VERSION := 1`):**
  - `capture_state()` records `region_scene`, `has_player_pose`, `player_x`, `player_y`, `player_facing`, plus all quest indices, flags, and dictionaries.
  - `save_to_file()` writes `.tmp`, rotates prior save to `.bak`, and atomically promotes `.tmp` -> `.json`.
  - `_parse_save_dict()` uses `JSON.new()` for silent syntax validation; `apply_state()` and `peek_save_summary()` enforce schema validation (`version`, existing `quest_data_path`, non-negative `current_index`, typed dictionaries) and fall back cleanly from a damaged primary file to `.bak`.

## Characters, Interactables & UI
- **Player (`scripts/characters/player.gd`, `scripts/characters/pixel_camera.gd`):** Normalized 8-direction movement (`speed = 100.0`), 4-frame procedural walk animations, `movement_locked` modal guard, and integer-snapped `Camera2D`.
- **NPCs (`scripts/characters/npc.gd`):** Procedural pixel-art sprites for `caelen`, `mira`, `elara`, and `lyra`, 2-frame idle animation, solid `CircleShape2D` (`radius = 7.0`), and player-facing turn on dialogue open.
- **Briarwood Interactables (`scripts/interactables/briarwood_interactable.gd`) & Props (`scripts/world/briarwood_prop.gd`):** 10 interactive kinds and 9 procedural woodland/ruin props with reactive lit/collected/repaired/unlocked visuals.
- **HUD, System Menu, Field Satchel & Minigames (`scripts/ui/hud.gd`, `title_menu.gd`, `inventory_panel.gd`, `rune_puzzle.gd`, `bridge_repair.gd`, `mirror_puzzle.gd`):**
  - Priority -> distance -> node-path single-prompt selection with zero flicker and viewport guards around asynchronous scene transitions.
  - `TitleMenu` (`M` / `F10`) provides **New Game**, **Continue Saved Game** (cross-region scene load + exact pose resume), **Save Progress** (`F5` shortcut also available), **Open Field Satchel**, and **Resume Exploration**.
  - `InventoryPanel` (`I` / `Tab`) surfaces Bellhaven keys & ciphers, Carpenter Worksite repair supplies (`[IN SATCHEL]` -> `[USED IN BRIDGE]`), Oakhaven inscriptions, Elena's optional Brass Survey Compass, and First Beacon Echo notes.
