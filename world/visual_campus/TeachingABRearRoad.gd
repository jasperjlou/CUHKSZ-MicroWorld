extends RefCounted
## V140: legacy A rear samples17.8/17.9 vs front26.7 support the lower road.
## -1.83 is (17.9-26.7)*.4625+2.24, a fitted scale, NOT surveyed metres.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const A:float=-1.83
const B:float=-2.325
const G:float=2.24
const CUTS:Array[Rect2]=[Rect2(-128.2,-78,77.2,8),Rect2(-128.2,-163.8,6.4,85.8),Rect2(-138.32,-170.2,16.52,6.4),Rect2(-138.32,-181.5,6.4,11.3)]

static func cutout(x:float,z:float)->bool:
	for r:Rect2 in CUTS:
		if r.has_point(Vector2(x,z)):return true
	return false

static func terrain_breaks()->Dictionary:
	var xs:Array[float]=[];var zs:Array[float]=[-148]
	for r:Rect2 in CUTS:
		xs.append_array([r.position.x,r.end.x]);zs.append_array([r.position.y,r.end.y])
	return {"x":xs,"z":zs}

static func wall(n:Node3D,a:Vector3,b:Vector3)->void:
	# Variable-height retaining face, not a tilted rectangular block.
	var v:=K.quad(a,b,Vector3(b.x,G,b.z),Vector3(a.x,G,a.z))
	var back:=v.duplicate();back.reverse();v.append_array(back)
	K.surface(n,v,"a6aaa0",15,true)
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	if is_equal_approx(a.x,b.x) and a.x>-139.5 and a.x<-118.2:
		# The upper bridge replaces the excavation-edge guard along its crossing.
		# Keeping that guard through the deck would fence off both bridge entrances.
		var lo:float=minf(a.z,b.z);var hi:float=maxf(a.z,b.z)
		for span:Vector2 in [Vector2(lo,minf(hi,-169.2)),Vector2(maxf(lo,-164.8),hi)]:
			if span.y>span.x:C.rail(n,Vector3(a.x,G,span.x),Vector3(a.x,G,span.y))
	else:C.rail(n,Vector3(a.x,G,a.z),Vector3(b.x,G,b.z))

static func build(root:Node3D)->void:
	var n:=K.holder(root,"TeachingABRearRoadV140")
	var S:Script=load("res://world/visual_campus/ZhangCourtGround.gd")
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	S.floor_rect(n,-128.2,-121.8,-78,-70,A)
	S.slope(n,Vector3(-121.8,A,-74),Vector3(-54,G,-74),8)
	S.floor_rect(n,-54,-51,-78,-70,G)
	S.floor_rect(n,-128.2,-121.8,-148,-78,A)
	S.slope(n,Vector3(-125,A,-148),Vector3(-125,B,-163.8),6.4)
	S.floor_rect(n,-138.32,-121.8,-170.2,-163.8,B)
	S.floor_rect(n,-138.32,-131.92,-181.5,-170.2,B)
	# V197 outside apron shares the low road; remove its invented outer canyon wall.
	for x in [-121.8]:
		wall(n,Vector3(x,A,-78),Vector3(x,A,-148))
		wall(n,Vector3(x,A,-148),Vector3(x,B,-163.8))
	for z in [-78,-70]:wall(n,Vector3(-121.8,A,z),Vector3(-54,G,z))
	wall(n,Vector3(-128.2,A,-70),Vector3(-121.8,A,-70))
	wall(n,Vector3(-128.2,A,-78),Vector3(-128.2,A,-70))
	# Crossroad perimeter deliberately omits all three road openings.
	# Gate-axis profiles rise from the rear datum toward the mall. No overpass
	# exists in this source strip; SouthGateAvenue now owns the continuous slope.
	# The low junction and B opening remain unobstructed on all three branches.
	var apron:=K.holder(n,"OpenRearApronV197")
	K.surface(apron,K.quad(Vector3(-148,A+.025,-148),Vector3(-128.2,A+.025,-148),Vector3(-128.2,A+.025,-78),Vector3(-148,A+.025,-78)),"414b4c",2)
	for z in range(-144,-82,12):
		K.box(apron,Vector3(-146.8,A+.046,z),Vector3(.20,.025,5),"60685f",false,11)
	K.finish(apron)
	# Recessed drains follow the low road rather than floating on the former upper plane.
	for z in range(-146,-80,8):K.box(n,Vector3(-127.8,A+.014,z),Vector3(.22,.025,5),"66736c",false,11)
	K.box(n,Vector3(-125,B+.012,-169.8),Vector3(5.6,.024,.20),"66736c",false,11)
	K.finish(n)
