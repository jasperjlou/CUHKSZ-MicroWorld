extends RefCounted
## Central Mall scene 116440794: white vertical wings, dark base, finned glass bridge.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const Rear := preload("res://world/visual_campus/AdministrationRearBridge.gd")
const Site := preload("res://world/visual_campus/LowerCampusLandscape.gd")

static func rear_terrace(b: Node3D,builder: RefCounted) -> void:
	# A third ascent reaches the official 4F backdoor level; heights remain inferred, not surveyed.
	builder.stairs(b,Vector3(0,8.8,-26),Vector3(0,12.4,-38),20,23)
	K.box(b,Vector3(0,12.24,-41.5),Vector3(40,.32,7),"aaa99c",true,6)
	K.box(b,Vector3(0,12.24,-24.5),Vector3(40,.32,3),"aaa99c",true,6)
	for side in [-1,1]:
		K.box(b,Vector3(side*15,12.24,-32),Vector3(10,.32,16),"aaa99c",true,6)
		K.box(b,Vector3(side*20,6.2,-34),Vector3(.5,12.4,22),"939b8c",true,15)
		if side<0:C.glass_rail(b,Vector3(side*20,12.4,-34),22,PI/2)
		else:
			C.glass_rail(b,Vector3(20,12.4,-29.8),13.6,PI/2)
			C.glass_rail(b,Vector3(20,13.0,-42),6,PI/2)
		C.glass_rail(b,Vector3(side*10,12.4,-31.8),11.4,PI/2)
		for z in [-29,-40]:
			if side>0 and z==-40:continue
			Site.hedge(b,Vector3(side*17.3,12.4,z),Vector2(2.7,5))
		K.bench(b,Vector3(side*14,13.0 if side>0 else 12.4,-41.5),PI/2)
	K.box(b,Vector3(0,6.2,-45),Vector3(40,12.4,.5),"939b8c",true,15)
	C.glass_rail(b,Vector3(-12,12.4,-45),16)
	C.glass_rail(b,Vector3(7,12.4,-45),6)
	C.glass_rail(b,Vector3(15,13.0,-45),10)
	preload("res://world/visual_campus/AdministrationLookout.gd").build(b,builder)

static func white_elevation(b: Node3D,p: Vector3,width: float,yaw: float=0.0) -> void:
	var n:=K.holder(b,"AdministrationWhitePanels",p);n.rotation.y=yaw
	var count:=maxi(2,int(width/3.2));var pitch:=width/count
	K.box(n,Vector3(0,4.48,-.42),Vector3(width,.28,.84),"494e4e",true)
	K.box(n,Vector3(0,12.28,-.3),Vector3(width,.24,.6),"454a49")
	K.box(n,Vector3(0,8.4,-1.12),Vector3(width,7.6,.25),"4c5352",true)
	for i in count:
		var x: float=-width/2+(i+.5)*pitch
		K.box(n,Vector3(x-pitch*.13,8.4,-.22),Vector3(pitch*.67,7.65,.44),"c8c9c2",false,22)
		K.box(n,Vector3(x-pitch*.18,8.4,.017),Vector3(.035,7.6,.05),"8f9691",false,11)
		var wx:=x+pitch*.365
		K.window(n,Vector3(wx,8.38,-.42),pitch*.24,6.2)
		K.box(n,Vector3(wx,9.5,-.33),Vector3(pitch*.26,.85,.16),"55534f")
	K.finish(n)

