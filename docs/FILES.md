# Active Files — ASHVALE: THE THIRTEENTH BELL (Phases 0–6)

## Project Configuration & Docs
- `project.godot`: Godot 4.7.2 settings (`640x360`, Compatibility renderer, input actions, bitmap theme, `AshvaleAudio` autoload)
- `README.md`: Controls, Prologue & Chapters 1–5 + Epilogue progression guide, save/resume behavior, and CLI test commands
- `docs/GAME_DESIGN.md`: Canonical story bible for Ashvale
- `docs/ARCHITECTURE.md`: Prologue and Chapters 1–5 + Epilogue architecture
- `docs/VALIDATION.md`: Automated test suites (`validate*.gd`), screenshot captures, and manual playtesting checklist
- `docs/FILES.md`: Active file inventory

## Quest Data
- `data/prologue_quest.json`: Bellhaven prologue objectives, `MOON`/`SUN`/`STAR` cipher, villager dialogues, and story events
- `data/chapter1_quest.json`: Briarwood Chapter 1 objectives, `BridgeRepair` & `MirrorPuzzle` solutions, Historian Lyra stage dialogues, inscriptions, and Elena's Echo
- `data/chapter2_quest.json`: Floodmill Chapter 2 objectives, `WatermillRepair`, `SluicePuzzle` & `LedgerPuzzle` solutions, Lyra dialogues, Archive records, and Second Beacon Elena recording
- `data/chapter3_quest.json`: Ironwatch Keep Chapter 3 objectives, `CrestPuzzle` solution (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`), Lyra & Last Bell Warden dialogues, Archives/Barracks chronicles, Elena's research, Third Beacon & Dawnspire unlock
- `data/chapter4_quest.json`: Dawnspire Mountain Chapter 4 objectives (`enter_foothills` -> `complete_chapter4`), `CelestialPuzzle` solution, Lyra stage dialogues, Elena's preserved journal, Sanctuary Revelation lines, Great Bell Gate unlock, and 4 optional remembrance discoveries
- `data/chapter5_quest.json`: Great Bell Sanctum Chapter 5 & Epilogue objectives (`enter_great_bell_chamber` -> `display_ending_credits`), 3 memory fragments, Bell Wardens' complete record, canonical Elena final message, 3-conduit shield stabilization & binding severance, Last Bell climax dialogue, canonical Dawn Terrace memorial epilogue, and Sunrise Bellhaven villager closure dialogues

## Scenes
- `scenes/sjt_exterior.tscn`: Playable Bellhaven Village Square scene (Prologue startup entry & Sunrise Bellhaven post-game)
- `scenes/briarwood_forest.tscn`: Playable Briarwood Forest scene (Chapter 1)
- `scenes/floodmill_village.tscn`: Playable Floodmill: The Drowned Village scene (Chapter 2)
- `scenes/ironwatch_keep.tscn`: Playable Ironwatch Keep scene (Chapter 3)
- `scenes/dawnspire_mountain.tscn`: Playable Dawnspire Mountain scene (Chapter 4)
- `scenes/great_bell_sanctum.tscn`: Playable Great Bell Sanctum & Dawn Terrace Finale scene (Chapter 5)
- `scenes/campus_prototype.tscn`: Baseline isometric courtyard harness validated by `tests/validate.gd`
- `scenes/characters/player.tscn`: Protagonist (`Aren`) scene with pixel-snapped camera
- `scenes/characters/npc.tscn`: Reusable NPC scene
- `scenes/environment/sjt_building.tscn`: Medieval Bellhaven buildings and porch geometry
- `scenes/environment/terminal.tscn`: Multi-role Bellhaven story interactable scene
- `scenes/ui/hud.tscn`: HUD, paginated dialogue panel, `RunePuzzle`, dynamic minigame/menu/satchel host, and completion overlay

## Scripts
- `scripts/systems/quest_manager.gd`: Chronological Prologue & Chapters 1–5 quest engine with atomic `SAVE_VERSION = 5` JSON persistence, `v1`–`v4` compatibility, pose/region/stealth & cliff checkpoint storage, optional discovery remembrance summary, and `.bak` recovery
- `scripts/characters/player.gd`: Normalized 8-directional movement, collision, external Whispering Cliffs wind drift support, facing, and Aren pixel art
- `scripts/characters/pixel_camera.gd`: Pixel-snapped follow camera
- `scripts/characters/npc.gd`: Reusable NPC behavior, dynamic prompt refresh, idle bob animation, and procedural art (`caelen`, `mira`, `elara`, `lyra`, `warden`)
- `scripts/interactables/terminal.gd`: Bellhaven multi-role interactable (`ready_to_travel` transition arming included)
- `scripts/interactables/briarwood_interactable.gd`: Briarwood interactive objects (including `floodmill_gate` `ready_to_travel` arming)
- `scripts/interactables/floodmill_interactable.gd`: Floodmill interactive objects (`entrance_arch`, `village_plaque`, `optional_lore`, `watermill_mechanism`, `mill_diagram`, `mill_part`, `sluice_console`, `canal_clue`, `archive_entrance`, `archive_record`, `ledger_table`, `second_beacon`, `ironwatch_gate` with `ready_to_travel` transition arming)
- `scripts/interactables/ironwatch_interactable.gd`: Ironwatch Keep interactive objects (`floodmill_return_gate`, `courtyard_arch`, `courtyard_monument`, `warden_records`, `barracks_log`, `barracks_keepsake`, `crest_clue`, `crest_altar`, `shadow_ward_switch`, `elena_research`, `third_beacon`, `dawnspire_gate` with `ready_to_travel` transition arming)
- `scripts/interactables/dawnspire_interactable.gd`: Dawnspire Mountain interactive objects (`ironwatch_return_gate`, `foothills_entrance`, `cliff_marker`, `skybridge_console`, `skybridge_diagram`, `skybridge_part`, `refuge_mural`, `elena_journal`, `observatory_arch`, `celestial_clue`, `celestial_mechanism`, `sanctuary_threshold`, `sanctuary_nexus`, `great_bell_gate`, `optional_discovery`)
- `scripts/interactables/great_bell_interactable.gd`: Great Bell Sanctum interactive objects (`sanctum_dawnspire_gate`, `antechamber_threshold`, `forgotten_hall_arch`, `memory_crystal`, `warden_record`, `elena_echo_plinth`, `great_bell_binding`, `beacon_conduit`, `dawn_terrace_overlook`, `dawn_memorial`, `bellhaven_sunrise_arch`)
- `scripts/ui/hud.gd`: Priority interactable selection, paginated dialogue router, minigame orchestration, stealth/wind status banner, manual save/continue/new-game routing, finale climax & epilogue orchestration, and completion overlays
- `scripts/ui/ending_credits.gd`: Interactive finale credits screen (`ASHVALE: THE THIRTEENTH BELL` / `THE END`) with post-game Dawn Terrace continue, Sunrise Bellhaven visit, Title Menu, and New Game actions
- `scripts/ui/title_menu.gd`: System/Title Menu overlay (`New Game`, `Continue`, `Save Progress`, `Field Satchel`, `Resume`, and 4-bus audio sliders)
- `scripts/ui/inventory_panel.gd`: Aren's Field Satchel items, materials, inscriptions, Floodmill parts/records, Ironwatch chronicles/crests/testimony, Dawnspire components/journal/pillars/triad, Chapter 5 memory records/seal/memorial chronicle, and relic tracker
- `scripts/ui/rune_puzzle.gd`: Prologue 3-disc Rune-Alignment minigame (`MOON`, `SUN`, `STAR`)
- `scripts/ui/bridge_repair.gd`: Chapter 1 Minigame A (`LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`)
- `scripts/ui/mirror_puzzle.gd`: Chapter 1 Minigame B (`DAWN`, `ZENITH`, `DUSK`)
- `scripts/ui/watermill_repair.gd`: Chapter 2 Minigame A (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`)
- `scripts/ui/sluice_puzzle.gd`: Chapter 2 Minigame B (`DIVERT`, `DRAIN`, `OPEN`)
- `scripts/ui/ledger_puzzle.gd`: Chapter 2 Minigame C (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`)
- `scripts/ui/crest_puzzle.gd`: Chapter 3 Minigame A (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`)
- `scripts/ui/skybridge_repair.gd`: Chapter 4 Minigame A counterweight balance puzzle (`GRANITE WEIGHT`, `BRONZE PINION`, `TENSION CHAIN`)
- `scripts/ui/celestial_puzzle.gd`: Chapter 4 Minigame B rotating astronomical ring alignment puzzle (`FIRST BEACON DAWN`, `SECOND BEACON TIDE`, `THIRD BEACON CROWN`)
- `scripts/world/sjt_region.gd`, `scripts/world/sjt_landscape.gd`: Bellhaven tiles, props, NPCs, roads, beacon beam, save/reset sync, and `travel_to_briarwood()`
- `scripts/world/briarwood_region.gd`, `scripts/world/briarwood_landscape.gd`, `scripts/world/briarwood_prop.gd`: Briarwood tiles, woodland/ruin props, dynamic `BridgeBlocker`, Lyra relocation, `travel_to_floodmill()`, and save state sync
- `scripts/world/floodmill_region.gd`, `scripts/world/floodmill_building.gd`, `scripts/world/floodmill_landscape.gd`, `scripts/world/floodmill_prop.gd`: Floodmill wetland terrain, 5 isometric buildings, canal/causeway blockers, Lyra checkpoints, `travel_to_ironwatch()`, throttled (`12.5 Hz`) marsh/mist animation, environmental props, and save state sync
- `scripts/world/ironwatch_region.gd`, `scripts/world/ironwatch_building.gd`, `scripts/world/ironwatch_landscape.gd`, `scripts/world/ironwatch_prop.gd`, `scripts/world/shadow_sentinel.gd`: Ironwatch Keep basalt fortress, extended precipice backdrop, 6 wings, Hall of Crests portcullis, Shadowed Passage stealth checkpoints & sentinels, triad beam lattice, Last Bell Warden, Third Beacon, `travel_to_dawnspire()`, and save state sync
- `scripts/world/dawnspire_region.gd`, `scripts/world/dawnspire_building.gd`, `scripts/world/dawnspire_landscape.gd`, `scripts/world/dawnspire_prop.gd`: Dawnspire Mountain 7 alpine areas, storm-cloud precipice backdrop, Whispering Cliffs wind zones & shelter checkpoints, Skybridge & Sanctuary collision blockers, Lyra ascent checkpoints, `travel_to_ironwatch()`, `travel_to_great_bell()`, and save state sync
- `scripts/world/great_bell_region.gd`, `scripts/world/great_bell_building.gd`, `scripts/world/great_bell_landscape.gd`, `scripts/world/great_bell_prop.gd`: Great Bell Sanctum Areas A–D (Bell Antechamber, Hall of Forgotten Names, Heart of the Bell with three-conduit beam geometry and chain severance, Dawn Terrace with sunrise sky rays & Memorial of Remembered Names), `HeartChamberBlocker` & `DawnTerraceBlocker`, Lyra checkpoints, `travel_to_dawnspire()`, `travel_to_bellhaven_sunrise()`, and save state sync
- `scripts/world/sjt_building.gd`, `scripts/world/sjt_art.gd`, `scripts/world/sjt_landmark.gd`, `scripts/world/campus_furniture.gd`, `scripts/world/prop.gd`: Bellhaven architecture, blacksmith anvil/quench tub & village storytelling props, furnishings, and foliage
- `scripts/systems/audio_manager.gd`, `default_bus_layout.tres`: 4-bus (`Master`, `Music`, `SFX`, `Ambient`) procedural PCM16 audio engine (`AshvaleAudio` autoload) and volume persistence (`user://ashvale_audio_settings.json`)
- `scripts/systems/cinematic_director.gd`: Skippable letterboxed story cinematics coordinator (`[X] SKIP SCENE`) with `PixelCamera` choreography
- `scripts/world/campus.gd`, `scripts/world/ground_details.gd`: Baseline yard helpers used by `scenes/campus_prototype.tscn`
- `scripts/tools/generate_tiles.gd`, `scripts/tools/generate_font.gd`: Procedural tileset and bitmap font generators
- `docs/ART_DIRECTION.md`: Canonical pixel density, isometric scale, lighting restraint, and 4-region palette/storytelling specification

