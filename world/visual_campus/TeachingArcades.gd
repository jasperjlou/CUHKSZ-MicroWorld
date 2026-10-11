extends RefCounted
## Visible construction from Teaching C 41566307 and Teaching B 41566303.
## High arcade uses the retained 8.5 m second-floor datum; exact clear height is not measured.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func downlight(b: Node3D,p: Vector3) -> void:
	K.box(b,p,Vector3(.20,.10,.20),"626e63",false,11)
	K.box(b,p-Vector3.UP*.057,Vector3(.14,.018,.14),"e8e3cf",false,17)

static func c_arcade(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"TeachingCHighPublicArcade")
	# Translate the photographed front arcade as a unit; do not stretch its columns/services.
	n.position.z=float(r.depth)*.46-47*.46
	var w: float=r.width;var d: float=47.0;var wall_z: float=d*.30
	var door_x: float=w*.25
	# The main promenade is a tall beam-and-column space, with clerestory glazing above a white band.
	K.box(n,Vector3(0,.064,d*.405),Vector3(w*.80,.028,d*.25),"9c9990",false,23)
	K.box(n,Vector3(0,8.5,d*.398),Vector3(w*.80,.25,d*.239),"b1b4a8",true,15)
	K.box(n,Vector3(0,8.31,d*.398),Vector3(w*.80,.10,d*.239),"b9baae",false,22)
	for i in 10:
		var x: float=-27.72+i*6
		if x<5:
			K.box(n,Vector3(x,4.13,21.02),Vector3(.62,8.26,.62),"b8baae",true,22)
		K.box(n,Vector3(x,8.02,18.7),Vector3(.40,.62,11.2),"b7baad",false,22)
		downlight(n,Vector3(x+2.8,8.22,18.2))
		if i%3==0:
			K.box(n,Vector3(x,2.35,21.36),Vector3(.46,2.4,.04),"76647c",false,22)
			K.label(n,"教学 C\nTEACHING C",Vector3(x,2.35,21.39),.0023)
	for z in [14.25,21.02,24.15]:K.box(n,Vector3(0,8.05,z),Vector3(w*.8,.56,.33),"afb4a6",false,22)
	# Two unequal glazed rooms leave the entrance aligned with the oblique wing mouth.
	for span: Vector2 in [Vector2(-w*.4,door_x-4.15),Vector2(door_x+4.15,w*.4)]:
		var width: float=span.y-span.x;var middle: float=(span.x+span.y)/2
		# V135 official right cube: pale utility wall, not a second glazed shop.
		# Position/width fitted to retained entry; date of panorama unknown.
		if span.x>door_x:
			K.box(n,Vector3(middle,4.1,wall_z),Vector3(width,8.2,.24),"c5c1b3",true,22)
			var ux:float=middle+.8
			K.box(n,Vector3(ux,1.20,wall_z+.15),Vector3(1.65,2.4,.045),"cbd1cb",false,22)
			for dx in [-.825,0,.825]:K.box(n,Vector3(ux+dx,1.20,wall_z+.185),Vector3(.035,2.43,.035),"8f9b96",false,11)
			K.box(n,Vector3(ux,2.415,wall_z+.185),Vector3(1.7,.035,.035),"8f9b96",false,11)
			for dx in [-.11,.11]:K.box(n,Vector3(ux+dx,1.1,wall_z+.22),Vector3(.025,.20,.05),"58635d",false,11)
			var nameplate:=K.label(n,"Teaching C",Vector3(middle,3.6,wall_z+.15),.008)
			nameplate.modulate=Color("343e3e")
			continue
		var count:=maxi(1,ceili(width/3.0));var pitch: float=width/count
		for i in count:
			var x: float=span.x+(i+.5)*pitch
			K.box(n,Vector3(x,2.08,wall_z),Vector3(pitch-.09,3.96,.09),"658783",true,19)
			K.box(n,Vector3(x,6.5,wall_z),Vector3(pitch-.09,3.18,.09),"658783",true,19)
			for dx in [-pitch/2,pitch/2]:K.box(n,Vector3(x+dx,4.05,wall_z+.04),Vector3(.065,8.1,.16),"44564e",false,11)
			K.box(n,Vector3(x,3.62,wall_z+.08),Vector3(pitch,.065,.16),"44564e",false,11)
		K.box(n,Vector3(middle,4.51,wall_z+.08),Vector3(width,.82,.24),"babdaf",false,22)
		K.box(n,Vector3(middle,4.8,13.2),Vector3(width,.25,1.8),"afb4a6",true,15)
		K.box(n,Vector3(middle,.061,wall_z-1.9),Vector3(width,.05,3.5),"aaa99d",false,12)
		K.box(n,Vector3(middle,2.10,wall_z-3.7),Vector3(width,4.2,.18),"aaad9f",true,22)
		K.bench(n,Vector3(middle,0,wall_z-2.7))
		K.box(n,Vector3(middle,4.22,wall_z-1.8),Vector3(2.2,.055,.15),"e3dfcc",false,17)
	# Plain entrance surround, tall transom slats and open doors from the rear-facing cube view.
	for side in [-1,1]:
		K.box(n,Vector3(door_x+side*3.12,4.1,wall_z),Vector3(2.04,8.2,.28),"bcbbae",true,22)
		K.box(n,Vector3(door_x+side*2.05,2.65,wall_z+.19),Vector3(.14,5.3,.22),"36473e",true,11)
		var door:=K.holder(n,"OpenCEntranceLeaf",Vector3(door_x+side*2.02,0,wall_z-.85));door.rotation.y=side*.16
		K.box(door,Vector3(0,1.94,0),Vector3(.10,3.88,1.7),"73938b",false,19)
		K.box(door,Vector3(.06,1.3,.42),Vector3(.06,1.1,.055),"a5ada0",false,11);K.finish(door)
	K.box(n,Vector3(door_x,3.95,wall_z+.13),Vector3(4.15,.18,.25),"35453d",false,11)
	K.box(n,Vector3(door_x,6.78,wall_z),Vector3(4.15,2.86,.28),"bcbbae",true,22)
	K.box(n,Vector3(door_x,4.65,wall_z-.075),Vector3(4.0,1.20,.065),"6f898c",false,19)
	K.box(n,Vector3(door_x,5.29,wall_z+.07),Vector3(4.28,.12,.18),"384b40",false,11)
	for i in 15:K.box(n,Vector3(door_x-1.86+i*.265,4.65,wall_z+.07),Vector3(.05,1.18,.18),"384b40",false,11)
	var entrance_letter:=K.label(n,"C",Vector3(door_x-3.06,3.33,wall_z+.18),.021)
	entrance_letter.modulate=Color("343e3e")
	# The former free-standing inner tube is replaced by TeachingCCirculation within the diagonal wing.
	# Hanging fins occupy the upper portion; the walking band below remains open.
	for i in int(w*.80/.44):K.box(n,Vector3(-w*.4+(i+.5)*.44,5.85,24.1),Vector3(.075,4.2,.56),"987455",false,11)
	for y in [4.05,7.78]:K.box(n,Vector3(0,y,23.78),Vector3(w*.80,.10,.12),"535e53",false,11)
	for x in range(-27,28,6):
		var brace:=K.holder(n,"ShadeDiagonalBracket",Vector3(x,7.03,23.45));brace.rotation.x=-.60
		K.box(brace,Vector3.ZERO,Vector3(.07,1.65,.09),"535e53",false,11);K.finish(brace)
	# Visible services hug the inner wall instead of floating across the centre of the hall.
	for z in [15.1,15.32,15.55]:K.box(n,Vector3(0,7.8,z),Vector3(w*.76,.065,.065),"788273",false,11)
	for x in range(-27,28,4):K.box(n,Vector3(x,7.75,15.3),Vector3(.055,.22,.7),"727d6f",false,11)
	# Inner deck edge has a real stair opening; no rail spans the landing.
	for x in range(-29,16):
		if absf(x+w*.27)<1.75 or absf(x+23)<1.45:continue
		K.box(n,Vector3(x,5.47,8.94),Vector3(.045,1.08,.045),"5c6d60",false,11)
		K.box(n,Vector3(x,6.02,8.94),Vector3(1.0,.06,.06),"5c6d60",false,11)
	# Green roof panels stop before the stone return and projected end body.
	for i in 3:
		K.box(n,Vector3(-19+i*8.5,8.647,18.7),Vector3(8.1,.024,10.1),"6f7950",false,3)
		K.box(n,Vector3(-23.1+i*8.5,8.67,18.7),Vector3(.15,.024,10.3),"b2b39f",false,6)
	K.finish(n)

