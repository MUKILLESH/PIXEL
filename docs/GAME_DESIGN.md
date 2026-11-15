# ASHVALE: THE THIRTEENTH BELL — Game Design Document

> **Engine:** Godot 4.7.2 Standard (GL Compatibility, GDScript)  
> **Perspective:** Isometric 2.5D Pixel Art (640×360 native viewport, 2:1 diamond projection, integer scaling)  
> **Genre:** Medieval Fantasy Adventure, Exploration, Mystery, Story-Driven Puzzles  
> **Core Themes:** Memory, Sacrifice, Truth, and Hope  
> **Status:** Authoritative Design Reference (Phase 0 Active)  

---

## 1. Game Premise

For three centuries, the medieval kingdom of **Ashvale** has been sheltered from a supernatural tempest—the **Veilstorm**—by the sacred **Great Bell** atop **Dawnspire Mountain**. Every evening at dusk, the Great Bell tolls **twelve times**, knitting a silver ward across the horizon.

One night in **Bellhaven Village**, young apprentice mapmaker **Aren** hears the Great Bell toll a **thirteenth** time.

An ancient Stone Rune Pedestal in the village square awakens with an ominous warning: something beneath the kingdom is stirring. As Aren investigates across Ashvale, he uncovers the kingdom's buried secret: the Great Bell's protective ward does not run on faith or wind—it sustains itself by slowly **consuming the memories** of Ashvale's people. With the thirteenth chime, the ancient pact is fracturing, citizens are forgetting names and faces faster than ever, and the Veilstorm presses closer against the valley walls.

Aren must journey across five interconnected regions, rekindle **three Ancient Beacons** built before the Bell's pact, climb Dawnspire Mountain, and break the memory-consuming curse so Ashvale can face a true dawn without losing who they are.

---

## 2. World Regions

The kingdom of Ashvale spans **five regions**, traversed in a fixed chronological order as the story unfolds:

1. **Bellhaven Village (Phase 0 Starting Region)**
   - **Atmosphere:** Lantern-lit cobblestone square, warm candlelit cottage windows, forge embers, and cool night air beneath the valley rim.
   - **Landmarks:** Village Square, Cartographer's Cottage, Blacksmith Workshop, Modest Bell Tower (*Bellhaven Belfry*), Stone Well, and the Stone Rune Pedestal.
   - **Role:** Starting hub, prologue mystery, and base of Aren's cartography notes.

2. **Briarwood Forest**
   - **Atmosphere:** Mist-shrouded old-growth woods choked with silver-barked briars, fallen mile-markers, and lantern shrines.
   - **Landmarks:** Overgrown Surveyor's Trail, Hollow Sentinel Oak, Moss-Covered Boundary Gate.
   - **Role:** First wilderness expedition where memory-echoes linger in inscribed trail stones.

3. **Floodmill Wetlands**
   - **Atmosphere:** Sunken watermills, reed-choked canals, broken sluice bridges, and pale fog over dark water.
   - **Landmarks:** Old Millhouse, Sluiceway Locks, and the Drowned Sanctum housing the **First Ancient Beacon**.
   - **Role:** Environmental water-level and routing puzzles culminating in igniting Beacon I.

4. **Ironwatch Keep**
   - **Atmosphere:** Grim mountain-pass fortress carved into dark basalt, guarded by the Order of Bell-Wardens and lit by tall iron braziers.
   - **Landmarks:** Outer Gatehouse, Great Foundry Hall, Bell-Warden Archive, and the Spire Courtyard housing the **Second Ancient Beacon**.
   - **Role:** Political/moral confrontation over the Bell's true cost and mechanical forge puzzles for Beacon II.

5. **Dawnspire Mountain**
   - **Atmosphere:** Wind-carved alpine switchbacks, frost-rimmed rune pillars, and towering stone belfry overlooking the swirling Veilstorm.
   - **Landmarks:** Pilgrim Steps, Summit Sanctum (**Third Ancient Beacon**), and the **Great Bell Belfry**.
   - **Role:** Final ascent, beacon convergence, and the decisive finale.

---

## 3. Major Characters

- **Aren (Protagonist):**  
  A young apprentice mapmaker in Bellhaven Village. Dressed in a forest-green tunic, traveler's cloak, and leather scroll satchel, he carries a brass compass and field journal. Observant and stubbornly hopeful, he sketches landmarks to hold onto details even as others forget them.

- **Master Caelen:**  
  Bellhaven's elderly master cartographer and Aren's mentor. Decades of drawing Ashvale's borders have left gaps in his own recollection—his old maps remember places and names he can no longer speak aloud.

- **Mira the Blacksmith:**  
  Bellhaven's blunt, warm-hearted ironworker. Her forge stays lit past curfew; she recognizes the strange alloy of shards shaken loose by the thirteenth chime and aids Aren with tools and forge-lore.

- **Sister Elara:**  
  Keeper of the Bellhaven Belfry and village chronicler. She tends the local chime records and notices the first discrepancies in the historical ledgers.

- **Commander Vane:**  
  Stoic Lord Warden of Ironwatch Keep. Bound by an inherited vow to keep the Great Bell ringing at any cost, believing humanity cannot survive the Veilstorm without the Bell's sacrifice.

