# ASHVALE: THE THIRTEENTH BELL

An isometric 2.5D pixel-art mystery adventure built in **Godot 4.7.2 Standard** (`GDScript`).

After the Great Bell of **Bellhaven Village** tolls a forbidden thirteenth time, apprentice mapmaker **Aren** uncovers a rune cipher leading to his missing mother **Elena**, journeys through **Briarwood Forest** alongside traveling historian **Lyra** to awaken the First Ancient Beacon, enters **Floodmill: The Drowned Village** to restore the Second Ancient Beacon, breaches **Ironwatch Keep** to uncover the Bell Wardens' lie and ignite the Third Ancient Beacon, and ascends **Dawnspire Mountain** to synchronize all three Beacons and unseal the **Great Bell Gate**.

## Controls

- **Move:** `WASD` / `Arrow Keys`
- **Interact / Advance Dialogue / Confirm Puzzle:** `E`, `Enter`, or `Space`
- **Dismiss / Cancel UI:** `Esc`
- **Field Satchel (Inventory & Clues):** `I` or `Tab`
- **Title / System Menu (New Game, Continue, Manual Save, Satchel):** `M` or `F10`
- **Quick Save Progress:** `F5`
- **In Minigames (`RunePuzzle`, `BridgeRepair`, `MirrorPuzzle`, `WatermillRepair`, `SluicePuzzle`, `LedgerPuzzle`, `CrestPuzzle`, `SkybridgeRepair`, `CelestialPuzzle`):** `W/S` or `Up/Down` selects rows, `A/D` or `Left/Right` cycles values, `E`/`Enter` verifies, `Esc` closes cleanly, or click UI buttons directly

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
9. Speak with **Lyra** by the Second Beacon (`complete_chapter2`) to display `CHAPTER 2 COMPLETE — THE DROWNED VILLAGE` and unlock the **Ironwatch Keep Gate** (`unlock_ironwatch_path` / press `E` twice to enter Ironwatch Keep).