static func build(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	var w: float=r.width;var d: float=r.depth;var wing_w:=w*.27;var wing_x: float=w/2-wing_w/2
	for side in [-1,1]:
		var x: float=side*wing_x
		K.box(b,Vector3(x,4.27,0),Vector3(wing_w,.32,d),"aeb3a9",true)
		K.box(b,Vector3(x,12.225,0),Vector3(wing_w+.4,.35,d+.4),"777d79",true)
		white_elevation(b,Vector3(x,0,d/2),wing_w)
		white_elevation(b,Vector3(side*w/2,0,0),d,side*PI/2)
		white_elevation(b,Vector3(side*(w/2-wing_w),0,0),d,-side*PI/2)
		white_elevation(b,Vector3(x,0,-d/2),wing_w,PI)
		# Recessed ground floor glass and dark square pillars establish the overhang.
		for z in range(-23,27,7):
			for edge in [-1,1]:
				K.box(b,Vector3(x+edge*(wing_w/2-1),2.05,z),Vector3(.68,4.1,.68),"50544e",true,22)
		for banner_x in [-wing_w*.27,wing_w*.27]:
			K.box(b,Vector3(x+banner_x,8.8,d/2+.1),Vector3(1.3,6.9,.10),"725a83")
			if banner_x<0:K.label(b,"博\n文\n约\n礼",Vector3(x+banner_x,8.7,d/2+.18),.007)
		K.box(b,Vector3(x,12.404,0),Vector3(wing_w-1,.008,d-1),"999e98",false,18)
	# Tall, slim white fins stand in front of the glass, not a solid gray top storey.
	var bridge_d:=d*.55;var bridge_z:=-8.0
	# The 4F front band has a shallower slab; the rear half is an open bay under 5F.
	var front_depth: float=bridge_d/2
	K.box(b,Vector3(0,12.24,bridge_z+front_depth/2),Vector3(w,.32,front_depth),"646d69",true)
	K.box(b,Vector3(0,15.98,bridge_z),Vector3(w,.24,bridge_d),"939d99",true,16)
	K.box(b,Vector3(0,27.36,bridge_z),Vector3(w,.32,bridge_d),"939d99",true,18)
	var front_z: float=bridge_z+bridge_d/2-.5
	K.box(b,Vector3(0,19.8,front_z),Vector3(w,14.8,.15),"4c6878",true,5)
	for i in int(w/.92):
		var x: float=-w/2+(i+.5)*.92
		K.box(b,Vector3(x,21.65,front_z+.65),Vector3(.11,11.5,1.0),"bbc4bd",false,11)
		# The warm, separately framed bottom strip is visible below the main white grille.
		K.box(b,Vector3(x,14.24,front_z+.47),Vector3(.10,3.26,.48),"9b8775",false,11)
		K.box(b,Vector3(x+.34,13.35,front_z+.09),Vector3(.57,1.56,.08),"8e7e72",false,15)
	K.box(b,Vector3(0,16.03,front_z+.5),Vector3(w,.27,1.18),"5c655e",false,11)
	K.box(b,Vector3(0,12.48,front_z+.40),Vector3(w,.18,.96),"636a62",false,11)
	for y in [12.4,16.1,19.8,23.5,27.2]:K.box(b,Vector3(0,y,front_z+.2),Vector3(w,.13,.22),"a6b3a8",false,11)
	Rear.elevation(b,w,bridge_z-bridge_d/2)
	Rear.corner_lobby(b,bridge_z-bridge_d/2)
	for x in [-w/2,w/2]:
		C.glazing(b,Vector3(x,21.65,bridge_z),bridge_d,11.1,PI/2)
		K.box(b,Vector3(x-signf(x)*.09,21.65,bridge_z),Vector3(.06,11.1,bridge_d),"516d79",false,5)
		C.glazing(b,Vector3(x,14.24,bridge_z+bridge_d/4),bridge_d/2,3.68,PI/2)
		for y in [16.1,19.8,23.5]:K.box(b,Vector3(x,y,bridge_z),Vector3(.16,.12,bridge_d),"8f9f9a",false,11)
	# The photographed opening contains a broad rising stair; preserve access at both sides.
	builder.stairs(b,Vector3(0,0,14),Vector3(0,4.4,-1),26,28)
	K.box(b,Vector3(0,4.24,-3),Vector3(26,.32,4),"b5b6ae",true,6)
	builder.stairs(b,Vector3(0,4.4,-5),Vector3(0,8.8,-20),26,28)
	K.box(b,Vector3(0,8.64,-23),Vector3(26,.32,6),"b5b6ae",true,6)
	rear_terrace(b,builder)
	Rear.terrace_returns(b,w)
	Rear.stair_guards(b)
	preload("res://world/visual_campus/AdministrationPublic.gd").build(b,r)
	K.label(b,"行政楼  ADMINISTRATION",Vector3(0,12.22,7.2),.008)
