extends RefCounted
## Both entrance-side cores reach5F; only the diagonal core continues to6F. Dimensions fitted.
const K := preload("res://world/visual_campus/LibraryCorePlanKit.gd")
const Stairs := preload("res://world/visual_campus/LibraryStairKit.gd")
const CORES := [{"id":"LibraryLeftServiceCore","position":Vector3(-26.9019243,0,9.3008526),"yaw":-0.0560585,"scale":Vector3(5.4/8.6,1,9.0/15.5),"triple":true},{"id":"LibraryDiagonalServiceCore","position":Vector3(.5,0,20.8),"yaw":PI/4,"scale":Vector3(9.2/15.2,1,11.5/15.2),"triple":false}]
const LEVELS := [0.0,4.4,8.8,12.8,16.8]

static func local_point(index: int,p: Vector3) -> Vector3:
	return CORES[index].position+Basis(Vector3.UP,CORES[index].yaw)*(p*CORES[index].scale)

static func rect_poly(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])

static func cut_openings(poly: PackedVector2Array) -> Array[PackedVector2Array]:
	# Partition around each stair rectangle. No unsupported polygon-with-hole triangulation.
	var parts: Array[PackedVector2Array]=[poly]
	for core in CORES:
		var forward:=Basis(Vector3.UP,float(core.yaw))*Basis.from_scale(core.scale);var inverse:=forward.inverse();var next: Array[PackedVector2Array]=[]
		for part in parts:
			var local:=PackedVector2Array()
			for q in part:
				var v: Vector3=inverse*(Vector3(q.x,0,q.y)-core.position);local.append(Vector2(v.x,v.z))
			var well:Rect2=Rect2(-3.5,-2.9,7,5.8) if core.triple else preload("res://world/visual_campus/LibraryDiagonalCore.gd").WELL
			for rect: Rect2 in [Rect2(-150,-150,well.position.x+150,300),Rect2(well.end.x,-150,150-well.end.x,300),Rect2(well.position.x,-150,well.size.x,well.position.y+150),Rect2(well.position.x,well.end.y,well.size.x,150-well.end.y)]:
				for fragment: PackedVector2Array in Geometry2D.intersect_polygons(local,rect_poly(rect)):
					var out:=PackedVector2Array()
					for q in fragment:
						var v: Vector3=core.position+forward*Vector3(q.x,0,q.y);out.append(Vector2(v.x,v.z))
					next.append(out)
		parts=next
	return preload("res://world/visual_campus/LibraryRemoteCore.gd").cut_openings(parts)

static func lift(n: Node3D,p: Vector3,yaw: float,level: int) -> void:
	var b:=K.holder(n,"LiftFront",p);b.rotation.y=yaw
	K.box(b,Vector3(0,1.55,-.85),Vector3(2.55,3.1,1.9),"a4aba1",true,22)
	for side in [-1,1]:
		K.box(b,Vector3(side*.50,1.22,.13),Vector3(.96,2.44,.055),"9aa69e",false,11)
		K.box(b,Vector3(side*1.05,1.25,.18),Vector3(.10,2.5,.14),"626e65",false,11)
	K.box(b,Vector3(0,2.52,.18),Vector3(2.2,.10,.15),"626e65",false,11)
	K.box(b,Vector3(0,2.77,.15),Vector3(.52,.24,.045),"354c42",false,22)
	K.label(b,str(level)+"F",Vector3(0,2.77,.19),.0028)
	K.box(b,Vector3(1.20,1.08,.20),Vector3(.13,.25,.035),"647269",false,11)
	K.finish(b)

