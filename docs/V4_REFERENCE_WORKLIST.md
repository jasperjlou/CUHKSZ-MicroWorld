# V4 exterior modeling worklist

Baseline: `6cd48b04fc669dfe92e33b82fe2b63feabfa8fea`. Work only on
`world/campus-exterior-v4`; keep the original V3 scene available for comparison.
Immutable input snapshot: `systems/data/campus_environment_v3_frozen.json`.

## Decisions supported by refreshed official material

- Music: [2025 opening report](https://www.cuhk.edu.cn/zh-hans/article/15580)
  describes seven principal buildings, petal-shaped performance forms, U-shaped
  teaching/living courts and weather-covered links. Eighth has two dormitory
  buildings. Model five masses at the existing Music anchor and two at the
  separate Eighth anchor; their exact footprints remain inferred.
- [Muse facilities](https://muse.cuhk.edu.cn/page/76) and
  [Diligentia facilities](https://diligentia.cuhk.edu.cn/page/1051) support three
  dormitory masses each. Their placement, height ordering and unseen elevations
  are conservative guide-derived interpretations, not verified measured plans.
- [Campus life](https://cuhk.edu.cn/zh-hans/campus-life) supports three connected
  blocks in each Shaw ensemble. Keep East/West existing anchors.
- [Current campus description](https://admissions.cuhk.edu.cn/node/909) supports
  the upper residential / middle greenway and motor road / lower academic
  relationship and surrounding hills. It does not establish exact sidewalk
  offsets or true elevations.
- [Current college names](https://admissions.cuhk.edu.cn/node/30) are used for
  physical signs. Legacy stable IDs remain unchanged.

## Existing sources used first

31-reference index, 294-panorama catalog, region packs, V2 architecture profiles,
guide-derived footprints, local ground observation notes and legacy topology
audit. `references/exterior_v4/building_coverage.json` lists building-specific
panorama candidates. Metadata candidates are not claimed to be newly visually
reviewed panoramas. Prior reviewed lake/roundabout observations support low
curbs, tree pits, thin dark lamp posts and separated roadside paving locally;
they do not prove every campus segment or hotspot-to-hotspot walkability.

## Modeling priorities

P0: Music aggregate silhouette, steep raw pad edges, shared motor/walk corridors.
P1: seven distinct college ensembles, Tier A exterior sides/roofs, public arrival
axes, lake/campus context. P2: remaining shell completion, fixtures and signage.
Unknown rear facades use `INFERRED_REAR_FACADE`; no raw photo texture imports.
Exact corridor lengths and shuttle boarding curbs remain inferred/placeholder.

Research is bounded to decisions above. Inaccessible original images and missing
survey-grade terrain do not block conservative authoring, and do not justify
raising geometry confidence. No interiors, Agent changes or live-model calls.
