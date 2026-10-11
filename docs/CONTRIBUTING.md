# Contributing

- Fetch main before starting, then branch from current main (`world/...`, `agent/...`, `fix/...`). Large features should use a pull request.
- Preserve collaborator history. Never force-push main, reset it to a feature branch, or move historical tags.
- Keep logical commits and distinguish geometry/data changes from Agent policy or evaluation changes.
- Campus anchors, roads and interiors are authoritative shared-world data. Do not duplicate a simplified Agent map or move buildings to hide navigation failures. Record necessary NAVIGATION_BLOCKER_FIX changes and confidence.
- Keep inferred / verified / placeholder and replaceable metadata. Reference visibility is not a redistribution license.
- Do not commit raw reference photography, legacy asset dumps, credentials, logs or test artifacts.
- Baked scenes are tracked project-authored assets. Use **rendered** Godot baking, not headless saving of MultiMesh. Normalize LF/CRLF source fingerprints and validate binary hashes.
- Run `python tools/check_unified_campus.py --qa --rc1` for integration changes; run rendered Human/Agent routes for movement, door, stairs or streaming changes.
- Historical `world/*` branches and `v1.0.0-rc1` remain reproduction milestones. Current features branch from main after V6 promotion.
