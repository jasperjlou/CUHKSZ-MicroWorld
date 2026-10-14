extends RefCounted
## Official2025-08-12 update: wall-mounted24h slot outside2F entrance.
## Pier location within the existing entry side bay and metric size remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func rounded_face(parent:Node3D,width:float,height:float,radius:float,z:float,color:String,kind:int)->void:
	var polygon:=PackedVector2Array()
	for corner in 4:
		var centre:=Vector2((width/2-radius)*(1 if corner<2 else -1),(height/2-radius)*(1 if corner in [1,2] else -1))
		for step in 7:
			var angle:float=(-90+corner*90+step*15)*PI/180
			polygon.append(centre+Vector2(cos(angle),sin(angle))*radius)
	var plate:=K.holder(parent,"RoundedReturnPlate",Vector3(0,1.50,z));plate.rotation.x=PI/2
	var mesh:=preload("res://world/visual_campus/LibraryEntryCeiling.gd").prism(polygon,-.013,.013)
	K.surface(plate,mesh,color,kind)
static func build(parent:Node3D,position:Vector3,yaw:float)->void:
	var n:=K.holder(parent,"LibraryBookReturn2025",position);n.rotation.y=yaw
	# Shallow face on the white pier; no freestanding cabinet obstructs the approach.
	rounded_face(n,.88,1.02,.085,.095,"e6d9ac",17)
	rounded_face(n,.82,.96,.075,.122,"abb0ad",22)
	var badge:=MeshInstance3D.new();var ring:=TorusMesh.new();ring.inner_radius=.10;ring.outer_radius=.115;ring.rings=32;ring.ring_segments=8
	badge.mesh=ring;badge.material_override=K.material("414c46",22);badge.position=Vector3(0,1.80,.144);badge.rotation.x=PI/2;n.add_child(badge)
	K.box(n,Vector3(-.15,1.21,.142),Vector3(.35,.23,.015),"49524c",false,22)
	K.box(n,Vector3(-.15,1.22,.154),Vector3(.31,.18,.015),"b3b8b4",false,11)
	K.box(n,Vector3(-.15,1.31,.166),Vector3(.28,.020,.025),"6a746e",false,11)
	for info:Array in [["24",Vector3(0,1.82,.16),.0013],["HOUR",Vector3(0,1.74,.16),.00035],["BOOK DROP",Vector3(-.08,1.58,.15),.00070],["还书箱",Vector3(-.12,1.43,.15),.0010],["LIFT TO OPEN",Vector3(-.15,1.23,.168),.00032]]:
		K.label(n,info[0],info[1],info[2]).modulate=Color("39413e")
	for i in 9:K.box(n,Vector3(.23,1.50-i*.036,.145),Vector3(.18-(i%3)*.016,.007,.004),"626961",false,22)
	n.set_meta("source","2025 service-upgrade photo; capture date unknown; entry side-bay pose/size fitted")
	K.finish(n)
