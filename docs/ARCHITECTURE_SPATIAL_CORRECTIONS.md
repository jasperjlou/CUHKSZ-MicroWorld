# Architecture V2 spatial freeze

Baseline: `faa437023719a8d08ba720e079a695955c645bc7`.

No building was relocated. Centers, footprint records, yaw, estimated heights, terrain, lake outline, vehicle routes, pedestrian polylines and planning nodes remain the V1 data. The snapshot is `systems/data/campus_masterplan_v1_frozen.json`; its database hash is LF-canonical for Windows portability.

The V2 layer replaces visual massing with shells inside those footprints. Small parapets, facade thickness, canopy details and roof screens are architectural additions, not revised surveyed heights. The isolated scene camera and HUD changed. Forecourts use the existing ground; no raised paving collider or new terrain floor was added. Corridor pillars leave a central opening. Bell-tower approach is outside the solid shaft; no interior is claimed.

No before/after spatial correction entries are necessary: none were made. Future relocation requires explicit reference, old/new transforms and confidence. A photograph of architectural appearance does not verify the V1 placement, dimensions or bearing.
