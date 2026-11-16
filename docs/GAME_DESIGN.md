# ASHVALE: THE THIRTEENTH BELL — Game Design Document

> **Engine:** Godot 4.7.2 Standard (GL Compatibility, GDScript)  
> **Perspective:** Isometric 2.5D Pixel Art (640×360 native viewport, 2:1 diamond projection, integer scaling)  
> **Genre:** Medieval Fantasy Adventure, Exploration, Mystery, Story-Driven Puzzles  
> **Core Themes:** Memory, Sacrifice, Truth, and Hope  
> **Status:** Canonical Design Reference (Phase 3 — Playable Prologue, Chapter 1 & Chapter 2 Active)

---

## 1. Game Premise

For three centuries, the medieval kingdom of **Ashvale** has been sheltered from an unnatural abyssal tempest—the **Veilstorm**—by the sacred **Great Bell** atop **Dawnspire Mountain**. Every evening at dusk, the Great Bell tolls **twelve times**, knitting a silver protective barrier above the valley.

Years ago, apprentice mapmaker **Aren**'s mother, **Elena**, vanished while charting forbidden landmarks and investigating the origins of the Great Bell. One storm-tossed night in **Bellhaven Village**, the Great Bell tolls a **thirteenth** time.

An ancient **Stone Rune Pedestal** in Bellhaven Square ignites with a warning that something beneath the kingdom is awakening. Through village records, Elena's hidden notes, and the research of **Lyra** (a historian and Elena's former expedition partner), Aren learns the kingdom's hidden cost: the Great Bell does not hold back the storm through mercy or magic alone—it feeds on the **memories** of Ashvale's people. Now the ward is fracturing. To uncover the truth behind his mother's disappearance and break the curse forever, Aren must journey across Ashvale with Lyra, rekindle **three Ancient Beacons** built before the Bell, and confront the kingdom's oldest lie.

---

## 2. World Regions

Ashvale spans **five interconnected regions**, traversed in strict chronological order:

1. **Bellhaven Village (Prologue — Playable in Phase 1)**
   - **Atmosphere:** Lantern-lit cobblestone square, half-timbered cottage, Bellhaven Belfry tower, glowing forge hearth, ancient Stone Rune Pedestal, and the silver-briared western path into Briarwood.
   - **Key Sites:** Bellhaven Square, Cartographer's Cottage & Sealed Survey Chest, Blacksmith Workshop, Bellhaven Belfry, Stone Well, Anvil Plinth, and the Briarwood Waystone Gate.
   - **Role:** 15–20 minute playable story prologue establishing the thirteenth chime, Aren's mother Elena's trail, the Rune-Alignment cipher, and the awakening of the Briarwood road.

2. **Briarwood Forest (Chapter 1 — Playable in Phase 2/2.5)**
   - **Atmosphere:** Mist-shrouded old-growth woods choked with silver-barked briars, fallen survey markers, Carpenter's Worksite, Mirror Grove, and mossy lantern shrines.
   - **Role:** Reunion with companion historian **Lyra**, bridge reconstruction (`BridgeRepair`), solar mirror alignment (`MirrorPuzzle`), and awakening the **First Ancient Beacon**.

3. **Floodmill Wetlands / The Drowned Village (Chapter 2 — Playable in Phase 3)**
   - **Atmosphere:** Abandoned half-submerged medieval village, Miller's Cottage, Ruined Homestead, Old Watermill, Canal Lockhouse & Sluice Canal, cutaway Forgotten Archive library, and Second Beacon Sanctuary.
   - **Role:** Watermill repair (`WatermillRepair`), canal sluice control (`SluicePuzzle`), archive ledger reconstruction (`LedgerPuzzle`), uncovering the erased thirty-six hearths, awakening the **Second Ancient Beacon**, and unlocking the **Ironwatch Keep** mountain gate.

4. **Ironwatch Keep (Chapter 3 — Phase 4 Playable)**
   - **Atmosphere:** Ruined basalt gatehouse courtyard with four hooded Warden statues & supply wagon, Abandoned Barracks, cutaway Gothic lancet Fortress Archives lit by candle chandeliers, arcane Hall of Crests, stealth-patrolled Shadowed Passage with glowing Ward Alcoves, and violet/gold Beacon Vault.
   - **Role:** Exposing the first catastrophe sacrifice versus later Keepers' concealed memory harvest, solving the Hall of Crests (`CrestPuzzle`), crossing the Shadowed Passage, confronting the **Last Bell Warden**, recovering Elena's triad research, awakening the **Third Ancient Beacon**, and unsealing the **Dawnspire Citadel Gate**.

