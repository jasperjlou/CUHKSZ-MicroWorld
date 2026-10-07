# V6 Agent migration audit

Baseline: V5 `af907bcc3926fc1330a2e29a224e8547e9906682`; immutable RC1 tag `v1.0.0-rc1`. V6 changes the main-product policy after acceptance, not historical research results.

| Existing component | Classification | V6 integration |
|---|---|---|
| GameState authoritative flags / snapshot | GENERIC_REUSABLE | Shared exact autoload; V6 location registry augments it through the environment |
| WorldTime | GENERIC_REUSABLE | Same clock; physics ticks only in Human play or action execution; provider wait is gated |
| EventBus / EventLogger | GENERIC_REUSABLE | Same event emitter/logger; separate V6 run directory |
| CharacterBody3D Player | GENERIC_REUSABLE | Existing agent_controlled/navigation_direction inputs, exact capsule and move_and_slide |
| AgentEnvironment | RC1_SPECIFIC | Contains small-map TARGETS, MainWorld reset and RC1 dialogue dependencies; retain, add campus adapter |
| RuleBasedAgent | RC1_SPECIFIC | Photo/friend/late-dinner policy retained for RC1; V6 public task destination policy separate |
| RandomAgent | NEEDS_ADAPTATION | CampusRandomAgent accepts only supplied legal actions and deterministic seed |
| LLMAgent | NEEDS_ADAPTATION | Provider generate_action contract reused; RC1 action allowlist/prompt not valid for campus; new exact-member validator |
| TaskVerifier / JourneyVerifier | RC1_SPECIFIC | Preserve their old contracts; CampusVerifier independently checks real milestone records |
| Journey replay | NEEDS_ADAPTATION | CampusReplay re-executes semantic actions in the actual physics world |
| Benchmark runner / scores | RC1_SPECIFIC | Historical baseline remains explicit; V6 integration tasks are not a research benchmark |
| Old transport abstraction | DEPRECATED_FOR_V6 | V5 stop meshes are placeholders without a synchronized timetable; no board action advertised |

No paid model calls, RAG, new NPC reasoning, or copy of a fake Agent-only campus. Semantic coordinates derive frozen V5 footprints/routes; outdoor Y samples the same V4 terrain used by collision, rather than outdated source-route elevations. Indoor stair Y remains actual V5 geometry. Geometry has not been moved to aid navigation.

Reset recreates loaded interior instances, restores doors, phone, bounded teacher/photo state, task, navigation, visited milestones and logs. Normal navigate_to writes navigation_direction only. An initial episode spawn or explicit Human developer reset is the permitted position assignment.
