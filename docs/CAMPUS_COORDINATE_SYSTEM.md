# Campus Masterplan coordinate system

2026-10-07. Independent from the RC1 local journey coordinate frame.

- Y is vertical; +X east, -X west, -Z north, +Z south.
- Origin: approximate centre of the existing Fairy Lake water body, not a scene corner. Water datum Y=24 game units. Lower plateau Y=8; upper plateau Y=54; relief is ESTIMATED_METRIC / placeholder.
- The locally archived May 2026 guide matches the user-supplied guide in the conversation. It is a perspective illustration, **without a usable north arrow or scale bar**. Its visual up/right are adopted as provisional north/east. `north_confidence=APPROXIMATED`. North/east gate labels are not a compass. No geographic rotation has been measured; all building yaw values are approximate. A future calibrated survey can apply one global transform to this frame.
- `APPROXIMATED_METRIC_SCALE`: GAME UNIT APPROXIMATES REAL-WORLD METER SCALE. The 94×176 track envelope and 30×34 two-court block provide conventional sports-scale sanity anchors, **not two measured campus anchors**. Guide perspective prevents one reliable pixel-to-metre ratio. Distances/heights/footprints cannot be quoted as real metres.
- Manual guide-plane anchors encode arrangement; the affine `(u-.11)*1250, (v-.25)*1300` is a reproducible authoring convention, not image rectification. It prioritizes adjacency and consistent model scale over perspective-image lengths.
- Buildings use footprint width/depth, estimated height and local composition in `campus_masterplan.json`. Terrain pads meet each estimated datum. Roads and paths are separately described in `campus_paths.json`; actual surfaces follow terrain.
- Source priority: supplied/archived guide → official photographs/VR → legacy numeric audit. Legacy DAE remains uncalibrated, reference only; no source mesh is imported.

Default geometry confidence is inferred; weak facility placement is placeholder. `APPROXIMATED`, `LOW_CONFIDENCE`, `ESTIMATED_METRIC`, and `replaceable=true` are separate fields. No world-space footprint is upgraded to verified merely because its building name appears on the official guide.

Rebuild authored data and derived inventory/table/distances:

```text
python tools/build_campus_masterplan.py --stage MASSING
```

RC1 and CampusMaster coexist. This frame does not re-register or overwrite RC1 semantic anchors. The existing High Table scene remains `PROTOTYPE_UNREGISTERED`: its real venue is not established.
