# Validation & Playtesting — ASHVALE: THE THIRTEENTH BELL (Phases 0–3)

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
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase3.gd
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
- **`tests/validate_phase3.gd` (129 checks):**
  - Briarwood `FloodmillGate` locked pre-Chapter-1, unlocked upon Chapter 1 completion, armed via two-step prompt, and live transition to `res://scenes/floodmill_village.tscn`.
  - All 18 Floodmill approach spots free of solids, all 5 isometric buildings (including Old Watermill and Cutaway Forgotten Archive) and 3 minigame panels present.
  - Physical north canal crossing blocked prior to sluice drain (`ArchiveFloodBlocker`), anti-skip & anti-duplicate guards on parts and Archive records, optional Weaver Homestead Locket preserved safely, and all 14 chronological objectives in `chapter2_drowned_village`.
  - Keyboard and validation rejection/solve coverage for `WatermillRepair` (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`), `SluicePuzzle` (`DIVERT`, `DRAIN`, `OPEN`), and `LedgerPuzzle` (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`), plus physical walk across the drained Archive causeway.
  - Second Ancient Beacon activation, canonical Elena/Aren/Lyra Second Beacon lines, `CHAPTER 2 COMPLETE — THE DROWNED VILLAGE` banner, `IronwatchGate` Chapter 3 teaser, Field Satchel Chapter 2 summary, cross-region startup `Continue` -> Floodmill exact pose/world-state resume, Phase 2 (`version == 1`) backwards save compatibility, and `.bak` recovery.

## Visual Screenshot Captures

```powershell
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_briarwood.gd
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_floodmill.gd
```

Inspected visual captures include `tests/briarwood_edge_lyra.png`, `tests/briarwood_bridge_repair.png`, `tests/briarwood_mirror_puzzle.png`, `tests/briarwood_beacon_complete.png`, `tests/briarwood_overview.png`, `tests/phase2_5_satchel.png`, `tests/phase2_5_menu.png`, `tests/floodmill_arrival_village.png`, `tests/floodmill_watermill_repair.png`, `tests/floodmill_sluice_puzzle.png`, `tests/floodmill_ledger_puzzle.png`, `tests/floodmill_second_beacon.png`, and `tests/floodmill_overview.png`.

## Manual Playtesting Checklist (Interactive Verification)

Because headless runs cannot judge subjective pacing, audio-free visual feel, mouse hover/click ergonomics across OS window resizing, or process-restart persistence across separate OS launches, verify these manually in the windowed game (`.\Godot_v4.7.2-stable_win64_console.exe`):

1. **Startup & Menu Feel:** Launch the game, press `M`, inspect the **System Menu** and **Field Satchel** (`I`), and confirm sharp bitmap typography and clean `Esc` dismissal.
2. **Continuous Unassisted Playthrough (Bellhaven -> Briarwood -> Floodmill):** Play naturally with keyboard movement/mouse clicks through all Bellhaven conversations, the Rune Puzzle (`MOON`, `SUN`, `STAR`), the Briarwood Waystone transition, Meeting Lyra, Carpenter Worksite, Bridge Repair (`LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`), Mirror Grove (`DAWN`, `ZENITH`, `DUSK`), First Beacon, Floodmill Gate transition, Floodmill Village Square + optional Weaver Homestead Locket, Old Watermill (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`), Sluice Gate Control (`DIVERT`, `DRAIN`, `OPEN`), crossing the drained causeway into the cutaway Forgotten Archive, Master Ledger (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`), Second Beacon, Elena's Echo, and Ironwatch Keep Gate teaser.
3. **True Process-Exit Save & Resume across All 3 Regions:** Press `M` -> **SAVE PROGRESS** (or press `F5`) in Bellhaven, mid-Chapter-1 Briarwood, and mid/post-Chapter-2 Floodmill; completely close and relaunch `.\Godot_v4.7.2-stable_win64_console.exe`, press `M` -> **CONTINUE SAVED GAME**, and confirm Aren resumes at the exact region, coordinates, facing direction, spinning waterwheel / drained canal / Archive clues / Satchel items, and NPC states.
4. **Window Scaling & Mouse Controls:** Resize or maximize the 1280x720 window (pixel-integer scaling) and confirm mouse hover/clicks inside all six minigame panels (`RunePuzzle`, `BridgeRepair`, `MirrorPuzzle`, `WatermillRepair`, `SluicePuzzle`, `LedgerPuzzle`), `InventoryPanel`, and `TitleMenu` remain aligned and responsive.
