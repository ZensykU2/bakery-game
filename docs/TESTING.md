# Testing strategy

Run deterministic tests from PowerShell:

```powershell
& 'G:\GODOT\Godot_v4.7-stable_win64.exe' --headless --path 'G:\Bakery-game\bakery-game' --scene res://tests/TestRunner.tscn
```

The command exits with code `0` only when every test passes. Add focused tests to `tests/test_runner.gd` whenever changing deterministic logic such as serialization, migrations, inventory value behavior, schedules, pricing, or customer selection.

## Test layers

1. Deterministic tests: fast, headless checks for data objects and pure game rules. These run on every meaningful logic change.
2. Catalog validation: run the Godot editor headlessly after resource changes. `ItemDB` reports duplicate IDs, missing assets, invalid recipes, and invalid requirement references in debug builds.
3. Manual feature checks: use a short checklist whenever a change needs the running game, physics, scene ownership, input routing, or visuals.
4. Regression checks: when a bug is fixed, add a deterministic test if possible; otherwise add its reproduction and expected result to the relevant manual checklist.

## Current deterministic coverage

- `InventoryItem` cloning and weighted freshness merging.
- New and legacy bake-state serialization.
- Dropped-item persistence records.
- Basic `GameState` round-tripping.
- Save migration from versions 0 and 1 to the current save version.

## Manual smoke checklist before a release

- Create, overwrite, load, delete, and corrupt a save slot; confirm backup recovery works.
- Save in each world scene and confirm scene, exact player position, inventory, time, drops, and active bakes restore correctly.
- Buy rapidly, fill the inventory, sell, bake, save mid-bake, reload, and harvest.
- Open every gameplay overlay; verify Escape closes it before the pause menu opens and I never creates overlapping panels.
- Change day/time, confirm decay, baking completion, lighting, and pass-out behavior.

## Future customer-system coverage

Before building customer scenes, add deterministic tests for schedule generation, rush-hour weighting, tourist roster eviction, preference scoring, and path-request selection. Keep navigation and visual assembly as manual/integration checks.