5. **Dawnspire Mountain & The Summit Sanctum (Chapter 4 & Final Chapter — Planned)**
   - **Atmosphere:** Wind-carved alpine switchbacks, frost-rimmed obelisks overlooking the churning Veilstorm, and the colossal Great Bell belfry.
   - **Role:** Ascent to Dawnspire, channeling the connected triad of all three Ancient Beacons, discovering Elena's final sacrifice, and ending the Bell's curse.

---

## 3. Canonical Characters

- **Aren (Protagonist):**  
  Young apprentice mapmaker living in Bellhaven Village. Dressed in a forest-green tunic, traveler's cloak, and leather scroll satchel, he relies on maps and field notes to remember what the Bell tries to take. Driven by the disappearance of his mother, **Elena**, years earlier.

- **Lyra (Primary Companion — Historian):**  
  A dedicated scholar and field historian who assisted Elena on her final survey of the Beacons before Elena vanished at the threshold of Dawnspire. Ahead on the Briarwood trail during the Prologue (introduced through Sister Elara's records and Elena's letter), Lyra becomes Aren's primary companion from Chapter 1 through the Final Chapter.

- **Master Caelen (Village Bell Keeper):**  
  Bellhaven's elderly bell keeper and former master mapmaker who raised Aren after Elena disappeared. He knows far more about the thirteenth chime and Elena's final expedition than he initially admits, and entrusts Aren with the brass key to Elena's sealed chest.

- **Mira (Blacksmith):**  
  Bellhaven's warm-hearted, outspoken blacksmith who keeps her forge burning late into the night. She welcomes Aren into daily village life, remarks on villagers forgetting familiar names, and recalls repairing the middle bronze ring on the square's Stone Rune Pedestal for Elena.

- **Sister Elara (Bellhaven Historian):**  
  Custodian of Bellhaven's oldest ledgers and belfry archives. She recognizes the ancient pre-Bell Beacon glyphs waking on the Stone Rune Pedestal, connects them to Lyra's historical research, and helps Aren piece together the final cipher symbol.