static func core_build(parent: Node3D,index: int) -> void:
	var record: Dictionary=CORES[index];var n:=K.holder(parent,record.id,record.position);n.rotation.y=record.yaw
	n.set_meta("core_plan_scale",record.scale)
	var levels: Array=LEVELS.duplicate()
	if index==1:levels.append(20.8)
	var height: float=levels[-1]+3.8
	# Quiet walls and stair enclosure; every floor has a genuine side doorway at the rear landing.
	for side in [-1,1]:
		for span: Vector2 in [Vector2(-7.65,-5.0),Vector2(-2.6,7.65)]:
			K.box(n,Vector3(side*4.25,height/2,(span.x+span.y)/2),Vector3(.20,height,span.y-span.x),"b7b9aa",true,22)
		for y in levels:K.box(n,Vector3(side*4.25,y+3.35,-3.8),Vector3(.20,.9,2.4),"b7b9aa",true,22)
	for z in [-7.65,7.65]:K.box(n,Vector3(0,height/2,z),Vector3(8.6,height,.20),"aeb3a6",true,22)
	for level in levels.size():
		var y: float=levels[level]
		# Main and half-level landings are separate from the flight shafts.
		K.box(n,Vector3(0,y-.12,-3.8),Vector3(8.3,.24,1.8),"b8b8aa",true,12)
		for side in [-1,1]:K.box(n,Vector3(side*3.5,y-.12,1.6),Vector3(1.2,.24,9.0),"b8b8aa",true,12)
		K.box(n,Vector3(0,y-.12,5.975),Vector3(8.3,.24,3.35),"b8b8aa",true,12)
		if record.triple:
			for x in [-1.42,1.42]:lift(n,Vector3(x,y,-5.25),0,level+1)
		lift(n,Vector3(0,y,5.25),PI,level+1)
		if not record.triple:
			for side in [-1,1]:
				K.box(n,Vector3(side*2.8,y+1.35,5.2),Vector3(1.45,2.7,.16),"939d8d",true,22)
				K.label(n,"卫生间",Vector3(side*2.8,y+2.85,5.04),.003).rotation.y=PI
		K.label(n,str(level+1)+"F · 楼梯 / 电梯",Vector3(4.38,y+2.75,-3.8),.0036).rotation.y=PI/2
		K.box(n,Vector3(0,y+3.82,-3.8),Vector3(1.1,.05,.40),"dedfc8",false,17)
		var lamp:=OmniLight3D.new();lamp.position=Vector3(0,y+3,-3.8)*record.scale;lamp.light_energy=.6;lamp.omni_range=10;lamp.light_color=Color("ede7d3");n.add_child(lamp)
		if level==levels.size()-1:continue
		var half: float=(levels[level+1]-y)/2
		var first:=K.holder(n,"FireStairOutward",Vector3(-1.45,y,-2.8))
		Stairs.flight(first,5.6*record.scale.z,half,2.1*record.scale.x);K.finish(first)
		K.box(n,Vector3(0,y+half-.12,3.8),Vector3(7,.24,2.0),"b8b8aa",true,12)
		var second:=K.holder(n,"FireStairReturn",Vector3(1.45,y+half,2.8));second.rotation.y=PI
		Stairs.flight(second,5.6*record.scale.z,half,2.1*record.scale.x);K.finish(second)
		# Central well guard continues through the turning landing without sealing either flight.
		K.box(n,Vector3(0,y+half+1,4.66),Vector3(5.8,1.1,.12),"687c70",true,11)
	K.box(n,Vector3(0,height-.08,0),Vector3(8.7,.16,15.5),"adb1a3",false,22)
	K.finish(n)

static func build(parent: Node3D) -> void:
	core_build(parent,0)
	preload("res://world/visual_campus/LibraryDiagonalCore.gd").build(parent)
	preload("res://world/visual_campus/LibraryRemoteCore.gd").build(parent)
	var b:=K.holder(parent,"LibraryCoreWingConnections")
	# RegisteredFloors owns the continuous wing slab.
	# Clear approaches to the side doors; upper short bridges meet retained floor edges.
	# Both plan-corrected cores now join the continuous slabs without the retired offset bridge.
	# The broader diagonal wing now joins the registered slabs directly.
	# Retire the old offset approach bridges instead of leaving floating duplicate decks.
	K.finish(b)
