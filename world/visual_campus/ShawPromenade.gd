extends RefCounted
## Official70040609 shows brown rectangular pavers and a hillside side branch.
## 2026-09 lantern-event photo corroborates paving type, not surveyed coordinates.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const PAVER:="746c69"

static func height_blend(x: float,z: float,across: float) -> float:
	# Gentle terrain beside the end wall, joining the existing raised rear court.
	# Avoid the old near-vertical x99.3-99.7 grade jump through this public path.
	var blend: float=smoothstep(-505,-502.5,z)*(1.0-smoothstep(-495,-492,z))
	return lerpf(across,smoothstep(94,116,x)*(1.0-smoothstep(145,175,x)),blend)

static func flower_box(n: Node3D,p: Vector3,seed: int) -> void:
	K.box(n,p+Vector3.UP*.30,Vector3(1.12,.60,1.12),"685447",true,4)
	K.box(n,p+Vector3.UP*.61,Vector3(.99,.035,.99),"504a35",false,8)
	for side in [-1,1]:
		K.box(n,p+Vector3(side*.56,.62,0),Vector3(.065,.07,1.17),"90745d",false,4)
		K.box(n,p+Vector3(0,.62,side*.56),Vector3(1.17,.07,.065),"90745d",false,4)
	V.branch(n,p+Vector3.UP*.6,p+Vector3(.08,1.7,.03),.035)
	V.shrub(n,p+Vector3(0,.9,0),Vector3(1.1,.65,1.1),seed)
	# Sparse paper-like bracts, not photographic vegetation or temporary event props.
	for i in 15:
		var a:float=i*2.39996;var q:=p+Vector3(cos(a)*.45,1.35+sin(i*1.8)*.3,sin(a)*.45)
		K.box(n,q,Vector3(.10,.045,.09),"b44b86" if i%3 else "d873a3",false,22,a)

static func build(root: Node3D,builder) -> void:
	var n:=K.holder(root,"ShawEastPaverPromenadeV75")
	# Retain the front entrance stair, turning only its street approach to pavers.
	builder.ribbon(n,[[42,G,-494],[42,G,-574]],16,PAVER,33,.14)
	# V127 source-led lower lane now owns this approach, including its fitted rise to Z=-493.
	for x in [36.8,47.6]:builder.ribbon(n,[[x,G,-496],[x,G,-574]],.24,"8d9995",26,.153)
	for z in [-516,-541,-570]:builder.ribbon(n,[[34.0,G,z],[50.0,G,z]],.27,"6b6c64",26,.154)
	for route: Dictionary in builder.data.routes:
		if route.id=="shaw_east_paver_side_link":
			builder.ribbon(n,route.points,6.4,PAVER,33,.14)
			for side in [-1,1]:
				var edge:=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(route.points,side*3.10)
				builder.ribbon(n,edge,.18,"8d9995",26,.157)
	# Exposed entrance apron: no planted bed across the existing broad main stair.
	builder.ribbon(n,[[42,G,-560],[49.1,G,-560]],12,PAVER,33,.14)
	# The side transition has curvature in both axes. Sample the width as well,
	# so the terrain cannot protrude through a single broad cross-slope chord.
	var paving:=PackedVector3Array()
	for x in range(94,120):
		for j in 8:
			var za:float=-502.2+j*.8;var zc:float=za+.8
			var ps:Array[Vector3]=[]
			for p:Vector2 in [Vector2(x,za),Vector2(x+1,za),Vector2(x+1,zc),Vector2(x,zc)]:ps.append(Vector3(p.x,builder.height(p.x,p.y)+.17,p.y))
			paving.append_array(K.quad(ps[0],ps[1],ps[2],ps[3]))
	K.surface(n,paving,PAVER,33)
	# Tree strip against the building, split around its main door/steps.
	for bounds: Vector2 in [Vector2(-547,-509),Vector2(-574,-573)]:
		K.box(n,Vector3(52.3,G+.11,(bounds.x+bounds.y)/2),Vector3(3.4,.13,bounds.y-bounds.x),"667750",false,3)
	for z in [-514,-530,-544]:
		K.tree(n,Vector3(52.2,G+.18,z),10.2,7500+absi(z),1.4)
		V.shrub(n,Vector3(53,G+.17,z),Vector3(2.0,.45,4.5),7500+absi(z))
		# Three-point braces observed on young street trees.
		for a in [0.0,2.094,4.189]:V.branch(n,Vector3(52.2+cos(a)*.95,G,z+sin(a)*.95),Vector3(52.2,G+2.25,z),.026)
	for z in [-507,-533,-569]:
		K.box(n,Vector3(33,G+3.45,z),Vector3(.13,6.9,.13),"9aa8a1",false,11)
		K.box(n,Vector3(33.55,G+6.78,z),Vector3(1.2,.10,.12),"9aa8a1",false,11)
		K.box(n,Vector3(34.0,G+6.73,z),Vector3(.75,.11,.34),"7f908a",false,11)
		K.box(n,Vector3(34.0,G+6.66,z),Vector3(.59,.025,.24),"d0d6c4",false,17)
	# Flower border towards Student Centre; public branch remains unobstructed.
	for z in [-480,-486,-492]:
		V.shrub(n,Vector3(22,G+.10,z),Vector3(3,.7,4.2),7500+absi(z))
	# Layered planted edge visible across the side branch towards Student Centre.
	for x in [56,65,74,83]:
		V.shrub(n,Vector3(x,G+.08,-494),Vector3(6,.65,1.5),7500+x)
		V.shrub(n,Vector3(x+1,G+.08,-490.5),Vector3(3,1.15,2.2),7600+x)
		K.tree(n,Vector3(x-1,G+.08,-487.5),8.5,7700+x,1.2)
	for p: Vector2 in [Vector2(49.6,-494.8),Vector2(61,-494.8),Vector2(82,-494.8),Vector2(47.7,-503.8)]:
		flower_box(n,Vector3(p.x,builder.height(p.x,p.y)+.14,p.y),int(p.x)*75)
	for z in [-514,-540]:K.bench(n,Vector3(31.5,G,z),-PI/2)
	K.finish(n)
