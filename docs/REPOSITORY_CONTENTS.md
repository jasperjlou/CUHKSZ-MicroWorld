# GitHub repository contents and local dependencies

Prepared 2026-09-29 for `CUHKSZ-MicroWorld`. The owner subsequently explicitly
authorized public visibility; raw-reference and credential exclusions still apply.

## History and release scope

The local repository already had four commits, ending at `3bbb471` (V0.5 freeze),
on `master`, with no remote. This publication preserves those commits and keeps
the old local branch; `main` continues from the same history. No squash, history
rewrite, force push, or Git LFS migration is part of this operation.

The requested documentation baseline is **V1.0 Phase D2**. The actual working tree
already contains the subsequent evidence-aware D2 connection and Phase E branch
implementation, and `project.godot` says `1.0.0-phase-e`. These existing changes
are included as-is; this packaging operation does not downgrade or edit game
logic, physics, maps, navigation, or version configuration.

## Included

- GDScript, `.tscn` scenes, `.tres` resources, `project.godot`, stable `.gd.uid`
  identifiers, and Godot `.import` settings sidecars.
- Procedural campus assets, the existing generated sign textures, and the bundled
  Noto Chinese font with its existing OFL notice.
- Agent/benchmark implementation and test source, launch/analysis tools, task
  configurations, documentation, source URLs and reference metadata.
- Compact old-model numerical summaries and candidate/provenance records;
  these are not exported meshes, textures, or executable legacy assets.
- `.gitattributes` preserves existing bytes for world scripts and runtime data
  whose hashes are recorded in provenance receipts; it does not edit their code.

## Excluded and preserved locally

- `.godot/`, `.tools/`, `tests/artifacts/`, Python/editor caches, logs, temporary
  files, local screenshots and build/export outputs.
- `references/**/originals/` and all raw reference media by default, including
  official campus images, panoramas, maps, PDF publications and private photos.
- The external legacy player (~14.2 GB), third-party raw models, DAE/FBX/Blender
  data, research downloads, executables and resource dumps.
- `.env*`, local overrides, credentials/private keys and export credentials.

Ignoring files does not delete them. Reference acquisition is documented in
[`references/README.md`](../references/README.md); no old player or raw model is
needed to run this project's authored Godot scenes.

## Size and rights review

The only existing source candidate above 10 MB is
`assets/fonts/NotoSansSC.ttf`: **17,772,300 bytes (17.77 MB / 16.95 MiB)**.
It is an existing runtime dependency already in local Git history; its OFL notice
is retained. No candidate or historical blob exceeds 50 MB or 100 MB.
The two generated sign PNGs are approximately 3.04 MB and 2.14 MB.

`walk_without_phone_reference.png` was generated using a user-supplied photograph
as a reference. The existing provenance describes its derivation; this is not a
blanket copyright clearance. The repository is publicly readable by the owner's
explicit instruction, has no new overall license, and does not grant permission
to redistribute the underlying reference photograph or unrelated legacy assets.
Other source/model records marked `LICENSE_UNCLEAR` or `REFERENCE_ONLY` remain
reference notes, not permission to redistribute their originals.

No project-wide LICENSE is introduced. **License pending / All rights reserved
unless otherwise stated.** Existing individual notices, including the font OFL,
remain applicable to their respective files.

## Reproducibility limits

Install Godot 4.5.1 separately; the local engine under `.tools/` is not uploaded.
Open `project.godot` and run the main scene. The Chinese font is bundled.
Tests can regenerate ignored artifacts. Historical QA reports are dated evidence,
not a claim that all old raw reference files are available to a fresh clone.