- **Elena (Aren's Missing Mother — Backstory Anchor):**  
  Master cartographer who discovered that the three Ancient Beacons could shield Ashvale cleanly without erasing memories. Before vanishing, she hid her cipher notes in Bellhaven so Aren would follow only when the Thirteenth Toll forced the truth into the open.

- **Last Bell Warden / Commander Vane (Keeper of Ironwatch — Chapter 3):**  
  Ancient guardian of Ironwatch Keep who concealed records of the Ancient Beacons out of terror that silencing the Great Bell would surrender Ashvale to the Veilstorm, confessing how thirty-six lives were forgotten so ten thousand could live before yielded to Elena's research.

---

## 4. Chronological Story & Chapters

Progression follows a **strict chronological order**. Players explore freely within unlocked areas, but story milestones cannot be skipped.

### Prologue: *The Thirteenth Toll* (Bellhaven Village — Phase 1 Playable)
1. **Investigate the Thirteenth Bell:** Aren hears the unnatural 13th chime and inspects the awakening Stone Rune Pedestal in Bellhaven Square.
2. **Speak with Three Village NPCs:** Aren speaks with **Master Caelen**, **Mira**, and **Sister Elara**, uncovering clues about village memory loss, Elena's disappearance, historian **Lyra**, and three astronomical symbols (`MOON`, `SUN`, `STAR`).
3. **Find Mother's Letter:** Using Master Caelen's key on the sealed survey chest beside the cottage, Aren reads **Elena's letter**, confirming the order of the three rings and learning she set out toward the Beacons with Lyra.
4. **Solve the Rune Pedestal Puzzle:** At the Stone Rune Pedestal, Aren aligns the three concentric stone rings (`Outer = MOON`, `Middle = SUN`, `Inner = STAR`). The pedestal glows and projects a guiding light toward Briarwood.
5. **Discover the Path to Briarwood:** Aren approaches the parting silver-briared **Briarwood Waystone**, discovering the first Ancient Beacon lies within Briarwood Forest where Elena and Lyra searched.
6. **Prologue Completion Sequence:** Connecting the beacon's light to his mother's final footsteps, Aren commits to leaving Bellhaven at dawn. Displays **"PROLOGUE COMPLETE — THE THIRTEENTH TOLL"** and unlocks Briarwood for Phase 2.

### Chapter 1: *Whispers of Briarwood* (Briarwood Forest — Phase 2/2.5 Playable)
- Aren crosses into misty Briarwood, meets **Lyra**, repairs the collapsed **Old Bridge** (`LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`), aligns the **Mirror Grove** (`DAWN`, `ZENITH`, `DUSK`) using three forest inscriptions, ignites the **First Ancient Beacon**, and hears Elena's first memory echo pointing to Floodmill.

### Chapter 2: *The Drowned Village* (Floodmill Wetlands — Phase 3 Playable)
- Entering abandoned Floodmill, Aren and Lyra inspect the chiseled Census Stone, repair the **Old Watermill** (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`), drain the **Archive Causeway** via the **Canal Sluice Console** (`DIVERT`, `DRAIN`, `OPEN`), gather three surviving fragments inside the cutaway **Forgotten Archive**, reconstruct the **Master Village Ledger** (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`) proving Floodmill's thirty-six families were erased as a memory offering, rekindle the **Second Ancient Beacon**, witness Elena's second echo, and unlock the eastern pass toward **Ironwatch Keep**.

### Chapter 3: *The Keeper's Lie* (Ironwatch Keep — Phase 4 Playable)
- Reaching the basalt fortress, Aren and Lyra explore the ruined courtyard and cutaway Fortress Archives (proving the original sacrifice of thirty-six volunteers saved ten thousand citizens during a genuine catastrophe) and the Abandoned Barracks (proving later High Keepers concealed the beacon alternative and silently consumed border towns like Floodmill). After gathering three historical crest clues, solving the **Hall of Crests** puzzle (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`), and slipping through the **Shadowed Passage** past patrolling Shadow Sentinels, Aren confronts the **Last Bell Warden**, recovers Elena's Harmonic Lattice folio, restores the **Third Ancient Beacon**—linking Briarwood, Floodmill, and Ironwatch in harmonic resonance—and unseals the road to **Dawnspire**.

### Chapter 4: *The Road to Dawnspire* (Alpine Ascent)
- As the Veilstorm closes in and the 13th chime tolls faster, Aren and Lyra climb the shattered pilgrim switchbacks, piecing together Elena's final camp and map fragments.

### Final Chapter: *The Last Bell* (Dawnspire Mountain Summit)
- Channeling the unified triad light of the three Ancient Beacons alongside Lyra reveals Elena's final truth: she stayed behind in the Dawnspire Sanctum to hold the fracturing seal steady until someone worthy could align all three Beacons, shattering the memory-stealing pact and dispelling the Veilstorm cleanly so no one has to forget again.

---

## 5. Minigame Concepts

1. **Concentric Rune Alignment (Prologue — Implemented in Phase 1):**  
   Rotate three concentric carved stone rings (`Outer`, `Middle`, `Inner`) against a fixed zenith marker until the three symbols match clues discovered from villagers and Elena's letter (`MOON`, `SUN`, `STAR`). Supports mouse clicks and keyboard (`W/S` ring selection, `A/D` rotation, `E/Enter` confirm, `ESC` exit).
2. **Old Bridge Repair & Mirror Grove Alignment (Chapter 1 — Implemented in Phase 2):**  
   Sequential structural timber/rope assembly (`BridgeRepair`: `LEFT BEAM`, `RIGHT PLANK`, `ROPE LASHING`) and three-mirror solar beam triangulation (`MirrorPuzzle`: `DAWN`, `ZENITH`, `DUSK`).
3. **Watermill Gearbox, Canal Sluice Routing & Ledger Reconstruction (Chapter 2 — Implemented in Phase 3):**  
   `WatermillRepair` (`IRON DRIVE GEAR`, `BRONZE PINION`, `OAK COUPLING BELT`), `SluicePuzzle` (`DIVERT`, `DRAIN`, `OPEN` lowering water depth to `0` cubits), and `LedgerPuzzle` (`THIRTY-SIX HEARTHS`, `MEMORY OFFERING`, `IRONWATCH SEAL`).
4. **Hall of Crests & Shadowed Passage Stealth (Chapter 3 — Implemented in Phase 4):**  
   `CrestPuzzle` (`SILVER BELL`, `SUNDERED SHIELD`, `CROWNED FLAME`) and non-combat sentinel stealth in the **Shadowed Passage** with Ward Alcove checkpoints (`checkpoint_0`/`checkpoint_1`/`checkpoint_2`), warning indicators, and non-destructive reset.
5. **Dawnspire Ascent & Final Chime Sequence (Chapters 4–5):**  
   Harmonic Bell resonance and alpine beacon relays.

---

## 6. Quest & Progression Rules

- **Strict Ordering:** Prologue, Chapter 1, Chapter 2, and Chapter 3 objectives advance only sequentially via unique quest IDs; out-of-order interactions show diegetic locked feedback without bypassing progression.
- **No Repeat Farming / Exploits:** Unique story flags gate every NPC count (`talked_npcs`), item/part pickup (`materials_collected`, `mill_parts_collected`), archive/crest records (`archive_clues_found`, `crest_clues_found`), optional discoveries (`optional_discoveries`), and puzzle/chapter completion flags.
- **Stage-Aware World & Dialogue:** Talking to Bellhaven NPCs, traveling historian Lyra, and the Last Bell Warden updates dynamically across every story milestone, ensuring players never become soft-locked if they revisit clues.

---

## 7. Development Phases

- **Phase 0 (Completed):** Isometric pixel-art foundation in Bellhaven Village, Aren controller & sprite, pixel-snapped camera, collisions, and basic HUD.
- **Phase 1 (Completed):** Playable Prologue in Bellhaven Village (`data/prologue_quest.json`), NPC & dialogue system, Rune Puzzle, Mother's Letter, and Briarwood Waystone.
- **Phase 2 & 2.5 (Completed):** Briarwood Forest (`scenes/briarwood_forest.tscn`), Historian Lyra companion progression, `BridgeRepair` & `MirrorPuzzle`, First Ancient Beacon, Field Satchel (`InventoryPanel`), `TitleMenu`, cross-region save/resume (`SAVE_VERSION = 1`), and `.bak` recovery.
- **Phase 3 (Completed):** Floodmill Wetlands / The Drowned Village (`scenes/floodmill_village.tscn`), 5 isometric buildings including rotating Old Watermill and cutaway Forgotten Archive Hall, `WatermillRepair`, `SluicePuzzle`, `LedgerPuzzle`, Second Ancient Beacon, `SAVE_VERSION = 2` with `v1` compatibility, and Ironwatch Keep gate unlock.
- **Phase 4 (Completed):** Ironwatch Keep / The Keeper's Lie (`scenes/ironwatch_keep.tscn`), 6 fortress areas (Courtyard, Abandoned Barracks, cutaway Gothic Archives, Hall of Crests, Shadowed Passage stealth corridor, Warden's Chamber & Beacon Vault), `CrestPuzzle`, non-destructive `ShadowSentinel` stealth, Last Bell Warden confrontation, Elena's research, Third Ancient Beacon three-beacon connection, `SAVE_VERSION = 3` (`v1`/`v2` compatible), and Dawnspire Citadel Gate unlock.
- **Phase 4.5 (Completed — The Living World):** Cohesive art direction (`docs/ART_DIRECTION.md`), environmental storytelling and throttled (`12.5 Hz`) landscape ambience across all 4 regions, Ironwatch precipice extension, Aren idle breathing & timed footstep cadence, NPC 8-direction turn + dialogue badge, procedural PCM16 audio & 4-bus mixer (`AudioManager`, `default_bus_layout.tres`, `TitleMenu` sliders saved to `user://ashvale_audio_settings.json`), `CinematicDirector` skippable cinematics with `PixelCamera` focus & framing, `RegionBanner` + `TransitionFade`, and forward/backward regional entry poses.
- **Future Phases (Chapters 4–5):** Dawnspire Mountain ascent and Final Chapter climax with Elena & Great Bell resolution.
