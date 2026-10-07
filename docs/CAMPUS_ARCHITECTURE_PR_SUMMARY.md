# Campus Architecture V2

Replaces anonymous V1 building massing in the isolated campus explorer with a full 44-site procedural shell pass: 16 Tier A focal sites, 27 B, 1 C. Interlocking Library volumes, paired Administration wings, Student Centre courts, residential podium/tower accents, academic screen/glass language, Sports Hall and curved Music landmark now have shared facade/roof/entrance detail. Local arcade openings, courts and restrained zoned landscaping improve pedestrian reading without moving the masterplan.

Facade MultiMeshes and material-baked boxes keep overview draw calls at 521 versus V1 457 in the same-machine sample; uncapped frame time ~3.15 ms versus ~2.38 ms. Building collision bodies share simple shapes; there are no window colliders or facade trimeshes.

Validation: 44 profiles and immutable V1 records, 1,770 spatial/frozen-source assertions, 875 rendered acceptance checks including entrance capsules and two-way original-controller campus traversal (~2,325 game units), 279 unchanged RC1 core checks. This is scripted traversal and capture evidence, not first-time-human recognition. The default RC1 environment, physics, Agent and benchmark remain unchanged. Raw reference/legacy assets remain outside Git.

Remaining uncertainty: unseen elevations, college-specific topology, exact Music performance-building curves and unmeasured scale. See CAMPUS_ARCHITECTURE_V2.md and ARCHITECTURE_REFERENCE_GAPS.md. Merge target should be the existing map-development branch; no automatic main merge.