## Assets
- `assets/tiles/courtyard.png`, `assets/tiles/courtyard.tres`: 64x32 isometric ground tiles
- `assets/fonts/after_hours.png`, `after_hours.fnt`, `after_hours.tres`: 8px pixel bitmap font (80 supported glyphs)
- `assets/fonts/pixel_theme.tres`: Default UI font theme
- `default_bus_layout.tres`: 4-bus audio routing layout (`Master`, `Music`, `SFX`, `Ambient`)

## Automated Tests & Captures
- `tests/validate.gd`: Baseline isometric/movement/collision/camera/UI suite (63 checks)
- `tests/validate_sjt.gd`: Bellhaven architectural collisions, routes, and scenery coverage suite (39 checks)
- `tests/validate_zone.gd`: Priority selection, overlap handoff, furnishings, seating loop, and HUD bounds suite (71 checks)
- `tests/validate_phase1.gd`: Prologue quest sequencing, clues, Rune Puzzle, Briarwood Waystone, banner, and NPC suite (77 checks)
- `tests/validate_phase2.gd`: Chapter 1 transition, Briarwood spots, 10-objective quest, both minigames, physical bridge crossing, Ruined Camp relic, Elena Echo, Floodmill gate, and save/load suite (108 checks)
- `tests/validate_phase2_5.gd`: End-to-end no-teleport walkthrough (Bellhaven -> Briarwood), Field Satchel & Title Menu checks, cross-region Save/Exit/Reopen/Continue, same-region Bellhaven resume, New Game reset, and corrupt-save / `.bak` fallback checks (88 checks)
- `tests/validate_phase3.gd`: Briarwood -> Floodmill transition, approach clearances, out-of-order lockouts, all 14 Floodmill objectives, optional Weaver Homestead Locket, `WatermillRepair`, `SluicePuzzle` + physical causeway drain crossing, Cutaway Archive 3 records, `LedgerPuzzle`, Second Beacon + canonical Elena/Aren/Lyra lines, Ironwatch Keep Gate unlock, Field Satchel Chapter 2 tracking, cross-region Floodmill Save/Continue resume, `v1` save backwards compatibility, and `.bak` recovery (129 checks)
- `tests/validate_phase4.gd`: Floodmill -> Ironwatch transition, 6 fortress wings, approach clearances, out-of-order lockouts, all 13 `chapter3_keepers_lie` objectives, optional Warden's Tarnished Locket, 3 Watch Crest clues, `CrestPuzzle` (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`), `Shadowed Passage` stealth checkpoints & non-destructive detection recovery, canonical Last Bell Warden confrontation lines, Elena research, Third Ancient Beacon triad, Dawnspire road unlock, Field Satchel Chapter 3 tracking, `SAVE_VERSION = 3` resume, `v1`/`v2` backwards compatibility, and `.bak` recovery (104 checks)
- `tests/validate_phase4_5.gd`: Phase 4.5 visual/audio/cinematic integration suite — `ART_DIRECTION.md`, 4-bus `AudioManager` + `TitleMenu` slider mute/save/reload with clean backup isolation, Aren idle breathing & footstep timing, NPC dialogue facing, skippable cinematics (`Bellhaven`, `Briarwood`, `Floodmill`, `Ironwatch`), forward/backward regional entry pose continuity, Save v3 non-interference with audio settings, and per-region frame-time health checks (44 checks)
- `tests/validate_phase5.gd`: Chapter 4 (Dawnspire Mountain) full validation suite — Ironwatch -> Dawnspire transition, 7 alpine areas & 23 clear approach spots, out-of-order lockouts, Whispering Cliffs checkpoint & gale hazard reset safety, `SkybridgeRepair` & physical ravine crossing, Pilgrim's Refuge & canonical Elena's Journal lines verbatim, `CelestialPuzzle` astrolabe & Sanctuary stair unlock, Three-Beacon synchronization & canonical Sanctuary Revelation lines verbatim, Great Bell Gate unlock, non-repeating `CHAPTER 4 COMPLETE — THE ROAD TO DAWNSPIRE` banner, Field Satchel Chapter 4 tracking, backward Dawnspire -> Ironwatch travel, Save `v4` round-trip, `v1`/`v2`/`v3` backwards compatibility, and `.bak` recovery (113 checks)
- `export_presets.cfg`: Godot Windows Desktop export preset (`dist/ASHVALE-Windows/ASHVALE.pck` / `ASHVALE.exe`, excluding tests/docs/tools)
- `RELEASE_NOTES.md`, `PLAYER_GUIDE.md`, `KNOWN_ISSUES.md`, `RELEASE_CHECKLIST.md`: Phase 7 Windows release documentation
- `tests/validate_phase6.gd`: Chapter 5 (The Last Bell & Epilogue) full validation suite — Dawnspire -> Great Bell gate gating & transition, 4 sanctum zones & 16 clear approach spots, 14 chronological objectives, out-of-order lockouts, 3 Memory Fragments & Complete Warden Record, canonical Elena Final Message & Epilogue lines verbatim, 3-conduit shield stabilization, chain severance, skippable `last_bell_climax` cinematic, immediate clearing of `display_ending_credits`, interactive `EndingCredits` & non-looping post-game exploration, Sunrise Bellhaven (`VillageMemorial`, `LyraBellhaven`, updated Caelen/Mira/Elara dialogue, Dawn Terrace round-trip), Save `v5` post-game `Continue` safety, `v1`–`v4` compatibility, and `.bak` recovery (73 checks)
- `tests/validate_phase7_release.gd`: Phase 7 complete-game release QA suite — resource checks, Prologue -> Chapter 1 -> Chapter 2 -> Chapter 3 -> Chapter 4 -> Chapter 5 -> Epilogue -> Credits -> Sunrise Bellhaven full chain, immediate clearing of `display_ending_credits`, `TitleMenu` `QUIT TO DESKTOP` & fullscreen toggle, audio settings isolation, `Continue` & `New Game` reset safety, and zero orphan node verification (97 checks; **1,006 total checks across 12 suites**)
- `tests/profile_phase7.gd`: Windowed GPU OpenGL 3.3 performance & memory profiler across all 6 regions
- `tests/capture_sjt.gd`, `tests/capture_briarwood.gd`, `tests/capture_floodmill.gd`, `tests/capture_ironwatch.gd`, `tests/capture_phase4_5.gd`, `tests/capture_dawnspire.gd`, `tests/capture_phase6.gd`, `tests/capture.gd`: Automated PNG visual review generators (`tests/*.png`, including `verify_dawnspire_*.png`, `verify_phase6_*.png`, `before_*.png`, `after_*.png`, and `cinematic_*.png`)
