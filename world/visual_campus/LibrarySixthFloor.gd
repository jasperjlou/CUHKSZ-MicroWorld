extends RefCounted
## Reduced 6F plan, aligned to the 2025-09 official room-use update. Metric placement is fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const A := preload("res://world/visual_campus/LibraryAtrium.gd")
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
const Y := 20.8
const GROUP_ROOMS := [606,607,611,612,619,621,629]

static func floor_part(n: Node3D,p: PackedVector2Array,rect: Rect2) -> void:
	for part: PackedVector2Array in Geometry2D.intersect_polygons(p,Core.rect_poly(rect)):
		for fragment: PackedVector2Array in Core.cut_openings(part):
			A.plane(n,fragment,Y);A.plane(n,fragment,Y-.28,true)

static func cell(n: Node3D,id: int,p: Vector3,yaw: float,width: float=2.2,depth: float=2.5) -> void:
	var b:=K.holder(n,"ResearchCell"+str(id),p);b.rotation.y=yaw
	# Publicly visible envelope only. Staff interiors are not inferred from map symbols.
	for side in [-1,1]:K.box(b,Vector3(side*width/2,1.3,0),Vector3(.10,2.6,depth),"c4c9bd",true,22)
	K.box(b,Vector3(0,1.3,-depth/2),Vector3(width,2.6,.12),"bcc5b8",true,22)
	K.box(b,Vector3(0,2.62,0),Vector3(width+.1,.10,depth+.1),"d7d9ce",false,22)
	for side in [-1,1]:K.box(b,Vector3(side*(width/4+.28),1.3,depth/2),Vector3(width/2-.55,2.6,.10),"c1c9bb",true,22)
	K.box(b,Vector3(0,1.22,depth/2),Vector3(1.08,2.44,.08),"77938f",true,19)
	for x in [-.58,.58]:K.box(b,Vector3(x,1.27,depth/2+.05),Vector3(.06,2.54,.10),"778779",false,11)
	K.box(b,Vector3(0,2.47,depth/2+.07),Vector3(1.2,.14,.10),"697b69",false,11)
	K.box(b,Vector3(.4,1.05,depth/2+.11),Vector3(.035,.27,.04),"b3b9ad",false,11)
	var group: bool=id in GROUP_ROOMS
	K.box(b,Vector3(0,2.30,depth/2+.09),Vector3(.9,.25,.035),"9f9369" if group else "5d7180",false,22)
	K.label(b,("S" if id in [501,502] else "")+str(id),Vector3(0,2.3,depth/2+.12),.003)
	K.finish(b)

static func cluster(n: Node3D,ids: Array,p: Vector3,yaw: float) -> void:
	var b:=K.holder(n,"SixthCellCluster"+str(ids[0]),p);b.rotation.y=yaw
	for i in 3:cell(b,int(ids[i]),Vector3((i-1)*2.3,0,-1.35),PI)
	for i in 2:cell(b,int(ids[i+3]),Vector3((i-.5)*3.45,0,1.35),0,3.35)
	K.finish(b)

static func desk(n: Node3D,p: Vector3,yaw: float=0) -> void:
	var b:=K.holder(n,"OpenStudyTable",p);b.rotation.y=yaw
	K.box(b,Vector3(0,.75,0),Vector3(3.2,.08,1.3),"bba884",false,4)
	for x in [-1.3,1.3]:K.box(b,Vector3(x,.36,0),Vector3(.08,.72,.9),"809084",false,11)
	for x in [-.9,.9]:
		for side in [-1,1]:
			K.box(b,Vector3(x,.44,side*1.05),Vector3(.56,.08,.52),"91a28c",false,22)
			K.box(b,Vector3(x,.73,side*1.29),Vector3(.56,.60,.07),"82967d",false,22)
	K.finish(b)

static func build(parent: Node3D,p: PackedVector2Array) -> void:
	var n:=K.holder(parent,"LibraryReducedSixthFloor")
	floor_part(n,p,Rect2(13,-20,137,170))
	floor_part(n,p,Rect2(-16,12,29,138))
	floor_part(n,p,Rect2(-16,-6,29,2))
	A.flight(n,Vector3(-12,16.8,12),PI)
	# The left wing and far rear reading bay stay open to the level below.
	A.edge(n,Vector3(13,Y,-4),Vector3(13,Y,12))
	A.edge(n,Vector3(-16,Y,-6),Vector3(-16,Y,-4))
	A.edge(n,Vector3(-16,Y,-6),Vector3(13,Y,-6))
	for span: Vector2 in [Vector2(-16,-13.8),Vector2(-10.2,13)]:A.edge(n,Vector3(span.x,Y,-4),Vector3(span.y,Y,-4))
	A.edge(n,Vector3(-16,Y,12),Vector3(13,Y,12))
	A.core_guard(n,Y)
	A.edge(n,Vector3(-16,Y,12),Vector3(-16,Y,28.9))
	# Rear cutoff guard endpoints follow the clipped footprint instead of floating across the notch.
	for part: PackedVector2Array in Geometry2D.intersect_polygons(p,Core.rect_poly(Rect2(13,-20,137,170))):
		for i in part.size():
			var a:=part[i];var b:=part[(i+1)%part.size()]
			if absf(a.y+20)<.01 and absf(b.y+20)<.01:A.edge(n,Vector3(a.x,Y,a.y),Vector3(b.x,Y,b.y))
	cluster(n,[628,627,626,629,630],Vector3(29,Y,-15),0)
	cluster(n,[620,619,618,616,617],Vector3(21,Y,-5),0)
	cluster(n,[623,624,625,621,622],Vector3(32,Y,-5),PI/4)
	cluster(n,[613,614,615,611,612],Vector3(21,Y,6),PI/4)
	cluster(n,[610,609,608,606,607],Vector3(30,Y,3.5),0)
	for i in 4:
		var point:=Core.local_point(1,Vector3(9.6,Y,-5.0+i*2.5/Core.CORES[1].scale.z))
		cell(n,602+i,point,-PI/4,2.35,2.6)
	for p2: Vector2 in [Vector2(28,-10),Vector2(15.5,0),Vector2(15.5,7)]:desk(n,Vector3(p2.x,Y,p2.y),PI/2)
	K.label(n,"6F · 开放学习区",Vector3(16,Y+2.3,11),.006)
	K.box(n,Vector3(4,Y+.6,14.4),Vector3(1.3,1.2,.8),"b9c1b4",false,22)
	K.box(n,Vector3(4,Y+1.28,14.4),Vector3(1.15,.16,.7),"56695d",false,11)
	for x in [19,32]:
		K.box(n,Vector3(x,Y+3.75,-7),Vector3(.12,.06,23),"e4e2d3",false,17)
		var light:=OmniLight3D.new();light.position=Vector3(x,Y+3,-5);light.light_energy=.7;light.omni_range=19;light.light_color=Color("eef0de");n.add_child(light)
	K.finish(n)
