extends RefCounted
## Anniversary aerial: grey footway, continuous ochre tactile strip, white twin-arm lamps.
## Widths, lamp spacing and precise street registration remain photographic fits.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const T=preload("res://world/visual_campus/TrackOuterSite.gd")

static func lamp(parent:Node3D,p:Vector3,across:Vector2)->void:
	var n:=K.holder(parent,"WhiteTwinArmLamp",p)
	n.rotation.y=atan2(-across.y,across.x)
	K.box(n,Vector3(0,.12,0),Vector3(.28,.24,.28),"a2aaa7",false,11)
	K.box(n,Vector3(0,3.5,0),Vector3(.13,7,.13),"d9dcd6",false,11)
	for side in [-1,1]:
		var previous:=Vector3(0,7,0)
		for i in range(1,9):
			var angle:=float(i)/8*PI/2
			var q:=Vector3(side*1.6*(1-cos(angle)),7+1.2*sin(angle),0)
			var arm:=MeshInstance3D.new();var tube:=CylinderMesh.new()
			tube.top_radius=.045;tube.bottom_radius=.055;tube.height=previous.distance_to(q);tube.radial_segments=6
			arm.mesh=tube;arm.material_override=K.material("d9dcd6",11);arm.position=(previous+q)/2
			arm.basis=Basis(Quaternion(Vector3.UP,(q-previous).normalized()));n.add_child(arm);previous=q
		K.box(n,previous+Vector3(side*.24,0,0),Vector3(.64,.13,.25),"d1d6cf",false,11)
		K.box(n,previous+Vector3(side*.24,-.075,0),Vector3(.48,.025,.18),"ebebdb",false,17)
	K.finish(n)

static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"SportsStreetFinishV198")
	# The walking surface stays the existing continuous grade. All relief is visual only.
	T.ribbon(n,builder,4.9,5.5,1,"8c805f",22,.112)
	for offset:float in [4.97,5.11,5.25,5.39]:
		T.ribbon(n,builder,offset,offset+.045,1,"988b65",22,.120)
	# Lamps sit in the planted divider, with a 6.5 m stagger from the existing trees.
	for i in T.ROAD.size()-1:
		var length:float=T.ROAD[i].distance_to(T.ROAD[i+1])
		if length<35:continue
		for station in range(6,int(length)-3,26):
			var t:float=(station+.5)/length
			var p:Vector3=T.edge(i,T.half_width(i)+3.7,0).lerp(T.edge(i+1,T.half_width(i+1)+3.7,0),t)
			p.y=builder.height(p.x,p.z)+.10
			lamp(n,p,T.normal(i).lerp(T.normal(i+1),t).normalized())
	K.finish(n)
