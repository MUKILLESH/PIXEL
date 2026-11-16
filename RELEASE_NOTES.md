# Release Notes — ASHVALE: THE THIRTEENTH BELL (v1.0.0)

**Engine:** Godot Engine 4.7.2 Standard (`GL Compatibility`)  
**Target Platform:** Windows (x86_64)  
**Save Schema Version:** `5` (backward compatible with `v1`–`v4` saves)  

---

## What Is Included in v1.0.0

### Complete Playable Chronicle (Prologue through Finale & Epilogue)
- **Prologue — The Thirteenth Toll (`scenes/sjt_exterior.tscn`):** Investigate the ominous thirteenth chime in Bellhaven Village, speak with Master Caelen, Mira, and Sister Elara, recover Elena's survey notes, solve the concentric Rune Pedestal puzzle (`MOON`, `SUN`, `STAR`), and unseal Briarwood Waystone.
- **Chapter 1 — Whispers of Briarwood (`scenes/briarwood_forest.tscn`):** Reunite with Historian Lyra, rebuild the collapsed Old Bridge (`BridgeRepair`), read Oakhaven's three erased-village inscriptions, align Mirror Grove (`MirrorPuzzle`), rekindle the **First Ancient Beacon**, and discover Elena's first echo.
- **Chapter 2 — The Drowned Village (`scenes/floodmill_village.tscn`):** Repair the Old Watermill (`WatermillRepair`), drain the sunken Archive Causeway via the Canal Sluice Console (`SluicePuzzle`), reconstruct the parish ledger (`LedgerPuzzle`), uncover the fate of Floodmill's thirty-six families, ignite the **Second Ancient Beacon**, and unlock Ironwatch Keep.
- **Chapter 3 — The Keeper's Lie (`scenes/ironwatch_keep.tscn`):** Investigate the Fortress Archives and Barracks logs, solve the Hall of Crests (`CrestPuzzle`), sneak through the Shadowed Passage past Shadow Sentinels using Ward Alcove checkpoints, confront the Last Bell Warden, read Elena's triad research, and ignite the **Third Ancient Beacon**.
- **Chapter 4 — The Road to Dawnspire (`scenes/dawnspire_mountain.tscn`):** Climb the gale-swept Whispering Cliffs using shelter cairns, balance the counterweight Skybridge (`SkybridgeRepair`), read Elena's preserved journal inside Pilgrim's Refuge, align the Celestial Observatory (`CelestialPuzzle`), synchronize all three Ancient Beacons at Dawnspire Sanctuary, and unlock the Great Bell Gate.
- **Chapter 5 — The Last Bell & Epilogue (`scenes/great_bell_sanctum.tscn` & Sunrise Bellhaven):** Enter the monumental Great Bell Sanctum, recover the three essential Memory Fragments, reveal the Bell Wardens' Complete Record, hear Elena's final message (`"You already did, Aren. You remembered me."`), light all three Beacon Conduits around the Heart of the Bell, stabilize the replacement shield, sever the memory-consuming chains (`last_bell_climax` skippable cinematic), place Elena's journal beside the Dawn Terrace memorial (`"Of places. And of the people we almost forgot."`), view the interactive Ending Credits, and explore **Bellhaven at Sunrise**.

### Phase 7 Polish, Quality-of-Life & Release Readiness
- **Immediate Objective Completion on Credits Display:** Opening `EndingCredits` clears `"Display ending credits."` immediately and transitions cleanly into post-game state (`"Chapter 5 Complete - Ashvale Remembered."`).
- **System Menu Quit & Fullscreen Toggle:** Added `QUIT TO DESKTOP` (`TitleMenu`) and `[F11]` fullscreen/windowed toggle across desktop play.
- **Monumental Great Bell Centerpiece & Sanctum Architecture:** Upgraded obsidian-and-bronze belfry arches, hammered metallic Bell shading, engraved waist runes, fracturing purple chains vs. morning harmonic halos, Floor Compass medallion, north gallery plaques, radial dais spokes, and layered sunrise mountain vista.
- **Four-Bus Procedural Audio Engine:** `Master`, `Music`, `SFX`, and `Ambient` volume sliders persisted independently to `user://ashvale_audio_settings.json`.
- **Windows Release Pack (`dist/ASHVALE-Windows/ASHVALE.pck`):** Exported via `export_presets.cfg` filtering out test/development files and tested outside the project folder via `--main-pack`.

---

## Attribution
- Built with **Godot Engine 4.7.2 Standard** (MIT License).
- Original story, gameplay systems, procedural 2.5D pixel art, custom `After Hours Pixel` 8px bitmap font, and procedural PCM16 music/SFX authored specifically for **ASHVALE: THE THIRTEENTH BELL**.
