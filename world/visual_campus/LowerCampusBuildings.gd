extends RefCounted
## Exterior masses from named official panorama views; dimensions remain estimates.
const SportsComplex := preload("res://world/visual_campus/SportsComplex.gd")
const Western := preload("res://world/visual_campus/WesternCampus.gd")
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Landmarks := preload("res://world/visual_campus/LandmarkBuildings.gd")
const StartZone := preload("res://world/visual_campus/StartZoneBuildings.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	if Landmarks.handles(r.id):
		Landmarks.build(b,r)
		return
	if StartZone.handles(r.id):
		StartZone.build(b,r)
		return
	match r.model:
		"academic":academic(b,r)
		"laboratory":laboratory(b,r)
		"dormitory":dormitory(b,r)
		"research":research(b,r)
		"sports":sports(b,r)
		"sports_complex":SportsComplex.build(b)
		"gate":gate(b,r)
		"track":track(b,r)

static func academic(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth;var top: float=r.floor_levels[-1]
	# Recessed glass base, white classroom bars and a roof parapet.
	K.volume(b,Vector3(0,4.6,-d*.18),Vector3(w,top-4.6,d*.62),"c0c5bd",r.floor_levels.slice(1).map(func(v):return float(v)-4.6))
	K.gallery(b,Vector3(0,0,d*.24),w,9,4.6)
	for side in [-1,1]:
		K.volume(b,Vector3(side*w*.40,0,0),Vector3(w*.2,top,d*.8),"b6bdb5",r.floor_levels)
		K.box(b,Vector3(side*w*.33,8,d*.43),Vector3(3,6,.12),"80618b")
	for x in range(-int(w*.3),int(w*.3),3):
		if abs(x)<5:continue
		K.window(b,Vector3(x,2.3,d*.16),2.4,3.8)
	K.label(b,r.name,Vector3(0,5.2,d*.42),.009)
	if r.id=="zhi_xin":
		K.box(b,Vector3(0,2.5,d*.46),Vector3(12,3.2,.14),"506976",false,5)
		K.label(b,"Philip Yu Library",Vector3(0,3,d*.48),.009)
	for x in [-w*.22,w*.22]:K.bench(b,Vector3(x,0,d*.30))

static func laboratory(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	K.volume(b,Vector3(0,0,-d*.29),Vector3(w,23.3,d*.30),"b8c0b6",[0,4.8,8.5,12.2,15.9,19.6,23.3])
	for side in [-1,1]:K.volume(b,Vector3(side*w*.35,4.8,0),Vector3(w*.30,18.5,d*.75),"65756f",[0,3.7,7.4,11.1,14.8,18.5])
	K.gallery(b,Vector3(0,0,d*.31),w*.85,8,4.8)
	K.screen(b,Vector3(-w*.27,0,d*.40),w*.22,4.6,.5)
	for y in [8.5,12.2,15.9,19.6]:
		K.box(b,Vector3(0,y,d*.08),Vector3(w*.5,.26,6),"a9b1a7")
		K.box(b,Vector3(0,y+1.45,d*.15),Vector3(w*.50,2.35,.12),"485f6b",false,5)
		for x in range(-int(w*.25),int(w*.25),1):K.box(b,Vector3(x,y+1.4,d*.23),Vector3(.07,2.8,.18),"a6956e",false,4)
	K.label(b,"张岭彬楼 · 原教学D",Vector3(0,5.5,d*.43),.01)

static func dormitory(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth;var top: float=r.floor_levels[-1]
	K.volume(b,Vector3(0,4.8,-d*.20),Vector3(w,top-4.8,d*.54),"b8c3b8",[])
	for side in [-1,1]:K.volume(b,Vector3(side*w*.37,0,0),Vector3(w*.25,top,d*.8),"c4cbbf",[])
	for y: float in r.floor_levels.slice(1):
		if y>=top:continue
		K.box(b,Vector3(0,y,d*.09),Vector3(w*.76,.28,6),"9ba998")
		for x in range(-int(w*.36),int(w*.36),3):
			K.window(b,Vector3(x,y+1.45,d*.04),1.65,2.35)
			K.box(b,Vector3(x,y+1.0,d*.15),Vector3(2.9,.12,.10),"67766b")
		K.box(b,Vector3(0,y+1.15,d*.15),Vector3(w*.74,.07,.07),"657469")
		for x in range(-int(w*.36),int(w*.36),1):K.box(b,Vector3(x,y+.6,d*.15),Vector3(.05,1.1,.05),"657469")
	K.gallery(b,Vector3(0,0,d*.23),w*.86,10,4.8)
	K.screen(b,Vector3(-w*.25,0,d*.40),w*.2,4.3)
	K.label(b,r.name,Vector3(0,5.5,d*.43),.01)
	for x in [-10,10]:K.planter(b,Vector3(x,0,d*.35))

static func research(b: Node3D,r: Dictionary) -> void:
	preload("res://world/visual_campus/ResearchComplex.gd").build(b,r)
	return

static func legacy_research_backdoor(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	# Backdoor panorama: a light stone cantilever and sheltered route on columns.
	K.volume(b,Vector3(0,5,-6),Vector3(w,12,d*.62),"c1c7bd",[0,4,8,12])
	K.volume(b,Vector3(-w*.19,17,-6),Vector3(w*.48,24,d*.62),"b1bab0",[0,4,8,12,16,20,24])
	K.volume(b,Vector3(w*.29,17,-6),Vector3(w*.22,16,d*.58),"bfc7bc",[0,4,8,12,16])
	for x in [-w*.36,0,w*.36]:
		round_column(b,Vector3(x,0,d*.05),5,.58)
		K.box(b,Vector3(x,4.8,d*.10),Vector3(3.2,.35,10),"a8b2a5")
	K.gallery(b,Vector3(0,0,d*.35),w*.9,8,5)
	K.screen(b,Vector3(w*.24,0,d*.18),w*.28,4.6,.45)
	K.label(b,"科研楼",Vector3(0,5.7,d*.49),.012)
	# Backdoor close-up: horizontal stone strips, bronze louvers and a round-column soffit.
	for y in [5.0,9.0,13.0,17.0]:K.box(b,Vector3(0,y,d*.31-6+.25),Vector3(w,.20,.30),"d0cbbd")
	for x in [-w*.25,0,w*.25]:
		for slat in 22:K.box(b,Vector3(x,8.0+slat*.24,d*.31-6+.42),Vector3(8,.065,.35),"a38a64",false,4)
	for x in [-w*.30,w*.30]:
		K.box(b,Vector3(x,2.2,d*.31-6-.2),Vector3(w*.30,4.1,.1),"4d6973",false,5)
	# The upper tower height is an explicit map-based estimate, not a backdoor count.
	for z in [-8,8]:K.planter(b,Vector3(-w*.38,0,z))
	# Deep cantilever, round columns and soffit: visible in the named backdoor panorama.
	# The former narrow gallery alone left a grass gap under an apparently floating tower.
	K.box(b,Vector3(0,.058,10),Vector3(w+.8,.04,25),"a5a89d",false,23)
	K.box(b,Vector3(0,5.06,14),Vector3(w*.94,.38,16),"c5c8bd",true,15)
	K.box(b,Vector3(0,5.52,21.9),Vector3(w*.94,1.15,.26),"c8c9c0",false,22)
	for y in [5.04,5.39,5.75,6.05]:K.box(b,Vector3(0,y,22.06),Vector3(w*.94,.028,.025),"8d978b",false,6)
	for x in [-27,-13,13,27]:
		round_column(b,Vector3(x,0,18.7),4.87,.46)
		K.box(b,Vector3(x,4.78,14),Vector3(.38,.25,15.4),"a7b0a2",false,15)
		K.box(b,Vector3(x,4.82,18.2),Vector3(1.6,.035,.20),"dfdbc1",false,17)
	for x in [-21,-7,7,21]:K.box(b,Vector3(x,.093,21.7),Vector3(8,.018,.15),"52665a",false,11)

static func round_column(b: Node3D,p: Vector3,height: float,radius: float) -> void:
	var mesh:=CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=16
	var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=K.material("c7cabe");n.position=p+Vector3.UP*height/2;b.add_child(n)
	var body:=StaticBody3D.new();var c:=CollisionShape3D.new();var shape:=CylinderShape3D.new();shape.height=height;shape.radius=radius
	c.shape=shape;body.position=n.position;body.add_child(c);b.add_child(body)

static func sports(b: Node3D,r: Dictionary) -> void:
	Western.sports(b,r)

static func gate(b: Node3D,r: Dictionary) -> void:
	if r.id=="old_gate":Western.old_gate(b)
	else:Western.west_waypoint(b)

static func track(b: Node3D,_r: Dictionary) -> void:
	Western.track(b)