---

## 4. Chronological Chapters & Main Quests

Story progression follows a **strict linear sequence** of five chapters:

### Chapter I — *The Thirteenth Chime* (Bellhaven Village)
- **Premise:** At nightfall, the Great Bell tolls thirteen times. The Stone Rune Pedestal in Bellhaven Square ignites with a warning.
- **Main Quest:** *"Investigate the thirteenth bell."* -> Inspect the Stone Rune Pedestal, speak with Master Caelen and Mira, uncover an ancient sealed map fragment beneath the village belfry, and open the gate to Briarwood.

### Chapter II — *The Fading Trails* (Briarwood Forest)
- **Premise:** Citizens begin forgetting roads beyond the village wall. Aren follows Caelen's oldest survey chart through mist-choked Briarwood.
- **Main Quest:** Realign overgrown waystone markers using the Cartography Minigame to trace the forgotten road to the wetlands.

### Chapter III — *The Drowned Beacon* (Floodmill Wetlands)
- **Premise:** Aren discovers that the Kingdom once relied on three Ancient Beacons—not the Great Bell—to hold back the Veilstorm cleanly.
- **Main Quest:** Restore the Floodmill sluices, uncover records of the Founders' split, and relight the **First Ancient Beacon**.

### Chapter IV — *The Warden's Burden* (Ironwatch Keep)
- **Premise:** Commander Vane bars passage toward Dawnspire, fearing that breaking the Bell's pact will doom Ashvale.
- **Main Quest:** Uncover the suppressed Warden Chronicle proving the Beacons can replace the Bell, solve the Great Foundry Forge Lock, persuade or bypass Vane, and ignite the **Second Ancient Beacon**.

### Chapter V — *Dawn Without Forgetting* (Dawnspire Mountain)
- **Premise:** The thirteenth bell tolls louder as the seal fractures and the Veilstorm gathers at the summit.
- **Main Quest:** Ascend Dawnspire Mountain, kindle the **Third Ancient Beacon**, enter the Great Bell Belfry, and unmake the memory-binding pact.

---

## 5. Minigame Concepts

1. **Cartography & Rune Alignment:**  
   Aren compares weathered parchment fragments against physical stone rune rings, rotating concentric rings and connecting landmark lines to unlock hidden trails and ciphered pedestals.
2. **Bell Resonance Tuning:**  
   In belfries and beacon chambers, Aren strikes pitched bronze tuning bells in exact harmonic order shown by visual chime ripples to dispel memory-locks.
3. **Forge & Mechanism Locks:**  
   Spatial isometric puzzles involving waterwheel sluice gates (Floodmill), bellows/counterweight chains (Ironwatch), and mirror-brazier beams to channel beacon fire.

---

## 6. Story Progression Rules

- **Fixed Chronology:** Regions and chapters unlock strictly in order (I -> II -> III -> IV -> V); players can revisit earlier regions for lore, but story states never branch out of sequence.
- **Non-Lethal Adventure:** No hack-and-slash combat or permadeath; obstacles are environmental, spatial, social, and puzzle-driven.
- **Memory Anchors:** Restoring each Beacon returns a major lost memory to the kingdom, visibly warming the lighting and NPC dialogue in earlier regions.
- **Controls Consistency:** Normalized 8-way WASD movement, `E` to interact/advance, `ESC` to dismiss/pause.

---

## 7. Definite Final Ending

Upon igniting all three Ancient Beacons, their golden triangulation beam strikes the belfry of **Dawnspire Mountain**. Inside the Great Bell sanctum, Aren confronts the lingering Echo of the First Founder—who forged the Bell out of fear that no mortal vigilance could last forever.

Instead of silencing the sky in darkness, Aren channels the three Beacons' steady light to **unbind the memory-consuming ward**, shattering the Great Bell's curse without unleashing the storm. The Veilstorm breaks apart against the unified Beacons. Across Bellhaven, Briarwood, Floodmill, and Ironwatch, long-stolen memories rush back to the living—Master Caelen remembers his family's names, Mira recalls the songs of her youth—and for the first time in three centuries, **a true golden dawn rises over Ashvale**.

---

## 8. Development Phases

- **Phase 0 (Current Milestone):** Rebooted project foundation in **Bellhaven Village at night**. Preserves isometric 2:1 ground rendering, 8-way movement/walk animations, pixel-snapped camera, Y-sorting, collisions, and interaction HUD. Replaces all legacy sci-fi/campus content with medieval village art, Aren's fantasy attire, and the Stone Rune Pedestal opening interaction.
- **Phase 1:** Bellhaven interiors (Cartographer's Cottage & Blacksmith Workshop), NPC actors (Master Caelen, Mira, Sister Elara), and multi-line dialogue choices.
- **Phase 2:** Briarwood Forest & Floodmill Wetlands scenes, Cartography & Rune Alignment minigame, and First Ancient Beacon restoration.
- **Phase 3:** Ironwatch Keep scene, Bell Resonance Tuning & Forge Mechanism minigames, and Second Ancient Beacon restoration.
- **Phase 4:** Dawnspire Mountain finale, Third Ancient Beacon, Great Bell ending cutscene, save/load system, and full audio mix.
