# GFX-1 — Bellhaven visual overhaul

## Recovery and scope

Starting release: `8359e3b`. Recoverable pre-upgrade checkpoint: `ba77d7a`, which also preserves the two project/export configuration edits already present when work began. No existing local changes were discarded.

This overhaul affects Bellhaven presentation only. The other regions continue using the original shared tree and tile assets. No story, dialogue, quest, inventory, movement, interaction ranges, collision geometry, NPC placement, chapter transition, save data or version migration code was edited. Save versions 1–5 keep their existing implementation; this pass does not claim a fresh full migration-suite run.

## Graphics changes

- Belfry: individual masonry courses, alternating stones, chipped edges, brighter quoins, tiled slate spire, stronger full bronze bell inside a stone arch, warm wall lanterns and tiny localized magical flecks.
- Cottage: patterned terracotta shingles, ridge caps, overhang shadows, side/front timber braces and pegs, shutters, lit panes, planked door hardware and brick chimney courses.
- Workshop: slate tile rows, chimney brickwork, ember opening, separate anvil/tool stand, quench barrel and stacked logs.
- Ground: six original region-local meadow textures with coherent clusters instead of noise; deterministic cobbles, edge soil/moss marks, small weeds and flower accents. Existing roads, footprints and routes are retained.
- Trees: Bellhaven-only subclass retains original trunk colliders while replacing canopies with varied stepped silhouettes, layered green masses, highlights, shaded undersides, branching trunks and roots.
- Village dressing: non-blocking market awning, crates/barrels, log piles and fenced garden patches. Decorations use feet-origin sorting and stay away from important interaction positions.
- Atmosphere: a few chimney smoke clusters, restrained motes and fountain glints at 8 Hz. Existing lantern pools, awakened pedestal beam and sunrise state remain supported.

Static ground detail is now a separate cached CanvasItem. Static buildings, trees and scenery generate their draw commands once; only the small atmospheric and story-state effect layers redraw periodically. No plugins, external assets, downloaded scripts or new dependencies were used. All new art is original local GDScript geometry or generated pixel textures.

## Matching comparison

`before.png` and `after.png` use the same 640×360 internal viewport, player position `(10,70)`, camera framing `(0,-96)`, fresh prologue state, and existing HUD. `before_overview.png` and `after_overview.png` use the same 960×540 review viewport. Ambient animation can differ slightly with timing; story state is identical. No gameplay save is read or written by the capture tool.

Capture command:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_gfx1.gd --quit-after 600
```

Use `-- --before` only on the checkpoint to regenerate the original comparison. The review files are excluded from Godot imports/exports with `.gdignore`.

## Validation

All executions were bounded and logs inspected for script/runtime errors:

| Check | Result |
|---|---|
| Godot import | Succeeded |
| `tests/validate.gd` | 63 checks, 0 failures |
| `tests/validate_sjt.gd` | 39 checks, 0 failures |
| `tests/validate_zone.gd` | 71 checks, 0 failures |
| `tests/validate_phase1.gd` | 77 checks, 0 failures |
| `tests/validate_gfx1.gd` | All 7 essential interactions reachable; 1,685 cells explored |
| Default startup smoke | 300 frames, no script/runtime errors |
| Graphical review | Native-scale and overview images inspected; UI and NPCs remain distinct |

The new reachability check uses the player's unchanged 6px collision radius against real world physics and reaches the Rune Pedestal, village post, Caelen, Mira, Elara, Mother's Letter chest and Briarwood Waystone. Existing focused tests also exercise prologue dialogue and puzzle progression.

An initial typed-array assignment error in the new palette helpers was caught during graphical validation and fixed before the final clean runs. No unresolved runtime errors were observed.

## Performance and remaining limits

Measured on the installed NVIDIA RTX 4050 / OpenGL Compatibility renderer after four seconds of warm-up: 240 stationary rendered frames at 640×360, mean **16.67 ms**, p95 **16.81 ms**, maximum **17.14 ms**, with the existing 60 FPS cap. This is a short local observation, not a traversal stress test or a guarantee for other hardware.

The composition and scale are deliberately unchanged. Some repeated masonry/cobble patterns remain visible; distant meadow space remains sparse. The existing long belfry name plaque follows the inherited roof placement. Smoke is intentionally faint and the tiny belfry accents are subtle. A full manual camera/occlusion sweep and whole-game visual review were not performed; no changes were made to other chapters to justify a whole-game suite. The shipped Windows executable was not rebuilt—run the updated project with F5.

## Source files

Modified: `sjt_art.gd`, `sjt_landscape.gd`, and small visual-only setup additions in `sjt_region.gd`.

New: Bellhaven-specific ground/tree/decor/air renderers, `generate_bellhaven_tiles.gd`, six-tile meadow atlas and TileSet, repeatable capture and reachability scripts, and these review artifacts. Collision and building scene files remain unchanged.