### Chapter 3 — The Keeper's Lie (`scenes/ironwatch_keep.tscn`)
1. Inspect the **Ironwatch Keep Threshold** (`enter_ironwatch`) and the **Courtyard Statue Circle** (`investigate_courtyard`).
2. Enter the cutaway **Fortress Archives** to read the **First Catastrophe Ledger** (`discover_warden_records`) revealing the initial sacrifice of thirty-six volunteers.
3. Search the **Abandoned Barracks** duty roster (`explore_barracks`) to uncover how later Keepers concealed the Ancient Beacons. *(Optional keepsake: recover the **Warden's Tarnished Locket**.)*
4. Discover all **3 Watch Crest clues** across the Archives lectern, Barracks armory plaque, and Hall of Crests stele (`find_crest_clues`).
5. Solve **Hall of Crests (`CrestPuzzle`)**: `SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME` (`solve_crest_puzzle`) to lift the Shadowed Passage portcullis.
6. Cross the **Shadowed Passage** past patrolling **Shadow Sentinels** using glowing **Ward Alcoves** (non-destructive checkpoint recovery upon detection), then harmonize the **North Ward Lantern** (`navigate_shadowed_passage`) and enter the **Warden's Chamber** (`reach_wardens_chamber`).
7. Confront the **Last Bell Warden** (`confront_last_warden`), read **Elena's Harmonic Lattice Folio** (`discover_elena_research`), ignite the **Third Ancient Beacon** connecting all three Beacons (`restore_third_beacon`), and unseal the **Dawnspire Citadel Gate** (`unlock_dawnspire_road` / `complete_chapter3`) to display `CHAPTER 3 COMPLETE — THE KEEPER'S LIE`, then press `E` twice at the unsealed Citadel Gate to ascend to Dawnspire Mountain.

### Chapter 4 — The Road to Dawnspire (`scenes/dawnspire_mountain.tscn`)
1. Survey the **Dawnspire Foothills** (`enter_foothills`) and speak with **Historian Lyra** about the storm and three beacon lines (`speak_lyra_foothills`).
2. Climb the **Whispering Cliffs** ridge, using carved **Wind Shelter Cairns** during gale gusts (non-destructive checkpoint reset upon precipice fall), and inspect the upper **Pilgrim Cairn** (`navigate_whispering_cliffs`).
3. Investigate the **Broken Skybridge** winch housing (`investigate_skybridge`), study the **Masonry Winch Diagram**, and recover all **3 counterweight components** (`granite_counterweight`, `bronze_pinion`, `tension_chain` -> `discover_bridge_mechanism`).
4. Solve **Minigame A (`SkybridgeRepair`)**: `GRANITE WEIGHT`, `BRONZE PINION`, `TENSION CHAIN` (`repair_skybridge`), then physically walk north across the balanced Skybridge span.
5. Inspect the murals inside **Pilgrim's Refuge** cutaway chapel (`discover_pilgrims_refuge`) and read **Elena's Preserved Journal** (`read_elena_journal`).
6. Enter the **Celestial Observatory** (`reach_observatory`), study the Solar, Lunar, and Stellar pillars (`find_celestial_clues`), and solve **Minigame B (`CelestialPuzzle`)**: `FIRST BEACON DAWN`, `SECOND BEACON TIDE`, `THIRD BEACON CROWN` (`solve_observatory_puzzle`) to unseal the Sanctuary Stair.
7. Ascend into **Dawnspire Sanctuary** (`enter_dawnspire_sanctuary`), synchronize all three Ancient Beacons at the **Sanctuary Nexus** (`synchronize_three_beacons`), witness **Elena's Sanctuary Revelation** (`witness_sanctuary_revelation`), unseal the **Great Bell Gate** (`reach_great_bell_gate`), and complete Chapter 4 (`CHAPTER 4 COMPLETE — THE ROAD TO DAWNSPIRE`, unlocking **The Last Bell**).
*(Optional Dawnspire explorations: **Abandoned Mountain Campsite**, **Forgotten Pilgrim's Letter**, **Mountain Memorial Plaque**, and **Hidden Valley Overlook**.)*

## Save System & Resume Flow

- Progress is stored atomically at `user://ashvale_save.json` with `.tmp` staging and `.bak` backup rotation (`SAVE_VERSION := 4`, backwards compatible with `version == 1`, `2`, and `3` saves).
- Saved state includes the active region scene (`sjt_exterior.tscn`, `briarwood_forest.tscn`, `floodmill_village.tscn`, `ironwatch_keep.tscn`, or `dawnspire_mountain.tscn`), Aren's exact position and facing direction, completed objectives, inventory/clues, bridge/mirror/watermill/sluice/ledger/crest/skybridge/celestial/sanctuary states, stealth and cliff shelter checkpoints, beacon activations, and NPC positions.
- Corrupted primary saves or mismatched schemas are rejected cleanly and automatically fall back to `user://ashvale_save.json.bak` when valid.
- **Audio & Cinematic Polish (Phase 4.5 + Phase 5):** Procedural PCM16 regional ambience and 16 sound effects (including Dawnspire wind, distant thunder, counterweight lock, celestial alignment, sanctuary awakening, and Great Bell resonance) routed through `default_bus_layout.tres` (`Master`, `Music`, `SFX`, `Ambient`) with `TitleMenu` volume controls persisted to `user://ashvale_audio_settings.json`, skippable story cinematics (`CinematicDirector`, `[X] SKIP SCENE`) across Bellhaven, Briarwood, Floodmill, Ironwatch Keep, and Dawnspire Mountain, regional arrival banners, and seamless forward/backward region entry poses.

## Running & Validation

```powershell
# Launch playable startup scene
.\Godot_v4.7.2-stable_win64_console.exe

# Run automated validation suites (836 checks total across 10 suites + bus check)
.\Godot_v4.7.2-stable_win64_console.exe --headless --import
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 300 -s .\.agents\skills\godot-audio\assets\check_audio_buses.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_zone.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_phase1.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_phase2.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 4800 -s res://tests/validate_phase2_5.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_phase3.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_phase4.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 2400 -s res://tests/validate_phase4_5.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 3600 -s res://tests/validate_phase5.gd

# Generate screenshot captures
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_briarwood.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_floodmill.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_ironwatch.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 240 -s res://tests/capture_phase4_5.gd -- --after
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 300 -s res://tests/capture_dawnspire.gd
```

See [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md), [docs/ART_DIRECTION.md](docs/ART_DIRECTION.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/FILES.md](docs/FILES.md), and [docs/VALIDATION.md](docs/VALIDATION.md) for architecture, visual standards, file inventory, and manual QA steps.
