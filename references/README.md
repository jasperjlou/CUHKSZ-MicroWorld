# Reference library: metadata, not an asset distribution

This directory versions source URLs, manifests, provenance, confidence records,
spatial notes, and compact derived analytical summaries. It does not grant rights
to copy the underlying photographs, panoramas, maps, publications, or models.

## Entry points

- [Source index](index.json) and [local reference viewer](viewer.html)
- [Fairy Lake notes](regions/fairy_lake/README.md)
- [Field-photo observations](regions/fairy_lake/field_20260929.json)
- [Current inferred construction](regions/fairy_lake/phase_e_construction.json)
- [Legacy build inventory](regions/fairy_lake/local_player_build_inventory.json)
- [Legacy ground analysis](legacy_models/ground_topology.json)
- [Asset provenance](../docs/ASSET_PROVENANCE.md)

## Local-only material

`**/originals/`, caches, downloads, raw media, and local-only folders are ignored.
Photographs, original Campus Guide images, PDF publications, panorama tiles, DAE,
Blender, FBX, Unity/Tuanjie data, and compiled legacy players are not included.
The illustrated May 2026 Campus Guide is a reference for broad topology, not a
surveyed coordinate system. The 14 recently supplied images have observation
records; their original files were unavailable at the recorded archive attempt.

For material required for a local investigation, follow the source URL in
`index.json` or the region manifest, check the source's terms and obtain permission
where necessary, then save it to the manifest's ignored local path. User-provided
photos must be obtained from their owner. Some sources may no longer be available.
Do not assume every original is downloadable or redistributable.

The approximately 14.2 GB legacy Virtual Campus/GTA player stays outside the
repository. Only its inventory, hashes, limitations, candidates, and reuse
decisions are versioned. No legacy mesh has been approved for import. Historical
absolute paths in notes identify the original research machine; they are not
portable dependencies and do not require that directory to exist on a clone.

Normal gameplay does not read this directory. The viewer can show unavailable
local-image links on a fresh clone. Full reference validation additionally checks
locally held originals, so it is not a source-only clone smoke test.

New binary exceptions require an explicit provenance and reuse review. Do not
force-add ignored originals or use Git LFS to bypass this boundary.
