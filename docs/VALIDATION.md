# Validation & Playtesting — ASHVALE: THE THIRTEENTH BELL (Phases 0–7)

## Automated Suites

Run from the repository root (`d:\MUKI PROJECT\VIT_After_Hours`):

```powershell
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
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 3600 -s res://tests/validate_phase6.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 3600 -s res://tests/validate_phase7_release.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 800 -s res://tests/profile_phase7.gd
.\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 180
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
  - Second Ancient Beacon activation, canonical Elena/Aren/Lyra Second Beacon lines, `CHAPTER 2 COMPLETE — THE DROWNED VILLAGE` banner, `IronwatchGate` Chapter 3 unlock, Field Satchel Chapter 2 summary, cross-region startup `Continue` -> Floodmill exact pose/world-state resume, Phase 2 (`version == 1`) backwards save compatibility, and `.bak` recovery.
- **`tests/validate_phase4.gd` (104 checks):**
  - Floodmill `IronwatchGate` locked pre-Chapter-2, unlocked upon Chapter 2 completion, armed via two-step prompt, and live transition to `res://scenes/ironwatch_keep.tscn`.
  - All 6 Ironwatch structures (`GatehouseBastion`, `RuinedBarracks`, `CutawayArchives`, `HallOfCrests`, `ShadowColonnade`, `BeaconVaultSanctum`), `Lyra`, `LastWarden`, both `ShadowSentinel` patrols, `CrestPuzzle` panel, and 15 approach spots free of solids.
  - Out-of-order progression lockouts, physical blockade of the northern Beacon Vault before solving Hall of Crests & clearing Shadowed Passage (`CrestPortcullisBlocker` / `PassageExitBlocker`), and all 13 chronological objectives in `chapter3_keepers_lie`.
  - Optional Warden's Tarnished Locket, 3 Watch Crest clues (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`), `CrestPuzzle` `ESC` close, wrong-combo rejection, keyboard solve, and Shadowed Passage `checkpoint_1` + sentinel detection recovery without losing clues.
  - Canonical Last Bell Warden confrontation lines verbatim, Elena's Harmonic Lattice folio, Third Ancient Beacon triad illumination, `DawnspireGate` unlock, `CHAPTER 3 COMPLETE — THE KEEPER'S LIE` banner, Field Satchel Chapter 3 tracking, `SAVE_VERSION = 3` resume, `v1`/`v2` compatibility, and `.bak` recovery.
- **Phase 4.5 Validation (`tests/validate_phase4_5.gd` — 44 checks, 0 failures; `check_audio_buses.gd` — 0 unknown buses):**
  - `docs/ART_DIRECTION.md` and `default_bus_layout.tres` (`Master`, `Music`, `SFX`, `Ambient`) presence and bus registration.
  - Headless smoke boot (`--headless --quit-after 180`) verifies zero startup scene-tree errors and zero ObjectDB leaks with the `AshvaleAudio` autoload.
  - Aren idle breathing animation, walking footstep SFX trigger cadence, and Master Caelen 8-direction turn + dialogue badge.
  - `TitleMenu` audio bus controls (`Music`, `SFX` mute at 0), independent `user://ashvale_audio_settings.json` persistence/reload, and clean test backup/restore without touching saves.
  - Skippable story cinematics, letterbox framing, `PixelCamera` focus/restoration, `KEY_X` skip callbacks, region transitions, and `12.5 Hz` landscape redraw throttling.
- **`tests/validate_phase5.gd` (113 checks, 0 failures):**
  - `Ironwatch -> Dawnspire` gate lockout pre-Chapter-3, two-step arming & transition post-Chapter-3, all 7 alpine areas, `Lyra`, `SkybridgeRepair`, `CelestialPuzzle`, and all 23 approach positions free of solids.
  - Out-of-order progression lockouts, physical `SkybridgeBlocker` and `SanctuaryBlocker` collision gating, Whispering Cliffs checkpoint tracking (`cliff_cp_1`), predictable gale wind drift, non-destructive cliff precipice recovery, and all 4 optional mountain discoveries.
  - `SkybridgeRepair` ESC close, wrong-combo rejection, keyboard solve (`GRANITE WEIGHT`, `BRONZE PINION`, `TENSION CHAIN`), and physical north ravine crossing.
  - Pilgrim's Refuge murals, canonical 4-line Elena's Journal verbatim, all 3 Celestial Observatory pillars (`sun`, `moon`, `stars`), `CelestialPuzzle` (`FIRST BEACON DAWN`, `SECOND BEACON TIDE`, `THIRD BEACON CROWN`), Sanctuary stair physical ascent, Three-Beacon synchronization, canonical 6-line Sanctuary Revelation verbatim, Great Bell Gate unlock, non-duplicating `CHAPTER 4 COMPLETE — THE ROAD TO DAWNSPIRE` banner, Field Satchel Chapter 4 tracking, backward `Dawnspire -> Ironwatch` travel, `SAVE_VERSION = 4` resume, `v1`/`v2`/`v3` save compatibility, and `.bak` recovery.
