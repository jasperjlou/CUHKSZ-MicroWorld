extends RefCounted
## V1.0 Phase A: entrance forecourt. Distances are authored game units, not metres.
const Lake := preload("res://world/FairyLakeLayout.gd")
const POINTS := [Vector3(8,2.4,42),Vector3(8,2.65,55),Vector3(8,2.9,68),Vector3(2,2.9,79)]
const IDS := ["UpperCampus_Direction","Entrance_Path_01","Entrance_Forecourt","Entrance_TreeWalk_End"]

static func right_at(index: int) -> Vector3:
	if index == 0:
		return Lake.right_at(0)
	var direction: Vector3 = POINTS[mini(index+1,POINTS.size()-1)]-POINTS[index-1]
	return Vector3(direction.z,0,-direction.x).normalized()

static func route_points() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for i in range(POINTS.size()-1,0,-1):
		result.append(POINTS[i])
	result.append_array(Lake.POINTS)
	return result

static func objects() -> Array:
	var result: Array = []
	for i in range(1,POINTS.size()):
		var titles := ["","入口灰石步道","树池台阶广场","入口林缘尽头"]
		var r := Lake.object(IDS[i],titles[i],"Path",POINTS[i],true,true,false,true,true,["entrance_extension","continuous_walk","local_connector"],"verified",["VR_42078153"])
		r.zone = "ZONE_UPPER_CONNECTOR"
		r.connector = i == 1
		r.confidence = "inferred"
		r.evidence.topology = "inferred"
		r.evidence.notes = "全景支持入口连续铺地与树池台阶；分段、长度、坐标与高差未经测量，不证明上下园连接。"
		result.append(r)
	for i in range(4):
		var p := Vector3(-0.5 if i%2 == 0 else 16.5,2.65 if i < 2 else 2.9,55 if i < 2 else 69)
		var tree := Lake.object("Entrance_Planter_%02d" % i,"方形树池","StreetFurniture",p,false,false,true,true,false,["reusable","stone_planter","tree"],"verified",["VR_42078153"])
		tree.zone = "ZONE_UPPER_CONNECTOR"
		tree.asset_id = "square_tree_planter"
		result.append(tree)
	for i in range(2):
		var stair := Lake.object("Entrance_Terrace_%02d" % i,"入口石阶","Path",Vector3(1 if i == 0 else 15,2.65,60),false,true,false,true,false,["reusable","steps","simplified_ramp_collision"],"verified",["VR_42078153"])
		stair.zone = "ZONE_UPPER_CONNECTOR"
		stair.asset_id = "granite_terrace"
		result.append(stair)
	return result