static func b_corridor(b: Node3D) -> void:
	# The B panorama shows a lobby extending into a corridor, not a sealed display alcove.
	K.box(b,Vector3(0,.145,-14.4),Vector3(5.4,.025,20),"a1a69f",false,12)
	K.box(b,Vector3(0,4.27,-14.4),Vector3(5.6,.12,20),"454b49",false,44)
	for side in [-1,1]:
		if side==1:K.box(b,Vector3(side*2.8,2.12,-14.4),Vector3(.18,4.24,20),"b8bcad",true,22)
		else:
			for span:Vector2 in [Vector2(-24.4,-10),Vector2(-6,-4.4)]:K.box(b,Vector3(-2.8,2.12,(span.x+span.y)/2),Vector3(.18,4.24,span.y-span.x),"b8bcad",true,22)
			K.box(b,Vector3(-2.8,3.62,-8),Vector3(.18,1.24,4),"b8bcad",true,22)
		K.box(b,Vector3(side*2.69,.12,-14.4),Vector3(.08,.24,20),"657363",false,11)
		for z in [-8,-15,-22]:
			if side==-1 and z==-8:continue
			K.box(b,Vector3(side*2.67,1.50,z),Vector3(.075,2.9,1.4),"738378",false,22)
			K.box(b,Vector3(side*2.60,2.30,z),Vector3(.035,.84,.98),"536b64",false,5)
	for z in range(-24,-4,2):
		K.box(b,Vector3(0,4.16,z),Vector3(5.5,.06,.045),"929b93",false,11)
		if z%4==0:K.box(b,Vector3(0,4.10,z),Vector3(1.4,.05,.24),"eee9d6",false,17)
	for x in [-1.8,0,1.8]:K.box(b,Vector3(x,4.16,-14.4),Vector3(.045,.06,20),"929b93",false,11)
	for z in [-9,-20]:
		var light:=OmniLight3D.new();light.position=Vector3(0,3.1,z);light.light_energy=.45;light.omni_range=8;light.light_color=Color("eee9d6");b.add_child(light)