- **`tests/validate_phase6.gd` (73 checks, 0 failures):**
  - `Dawnspire -> Great Bell Sanctum` gate gating pre/post Chapter 4, all 4 sanctum areas (Bell Antechamber, Hall of Forgotten Names, Heart of the Bell, Dawn Terrace), `HeartChamberBlocker` and `DawnTerraceBlocker` physical doorway gates, and all 16 approach positions free of solids.
  - Strict sequence gating across all 14 `chapter5_the_last_bell` objectives, all 3 Memory Fragments (**The Home**, **The Promise**, **The Sacrifice**), Bell Wardens' Complete Record, and canonical Elena Final Message verbatim lines (`"You already did, Aren. You remembered me."` / `"Let the thirteen tolls end here."`).
  - Three Beacon Conduits (`conduit_briarwood`, `conduit_floodmill`, `conduit_ironwatch`), replacement protective network stabilization, memory binding severance (`binding_severed = true`, `storm_resolved = true`), and skippable `last_bell_climax` cinematic (`[X]`).
  - Dawn Terrace return, canonical Memorial Epilogue dialogue verbatim (`"Of places. And of the people we almost forgot."`) with optional discovery remembrances, Elena's journal placement, immediate clearing of `display_ending_credits` upon opening `EndingCredits` (`Chapter 5 Complete - Ashvale Remembered.`), Sunrise Bellhaven (`sjt_exterior.tscn` morning lighting, `VillageMemorial`, `LyraBellhaven`, `DawnTerraceArch`, updated Caelen/Mira/Elara dialogue, and round-trip Dawn Terrace return), `SAVE_VERSION = 5` post-game `Continue` safety, `v1`–`v4` backwards compatibility, and `.bak` recovery.
- **`tests/validate_phase7_release.gd` (97 checks, 0 failures — Total across all 12 suites: 1,006 checks, 0 failures):**
  - Full 6-scene & 6-quest JSON resource validation, uninterrupted Prologue -> Chapter 1 -> Chapter 2 -> Chapter 3 -> Chapter 4 -> Chapter 5 -> Epilogue -> Credits -> Sunrise Bellhaven transition chain, immediate clearing of `display_ending_credits`, auto-saved post-game chronicle, `TitleMenu` `QUIT TO DESKTOP` option & `[F11]` fullscreen safety, audio settings isolation, non-looping `Continue`, clean `New Game` flag reset, and `0` leaked orphan nodes.
- **Windowed GPU Performance Profile (`tests/profile_phase7.gd` — OpenGL 3.3 Compatibility, RTX 4050 Laptop GPU):**
  - `BellhavenVillage`: `steady_fps=60.0`, `avg_frame_ms=16.66 ms`, `physics_ms=0.42 ms`, `mem_mb=42.58 MB`, `orphans=0`
  - `BriarwoodForest`: `steady_fps=60.0`, `avg_frame_ms=16.67 ms`, `physics_ms=0.52 ms`, `mem_mb=44.44 MB`, `orphans=0`
  - `FloodmillVillage`: `steady_fps=60.0`, `avg_frame_ms=16.67 ms`, `physics_ms=0.60 ms`, `mem_mb=45.36 MB`, `orphans=0`
  - `IronwatchKeep`: `steady_fps=60.0`, `avg_frame_ms=16.67 ms`, `physics_ms=0.55 ms`, `mem_mb=43.57 MB`, `orphans=0`
  - `DawnspireMountain`: `steady_fps=60.0`, `avg_frame_ms=16.67 ms`, `physics_ms=0.38 ms`, `mem_mb=44.50 MB`, `orphans=0`
  - `GreatBellSanctum`: `steady_fps=60.0`, `avg_frame_ms=16.67 ms`, `physics_ms=0.42 ms`, `mem_mb=44.73 MB`, `orphans=0`

## Visual Screenshot Captures

