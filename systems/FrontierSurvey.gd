extends RefCounted
## Gameplay coordinates are frozen; geographic registration remains unknown.
const ID := "FRONTIER_CONNECTOR_B"
const POSITION := Vector3(1,3.05,111)
const SOURCES := ["VR_42078153","VR_116384446","VR_130095287"]

static func observe() -> Dictionary:
	return {"id":ID,"name_zh":"林缘连接点","position":[1,3.05,111],"semantic_alias":"UNKNOWN_CONNECTOR","zone":"ZONE_CONNECTOR_UNKNOWN","confidence":"inferred","geographic_anchor":"not_surveyed","extension_enabled":true,"replaceable":true,"sources":SOURCES.duplicate(),"evidence_matrix":"references/regions/fairy_lake/v10c_frontier_evidence.json","current_construction":"systems/data/junction_world.json"}

static func confidence_zh(value: String) -> String:
	return {"verified":"已核实","inferred":"推断","placeholder":"临时占位","unknown":"未知"}.get(value,"未知")
