extends RefCounted
## Official 70215342 f/l/r/b + user 20261010_222257: wood-look apron,
## rendered service wall, dark double entry and glazed opposite end.
## Front datum retained; widths and the short entry recess are fitted, not a surveyed plan.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func leaf(n:Node3D,x:float) -> void:
	# Open outward at ninety degrees, leaving the central passage physically clear.
	var d:=K.holder(n,"OpenTeachingDoor",Vector3(x,0,22.31))
	K.box(d,Vector3(0,1.50,0),Vector3(.06,2.94,1.20),"819690",true,19)
	for z in [-.61,.61]:K.box(d,Vector3(0,1.50,z),Vector3(.085,3.04,.065),"35413d",false,11)
	for y in [.025,3.015]:K.box(d,Vector3(0,y,0),Vector3(.085,.065,1.25),"35413d",false,11)
	for s in [-1,1]:K.box(d,Vector3(s*.12,1.43,.36),Vector3(.035,1.02,.035),"aeb4ab",false,11)
	K.finish(d)

static func utility(n:Node3D,x:float,width:float) -> void:
	K.box(n,Vector3(x,1.18,21.80),Vector3(width,2.36,.045),"c8ccc2",false,22)
	for dx in [-width/2,0,width/2]:K.box(n,Vector3(x+dx,1.18,21.835),Vector3(.035,2.4,.035),"919b93",false,11)
	K.box(n,Vector3(x,2.38,21.835),Vector3(width+.05,.035,.035),"919b93",false,11)
	for dx in [-.095,.095]:K.box(n,Vector3(x+dx,1.10,21.87),Vector3(.025,.18,.045),"4f5b53",false,11)

static func build(parent:Node3D) -> void:
	var n:=K.holder(parent,"ZhangObservedEntranceArcadeV131")
	# Warm staggered long strips belong to the sheltered apron; exterior stone stays outside it.
	K.box(n,Vector3(0,.070,25),Vector3(64,.024,9),"9b845f",false,23)
	# Solid pale wall is distinct from the glazed cafe wing. Do not repeat glass through it.
	K.box(n,Vector3(-13.65,2.34,21.65),Vector3(30.3,4.68,.24),"c5bca4",true,22)
	K.box(n,Vector3(4.92,2.34,21.65),Vector3(1.2,4.68,.24),"c5bca4",true,22)
	K.box(n,Vector3(3,4.23,21.65),Vector3(2.64,.90,.24),"c5bca4",true,22)
	# Existing gallery begins at Z22; close its narrow horizontal gap to the facade.
	# This soffit infill sits behind the existing upper guard, outside the public walking band.
	K.box(n,Vector3(0,4.80,21.88),Vector3(60,.25,.76),"bab9af",false,22)
	utility(n,-20,1.65);utility(n,-25,1.05)
	var label:=K.label(n,"张岭彬楼\nZhang Lingbin Building",Vector3(-7.2,3.15,21.805),.006)
	label.modulate=Color("343c38")
	# Dark framed door and glazed transom; the named entrance is now an actual opening.
	for x in [1.66,4.34]:K.box(n,Vector3(x,1.88,21.79),Vector3(.12,3.76,.18),"36423f",true,11)
	for y in [.018,3.10,3.76]:K.box(n,Vector3(3,y,21.79),Vector3(2.80,.07,.18),"36423f",false,11)
	K.box(n,Vector3(3,3.42,21.74),Vector3(2.56,.56,.07),"738880",false,19)
	leaf(n,1.73);leaf(n,4.27)
	K.box(n,Vector3(3,.074,21.30),Vector3(2.58,.026,.74),"424b47",false,11)
	# A shallow public recess provides the observed dark ceiling/lighting at the entry.
	# Its far aperture remains open to existing public space; no guessed private-room layout.
	for x in [.56,5.44]:K.box(n,Vector3(x,1.78,18.76),Vector3(.18,3.56,5.54),"bec2b6",true,22)
	K.box(n,Vector3(3,3.58,18.76),Vector3(5.06,.14,5.54),"46504c",true,11)
	K.box(n,Vector3(3,.071,18.76),Vector3(4.8,.026,5.54),"697770",false,26)
	for z in [16.5,17.1,17.7,18.3,18.9,19.5,20.1,20.7,21.3]:
		K.box(n,Vector3(3,3.492,z),Vector3(4.82,.018,.025),"222d29",false,11)
	for z in [17.1,19.5,21.0]:K.box(n,Vector3(3,3.477,z),Vector3(1.32,.022,.24),"dde2d5",false,17)
	var light:=OmniLight3D.new();light.position=Vector3(3,2.75,18.7);light.light_energy=.45;light.omni_range=7;n.add_child(light)
	# Ground glass and high clerestory read as separate bands in the observed tall arcade.
	for span:Vector2 in [Vector2(5.55,11.1),Vector2(11.3,16.8),Vector2(17,22.5),Vector2(22.7,28.8)]:
		var x:float=(span.x+span.y)/2;var width:float=span.y-span.x
		K.box(n,Vector3(x,1.95,21.65),Vector3(width,3.86,.07),"718c85",true,19)
		for edge in [span.x,span.y,(span.x+span.y)/2]:K.box(n,Vector3(edge,1.98,21.75),Vector3(.065,3.96,.13),"48564f",false,11)
		for y in [.055,1.07,3.94]:K.box(n,Vector3(x,y,21.75),Vector3(width,.065,.13),"48564f",false,11)
		K.box(n,Vector3(x,4.77,21.60),Vector3(width,1.52,.24),"c5bca4",true,22)
		K.box(n,Vector3(x,6.74,21.65),Vector3(width,2.38,.07),"71867e",false,19)
		for edge in [span.x,span.y,(span.x+span.y)/2]:K.box(n,Vector3(edge,6.75,21.75),Vector3(.065,2.45,.13),"48564f",false,11)
		for y in [5.51,7.98]:K.box(n,Vector3(x,y,21.75),Vector3(width,.065,.13),"48564f",false,11)
	# White service conduit follows the wall/beam, avoiding a floating pipe across the walk.
	for x in [-9.8,-26.8]:
		K.box(n,Vector3(x,3.73,21.84),Vector3(.045,1.56,.045),"c8cdbf",false,11)
		K.box(n,Vector3(x,2.95,21.84),Vector3(.20,.20,.075),"d4d6c8",false,22)
	K.box(n,Vector3(-8.6,4.46,21.84),Vector3(36.4,.045,.045),"b8c1b6",false,11)
	K.finish(n)