```powershell
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_sjt.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_briarwood.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_floodmill.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 180 -s res://tests/capture_ironwatch.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 240 -s res://tests/capture_phase4_5.gd -- --after
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 300 -s res://tests/capture_dawnspire.gd
.\Godot_v4.7.2-stable_win64_console.exe --quit-after 300 -s res://tests/capture_phase6.gd
```

Inspected visual captures include `tests/briarwood_edge_lyra.png`, `tests/briarwood_bridge_repair.png`, `tests/briarwood_mirror_puzzle.png`, `tests/briarwood_beacon_complete.png`, `tests/briarwood_overview.png`, `tests/phase2_5_satchel.png`, `tests/phase2_5_menu.png`, `tests/floodmill_arrival_village.png`, `tests/floodmill_watermill_repair.png`, `tests/floodmill_sluice_puzzle.png`, `tests/floodmill_ledger_puzzle.png`, `tests/floodmill_second_beacon.png`, `tests/floodmill_overview.png`, `tests/verify_ironwatch_courtyard.png`, `tests/verify_ironwatch_archives.png`, `tests/verify_ironwatch_crest_puzzle.png`, `tests/verify_ironwatch_stealth.png`, `tests/verify_ironwatch_warden_vault.png`, `tests/verify_ironwatch_beacon_lit.png`, Phase 4.5 before/after & cinematic captures (`tests/before_*.png`, `tests/after_*.png`, `tests/cinematic_bellhaven_toll.png`, `tests/cinematic_ironwatch_triad.png`), Phase 5 Dawnspire captures (`tests/verify_dawnspire_*.png`), and Phase 6 Finale captures (`tests/verify_phase6_antechamber.png`, `tests/verify_phase6_forgotten_hall.png`, `tests/verify_phase6_heart_ritual.png`, `tests/verify_phase6_climax_cinematic.png`, `tests/verify_phase6_dawn_epilogue.png`, `tests/verify_phase6_ending_credits.png`).

## Manual Playtesting Checklist (Interactive Verification)

Because headless runs use the Dummy audio driver and cannot evaluate subjective audio balance, visual pacing, mouse hover/click ergonomics across OS window resizing, or process-restart persistence across separate OS launches, verify these manually in the windowed game (`.\Godot_v4.7.2-stable_win64_console.exe`):

1. **Startup, Menu & Audio Mix Listening:** Launch the windowed game (with speakers/headphones), press `M` to open **System Menu**, adjust the **MASTER**, **MUSIC**, **SFX**, and **AMBIENT** volume steps, verify audible volume attenuation and mute at `[MUTE]`, inspect the **Field Satchel** (`I`), and confirm sharp bitmap typography and clean `Esc` dismissal.
2. **Cinematics, Visual Polish & Skip Responsiveness:** Play through key story beats in Bellhaven, Briarwood, Floodmill, Ironwatch Keep, and Dawnspire Mountain to verify letterbox framing, camera focus pans, Whispering Cliffs gale gusts, subtle animated landscape details, `[X] SKIP SCENE` responsiveness, and smooth transition fades + region arrival banners.
3. **Continuous Unassisted & Bidirectional Regional Travel:** Walk physically through Prologue Bellhaven, Briarwood Chapter 1, Floodmill Chapter 2, Ironwatch Keep Chapter 3, and Dawnspire Mountain Chapter 4, plus backtrack through regional gates (`Dawnspire <-> Ironwatch <-> Floodmill <-> Briarwood <-> Bellhaven`) to confirm natural facing and spawn positions.
4. **True Process-Exit Save & Audio Settings Persistence:** Change audio levels in `TitleMenu` (`M`), press `F5` / **SAVE PROGRESS** across Bellhaven, Briarwood, Floodmill, Ironwatch, and Dawnspire Mountain, completely exit and relaunch `.\Godot_v4.7.2-stable_win64_console.exe`, confirm saved audio sliders loaded automatically on startup, and press `M` -> **CONTINUE SAVED GAME** to verify exact region, pose, puzzle, NPC, beacon, and Great Bell Gate resume.
5. **Window Scaling & Mouse Controls:** Resize or maximize the 1280x720 window (pixel-integer scaling) and confirm mouse hover/clicks inside all nine minigame panels (`RunePuzzle`, `BridgeRepair`, `MirrorPuzzle`, `WatermillRepair`, `SluicePuzzle`, `LedgerPuzzle`, `CrestPuzzle`, `SkybridgeRepair`, `CelestialPuzzle`), `InventoryPanel`, and `TitleMenu` (including audio slider buttons) remain aligned and responsive.
