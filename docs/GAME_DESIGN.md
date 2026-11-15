# ASHVALE: THE THIRTEENTH BELL — Game Design Document

> **Engine:** Godot 4.7.2 Standard (GL Compatibility, GDScript)  
> **Perspective:** Isometric 2.5D Pixel Art (640×360 native viewport, 2:1 diamond projection, integer scaling)  
> **Genre:** Medieval Fantasy Adventure, Exploration, Mystery, Story-Driven Puzzles  
> **Core Themes:** Memory, Sacrifice, Truth, and Hope  
> **Status:** Canonical Design Reference (Phase 1 — Playable Prologue Active)

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

2. **Briarwood Forest (Chapter 1)**
   - **Atmosphere:** Mist-shrouded old-growth woods choked with silver-barked briars, fallen survey markers, and mossy lantern shrines.
   - **Role:** Reunion with companion historian **Lyra**, waystone alignment, memory echoes of Elena's expedition, and trail toward the **First Ancient Beacon**.

3. **Floodmill Wetlands (Chapter 2)**
   - **Atmosphere:** Sunken watermills, reed-choked canals, half-submerged ruins known as the Drowned Village, and pale fog over dark water.
   - **Role:** Canal sluice and water-level routing puzzles culminating in igniting the **First Ancient Beacon** (or Second Beacon convergence—see Chapter flow below).

4. **Ironwatch Keep (Chapter 3)**
   - **Atmosphere:** Basalt fortress guarding the mountain pass, lit by iron braziers and patrolled by Wardens sworn to protect the Great Bell's secret.
   - **Role:** Confrontation with **Commander Vane** and the truth of *The Keeper's Lie*, forge locks, and the **Second Ancient Beacon**.

5. **Dawnspire Mountain & The Summit Sanctum (Chapter 4 & Final Chapter)**
   - **Atmosphere:** Wind-carved alpine switchbacks, frost-rimmed obelisks overlooking the churning Veilstorm, and the colossal Great Bell belfry.
   - **Role:** Ascent to Dawnspire, kindling the **Third Ancient Beacon**, discovering Elena's final sacrifice, and ending the Bell's curse.

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

- **Commander Vane (Keeper of Ironwatch — Chapter 3):**  
  Leader of Ironwatch Keep who concealed records of the Ancient Beacons out of terror that silencing the Great Bell would surrender Ashvale to the Veilstorm.

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

### Chapter 1: *Whispers of Briarwood* (Briarwood Forest)
- Aren crosses into misty Briarwood, meets **Lyra**, aligns fallen trail shrines using Elena's field journal, and uncovers the forest's hidden Beacon ante-chamber.

### Chapter 2: *The Drowned Village* (Floodmill Wetlands)
- Navigating sunken canals and forgotten homesteads, Aren and Lyra solve water-lock puzzles to reveal the submerged temple housing the **First Ancient Beacon** and restore its flame, returning long-lost childhood memories to Bellhaven.

### Chapter 3: *The Keeper's Lie* (Ironwatch Keep)
- Reaching the mountain fortress, Aren and Lyra confront **Commander Vane** and expose forged chronologies proving the Bell was never meant to be permanent. Solving Ironwatch's great foundry locks rekindles the **Second Ancient Beacon**.

### Chapter 4: *The Road to Dawnspire* (Alpine Ascent)
- As the Veilstorm closes in and the 13th chime tolls faster, Aren and Lyra climb the shattered pilgrim switchbacks, piecing together Elena's final camp and map fragments.

### Final Chapter: *The Last Bell* (Dawnspire Mountain Summit)
- Igniting the **Third Ancient Beacon** at the summit reveals Elena's final truth: she stayed behind in the Dawnspire Sanctum to hold the fracturing seal steady until someone worthy could align all three Beacons. Channeling the unified light of the Beacons alongside Lyra, Aren shatters the memory-stealing pact and dispels the Veilstorm cleanly. Lost memories flow back across every region, Elena's spirit finds peace as dawn breaks, and Ashvale wakes to a sunlit morning where no one has to forget again.

---

## 5. Minigame Concepts

1. **Concentric Rune Alignment (Prologue — Implemented in Phase 1):**  
   Rotate three concentric carved stone rings (`Outer`, `Middle`, `Inner`) against a fixed zenith marker until the three symbols match clues discovered from villagers and Elena's letter (`MOON`, `SUN`, `STAR`). Supports mouse clicks and keyboard (`W/S` ring selection, `A/D` rotation, `E/Enter` confirm, `ESC` exit).
2. **Waystone Triangulation & Canal Sluices (Chapters 1–2):**  
   Mapline tracing and water-gate routing puzzles.
3. **Bell Resonance & Forge Counterweights (Chapters 3–5):**  
   Harmonic chime-ripple sequences and brazier-beam alignment.

---

## 6. Quest & Progression Rules

- **Strict Ordering:** Prologue objectives (1 through 6) advance only sequentially via unique quest IDs; out-of-order interactions show diegetic locked feedback without bypassing progression.
- **No Repeat Farming / Exploits:** Unique story flags gate every NPC count (`talked_npcs` tracked per `npc_id`), letter pickup, and puzzle completion (`puzzle_solved` prevents re-triggering rewards).
- **Stage-Aware World & Dialogue:** Talking to Bellhaven NPCs updates dynamically as quest stages advance, ensuring players never become soft-locked if they revisit clues.

---

## 7. Development Phases

- **Phase 0 (Completed):** Isometric pixel-art foundation in Bellhaven Village, Aren controller & sprite, pixel-snapped camera, collisions, and basic HUD.
- **Phase 1 (Current Milestone — Playable Prologue):** Canonical story revision, reusable NPC & Dialogue System (`Master Caelen`, `Mira`, `Sister Elara`), data-driven `QuestManager` with 6 ordered objectives, **Rune-Alignment Minigame**, **Mother's Letter**, **Briarwood Waystone Gate**, environmental night lighting/idle animations, and `"PROLOGUE COMPLETE — THE THIRTEENTH TOLL"` ending sequence.
- **Phase 2:** Briarwood Forest & Floodmill Wetlands, companion Lyra following/dialogue, Chapter 1 & Chapter 2 quests.
- **Phase 3:** Ironwatch Keep, Commander Vane narrative arc, and Second Ancient Beacon.
- **Phase 4:** Dawnspire Mountain ascent, Third Beacon, Final Chapter cutscene, save/load persistence, and audio mix.
