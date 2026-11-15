# ASHVALE: THE THIRTEENTH BELL

An isometric 2.5D pixel-art mystery adventure built in **Godot 4.7.2 Standard** (`GDScript`).

After the Great Bell of **Bellhaven Village** tolls a forbidden thirteenth time, apprentice mapmaker **Aren** uncovers a rune cipher leading to his missing mother **Elena**, journeys through **Briarwood Forest** alongside traveling historian **Lyra** to awaken the First Ancient Beacon, and enters **Floodmill: The Drowned Village** to restore the Second Ancient Beacon and uncover what happened to the thirty-six forgotten hearths.

## Controls

- **Move:** `WASD` / `Arrow Keys`
- **Interact / Advance Dialogue / Confirm Puzzle:** `E`, `Enter`, or `Space`
- **Dismiss / Cancel UI:** `Esc`
- **Field Satchel (Inventory & Clues):** `I` or `Tab`
- **Title / System Menu (New Game, Continue, Manual Save, Satchel):** `M` or `F10`
- **Quick Save Progress:** `F5`
- **In Minigames (`RunePuzzle`, `BridgeRepair`, `MirrorPuzzle`, `WatermillRepair`, `SluicePuzzle`, `LedgerPuzzle`):** `W/S` or `Up/Down` selects rows, `A/D` or `Left/Right` cycles values, `E`/`Enter` verifies, `Esc` closes cleanly, or click UI buttons directly

## Playable Progression

### Prologue — The Thirteenth Toll (`scenes/sjt_exterior.tscn`)
1. Inspect the humming **Stone Rune Pedestal** in Bellhaven Square.
2. Speak with **Master Caelen**, **Mira**, and **Sister Elara** (`0/3 -> 3/3`) to uncover the `MOON`, `SUN`, `STAR` clues.
3. Recover **Mother's Letter** from Caelen's locked survey chest beside the cottage.
4. Solve the 3-ring **Rune-Alignment Minigame** (`MOON`, `SUN`, `STAR`).
5. Awaken the southwest **Briarwood Waystone** to complete the prologue (`PROLOGUE COMPLETE — THE THIRTEENTH TOLL`), then press `E` twice at the awakened gate to enter Briarwood Forest.

### Chapter 1 — Whispers of Briarwood (`scenes/briarwood_forest.tscn`)
1. Inspect the **Briarwood Trail Waystone** at the **Forest Edge** (`enter_briarwood`).
2. Meet **Historian Lyra** beside her campfire (`meet_lyra`).
3. Investigate the collapsed **Old Bridge** northwest of **Whispering Fork** (`investigate_bridge`).
4. Read the carpenter's ledger and gather **3 repair materials** (`plank_1`, `plank_2`, `rope_coil`) from the **Carpenter's Worksite** (`find_repair_materials`).
5. Solve **Minigame A (`BridgeRepair`)** in order: `LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING` (`repair_bridge`), reopening the physical crossing over the stream.
6. Read the **3 ancient Oakhaven inscriptions** (`west`, `center`, `east` -> `DAWN`, `ZENITH`, `DUSK`) north of the bridge (`discover_inscriptions`). *(Optional discovery: search the eastern **Ruined Camp** survey chest.)*
7. Solve **Minigame B (`MirrorPuzzle`)** at **Mirror Grove**: `DAWN`, `ZENITH`, `DUSK` (`solve_mirror_puzzle`).
8. Activate the **First Ancient Beacon** at the northern shrine (`activate_first_beacon`).
9. Experience **Elena's Memory Echo** (`experience_elena_recording`).
10. Speak with **Lyra** at the Beacon Shrine to chart **Floodmill Wetlands**, displaying `CHAPTER 1 COMPLETE — WHISPERS OF BRIARWOOD` and unlocking the **Floodmill Trail Gate** (`complete_chapter1`), then interact twice at the southeast gate to enter Floodmill.

### Chapter 2 — The Drowned Village (`scenes/floodmill_village.tscn`)
1. Survey the **Floodmill Entrance Arch** (`enter_floodmill`) and speak with **Lyra** overlooking the flooded rooftops (`speak_lyra_arrival`).
2. Inspect the chiseled **Floodmill Census Stone** in the **Abandoned Village** square (`explore_ruined_village`). *(Optional discovery: inspect the silver locket at the **Weaver's Homestead**.)*
3. Examine the **Old Watermill** mechanism (`discover_watermill`), read the millwright's diagram, and gather **3 parts** (`iron_drive_gear`, `bronze_pinion`, `oak_coupling_belt`) (`find_watermill_parts`).
4. Solve **Minigame A (`WatermillRepair`)** in order: `IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT` (`restore_watermill`) to spin the waterwheel and pressurize the canal sluices.
5. Investigate the **Canal Sluice Console** (`investigate_sluice_gates`), read the **Canal Depth Gauge**, and solve **Minigame B (`SluicePuzzle`)**: `DIVERT`, `DRAIN`, `OPEN` (`redirect_water_flow`), lowering the water depth to `0` cubits and draining the **Archive Causeway**.
6. Cross the drained causeway into the cutaway **Forgotten Archive** (`enter_forgotten_archive`), collect all **3 surviving records** (`record_census`, `record_tribute`, `record_transfer`), and solve **Minigame C (`LedgerPuzzle`)**: `THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL` (`reconstruct_village_ledger`).
7. Examine the bound Master Ledger to uncover what happened to Floodmill's thirty-six hearths (`discover_villagers_truth`).
8. Restore the **Second Ancient Beacon** at the northeast sanctuary (`restore_second_beacon`) and listen to **Elena's Memory Recording** (`witness_elena_message`).
9. Speak with **Lyra** by the Second Beacon (`complete_chapter2`) to display `CHAPTER 2 COMPLETE — THE DROWNED VILLAGE` and unlock the **Ironwatch Keep Gate** teaser (`Chapter 3`).

## Save System & Resume Flow

- Progress is stored atomically at `user://ashvale_save.json` with `.tmp` staging and `.bak` backup rotation (`SAVE_VERSION := 2`, backwards compatible with Phase 2 `version == 1` saves).
- Saved state includes the active region scene (`sjt_exterior.tscn`, `briarwood_forest.tscn`, or `floodmill_village.tscn`), Aren's exact position and facing direction, completed objectives, inventory/clues, bridge/mirror/watermill/sluice/ledger states, beacon activations, and NPC positions.
- Corrupted primary saves or mismatched schemas are rejected cleanly and automatically fall back to `user://ashvale_save.json.bak` when valid.

## Running & Validation

```powershell
# Launch playable startup scene
.\Godot_v4.7.2-stable_win64_console.exe

# Run automated validation suites
.\Godot_v4.7.2-stable_win64_console.exe --headless --import
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_zone.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase1.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase2.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase2_5.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless -s res://tests/validate_phase3.gd

# Generate screenshot captures
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_briarwood.gd
.\Godot_v4.7.2-stable_win64_console.exe -s res://tests/capture_floodmill.gd
```

See [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/FILES.md](docs/FILES.md), and [docs/VALIDATION.md](docs/VALIDATION.md) for architecture, file inventory, and manual QA steps.
