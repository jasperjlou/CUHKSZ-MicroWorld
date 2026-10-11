extends RefCounted
## V64: official aerial + T-junction panorama + photographer54 garden approach.
## Topology is reference-led; metre values and exact canopy alignment remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const S:=preload("res://world/visual_campus/StartZoneLandscape.gd")
const G:=2.24

static func terrace(b: Node3D,z0: float,z1: float,y: float,lawn: bool,width: float=22) -> void:
	var z:float=(z0+z1)/2;var depth:=absf(z1-z0)
	K.box(b,Vector3(23,G+(y-.12)/2,z),Vector3(width,y+.12,depth),"aaa99d",true,26)
	K.box(b,Vector3(23,G+y+.012,z),Vector3(width,.024,depth),"b8b6a8",false,26)
	if lawn:
		K.box(b,Vector3(23,G+y+.035,z),Vector3(12,.03,depth-3),"75965b",false,3)
		for x in [16.85,29.15]:K.box(b,Vector3(x,G+y+.04,z),Vector3(.18,.045,depth-2.7),"c3c2b2",false,26)
		for edge in [-1,1]:K.box(b,Vector3(23,G+y+.04,z+edge*(depth-2.8)/2),Vector3(12.4,.045,.18),"c3c2b2",false,26)

static func canopy(b: Node3D,a: Vector3,c: Vector3,width: float=3.2) -> void:
	var d:=c-a;var length:=Vector2(d.x,d.z).length()
	var n:=K.holder(b,"WhiteWalkCanopy",(a+c)/2);n.rotation.y=atan2(d.x,d.z)
	K.box(n,Vector3(0,.018,0),Vector3(width+.6,.035,length),"aaa99b",false,26)
	# Fine translucent roof, deep white edge beams and regularly spaced supports.
	K.box(n,Vector3(0,3.6,0),Vector3(width,.09,length),"c6d1c4",false,19)
	for x in [-width/2,width/2]:
		K.box(n,Vector3(x,3.52,0),Vector3(.13,.26,length),"d6dad0",false,22)
	for i in ceili(length/2)+1:
		var z:float=-length/2+i*length/ceili(length/2)
		K.box(n,Vector3(0,3.48,z),Vector3(width,.10,.075),"d6dad0",false,22)
	for i in ceili(length/7)+1:
		var z:float=-length/2+i*length/ceili(length/7)
		if a.z>-800 and c.z<-800 and absf(a.x-9.4)<.1 and n.position.z-z>-797 and n.position.z-z<-791:continue
		for x in [-width/2+.1,width/2-.1]:K.box(n,Vector3(x,1.74,z),Vector3(.14,3.48,.14),"d1d6cd",true,22)
	if a.z>-800 and c.z<-800 and absf(a.x-9.4)<.1:
		for world_z in [-790.5,-797.5]:
			for x in [-width/2+.1,width/2-.1]:K.box(n,Vector3(x,1.74,n.position.z-world_z),Vector3(.14,3.48,.14),"d1d6cd",true,22)
	K.finish(n)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"TowerGardenV64")
	# Alternating inset lawns, broad cross paving and three short flights terminate at the tower.
	terrace(b,-746,-766,0,true)
	terrace(b,-769,-777,.6,true)
	terrace(b,-780,-788,1.2,true)
	terrace(b,-791,-798,1.8,false,14)
	for item: Vector3 in [Vector3(-766,-769,0),Vector3(-777,-780,.6),Vector3(-788,-791,1.2)]:
		P.stair(b,Vector3(23,G+item.z,item.x),Vector3(23,G+item.z+.6,item.y),14 if item.z>1 else 22)
	# Low retaining sides are explicit; stone strips do not float above a default grass plane.
	for side in [-1,1]:
		for item: Vector3 in [Vector3(-769,-777,.6),Vector3(-780,-788,1.2),Vector3(-791,-798,1.8)]:
			# Last landing has a side-stair opening; its solid side faces are provided by the slab.
			if item.z<1.5:K.box(b,Vector3(23+side*11.15,G+item.z/2,(item.x+item.y)/2),Vector3(.25,item.z,absf(item.y-item.x)),"b0b2a4",true,26)
	# A side flight connects the raised entrance apron to the street-level covered walk.
	var side_stair:=K.holder(b,"TowerSideEntry",Vector3(7,G,-794));side_stair.rotation.y=-PI/2
	P.stair(side_stair,Vector3.ZERO,Vector3(0,1.8,-9),3.6);K.finish(side_stair)
	# Openings at each side flight meet the existing garden surface at its exact level.
	for x in [11.5,34.5]:
		for z in [-751,-759]:
			K.box(b,Vector3(x,G+.04,z),Vector3(2.4,.08,2.4),"605a41",false,4)
			V.shrub(b,Vector3(x,G+.12,z),Vector3(2.2,.45,2.2),absi(int(x*100+z)))
			K.tree(b,Vector3(x,G+.1,z),8.7,absi(int(x*100+z)))
	# Sports-side canopy joins the tower forecourt; supports remain outside walking centre lines.
	canopy(b,Vector3(9.4,G,-788),Vector3(9.4,G,-831))
	# The street crossing stays open overhead and free of posts; no undersized bus clearance.
	canopy(b,Vector3(18.5,G,-846),Vector3(18.5,G,-865))
	canopy(b,Vector3(18.5,G,-865),Vector3(27,G,-876))
	canopy(b,Vector3(27,G,-876),Vector3(30,G,-882))
	canopy(b,Vector3(30,G,-882),Vector3(30,G,-890))
	# Research-side sidewalk, with a crossing to the public stair foot, follows the vehicle bend.
	builder.ribbon(b,[[38,G,-778],[38,G,-801],[38,G,-824],[23,G,-829],[16,G,-835],[16,G,-854],[28,G,-860],[38,G,-864]],3,"aaa99d",26,.105)
	for z in [-795,-815,-833]:S.grate(b,41,z)
	for z in [-784,-821]:S.street_lamp(b,Vector3(39,G,z),-1)
	# Last-owned asphalt is above historical decorative apron slabs, with a shared curve.
	for route: Dictionary in builder.data.routes:
		if not route.id in ["east_crossroad","tower_street_junction"]:continue
		if route.id=="east_crossroad":
			preload("res://world/visual_campus/GardenBackStreet.gd").band(b,builder,route.points,-route.width/2,route.width/2,"525955",32,.132,true,false,true)
		else:builder.ribbon(b,route.points,route.width,"414b4c",2,.132)
		var travelled:=0.0;var mark_at:=3.0
		for i in range(route.points.size()-1):
			var a:Vector3=builder.point(route.points[i]);var c:Vector3=builder.point(route.points[i+1]);var length:=a.distance_to(c)
			while mark_at<travelled+length:
				var p:=a.lerp(c,(mark_at-travelled)/length);p.y=builder.height(p.x,p.z)+.153
				K.box(b,p,Vector3(.12,.02,2.6),"cbb35d",false,22,atan2(c.x-a.x,c.z-a.z));mark_at+=8
			travelled+=length
	for i in range(-3,4):K.box(b,Vector3(9.4,G+.165,-838+i),Vector3(3.1,.02,.55),"d4d4c8",false,22)
	# Short pale crossings across the two side streets; no road crosses the axial garden.
	for x in [0.0,45.0]:
		for i in range(-3,4):K.box(b,Vector3(x+i*.9,G+.17,-791),Vector3(.5,.024,3.2),"d4d4c8",false,22)
	K.finish(b)
