extends RefCounted
# Authored game units, NOT surveyed metres. Only local panorama composition is verified.
const POINTS := [Vector3(8,2.4,42), Vector3(3,1.5,25), Vector3(-1,0.6,8), Vector3(1,0.15,-10), Vector3(7,0.4,-26), Vector3(14,0.9,-42)]
const HALF_WIDTH := 2.8
const REFERENCES := ["VR_42078153", "VR_42078154", "LAKE_06", "LAKE_09"]

static func right_at(index: int) -> Vector3:
	var direction: Vector3 = POINTS[mini(index+1, POINTS.size()-1)] - POINTS[maxi(index-1,0)]
	return Vector3(-direction.z,0,direction.x).normalized()

static func object(id: String, title: String, kind: String, position: Vector3, interactable: bool, walkable: bool, obstacle: bool, landmark: bool, destination: bool, tags: Array, presence: String, sources: Array = []) -> Dictionary:
	var spatial_level := "placeholder" if presence == "placeholder" else "inferred"
	return {"id":id,"name_zh":title,"type":kind,"position":[position.x,position.y,position.z],"interactable":interactable,"walkable":walkable,"obstacle":obstacle,"landmark":landmark,"destination":destination,"semantic_tags":tags,"active":true,"zone":"ZONE_FAIRY_LAKE","connector":false,"confidence":spatial_level,"evidence":{"presence":presence,"position":spatial_level,"dimensions":spatial_level,"elevation":"placeholder","sources":sources,"units":"game_units_not_surveyed_metres"}}

static func objects() -> Array:
	var result: Array = []
	result.append(object("FairyLake","神仙湖","Water",Vector3(-28,-0.65,0),false,false,true,true,false,["water","non_walkable"],"verified",["VR_42078154","LAKE_06"]))
	for i in POINTS.size():
		result.append(object("FairyLake_Path_%02d" % (i+1),"湖边步道第%d段" % (i+1),"Walkable_Path",POINTS[i],false,true,false,false,true,["walkable","route_node"],"verified",["VR_42078154"]))
	result.append(object("UpperCampus_Direction","上园方向入口","Direction",POINTS[0],true,true,false,true,true,["entry","direction_only","connection_unverified"],"placeholder"))
	result.append(object("LowerCampus_Direction","下园方向出口","Direction",POINTS[-1],true,true,false,true,true,["exit","direction_only","connection_unverified"],"placeholder"))
	result.append(object("Sign_01","神仙湖题字石","Sign",POINTS[0]-right_at(0)*4.5,false,false,true,true,false,["stone","inscription"],"verified",["VR_42078153","LAKE_09"]))
	result.append(object("FairyLake_Viewpoint_01","湖畔观景处","Viewpoint",POINTS[3],true,true,false,true,true,["viewpoint","lake_view"],"inferred",["VR_42078154","LAKE_06"]))
	result.append(object("Pavilion_01","湖畔圆亭","Pavilion",POINTS[4]-right_at(4)*7,false,false,true,true,false,["domed_pavilion","scenery"],"verified",["VR_42078154","LAKE_06"]))
	result.append(object("Bench_01","树荫长椅","Bench",POINTS[2]+right_at(2)*4.5,false,false,true,false,false,["furniture"],"placeholder"))
	result.append(object("Road_01","湖侧预留道路","Road",POINTS[2]+right_at(2)*14,false,false,true,false,false,["reserved_shuttle_route","inactive"],"verified",["VR_42078154"]))
	var stop := object("UpperCampus_BusStop","接驳候车点（未开放）","BusStop",POINTS[0]+right_at(0)*11,false,false,false,false,false,["reserved","inactive","location_unverified"],"placeholder")
	stop.active = false
	stop.evidence.position = "placeholder"
	result.append(stop)
	result.append(object("Grass_Bank","湖岸草坡","Terrain",Vector3.ZERO,false,true,false,false,false,["grass","shore","bounded_play_area"],"verified",["VR_42078154"]))
	result.append(object("Railing_01","临水栏杆","Barrier",Vector3.ZERO,false,false,true,false,false,["safety_boundary","metal","wood_cap"],"verified",["VR_42078154"]))
	result.append(object("TreeBelt_01","湖侧树带","Vegetation",Vector3.ZERO,false,false,true,false,false,["trees","land_side"],"verified",["VR_42078154"]))
	result.append(object("HillBackdrop","远山背景","Scenery",Vector3.ZERO,false,false,true,false,false,["hills","background"],"verified",["VR_42078154"]))
	result.append(object("BuildingBackdrop","远处建筑轮廓","Scenery",Vector3(39,0,-70),false,false,true,false,false,["unnamed_buildings","background"],"placeholder"))
	for i in [1,3,4]:
		result.append(object("Lamp_%02d" % i,"步道灯","Lamp",POINTS[i]+right_at(i)*5.7,false,false,true,false,false,["street_furniture"],"placeholder"))
	return result

static func position_of(record: Dictionary) -> Vector3:
	var p: Array = record.position
	return Vector3(p[0],p[1],p[2])
