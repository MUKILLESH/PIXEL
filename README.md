# ASHVALE: THE THIRTEENTH BELL — Phase 1 Story Prologue

**Playable Story Prologue: "The Thirteenth Toll" (Bellhaven Village)**

An isometric 2.5D pixel-art fantasy adventure built in **Godot 4.7.2 Standard (GDScript)**. See the canonical [Game Design Document](docs/GAME_DESIGN.md) for the full kingdom narrative across five regions, six chapters, companions, and long-term roadmap.

## Story Premise

In the kingdom of **Ashvale**, the enchanted Great Bell normally tolls twelve times to hold back the supernatural Veilstorm—quietly consuming villagers' memories in return. One night it strikes **thirteen times**. **Aren**, a young apprentice mapmaker in **Bellhaven Village** whose mother **Elena** vanished alongside historian **Lyra** while mapping three lost Ancient Beacons, must uncover why the pact is cracking and open the road toward **Briarwood Forest**.

## Play & Manual Playtest Walkthrough

1. Launch the project in **Godot 4.7.2** (`F5`, opens `scenes/sjt_exterior.tscn`) or run from PowerShell:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path .
```

2. **Controls:**
   - **Move:** `WASD` or Arrow Keys
   - **Interact / Advance Dialogue:** `E`
   - **Close Dialogue / Puzzle:** `ESC` (safely backs out without losing state or locking movement)
   - **Rune Pedestal Puzzle:** `W`/`S` (or `Up`/`Down` / click ring button) to select ring, `A`/`D` (or `Left`/`Right` / `<` `>`) to rotate symbol, `E`/`Enter` (or `[ ALIGN RUNES ]`) to test alignment, `ESC` (or `[ CLOSE ]`) to exit.
   - See [Validation](docs/VALIDATION.md) for automated test coverage and the remaining manual playtest checklist before Phase 2.

3. **Prologue Progression (Objectives 1–6):**
   - **Objective 1 (`investigate_bell`):** Walk to the glowing **Stone Rune Pedestal** on the eastern cobbles and press `E` to inspect the omen of the thirteenth chime.
   - **Objective 2 (`speak_npcs`):** Speak with all three villagers (**Master Caelen** near the belfry square, **Mira** outside the blacksmith hearth, and **Sister Elara** near the village well). Talking before inspecting the pedestal or repeating the same villager will not bypass the `0/3 -> 3/3` counter; each villager gives one ring clue and Caelen hands over the survey chest key.
   - **Objective 3 (`find_mothers_letter`):** Inspect Elena's highlighted **Sealed Survey Chest** beside the cottage door to read Mother's letter.
   - **Objective 4 (`solve_rune_puzzle`):** Return to the **Stone Rune Pedestal**, open the 3-ring alignment cipher, and set **OUTER RING: `MOON`**, **MIDDLE RING: `SUN`**, **INNER RING: `STAR`**.
   - **Objective 5 (`discover_briarwood_path`):** Follow the golden-cyan beacon ray southwest to the awakened **Briarwood Waystone** gate.
   - **Objective 6 (`trigger_prologue_completion`):** Read the closing revelation at the waystone and dismiss **`PROLOGUE COMPLETE — THE THIRTEENTH TOLL`** (`E` or `ESC`) to unlock **Briarwood Forest** for **Chapter 1: Whispers of Briarwood**, then freely explore Bellhaven to hear updated NPC dialogue.

## Validate & Capture

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_zone.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_phase1.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 300
```

Render verification screenshots (`tests/*.png`):
- `& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_sjt.gd`
- `& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture.gd`

Regenerate procedural tiles or bitmap font:
- `& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_tiles.gd`
- `& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_font.gd`

See [Game Design Document](docs/GAME_DESIGN.md), [Architecture](docs/ARCHITECTURE.md), [Validation](docs/VALIDATION.md), and [Files](docs/FILES.md).
