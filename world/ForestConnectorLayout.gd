extends RefCounted
## Local composition supported by multiple views; actual inter-campus connection UNKNOWN.
const Entrance := preload("res://world/EntranceLayout.gd")
const Lake := preload("res://world/FairyLakeLayout.gd")
const POINTS := [Vector3(2,2.9,79),Vector3(-4,2.9,90),Vector3(-5,3.05,101),Vector3(1,3.05,111)]
const WIDTHS := [12.0,5.0,5.5,8.0]
const IDS := ["Entrance_TreeWalk_End","ForestEdge_Path_02","Roadside_Path_01","UNKNOWN_CONNECTOR"]
const ZONE := "ZONE_CONNECTOR_UNKNOWN"

static func right_at(index: int) -> Vector3:
	if index == 0:
		return Entrance.right_at(Entrance.POINTS.size()-1)
	var d: Vector3 = POINTS[mini(index+1,POINTS.size()-1)]-POINTS[index-1]
	return Vector3(d.z,0,-d.x).normalized()

static func route_points() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for i in range(POINTS.size()-1,0,-1):
		result.append(POINTS[i])
	result.append_array(Entrance.route_points())
	return result

static func objects() -> Array:
	var result: Array = []
	var titles := ["","林缘连接步道","路侧步道","林缘连接点"]
	for i in range(1,POINTS.size()):
		var r := Lake.object(IDS[i],titles[i],"Connector" if i == 3 else "Path",POINTS[i],true,true,false,true,true,["phase_b","local_composition","connection_unverified"],"inferred",["VR_42078153","VR_116384446","VR_130095287"])
		r.zone = ZONE
		r.connector = i == 3
		r.confidence = "inferred"
		r.replaceable = true
		r.inference_basis = ["延续既有路侧铺地；按2026导览图及实拍推理连接，未实测"]
		r.evidence.geographic_anchor = "unknown"
		if i == 3:
			r.frontier_id = "FRONTIER_CONNECTOR_B"
			r.evidence.geometry = "placeholder"
			r.evidence.presence = "placeholder"
			r.evidence.position = "placeholder"
		r.evidence.topology = "inferred"
		r.evidence.connection = "inferred"
		r.evidence.notes = "外观来自湖口及路侧全景；按现有资料推理接入第一岔路，可替换，未经测绘配准。"
		result.append(r)
	for item: Array in [["Connector_Road_View","路侧车道远景","Road",Vector3(33,2.85,106),"VR_116384446"],["Connector_Tower_View","浅色建筑远景","Background",Vector3(-28,2.2,179),"VR_116384446"],["Connector_Green_Slope","林侧绿化坡","Terrain",Vector3(-23,3,105),"VR_130095287"]]:
		var r := Lake.object(item[0],item[1],item[2],item[3],false,false,true,true,false,["phase_b","scenery","not_navigable"],"verified",[item[4]])
		r.zone = ZONE
		r.evidence.identity = "unknown" if item[2] == "Background" else "inferred"
		r.evidence.geographic_anchor = "unknown"
		r.evidence.position = "placeholder"
		r.evidence.notes = "仅外观类别在参考画面中得到核实；当前游戏位置未与全景配准。"
		result.append(r)
	return result
