extends RefCounted
## Official square 116443795: side flight beside planted bank,connected upper teaching walk.
## Flight split,metre widths and position fitted; photographic capture year unknown.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const M:=preload("res://world/visual_campus/PhotoMallGround.gd")
const G:=2.24
const X:=-17.3

static func cutout(x:float,z:float)->bool:
	# The authored steps and flat landing own this opening. The continuous grass
	# ramp used to intersect the landing exactly and show through its stone top.
	return x>X-1.4 and x<X+1.4 and z>-54 and z<-40

static func level(z:float) -> float:
	if z>=-45:return 1.12*clampf((-40-z)/5,0,1)
	if z>=-47:return 1.12
	return 1.12+1.12*clampf((-47-z)/7,0,1)

static func fitted_height(x:float,z:float,base:float) -> float:
	if x<=-19.3 or x>=-15.3 or z>=-40 or z<=-54:return base
	var weight:float=smoothstep(-19.3,-18.9,x)*(1-smoothstep(-15.7,-15.3,x))
	return lerpf(base,level(z),weight)

static func flight(n:Node3D,z0:float,z1:float,y0:float,y1:float) -> void:
	for i in 8:
		var h:float=y0+(y1-y0)*(i+1)/8
		K.box(n,Vector3(X,h-.08,lerpf(z0,z1,(i+.5)/8.0)),Vector3(2.8,.16,absf(z1-z0)/8+.015),"aab1a7",false,26)
	var slab:=K.surface(n,K.quad(Vector3(X-1.4,y0,z0),Vector3(X+1.4,y0,z0),Vector3(X+1.4,y1,z1),Vector3(X-1.4,y1,z1)),"aab1a7",26,true);slab.visible=false

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"EastGateTeachingLinkV92")
	flight(n,-40,-45,0,1.12);flight(n,-47,-54,1.12,G)
	K.box(n,Vector3(X,1.05,-46),Vector3(2.8,.14,2.04),"aab1a7",true,40)
	# Landings join the lower court and teaching-side upper path without crossing the lawn.
	# This tiny L-shaped ribbon previously folded over itself into a pointed fan.
	# A rectangular apron meets the flight's full width without overlapping mitres.
	K.box(n,Vector3(X,.106,-39.25),Vector3(2.8,.024,1.5),"919a92",false,40)
	M.paving(n,-37,-15.7,-59,-55.5);M.paving(n,-37,-33,-64,-56)
	M.paving(n,-18.7,-15.7,-56,-54) # Short stone head landing closes the remaining grass seam.
	# V98 continuous lawn replaces the old axial and transverse cuts.
	M.paving(n,-37,14.5,-64,-59);M.paving(n,19,39,-64,-59)
	M.paving(n,-5,5,-59,-54)
	M.drain(n,Vector2(-36.6,-63.5),Vector2(-36.6,-58))
	for side in [-1,1]:
		var x:float=X+side*1.55
		for z in [-40.0,-42.5,-45.0,-47.0,-50.5,-54.0]:
			K.box(n,Vector3(x,level(z)+.52,z),Vector3(.065,1.04,.065),"87958e",false,11)
		for zs:Vector2 in [Vector2(-40,-45),Vector2(-45,-47),Vector2(-47,-54)]:
			for rise in [.56,1.04]:
				preload("res://world/visual_campus/EastGateGround.gd").beam(n,Vector3(x,level(zs.x)+rise,zs.x),Vector3(x,level(zs.y)+rise,zs.y),.055)
			# Solid low cheek follows the actual grade; handrails themselves remain visual.
			var a:=Vector3(x,level(zs.x)+.12,zs.x);var c:=Vector3(x,level(zs.y)+.12,zs.y)
			preload("res://world/visual_campus/WesternCampus.gd").beam(n,a,c,.22,.24,"b3bbae")
	K.finish(n)
