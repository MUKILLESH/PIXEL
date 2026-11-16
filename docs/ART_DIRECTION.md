# Art Direction Guide — ASHVALE: THE THIRTEENTH BELL

## 1. Core Visual Identity
**ASHVALE: THE THIRTEENTH BELL** uses an atmospheric, restrained **2.5D Isometric Pixel-Art** aesthetic designed around crisp silhouettes, clear interactive readability, and cohesive environmental storytelling across a connected medieval kingdom.

- **Base Resolution & Scaling:** Native `640x360` pixel canvas scaled at integer multiples (`1280x720` default window) with nearest-neighbor texture filtering (`CanvasItem.texture_filter = TEXTURE_FILTER_NEAREST`) and pixel-snapped camera scrolling (`Camera2D.global_position = focus.round()`).
- **Isometric Projection:** 2:1 diamond terrain tiles (`64x32` px in `assets/tiles/courtyard.tres`) paired with feet-origin `y_sort_enabled` actor containers so characters pass naturally behind taller rooftops and in front of south-facing facades.
- **Character-to-Building Scale:**
  - Humanoid sprites (`Aren` and NPCs): ~`12px` wide by `38–42px` tall (`4–6px` foot shadow base), wearing high-contrast dark ink outlines (`#161924`) so protagonists remain legible over every terrain surface.
  - Architecture: Doors sit `~24–30px` tall; cottages rise `56–84px`; bell towers and fortress bastions rise `96–128px`.
- **Lighting & Effects Restraint:** Avoid full-screen post-processing blur or heavy additive bloom that washes out pixel boundaries. Communicate light using stepped translucent polygons, concentric soft glow rings, warm ember flecks, sparse fireflies, and subtle drifting fog bands.
- **UI & Typography:** Compact frames (`1px–2px` antique gold borders `#c79e5c` on deep slate `#0f0d14`) using the 8px `after_hours.tres` bitmap font with 1px dark drop shadows. World interaction prompts appear only above the currently selected interactable to keep exploration uncluttered.

---

## 2. Regional Palettes & Material Language

### Bellhaven Village (Prologue — *The Thirteenth Toll*)
- **Mood:** Warm, lived-in twilight sanctuary threatened by an ominous thirteenth bell stroke.
- **Palette:** Warm cobble taupe (`#5e554c`, `#433e39`), timber beam brown (`#6e472b`), slate belfry roofs (`#4a5466`), amber lantern pools (`#f5b856`), blacksmith forge embers (`#ff7a29`), and meadow clover greens (`#375740`).
- **Details:** Glowing cottage panes, anvil and bellows beside Mira's forge, wooden market crates and grain sacks around the square, weatherworn notice board, stone cistern water shimmer, and cyan-gold rune sparks around the awakened Pedestal.

### Briarwood Forest (Chapter 1 — *Whispers of Briarwood*)
- **Mood:** Lush, ancient woodland reclaiming forgotten shrines beside a mountain creek.
- **Palette:** Deep pine & fern greens (`#28382f`, `#2f693e`, `#4a5750`), damp earth trails (`#4f4334`), cool turquoise stream waters (`#1e5066`, `#67b5cc`), campfire ember orange (`#ff9e3b`), and cyan-gold arcane reflections (`#8be6f0`, `#f7e49e`).
- **Details:** Gently swaying forest ferns, weathered wooden fork signposts, mossy fallen logs, forgotten wayside stone shrines, animated creek ripples, flickering campfire glow, floating golden-lime fireflies, and harmonic light beams across Mirror Grove.

### Floodmill Wetlands (Chapter 2 — *The Drowned Village*)
- **Mood:** Quiet grief — a damp, half-submerged parish scrubbed from royal maps and memories.
- **Palette:** Muted storm slate-gray (`#3b474a`, `#4f5856`), rain-soaked stone (`#626b67`), deep marsh teal (`#163e4f`, `#215a70`), wet moss olive, warm archival candle pools (`#ebae4b`), and pale spectral mist (`rgba(0.75, 0.88, 0.94, 0.08)`).
- **Details:** Reflective rain puddles, rotating waterwheel and tailrace froth, swaying canal reeds, half-submerged cart wheels, broken cottages, scattered clay jugs & washbasins belonging to the thirty-six erased families, and drifting valley fog.

### Ironwatch Keep (Chapter 3 — *The Keeper's Lie*)
- **Mood:** Foreboding mountain fortress of the Bell Wardens guarding dark secrets behind basalt walls and violet wards.
- **Palette:** Obsidian & basalt blue-gray (`#12131c`, `#282c3a`, `#43495e`), aged crimson-violet Warden slate (`#4a3654`, `#3b2759`), antique brass (`#d9a94e`), warm orange torch pools (`#ff9e42`), cyan Ward Alcoves (`#8be6f0`), and spectral sentinel crimson (`#ff5c7c`).
- **Details:** Crenellated basalt towers, ringed Warden statues, discarded barracks shields and spears, worn crimson/gold banners, cracked battlement stonework, flickering wall torches, Gothic lancet stained glass inside the cutaway Archives, glowing Safe Alcoves in the Shadowed Passage, and converging three-beacon harmonic rays.
