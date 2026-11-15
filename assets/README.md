# Placeholder assets

`tiles/courtyard.png` and `tiles/courtyard.tres` are original procedural placeholders created by `scripts/tools/generate_tiles.gd`. The TileSet embeds the same image. Characters, trees, buildings, and terminal art are drawn with Godot primitives in their scripts. No third-party artwork or font files are required; text uses Godot's fallback font.

Phase 1.5 adds six ground variants and an original bitmap alphabet in `fonts/`. Its self-contained FontFile resource is now the shared UI font; the HUD no longer uses Godot's fallback font. Regenerate it with `scripts/tools/generate_font.gd`. The `.fnt` and PNG are retained as editable source outputs. The font uses uppercase forms for both cases.

The existing audio and sprites directories are preserved for future phases.
