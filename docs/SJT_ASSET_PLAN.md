# SJT exterior — visual asset plan

Historical initial plan. The current map file has since been replaced by `VIT Vellore Campus Map Infographic.png`; its labels differ. See [the zone-polish reference audit](SJT_ZONE_POLISH.md) for the latest evidence and the list of explicitly decorative additions.

Prepared 16 November 2026, before implementation. Source material: five user-supplied photographs in `docs/references/sjt/` and `docs/references/MAP/map.jpeg`. These are reference-only inputs, excluded from Godot's resource import by `.gdignore`. No photograph or map pixels will be used in game assets.

## Observed features and evidence

| Feature | Evidence | Interpretation |
|---|---|---|
| Broad multi-storey block, pale cream/off-white walls | All five photographs | Preserve a broad, stepped rectangular silhouette; compress bay spacing and height |
| Dense repeated horizontal window groups with dark panes and pale dividers | Front screenshot and both front JPGs | Draw repeated paired/tripled dark windows; retain rhythm rather than claim an exact count |
| Central grey/silver cladding with a taller dark inverted-U frame | Front screenshot, SJT elevated view, side elevated view | Strong central identifying motif extending over several floors |
| Large flat projecting entrance canopy on columns | All front views | Grey fascia, visible supports, shaded approach; traversable forecourt under the canopy |
| Wide slatted/pergola-like roof structures at centre and corners | Front-side JPG and elevated JPG | Preserve open slats, supports, stepped roof height; no invented roof machinery |
| White roof-level enclosures | Elevated angle and side elevated views | Simplify as plain low blocks; uncertain services omitted |
| External dark stair structure on one flank | Elevated angle and side elevated views | A dark braced stair strip on the visible left flank; approximate geometry only |
| Lawn, red walking surfaces, trees, curved shallow water feature, monument | Front screenshot and elevated views | Compressed forecourt with lawn, original curved basin outline and abstract monument silhouette |
| Building name near roof | Front views | Code-native label, not copied photograph lettering |

The photographs differ in lighting, perspective, tree cover and apparent age. Exact colours are not calibrated; the game will use the existing muted night palette. Window/floor counts, dimensions, doors and landscaping positions are not surveyed.

## Missing angles / unresolved details

- Clear rear elevation and rear ground-floor circulation.
- Unobstructed opposite flank and corner connections.
- Close-up beneath the entrance canopy: actual doors, steps/ramps, signage and column spacing.
- Roof plan confirming enclosure placement, slat depth and hidden structures.
- Current ground-level landscape plan and detailed monument/water-feature geometry.
- A north arrow / surveyed scale and verified building-entrance orientation for the supplied map.

These gaps do not prevent a front-focused exterior. Hidden faces stay plain and are explicitly approximate. The entrance ends at the building footprint; no invented accessible interior. The monument is an abstract silhouette, not a reconstruction of its inscription.

## Relative geography

Use map-image coordinates, not assumed compass directions: SJT sits above SJT Ground; VIT Lake is lower-left; PRP is to the right; a rail corridor lies above SJT. Preserve an open ground below the building and an approach route to the right. The lower-left route is labelled as the direction of the lake, but the lake and PRP themselves are not built in this small scene. Roads bend and distances compress for playability. The building is rotated for isometric readability; no claim of exact compass orientation.

## Visual design / asset manifest

| Asset | Native treatment | Anchor / collision | Provenance |
|---|---|---|---|
| SJT mass and facade | Original Godot integer-pixel polygons, 2:1 projected axes; cream, grey, dark blue glazing | Front-most footprint anchor; solid polygon | Authored procedural interpretation from supplied references |
| Entrance canopy | Separate roof and slender columns, same palette | Columns solid; player can walk beneath; roof drawn above occupants | Original geometry, approximate dimensions |
| Roof slats, windows and braced flank | Native drawing, no smoothing, reduced bay count | Part of building silhouette | Original code; observed motifs, simplified placement |
| Forecourt paving and lawn | Existing 64×32 tiles plus original red path overlays | Ground layer; walkable | Existing locally generated assets |
| Basin / monument / planting | Original isometric silhouettes and shrub clusters | Small footprint colliders | Photo-inspired motif, layout compressed |
| Student / terminal / HUD | Existing Phase 1.5 scenes | Existing behavior retained | Existing local art and code |

Target: 640×360 viewport, 1280×720 window, zoom 1, nearest filtering, no new dependencies. Use the existing cream highlights, cool grey shaded sides, muted foliage and cyan terminal. Strong silhouette and readable central portal take priority over micro-detail. Night lighting is stylized, not a real lighting survey.

## Implementation and review target

Create `scenes/sjt_exterior.tscn` as a separate region, retaining `campus_prototype.tscn` intact for F6/regression checks. Make the SJT scene the startup exterior. Reuse the player, smooth camera, terminal, HUD, tile resources and tree implementation. A small scene-specific layout owns paths and geography; the building is a reusable scene. No NPC, quest, inventory or interior systems.

Validate import/compile, the existing Phase 1.5 suite, SJT spawn and footprint collisions, walkable entrance route, canopy supports, terminal dialogue, map-edge coverage and references. Inspect native-scale renders from the forecourt and near the entrance. Record simplifications and remaining reference gaps in the delivery notes.

## Implemented visual target

The original procedural interpretation and compressed forecourt are shown below. This review render contains no source-photo pixels. See [implementation and validation](SJT_IMPLEMENTATION.md) and `assets/sjt_manifest.json` for provenance and results.

![SJT exterior and compressed front landscape](../tests/sjt_overview.png)
