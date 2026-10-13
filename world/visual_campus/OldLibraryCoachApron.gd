extends RefCounted
## Photo222613 + official aerial92544949: coaches beyond court, beside service road.
## Layout, coach dimensions and occupancy are fitted scene reconstruction, not a live fleet.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
static func coach(parent:Node3D,p:Vector3,accent:String)->void:
	# Local +X is the nose facing the approach; leave a separate road and footway.
	var n:=K.holder(parent,"ParkedCampusCoachV215",p)
	K.box(n,Vector3(0,1.35,0),Vector3(10.7,1.35,2.5),"d6d9d4",true,22)
	K.box(n,Vector3(-.15,2.60,0),Vector3(10.1,1.65,2.46),"2e444b",true,22)
	K.box(n,Vector3(-.15,3.43,0),Vector3(10.2,.16,2.52),"d2d6d0",false,22)
	K.box(n,Vector3(-1.0,3.57,0),Vector3(3.2,.17,1.55),"bdc7c1",false,22)
	for side:float in [-1,1]:
		K.box(n,Vector3(-.15,1.65,side*1.263),Vector3(10.2,.38,.035),accent,false,22)
		for x:float in [-4.7,-3.4,-2.1,-.8,.5,1.8,3.1,4.5]:
			K.box(n,Vector3(x,2.66,side*1.246),Vector3(.065,1.37,.055),"788881",false,11)
		for x:float in [-3.5,3.2]:
			var wheel:=MeshInstance3D.new();var cylinder:=CylinderMesh.new()
			cylinder.top_radius=.53;cylinder.bottom_radius=.53;cylinder.height=.27;cylinder.radial_segments=20
			wheel.mesh=cylinder;wheel.material_override=K.material("272e2c",22);wheel.rotation.x=PI/2;wheel.position=Vector3(x,.53,side*1.23);n.add_child(wheel)
			var hub:=MeshInstance3D.new();var disk:=CylinderMesh.new();disk.top_radius=.28;disk.bottom_radius=.28;disk.height=.025;disk.radial_segments=16
			hub.mesh=disk;hub.material_override=K.material("909b96",11);hub.rotation.x=PI/2;hub.position=Vector3(x,.53,side*1.38);n.add_child(hub)
		K.box(n,Vector3(5.42,1.05,side*.77),Vector3(.08,.18,.40),"dbe0d2",false,22)
		K.box(n,Vector3(4.5,2.97,side*1.55),Vector3(.38,.30,.16),"54645e",false,11)
		K.box(n,Vector3(4.4,3.06,side*1.36),Vector3(.10,.08,.43),"8b9790",false,11)
	# Sloped windshield and narrow wiper arms separate the coach from a glass box.
	K.surface(n,PackedVector3Array([Vector3(5.37,1.83,-1.18),Vector3(4.89,3.32,1.18),Vector3(4.89,3.32,-1.18),Vector3(5.37,1.83,-1.18),Vector3(5.37,1.83,1.18),Vector3(4.89,3.32,1.18)]),"263d43",22)
	K.box(n,Vector3(5.16,1.44,0),Vector3(.30,.48,2.45),accent,false,22)
	K.box(n,Vector3(5.36,.83,0),Vector3(.11,.17,2.40),"66766f",false,11)
	for z:float in [-.62,.62]:K.box(n,Vector3(5.30,1.95,z),Vector3(.08,.08,.64),"6c7c74",false,11)
	for i in 5:K.box(n,Vector3(-5.37,1.0+i*.10,0),Vector3(.025,.035,1.8),"56655f",false,11)
	# Entrance outline on the passenger flank, no invented route labels or branding.
	K.box(n,Vector3(3.85,1.63,1.285),Vector3(.85,2.35,.03),"2b4145",false,22)
	K.box(n,Vector3(3.85,1.62,1.31),Vector3(.025,2.35,.025),"9faea4",false,11)
	K.finish(n)
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"OldLibraryCoachApronV215")
	# The old long placeholder overlaid the through road. Park on the court side instead.
	K.box(n,Vector3(-103,G+.168,-668),Vector3(25,.024,22),"515956",false,32)
	for z:float in [-676.5,-671.4,-666.3,-661.2]:
		K.box(n,Vector3(-104,G+.187,z),Vector3(12.2,.01,.11),"ced2c5",false,22)
	K.box(n,Vector3(-110.1,G+.187,-668.85),Vector3(.11,.01,15.4),"ced2c5",false,22)
	for item in [[-673.9,"496d96"],[-668.8,"486f82"],[-663.7,"73917a"]]:
		coach(n,Vector3(-104,G+.18,item[0]),item[1])
	# Fitted paved forecourt and narrow pedestrian return remain outside parked bodies.
	builder.ribbon(n,[[-90,G,-676.4],[-90,G,-658],[-116.5,G,-658],[-116.5,G,-676.4]],2.0,"918c7c",65,.16)
	K.box(n,Vector3(-89.2,G+1.4,-673.4),Vector3(.065,2.8,.065),"7b8980",true,11)
	K.box(n,Vector3(-89.2,G+2.65,-673.4),Vector3(.075,.72,.59),"386983",false,22)
	var sign:=K.holder(n,"ParkingSymbol",Vector3(-89.155,G+2.65,-673.4));sign.rotation.y=PI/2
	var letter:=K.label(sign,"P",Vector3.ZERO,.006);letter.font_size=80
	# Tree belt observed behind/along the bays, rather than a new hill or enclosing wall.
	for p:Vector2 in [Vector2(-121,-658),Vector2(-113,-653.5),Vector2(-103,-653.5),Vector2(-92,-653.5)]:
		K.tree(n,Vector3(p.x,G,p.y),8.5,21500+absi(int(p.x)),1.4)
		V.shrub(n,Vector3(p.x,G,p.y),Vector3(5.5,.7,2.7),21500+absi(int(p.x)))
	K.finish(n)
