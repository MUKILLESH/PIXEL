# Phase 0 Validation — ASHVALE: THE THIRTEENTH BELL

## Automated Headless Checks

Run the full verification suite after generating tiles/fonts and importing:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_tiles.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_font.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_zone.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 300
```

## Graphical Captures

Generate and inspect rendered screenshots:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture.gd
```

## Covered Guarantees

- All scenes and GDScripts parse and load without missing resources or script errors.
- 2,401 isometric 64×32 tiles cover the Bellhaven Village Square and camera margins at all 4 diamond boundary extremes.
- Aren moves cleanly in all 8 directions with normalized diagonal speed, 4-frame walk animations, zero drift on release, and integer-snapped camera tracking.
- Solid building footprints, timber porch columns, Village Well, Anvil Plinth, trees, and village furnishings block penetration while permitting diagonal wall sliding.
- Priority-based world prompt shows `[E] INSPECT RUNE PEDESTAL`, opens `"The bell has rung thirteen times. Something beneath the village is awakening."`, locks movement while open, ignores key repeat, and closes cleanly on `E` or `ESC`.
