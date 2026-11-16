# Player Guide — ASHVALE: THE THIRTEENTH BELL (v1.0.0)

## Getting Started

1. **System Requirements:** Windows x86_64 with OpenGL 3.3+ graphics support (`1280x720` default window scaled cleanly in integer increments from `640x360` pixel art).
2. **Launching the Game:**
   - **Standalone Executable (after exporting with Godot 4.7.2 Windows templates):** Double-click `ASHVALE.exe` in `dist/ASHVALE-Windows/`.
   - **Packaged Data Launch:** Run `Godot_v4.7.2-stable_win64.exe --main-pack dist/ASHVALE-Windows/ASHVALE.pck` (or from `dist/ASHVALE-Windows/` directly).

---

## Controls

| Action | Keys / Input |
| :--- | :--- |
| **Move Aren** | `W` `A` `S` `D` or `Arrow Keys` (8 directions) |
| **Interact / Advance Dialogue / Confirm** | `E`, `Enter`, or `Space` |
| **Cancel / Back / Close UI** | `Esc` |
| **System Menu** (New Game, Continue, Save, Satchel, Audio, Quit) | `M` or `F10` |
| **Field Satchel** (Clues, Items, Relics) | `I` or `Tab` |
| **Quick Save Progress** | `F5` |
| **Toggle Fullscreen / Windowed** | `F11` |
| **Skip Story Cinematic** | `X` |
| **Inside Minigames** | `W`/`S` (or `Up`/`Down`) selects slot/ring; `A`/`D` (or `Left`/`Right`) cycles values; `E`/`Enter` confirms; `Esc` exits; or click UI buttons with mouse |

---

## Saving, Loading & Post-Game Exploration

- **Save File:** Written atomically (`user://ashvale_save.json` with `.bak` backup rotation) inside:  
  `%APPDATA%\Godot\app_userdata\ASHVALE- THE THIRTEENTH BELL\`
- **Audio Settings:** Saved independently in `ashvale_audio_settings.json` so adjusting volumes never touches story progress.
- **Post-Game Continue:** Completing Chapter 5 and viewing the credits saves a stable post-game state (`storm_resolved = true`, `chapter5_completed = true`). Choosing **Continue Saved Game** afterward places Aren back into free post-game exploration (at the Dawn Terrace or Sunrise Bellhaven) without trapping you in a repeating ending loop.
- **Starting Over:** Choose **New Game** inside the System Menu (`M` -> `NEW GAME`) to begin cleanly in Bellhaven Prologue with zero leftover completion flags.

---

## Tips for Exploring Ashvale

- **Follow the Objective Banner:** Your active goal sits at the bottom-left HUD (`Chapter 5 Complete - Ashvale Remembered.` once finished).
- **Check Your Field Satchel (`I`):** Recovered letters, cipher clues, bridge components, and optional remembrances are logged chronologically per chapter.
- **Non-Destructive Hazards:** Getting spotted in Ironwatch's **Shadowed Passage** or losing footing on Dawnspire's **Whispering Cliffs** returns Aren safely to the most recent illuminated Ward Alcove or Wind Shelter Cairn without losing items or clues.
- **Skippable Cinematics Without Loss:** Pressing `X` during any story sequence cleanly restores camera control and completes the corresponding beat.
