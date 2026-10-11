extends RefCounted
## V99: panorama70040618 + 2019 TA elevations (top datum28.600).
## Local footprint/face assignment remains fitted pending legacy/CAD/site registration.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func metal_face(n:Node3D,length:float,depth:float,axis:int,side:int) -> void:
	var yaw:=0.0 if axis==0 else PI/2
	var basis:=Basis(Vector3.UP,yaw)
	var origin:=Vector3(0,0,side*depth/2) if axis==0 else Vector3(side*depth/2,0,0)
	# One narrow horizontal glazing band in a vertically seamed dark metal envelope.
	for span:Vector2 in [Vector2(22.05,23.6),Vector2(25.1,28.6)]:
		K.box(n,origin+Vector3.UP*(span.x+span.y)/2,Vector3(length,span.y-span.x,.22),"444b53",true,11,yaw)
	K.box(n,origin+Vector3.UP*24.35,Vector3(length,1.5,.10),"526776",true,5,yaw)
	var panels:=ceili(length/.85)
	for i in panels+1:
		var u:float=-length/2+i*length/panels
		for span:Vector2 in [Vector2(22.05,23.6),Vector2(25.1,28.6)]:
			K.box(n,origin+basis*Vector3(u,(span.x+span.y)/2,side*.15),Vector3(.035,span.y-span.x,.045),"303942",false,11,yaw)
		K.box(n,origin+basis*Vector3(u,24.35,side*.09),Vector3(.045,1.5,.10),"3f4a52",false,11,yaw)
	for y in [23.6,25.1]:K.box(n,origin+basis*Vector3(0,y,side*.12),Vector3(length,.07,.12),"3a454e",false,11,yaw)

static func build(parent:Node3D) -> void:
	var n:=K.holder(parent,"FrontEnvelopeV99")
	# Open 3F promenade over the existing 8.7m canopy, not an opaque masonry strip.
	K.box(n,Vector3(11,8.91,95.93),Vector3(52,.42,.20),"c4c6bd",true,22)
	K.box(n,Vector3(11,9.72,95.88),Vector3(52,1.20,.055),"829baa",true,19)
	for i in 37:
		var u:float=-15+i*52.0/36
		K.box(n,Vector3(u,9.72,95.94),Vector3(.05,1.26,.11),"a3aaa7",false,11)
	for y in [9.1,10.33]:K.box(n,Vector3(11,y,95.94),Vector3(52,.07,.14),"aab0ac",false,11)
	# Side returns guard the two open ends of the canopy floor.
	for u in [-15.0,37.0]:
		K.box(n,Vector3(u,9.33,93.5),Vector3(.08,1.26,5),"829baa",true,19)
		K.box(n,Vector3(u,10.0,93.5),Vector3(.12,.065,5),"aab0ac",false,11)
	for u in [-13.0,-5.0,3.0,11.0,19.0,27.0,35.0]:
		K.box(n,Vector3(u,10.95,95.3),Vector3(.32,4.5,.32),"bfc1b7",true,22)
		K.box(n,Vector3(u,12.66,93.5),Vector3(.25,.35,5),"bfc1b7",false,22)
	K.box(n,Vector3(11,13.05,93.5),Vector3(52.4,.30,5.3),"c6c8be",true,22)
	K.box(n,Vector3(11,12.85,96.18),Vector3(52.4,.32,.16),"c6c8be",false,22)
	K.box(n,Vector3(11,13.245,96.18),Vector3(52.4,.07,.25),"626d6d",false,11)
	for u in [-10.0,-2.0,6.0,14.0,22.0,30.0]:
		K.box(n,Vector3(u,12.88,93.7),Vector3(.22,.035,.22),"e2e3d4",false,17)
	# Top floor outline is a local fit; height is the explicit historical elevation datum.
	var top:=K.holder(n,"DarkCantilever",Vector3(22.7,0,80.45))
	K.box(top,Vector3(0,21.825,0),Vector3(28.6,.45,29.9),"555e60",true,22)
	for axis in [0,1]:
		for side in [-1,1]:metal_face(top,28.6 if axis==0 else 29.9,29.9 if axis==0 else 28.6,axis,side)
	K.box(top,Vector3(0,28.47,0),Vector3(28.7,.26,30),"586268",true,18)
	K.box(top,Vector3(0,21.58,0),Vector3(28.6,.035,29.9),"3f494e",false,22)
	for u in [-10.0,-4.0,2.0,8.0]:
		K.box(top,Vector3(u,21.55,13),Vector3(.20,.025,.20),"d8ded5",false,17)
	K.finish(top);K.finish(n)
