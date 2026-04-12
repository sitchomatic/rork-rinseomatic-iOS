# Part 2 of 3 — Stability foundation with new Nick / Poli main menu control

## Features

- Replace the current profile picker on the main menu with a dramatic straight split **NICK / POLI** control aligned to the center line of the wallpaper.
- Keep the profile names positioned higher on the screen so they stay clear and readable over the background.
- Tapping **NICK** or **POLI** will only switch the active profile and keep the current access rules and warning state intact.
- Use the exact uploaded wallpaper as the visual base for this upgraded profile area.
- Tighten environment and startup handling so app configuration is more predictable at launch.
- Rework the widget into a simpler, safer structure so it is less likely to create extension-related build and stability issues.
- Reduce the risk of future error spirals by separating pure data, launch state, and screen state more cleanly.

## Design

- Keep the bold red-versus-blue identity from Part 1, but let the split profile control feel embedded into the wallpaper instead of floating above it.
- Make the split line feel intentional and cinematic, with the names sitting in the upper third for stronger visibility.
- Preserve the aggressive cyber look, but clean up the interaction layer so it still feels native on iPhone.
- Keep glow and glass effects controlled so readability stays stronger than spectacle.

## Pages / Screens

- **Main Menu**: Replace the existing profile selector with the new vertical split Nick / Poli control and preserve the current selection banner logic.
- **App Startup Flow**: Reduce launch complexity so state restoration, safe boot handling, and first-screen decisions are easier to trust.
- **Widget**: Rewrite the widget structure so it is simpler, more stable, and easier to maintain going forward.

## Status

- [x] Replace the current top profile buttons with the new full split Nick / Poli treatment.
- [x] Keep profile switching behavior the same after selection.
- [x] Preserve the current locked-state guidance until a profile is chosen.
- [x] Audit public configuration usage and remove fragile startup assumptions.
- [x] Simplify launch decision paths so profile selection, menu display, and screen restoration are less error-prone.
- [x] Reduce hidden coupling between startup checks, saved state, and live overlays.
- [x] Rebuild the widget around a cleaner, minimal data flow.
- [x] Remove unnecessary complexity in the widget entry and timeline structure.
- [x] Make the widget easier to evolve later without extension build complications.
- [x] Separate pure data from screen-driven state more clearly.
- [x] Reduce sources of concurrency and extension boundary errors.
- [x] Prepare the codebase for cleaner future refactors with fewer cascading failures.

## Part 2 Scope

1. **Profile control upgrade**
  - Replace the current top profile buttons with the new full split Nick / Poli treatment.
  - Keep profile switching behavior the same after selection.
  - Preserve the current locked-state guidance until a profile is chosen.
2. **Configuration and launch stability pass**
  - Audit public configuration usage and remove fragile startup assumptions.
  - Simplify launch decision paths so profile selection, menu display, and screen restoration are less error-prone.
  - Reduce hidden coupling between startup checks, saved state, and live overlays.
3. **Widget stability rewrite**
  - Rebuild the widget around a cleaner, minimal data flow.
  - Remove unnecessary complexity in the widget entry and timeline structure.
  - Make the widget easier to evolve later without extension build complications.
4. **Isolation and future build safety pass**
  - Separate pure data from screen-driven state more clearly.
  - Reduce sources of concurrency and extension boundary errors.
  - Prepare the codebase for cleaner future refactors with fewer cascading failures.

## Completion standard for Part 2

- [x] The main menu uses the new split **NICK / POLI** control over the uploaded wallpaper.
- [x] Profile taps switch profiles cleanly without changing the current access flow.
- [x] Startup behavior is more predictable and easier to maintain.
- [x] The widget is structurally simpler and safer for future builds.
- [x] The app is in a stronger position for the final performance and cleanup phase.

## Next Part

- **Part 3** will focus on performance optimisation, cleanup, and future build complication reduction.

