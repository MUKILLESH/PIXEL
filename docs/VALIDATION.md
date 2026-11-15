# Validation & Playtesting — ASHVALE: THE THIRTEENTH BELL (Phases 0–2.5)

## Automated Suites

Run from the repository root (`d:\MUKI PROJECT\VIT_After_Hours`):

```powershell
.\Godot_v4.7.2-stable_win64_console.exe --headless --import
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_zone.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase1.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase2.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase2_5.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 300
```

### Coverage Summary
- **`tests/validate.gd` (63 checks):** Isometric tile grid, camera integer snapping, viewport coverage, normalized 8-dir movement, collision sliding, boundary locks, and prompt/dialogue basics.
- **`tests/validate_sjt.gd` (39 checks):** Bellhaven Village facade/canopy depth sorting, porch columns, landmarks, courtyard navigation, and reference isolation.
- **`tests/validate_zone.gd` (71 checks):** Overlapping prompt selection priority vs distance, tie-breakers, 12 village furnishings, seating clearance, and compact HUD bounds.
- **`tests/validate_phase1.gd` (77 checks):** Strict 6-objective Prologue progression, early lockouts, anti-farming checks, `MOON/SUN/STAR` clues & Rune Puzzle, `PROLOGUE COMPLETE — THE THIRTEENTH TOLL`, and Bellhaven NPCs.
- **`tests/validate_phase2.gd` (108 checks):** Briarwood spots, 10-objective Chapter 1 sequence, anti-skip/anti-farm guards, `BridgeBlocker` physics & physical north crossing, `BridgeRepair` and `MirrorPuzzle`, Ruined Camp optional relic, Elena's Echo, Floodmill Gate unlock, and Briarwood save/load sync.
- **`tests/validate_phase2_5.gd` (88 checks):**
  - Full Bellhaven -> Briarwood story walkthrough driven solely via real `Input` movement actions (`walk_to`, zero debug commands or teleports).
  - Live `get_tree().change_scene_to_file()` transition carrying Prologue flags/inventory into Briarwood without blocking Chapter 1 objectives.
  - Title/System Menu (`M`/`F10`), Field Satchel Inventory (`I`/`Tab`), Manual Save (`F5`), Continue rejection when empty, and New Game reset back to Bellhaven spawn.
  - Same-region Bellhaven Save -> Resume and cross-region Save -> Restart at startup -> Continue -> Briarwood exact region, position, facing, bridge/mirror/beacon states, NPC checkpoint, and repeated-interaction safety.
  - Malformed JSON, future version, missing quest JSON, negative index rejection, and automatic fallback from corrupted primary file to valid `.bak`.

## Visual Screenshot Captures

```powershell
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_briarwood.gd
```

Inspected visual captures include `tests/briarwood_edge_lyra.png`, `tests/briarwood_bridge_repair.png`, `tests/briarwood_mirror_puzzle.png`, `tests/briarwood_beacon_complete.png`, `tests/briarwood_overview.png`, `tests/phase2_5_satchel.png`, and `tests/phase2_5_menu.png`.

## Manual Playtesting Checklist (Interactive Verification)

Because headless runs cannot judge subjective pacing, audio-free visual feel, mouse hover/click ergonomics across OS window resizing, or process-restart persistence across separate OS launches, verify these manually in the windowed game (`.\Godot_v4.7.2-stable_win64_console.exe`):

1. **Startup & Menu Feel:** Launch the game, press `M`, inspect the **System Menu** and **Field Satchel** (`I`), and confirm sharp bitmap typography and clean `Esc` dismissal.
2. **Continuous Unassisted Playthrough (Bellhaven -> Briarwood):** Play naturally with keyboard movement/mouse clicks through all Bellhaven conversations, the Rune Puzzle (`MOON`, `SUN`, `STAR`), the Briarwood Waystone transition, Meeting Lyra, Carpenter Worksite, Bridge Repair (`LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`), all three Oakhaven inscriptions + Ruined Camp chest, Mirror Grove (`DAWN`, `ZENITH`, `DUSK`), First Beacon, and Elena's Echo. Verify smooth camera tracking and comfortable corridor widths.
3. **True Process-Exit Save & Resume:** At two points (mid-Prologue in Bellhaven and post-Bridge or post-Chapter-1 in Briarwood), press `M` -> click **SAVE PROGRESS** (or press `F5`), close the game window completely, relaunch `.\Godot_v4.7.2-stable_win64_console.exe`, press `M` -> select **CONTINUE SAVED GAME**, and confirm Aren resumes at the exact region, coordinates, facing direction, Satchel items, and world object states.
4. **Window Scaling & Input Focus:** Resize or maximize the 1280x720 window (pixel-integer scaling) and confirm mouse clicks inside `RunePuzzle`, `BridgeRepair`, `MirrorPuzzle`, `InventoryPanel`, and `TitleMenu` remain aligned and responsive.
