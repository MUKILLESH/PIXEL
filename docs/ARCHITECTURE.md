# Phase 0 Architecture — ASHVALE: THE THIRTEENTH BELL

The startup region is `scenes/sjt_exterior.tscn` (**BellhavenVillage**), preserving the proven Phase 1.5 isometric rendering, movement, camera, Y-sorting, collision, and priority-interaction pipeline while converting every visual asset, label, and prop to medieval fantasy. `scenes/campus_prototype.tscn` also inherits the updated medieval tiles, cottages, trees, Aren character sprite, rune pedestal, and HUD.

## Scene Ownership

```text
BellhavenVillage (scripts/world/sjt_region.gd)
├── Ground (TileMapLayer, res://assets/tiles/courtyard.tres)
├── Landscape (scripts/world/sjt_landscape.gd: cobbles, lantern pools, shadows)
├── Boundary (four solid diamond boundary segments)
├── Actors (y_sort_enabled = true)
│   ├── SJT (scenes/environment/sjt_building.tscn -> Cottage + Belfry + Blacksmith)
│   ├── Player (scenes/characters/player.tscn -> Aren, foot collider, PixelCamera)
│   ├── Terminal (scenes/environment/terminal.tscn -> Stone Rune Pedestal)
│   ├── NoticeBoard (scenes/environment/terminal.tscn -> Village Signpost)
│   └── Trees / Furnishings / Basin (Village Well) / Monument (Anvil Plinth)
└── HUD (scenes/ui/hud.tscn -> Objective, Chime status, Message panel)
```

## Movement, Projection & Depth

- **Projection:** 2:1 isometric `TileSet` (`TILE_SHAPE_ISOMETRIC`, `TILE_LAYOUT_DIAMOND_DOWN`, `64×32` cells). Screen movement uses normalized `Input.get_vector` in `CharacterBody2D` (`MOTION_MODE_FLOATING`) at 100 px/s.
- **Y-Sorting:** `Actors` sorts every child by its base/foot origin. The multi-bay northern village row (`sjt_building.gd`) renders each 16-unit bay at its own ground line so Aren passes cleanly in front of and behind adjacent structures and beneath the belfry porch canopy.
- **Collisions:** Layer 1 holds solid building footprints, well/anvil/furnishing footprints, tree trunks, and diamond boundary edges; Layer 2 holds Aren's `CircleShape2D` foot collider (radius 6).

## Camera & Presentation

- `scripts/characters/pixel_camera.gd` detaches (`top_level = true`), runs after player physics (`process_physics_priority = 10`), exponentially eases toward `target + framing`, and rounds only the final display coordinate to integer pixels.
- All pixel art uses `default_texture_filter = 0` and integer viewport scaling (`640×360` -> `1280×720`).
- UI uses the original 5×7 bitmap font (`assets/fonts/after_hours.tres`) via `assets/fonts/pixel_theme.tres`.

## Interaction

- All `StaticBody2D` interactables in group `"interactables"` track player proximity via `Area2D` (`Range`).
- `scripts/ui/hud.gd` evaluates overlapping interactables each frame by `(priority, -distance, node_path)` so at most one world prompt (`[E] INSPECT RUNE PEDESTAL` or `[E] READ VILLAGE POST`) is shown at a time.
- Opening a message locks `player.movement_locked`, hides world prompts, and consumes `interact` / `dismiss` (`E` / `ESC`) cleanly to close.

## Future Phases (See `docs/GAME_DESIGN.md`)

- **Phase 1:** Bellhaven interiors, NPCs (Master Caelen, Mira, Sister Elara), multi-line dialogue data under `data/`.
- **Phase 2–4:** Briarwood Forest, Floodmill Wetlands, Ironwatch Keep, Dawnspire Mountain, minigames, and save/load.
