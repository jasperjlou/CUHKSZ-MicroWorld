extends RefCounted
## V124: historical +63.65 foyer / +63.45 forecourt / +62.45 mall / +58.65 lower.
## East Gate frame retained. Facing the mall is photo-supported; X/Z remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const D:=preload("res://world/visual_campus/LowerCampusLandscape.gd")
const ROOT_X:=99.0
const ROOT_Z:=-102.0
const ROOT_Y:=-1.56
const MALL:=3.8
const APRON:=Rect2(-37,-52,77,130)
const COURT:=Rect2(-13.5,3.7,44.0,56.3)
const STAIR_CUT:=Rect2(23.2,49,4.6,21.8)

static func local_point(x:float,z:float) -> Vector2:
	# yaw270: world X=rootX-localZ, world Z=rootZ+localX.
	return Vector2(z-ROOT_Z,ROOT_X-x)

static func cutout(x:float,z:float) -> bool:
	var p:=local_point(x,z)
	return APRON.has_point(p)

static func terrain_breaks() -> Dictionary:
	return {"x":[ROOT_X+52,ROOT_X-78,ROOT_X-3.7,ROOT_X-49,ROOT_X-60,ROOT_X-70.8],
		"z":[ROOT_Z-37,ROOT_Z+40,ROOT_Z-13.5,ROOT_Z+23.2,ROOT_Z+27.8,ROOT_Z+30.5]}

static func slab(n:Node3D,x0:float,x1:float,z0:float,z1:float,y:float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.13,(z0+z1)/2),Vector3(x1-x0,.26,z1-z0),"979c95",true,42)

static func retaining(n:Node3D,a:Vector3,c:Vector3,guard:bool=true) -> void:
	var d:=c-a;var yaw:=atan2(d.x,d.z)
	K.box(n,(a+c)/2+Vector3.UP*(MALL/2-.13),Vector3(.28,MALL+.26,d.length()),"aba99c",true,47,yaw)
	K.box(n,(a+c)/2+Vector3.UP*(MALL+.03),Vector3(.40,.09,d.length()),"bdbeaf",false,22,yaw)
	if guard:P.rail(n,a+Vector3.UP*(MALL+.07),c+Vector3.UP*(MALL+.07))

static func build(parent:Node3D,builder) -> void:
	var n:=K.holder(parent,"ICCSharedEntryDatumV124")
	# Partition the upper apron; no blanket slab may cover the lower courtyard or stair.
	var xs:Array[float]=[-37,-13.5,23.2,27.8,30.5,40]
	var zs:Array[float]=[-52,3.7,49,60,70.8,78]
	for i in xs.size()-1:
		for j in zs.size()-1:
			var p:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2)
			if COURT.has_point(p) or STAIR_CUT.has_point(p):continue
			slab(n,xs[i],xs[i+1],zs[j],zs[j+1],MALL)
	slab(n,-13.5,30.5,3.7,60,0)
	# Retaining edges and guards stop before the raised bridge and the lower stair opening.
	retaining(n,Vector3(-13.5,0,3.7),Vector3(-13.5,0,60))
	retaining(n,Vector3(30.5,0,3.7),Vector3(30.5,0,60))
	retaining(n,Vector3(-13.5,0,3.7),Vector3(30.5,0,3.7),false)
	for span:Vector2 in [Vector2(-13.5,-8.6),Vector2(2.2,23.2),Vector2(27.8,30.5)]:
		retaining(n,Vector3(span.x,0,60),Vector3(span.y,0,60))
	retaining(n,Vector3(-8.6,0,60),Vector3(2.2,0,60),false)
	for x in [23.2,27.8]:retaining(n,Vector3(x,0,60),Vector3(x,0,70.8))
	P.stair(n,Vector3(25.5,0,49),Vector3(25.5,MALL,70.8),3.4)
	# Bevel the lounge sill between the court and the slightly raised interior finish.
	K.surface(n,K.quad(Vector3(16,0,39.4),Vector3(21,0,39.4),Vector3(21,.135,38.5),Vector3(16,.135,38.5)),"aeb3a9",42,true)
	# Main entrance: short 0.2m threshold, +63.45 platform, then a 1m gentle bridge.
	slab(n,-11.7,8.2,41,47.75,4.8)
	P.stair(n,Vector3(-1.75,4.8,41),Vector3(-1.75,5,40),8)
	for span:Vector2 in [Vector2(-11.7,-5.9),Vector2(2.4,8.2)]:
		P.rail(n,Vector3(span.x,5,40),Vector3(span.y,5,40))
	for x in [-11.7,8.2]:P.rail(n,Vector3(x,4.8,41),Vector3(x,4.8,47.75))
	for span:Vector2 in [Vector2(-11.7,-8.2),Vector2(1.8,8.2)]:
		P.rail(n,Vector3(span.x,4.8,47.75),Vector3(span.y,4.8,47.75))
	var a:=Vector3(-3.2,4.8,47.75);var c:=Vector3(-3.2,MALL,75.15)
	K.surface(n,K.quad(a+Vector3(-5,0,0),a+Vector3(5,0,0),c+Vector3(5,0,0),c+Vector3(-5,0,0)),"989e97",42,true)
	var soffit:=K.quad(a+Vector3(-5,-.30,0),a+Vector3(5,-.30,0),c+Vector3(5,-.30,0),c+Vector3(-5,-.30,0))
	soffit.reverse() # Down-facing triangles stop jumps from the lower court.
	K.surface(n,soffit,"b5b9af",22,true)
	for side in [-1,1]:
		P.rail(n,a+Vector3(side*5,0,0),c+Vector3(side*5,0,0))
		var upper_a:=a+Vector3(side*5,0,0);var upper_c:=c+Vector3(side*5,0,0)
		K.surface(n,K.quad(upper_a,upper_c,upper_c+Vector3.DOWN*.30,upper_a+Vector3.DOWN*.30),"b5b9af",22)
	# Exposed bridge structure over the lower void; supports avoid its main walking axis.
	for z in [44,53.5]:
		var top:float=4.8 if z<47.75 else lerpf(4.8,MALL,(z-47.75)/27.4)
		for x in [-9.7,6.1] if z==44 else [-7.2,.8]:K.column(n,Vector3(x,0,z),top-.3,.44)
		K.box(n,Vector3(-1.8 if z==44 else -3.2,top-.38,z),Vector3(16.3 if z==44 else 9,.20,.42),"b6b8ad",false,22)
	D.drain(n,Vector3(8.5,.045,57.8),34)
	D.drain(n,Vector3(-1.75,4.826,43),15)
	var planting:=K.holder(n,"UpperStreetPlanting",Vector3(0,MALL,0))
	preload("res://world/visual_campus/ConferenceCourtGround.gd").bed(planting,-33,-29,9,35,12411)
	preload("res://world/visual_campus/ConferenceCourtGround.gd").bed(planting,32,35,6,24,12461)
	K.finish(planting);K.finish(n)
