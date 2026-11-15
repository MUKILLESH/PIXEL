# Phase 1 Architecture — ASHVALE: THE THIRTEENTH BELL

- **Main Scene:** `scenes/sjt_exterior.tscn` (`BellhavenVillage`, `scripts/world/sjt_region.gd`), configured in `project.godot` at `640x360` viewport (`1280x720` window), Compatibility renderer, nearest-neighbor canvas filtering, and 60 Hz physics.
- **Chronological Quest State (`scripts/systems/quest_manager.gd`, `data/prologue_quest.json`):**
  - Enforces strict linear progression across six prologue objectives:
    1. `investigate_bell`
    2. `speak_npcs` (tracks unique villagers via `record_npc_talked()`)
    3. `find_mothers_letter` (gated by `can_open_mothers_letter()`)
    4. `solve_rune_puzzle` (gated by `can_open_rune_puzzle()`)
    5. `discover_briarwood_path`
    6. `trigger_prologue_completion` (sets `prologue_completed` and `briarwood_unlocked`)
  - Supplies stage-aware NPC dialogue (`before_pedestal`, `investigation`, `after_puzzle`) and story event scripts (`mothers_letter`, `beacon_revelation`, `briarwood_ending`).
- **World & Scenery (`scripts/world/sjt_region.gd`, `scripts/world/sjt_landscape.gd`):**
  - Preserves Phase 0 `Ground` tiles (`assets/tiles/courtyard.tres`), Belfry/Cottage/Smithy (`scripts/world/sjt_building.gd`), `Basin`, `Monument`, trees (`scripts/world/prop.gd`), and 12 furnishings (`scripts/world/campus_furniture.gd`).
  - Spawns Bellhaven NPCs (`MasterCaelen`, `Mira`, `SisterElara`), Elena's survey chest (`MothersLetter`), and the southwest `BriarwoodGate` waystone.
  - Renders Bellhaven roads, lantern warm light pools, forge/window glow, and the awakened golden-cyan beacon beam connecting the pedestal to the Briarwood Waystone once Objective 4 completes.
- **Protagonist & Camera (`scenes/characters/player.tscn`, `scripts/characters/player.gd`, `scripts/characters/pixel_camera.gd`):**
  - `Aren` uses `CharacterBody2D` normalized 8-direction movement, 4-frame procedural walk animations, foot collider (`Feet`, radius `6`), `movement_locked` during modals, and integer-snapped camera framing.
- **Reusable NPCs (`scenes/characters/npc.tscn`, `scripts/characters/npc.gd`):**
  - `StaticBody2D` with solid `CircleShape2D` (`radius = 7.0`), `Range` `Area2D` (`radius = 40.0`), hover prompt `Indicator`, player-facing turn on interaction, 2-frame idle animation (`idle_time`, `idle_frame`), and per-ID pixel art (`caelen`, `mira`, `elara`).
- **Multi-Role Story Interactables (`scenes/environment/terminal.tscn`, `scripts/interactables/terminal.gd`):**
  - Preserves `interaction_priority` selection and proximity signals while supporting `@export_enum("RunePedestal", "NoticeBoard", "MothersLetter", "BriarwoodGate") var role` with reactive visual states (`puzzle_solved`, `gate_unlocked`, `letter_highlighted`).
- **HUD, Multi-Line Dialogue & Rune Puzzle (`scenes/ui/hud.tscn`, `scripts/ui/hud.gd`, `scripts/ui/rune_puzzle.gd`):**
  - `_update_selection()` updates the single active world interactable on `proximity_changed` and `_process` with priority -> distance -> node-path tie breaking and zero prompt flicker when modals open.
  - Multi-page dialogue pagination (`show_dialogue`) dynamically sizes text (`8px` / `16px`), displays `[E] CONTINUE (x/y)`, runs completion callbacks on final confirmation, and prevents early advancing on `ESC` cancellation.
  - `RunePuzzle` renders three concentric rotating discs (`SYMBOLS = ["SUN", "MOON", "STAR", "WAVE"]`, `SOLUTION = [1, 0, 2]`), supports both keyboard/action events and mouse buttons (`FOCUS_NONE`), and emits `puzzle_solved_signal` once.
  - `$PrologueComplete` displays `"PROLOGUE COMPLETE — THE THIRTEENTH TOLL"` until dismissed.
