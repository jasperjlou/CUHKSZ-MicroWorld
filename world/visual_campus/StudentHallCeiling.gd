extends RefCounted
## V222:016/017 timber baffles, linear luminaires and recessed round downlights.
## Roof/lightwell registration remains pending; no upper floors are cut from this visual fit.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
static func board(n:Node3D,u0:float,u1:float,v0:float,v1:float,y:float,height:float,color:String,kind:int=67)->void:
	var centre:=R.point((u0+u1)/2,(v0+v1)/2,y)
	# Original plan axes, including its small registration rotation.
	var axis:=R.point(u1,v0)-R.point(u0,v0)
	K.box(n,centre,Vector3((u1-u0)/P.PIXELS_PER_METRE,height,(v1-v0)/P.PIXELS_PER_METRE),color,false,kind,-atan2(axis.z,axis.x))
static func field(n:Node3D,u0:float,u1:float,v0:float,v1:float,y:float)->void:
	board(n,u0,u1,v0,v1,y+.11,.035,"655f50",22)
	var pitch:float=.145*P.PIXELS_PER_METRE
	# All panels share one rib phase so the strips rejoin around the recess without a sawtooth seam.
	for i in range(ceili(v0/pitch),floori(v1/pitch)+1):
		var v:float=i*pitch
		board(n,u0,u1,maxf(v0,v-.29),minf(v1,v+.29),y,.11,"b9a27c")
static func linear_light(n:Node3D,u:float,v:float,y:float)->void:
	board(n,u-10,u+10,v-.75,v+.75,y-.010,.055,"595d56",11)
	board(n,u-9.2,u+9.2,v-.40,v+.40,y-.043,.014,"eee5cb",17)
static func downlight(n:Node3D,u:float,v:float,y:float)->void:
	var h:=K.holder(n,"HallRoundDownlight",R.point(u,v,y-.075))
	for spec in [[.108,.028,"5d655e",11],[.077,.032,"eee5cb",17]]:
		var mesh:=CylinderMesh.new();mesh.top_radius=spec[0];mesh.bottom_radius=spec[0];mesh.height=spec[1];mesh.radial_segments=12
		var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=K.material(spec[2],spec[3]);h.add_child(node)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentHallCeilingV222")
	# Central recess is left unfilled by timber for the subsequent lightwell registration.
	# Its bounds project the dashed0315F rectangle; retained concrete above is still temporary.
	var well:Array=[612.,709.,508.,636.]
	for rect in [[427,well[0],507,687],[well[1],792,507,687],[well[0],well[1],well[3],687]]:
		field(n,rect[0],rect[1],rect[2],rect[3],15.47)
	# Low gallery soffits seen above the hall doors, beneath the existing4F circulation strip.
	field(n,427,500,507,687,11.98)
	field(n,500,792,507,548,11.98)
	for q in [[460,575],[460,645],[545,525],[665,525],[755,525]]:linear_light(n,q[0],q[1],11.98)
	for q in [[550,565],[550,615],[550,665],[750,565],[750,615],[750,665],[650,668]]:linear_light(n,q[0],q[1],15.47)
	for q in [[575,584],[575,642],[729,584],[729,642]]:downlight(n,q[0],q[1],15.47)
	# Thin perimeter and recess returns conceal baffle ends without covering the intended opening.
	for rect in [[427,792,505,507],[427,792,687,689],[425,427,505,689],[792,794,505,689],[610,612,508,636],[709,711,508,636],[612,709,636,638]]:
		board(n,rect[0],rect[1],rect[2],rect[3],15.58,.28,"cdcabb",22)
	n.set_meta("source","architect016/017; sizes fitted; unfinished skylight retains structural slab")
	K.finish(n)
