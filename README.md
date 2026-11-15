# VIT: After Hours — Phase 1.5

**Latest SJT zone polish:** one priority-selected world prompt, a smaller persistent HUD, higher-contrast player artwork, and decorative benches, lights, planting and a walkable seating loop. [Changes, reference accuracy and validation](docs/SJT_ZONE_POLISH.md).

**Current startup: SJT exterior.** F5 now opens the photograph-informed, compressed SJT region. Open `scenes/sjt_exterior.tscn` for F6. The original courtyard remains available at `scenes/campus_prototype.tscn`; all Phase 1.5 systems are preserved. See [asset plan and missing references](docs/SJT_ASSET_PLAN.md) and [SJT implementation/validation](docs/SJT_IMPLEMENTATION.md). SJT uses original procedural art, not redistributed photographs.

A small, playable Godot 4.7.2 Standard / GDScript foundation. This fictional college courtyard is a placeholder study, **not an accurate VIT campus map**. No external assets, packages, or dependencies were downloaded.

## Play

1. Launch `Godot_v4.7.2-stable_win64.exe` from this folder.
2. Import `project.godot` and open the project.
3. Press **F5**, or open `scenes/campus_prototype.tscn` and press **F6**.
4. Use **WASD** to walk. Approach the cyan terminal just above/right of spawn; **E** reads it. **E** or **Escape** dismisses the message.

From PowerShell in `D:\MUKI PROJECT\VIT_After_Hours`:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path .
```

The game uses Compatibility rendering, 640 × 360 internal resolution, a 1280 × 720 initial window, nearest filtering, and integer viewport scaling. Black margins at some window sizes are intentional. Physics and the frame cap target 60 Hz/FPS.

## Included

- 2,401 isometric 64 × 32 tiles: the original courtyard plus a scenery apron that covers the camera at every boundary.
- Reusable player and terminal scenes, two buildings, eight trees, and solid map edges.
- Normalized screen-relative movement, eight-way facing, four walking poses, foot collisions, Y sorting, and a smooth pixel-snapped follow camera.
- One introductory message; no quests, inventory, NPCs, saving, clock progression, or ECHO systems yet.

The map and props are assembled when the scene runs. The editor's static 2D view shows the player and terminal; run F6 to inspect the complete courtyard. Tune `speed` on the player or edit positions in `scripts/world/campus.gd`.

## Validate

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 300
```

Optional graphical captures: `--path . --script res://tests/capture.gd`. This writes `tests/courtyard_preview.png` and `tests/terminal_preview.png` and exits. Regenerate original ground artwork using `--headless --path . --script res://scripts/tools/generate_tiles.gd`, then reimport.

See [architecture](docs/ARCHITECTURE.md), [validation](docs/VALIDATION.md), and [file summary](docs/FILES.md).

## Phase 1.5 polish

The collision layout and controls are preserved. Grass and paving have six variants; trees have layered canopies, and buildings have framed doors, windows, roof details, steps, and ground shadows. A visible stone edge marks the playable boundary.

The student has a 39-pixel silhouette with a backpack, ID card, arm swing, foot motion, and a stationary ground shadow. The camera eases at 60 Hz and snaps its final displayed position to whole pixels. One-pixel stepping is intentional for crisp rendering.

The HUD uses an original local bitmap font at native/integer sizes, shared margins, objective text, nearby prompts, and a guarded dialogue panel. Resize letterboxing outside the game viewport is intentional; there are no empty black areas inside the courtyard viewport.

See [Phase 1.5 results](docs/PHASE_1_5.md). No dependencies or external assets were added. The capture script also produces boundary, character-pose, and resized-UI evidence.
