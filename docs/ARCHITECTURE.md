# Phase 1.5 architecture

The new startup region is `scenes/sjt_exterior.tscn`; the original courtyard structure below is preserved. SJT composes the same player, camera, HUD, terminal and tiles. Its reusable building splits rendering into facade bays plus a roof/flank, canopy and columns; `sjt_region.gd` owns the local layout. See [SJT implementation](SJT_IMPLEMENTATION.md).

## Scene ownership

```text
CampusPrototype (campus.gd: deterministic layout and wiring)
├── Ground (TileMapLayer, external courtyard.tres)
├── Shadows (ground-only cast shadows and visible border)
├── Boundary (four solid diamond edges)
├── Actors (Y sorting enabled)
│   ├── Player (CharacterBody2D, foot collider, Camera2D)
│   ├── Terminal (StaticBody2D, Area2D range, indicator)
│   └── Buildings / trees (StaticBody2D, generated footprint and art)
└── HUD (CanvasLayer, controls and dismissible message)
```

`assets/` holds original generated tiles and reserved art/audio/font folders. `scenes/` contains composition and reusable scenes. `scripts/` contains behavior, `data/` reserves future definitions, `docs/` explains the design, and `tests/` owns validation.

## Movement, projection, and depth

Ground uses a 2:1 isometric TileSet with diamond-down layout and 64 × 32 cells. Screen coordinates are ordinary 2D pixels; WASD is not rotated into grid axes. `Input.get_vector` caps diagonal magnitude at one. The floating CharacterBody2D moves only during physics ticks using `move_and_slide`. Speed is exported in pixels/second, default 100.

The player origin is at the feet. Building origins sit at their front footprint tips; tree and terminal origins sit at their bases. Every actor shares one Y-sorted parent and default Z index. Ground is drawn first outside this sorting group. Roofs and canopies rise above the sorting anchor. This simple whole-object sorting is suitable for the prototype's separated props; future large or intersecting buildings may need split facades/roof pieces.

Physics layer 1 is world solids; layer 2 is the player. The player checks layer 1. The terminal Area2D checks layer 2 and accepts only members of `player`. Building polygons match their isometric ground footprint; trees block their trunks rather than their entire canopy. Four segments prevent leaving the map.

## Camera and presentation

Camera2D belongs to the reusable player at zoom 1 and framing (0, -64), but its top-level transform is independent. `pixel_camera.gd` updates after player physics movement, eases a floating-point focus exponentially, and rounds only the final display position. Built-in fractional smoothing is disabled. `snap_to_target()` resets follow state on teleport. Nearest filtering and integer viewport scaling retain crisp artwork. The ground now extends to 49 × 49 cells, covering every camera corner at the original playable diamond's extremes. A visible stone edge follows the preserved boundary colliders.

The player uses native-pixel drawing, eight facings and four walking poses driven by real movement. Props use local drawing primitives; cast shadows occupy a separate layer below all actors. The tile generator uses Godot Image and ResourceSaver only; the saved TileSet embeds its six-variant image. The font generator similarly embeds original 5×7 glyph data in a FontFile resource, avoiding first-import dependencies. Source PNG and BMFont outputs are retained. The shared HUD theme uses native 8px or integer 16px text.

## Interaction

The reusable terminal owns its range, prompt, exported message, and dialogue-open guard. A non-repeating E press emits `message_requested`; the world connects this to the HUD. Proximity changes update the HUD prompt. The HUD locks player movement while reading, hides prompts, updates the objective, and consumes E/Escape before the terminal can reopen. No autoload or dialogue framework is needed for this single interaction.

## Later phases (not implemented)

- Campus regions: turn each region into a scene with the same ground/actor structure.
- NPCs: add reusable actors under the region's sorting parent.
- Dialogue and quests: keep definitions under `data/`; replace the terminal's one-message handler when required.
- Inventory and save/load: introduce explicit state and a save schema when gameplay needs them.
- Day/night: introduce a clock that drives presentation; the present 11:47 PM label is static.
- ECHO: design alternate region content and state transitions in a later phase.

No external campus sources were accessed. Official references in the original brief remain future research inputs, subject to the user's asset-use approval.
