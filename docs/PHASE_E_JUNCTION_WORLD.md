# D2 connection and initial Phase E branches

This note describes the existing source snapshot preserved during repository
preparation on 2026-09-29; it does not introduce new geometry.

The owner replaced the previous stop-on-unknown rule with evidence-aware
inference. D2 now connects the lake/forest corridor to the first junction through
an inferred middle road and a placeholder roadside pedestrian access (option B).
Phase E contains limited upper-campus, lower-campus, Ling College and other-area
walking branches; the vehicle road is a separate non-walkable navigation target.
These are playable authored connections, not proof of surveyed real-world routes.

The authoritative definition is
[`junction_world.json`](../systems/data/junction_world.json); its construction
record is [`phase_e_construction.json`](../references/regions/fairy_lake/phase_e_construction.json).
Each segment records confidence, inference basis and replaceability. The existing
F1 display and Agent observation expose construction status. Historical source
gaps remain in D/D2 reference notes without blocking the new authored world.

The navigation graph supplies waypoints to the existing physical character
movement. Original event, transport, observation and logging systems remain in
the snapshot. Branch ends are bounded; real upper/lower campuses and the college
interior are not fully implemented.

The preceding development run recorded 262 headless junction checks and 275
rendered checks, both with zero failures; the rendered route covered two complete
runs. Those local artifacts are intentionally ignored. This publication task did
not rerun or alter gameplay. See [repository scope](REPOSITORY_CONTENTS.md).
