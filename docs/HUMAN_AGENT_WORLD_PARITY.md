# Human / Agent world parity

Both modes instantiate `world/unified/UnifiedCampus.tscn`, with the **same V5 packed exterior** and ten V5 interior packed scenes. Same `player/Player.tscn` and script, CharacterBody3D capsule, collision mask, move_and_slide, gravity, stairs, door script, indoor camera rays and streaming activation. Human input and Agent navigation_direction converge in the existing Player physics function.

Human can hold Shift for 8.3-unit jogging; Agent uses the existing 5.1-unit walking input. Neither bypasses collision. Phone slows both to 2.4. This speed difference is explicit; physical constraints and geometry are shared.

The same authoritative GameState, WorldTime, EventBus and EventLogger support both. Campus observation projects current visible landmarks and public campus knowledge, omitting graph, shortest route, teacher perception internals and verifier requirements. Agent policy chooses actions; campus executor plans AStar3D waypoints. Infrastructure replanning is not Agent reasoning.

V6 is structured semantic navigation, **not autonomous visual navigation**. All indoor layouts are inferred, public platforms are limited slices, and High Table is a prototype activity venue. Shuttle boarding is unavailable until placeholder stop meshes receive a consistent transport adapter; no fictional physical bus is claimed.

Walking, stairs and doors use physical movement. The only body position assignment in the V6 adapter is reset initialization; cameras and Human developer reset are separately labelled. Replay runs actions through the same physical executor and compares verdict, visited IDs, action count, distance and simulation time.
