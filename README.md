# ASHVALE: THE THIRTEENTH BELL — Phase 0

**Phase 0 Medieval Fantasy Prototype (Bellhaven Village)**

An isometric 2.5D pixel-art adventure built in **Godot 4.7.2 Standard (GDScript)** with original procedural pixel-art assets and a warm nocturnal village atmosphere. See the authoritative [Game Design Document](docs/GAME_DESIGN.md) for the full narrative arc, five regions, characters, minigame concepts, and development phases.

## Play

1. Launch `Godot_v4.7.2-stable_win64.exe` from this folder.
2. Open `project.godot` and press **F5** (starts in Bellhaven Village Square, `scenes/sjt_exterior.tscn`).
3. Use **WASD** to explore the village square, cottage, blacksmith workshop, belfry porch, lanterns, and well.
4. Approach the glowing **Stone Rune Pedestal** near the belfry square and press **E** to read the opening message. Press **E** or **Escape** to close it.

From PowerShell:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path .
```

The game runs at 640×360 internal resolution, 1280×720 initial window, Compatibility rendering, nearest-neighbor filtering, integer viewport scaling, and 60 Hz physics.

## Phase 0 Included Features

- **2:1 Isometric World:** 64×32 medieval night-meadow grass and weathered cobblestone tiles (`assets/tiles/courtyard.tres`) with a full scenery apron covering every camera boundary.
- **Bellhaven Village Square:** Timber-and-plaster Cottage, central **Bellhaven Belfry** (stone bell tower with visible hanging bronze bell and timber porch canopy), **Blacksmith Workshop** with glowing forge embers, stone village well, iron anvil plinth, oak benches, wrought-iron street lanterns, herb planters, barrels, and medieval trees.
- **Protagonist (Aren):** Apprentice mapmaker in forest-green tunic, russet cloak, boots, and leather scroll satchel with 8-way facing, 4-frame walk cycle, foot collisions, Y-sorting, and a pixel-snapped follow camera.
- **Opening Interaction:** Priority-selected `[E] INSPECT RUNE PEDESTAL` prompt opening the message: *"The bell has rung thirteen times. Something beneath the village is awakening."* plus a nearby village signpost.
- **Minimal Medieval HUD:** Displays game title, current location (`BELLHAVEN VILLAGE`), chime indicator (`13TH CHIME`), and current objective (`Investigate the thirteenth bell.`).

## Validate

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_zone.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 300
```

Regenerate procedural tiles or bitmap font with:
- `--headless --path . --script res://scripts/tools/generate_tiles.gd`
- `--headless --path . --script res://scripts/tools/generate_font.gd`

See [Game Design Document](docs/GAME_DESIGN.md), [Architecture](docs/ARCHITECTURE.md), [Validation](docs/VALIDATION.md), and [Files](docs/FILES.md).
