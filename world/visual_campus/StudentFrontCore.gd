extends RefCounted
## V154 historical029/030/031 front staircase + shared columns. Heights/doors fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Court=preload("res://world/visual_campus/StudentTerracedCourts.gd")
const LEVELS=[0.,4.4,8.8,12.4,16.,19.6]

static func rect(n:Node3D,u0:float,v0:float,u1:float,v1:float,low:float,high:float,color:String,solid:bool=true,kind:int=22)->void:
	K.box(n,P.point((u0+u1)/2,(v0+v1)/2,(low+high)/2),Vector3(absf(v1-v0)/P.PIXELS_PER_METRE,high-low,absf(u1-u0)/P.PIXELS_PER_METRE),color,solid,kind)

static func guard(n:Node3D,a:Vector3,b:Vector3)->void:
	var delta:=b-a;var count:=ceili(Vector2(delta.x,delta.z).length()/.18)
	# Upright posts and short vertical panels; pitched whole guards used to protrude across landings.
	for i in count:
		var p:=a.lerp(b,(i+.5)/count)
		K.box(n,p+Vector3.UP*.52,Vector3(.075,1.04,absf(delta.z)/count),"46534e",true,19)
		K.box(n,a.lerp(b,float(i)/count)+Vector3.UP*.53,Vector3(.025,1.06,.025),"46534e",false,11)
	var top:=K.holder(n,"CoreHandrail",(a+b)/2+Vector3.UP*1.07)
	top.rotation.y=atan2(delta.x,delta.z);top.rotation.x=-atan2(delta.y,Vector2(delta.x,delta.z).length())
	K.box(top,Vector3.ZERO,Vector3(.075,.075,delta.length()),"46534e",false,11);K.finish(top)

static func deck(n:Node3D,u0:float,v0:float,u1:float,v1:float,y:float)->void:
	rect(n,u0,v0,u1,v1,y-.18,y,"b4b4a8",false)
	preload("res://world/visual_campus/LibraryUpperLevels.gd").sheet(n,P.polygon([[u0,v0],[u1,v0],[u1,v1],[u0,v1]]),y,"b4b4a8",26,true)

static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"RegisteredFrontCoreV154")
	# Actual front grid symbols, plus two north-wing supports. Foot and cap touch authored slabs.
	for q in [[118,460],[303,460],[118,563],[303,563],[118,685],[303,235],[97,154]]:
		rect(n,q[0]-5,q[1]-5,q[0]+5,q[1]+5,.075,16.,"c8c9bc")
	# Elevator shafts retain closed leaves; they are not advertised as operating lifts.
	for v in [94.,132.]:
		rect(n,129,v-16,171,v+16,.075,23.2,"b8b9ad")
		for y in LEVELS:
			rect(n,171, v-10,171.8,v+10,y+.10,y+2.8,"78827e",false,11)
			rect(n,171.9,v-.35,172.1,v+.35,y+.10,y+2.8,"454f4b",false,11)
	# Stair envelope from the front historic core. Door mouths face the public side aisle.
	rect(n,125,25,228,27,0,23.2,"b8b9ad")
	rect(n,226,27,228,87,0,23.2,"b8b9ad")
	rect(n,125,85,226,87,0,23.2,"b8b9ad")
	for i in LEVELS.size():
		var y:float=LEVELS[i];var ceiling:float=LEVELS[i+1] if i<LEVELS.size()-1 else 23.2
		rect(n,125,27,127,40,y,ceiling,"b8b9ad")
		rect(n,125,72,127,85,y,ceiling,"b8b9ad")
		rect(n,125,40,127,72,y+2.95,ceiling,"b8b9ad")
		# Entry landing spans both return flights. Original floor exists beneath it except at G.
		deck(n,127,28,148,84,y+.015)
	for i in range(LEVELS.size()-1):
		var low:float=LEVELS[i];var high:float=LEVELS[i+1];var half:float=(low+high)/2
		var a:=P.point(148,42,low+.015);var b:=P.point(208,42,half)
		var c:=P.point(208,70,half);var d:=P.point(148,70,high+.015)
		builder.stairs(n,a,b,1.45,16);builder.stairs(n,c,d,1.45,16)
		deck(n,208,28,226,84,half)
		for offset in [-.76,.76]:
			guard(n,a+Vector3(offset,0,0),b+Vector3(offset,0,0))
			guard(n,c+Vector3(offset,0,0),d+Vector3(offset,0,0))
		# No rail across landing turn or entry mouth. Mid-landing wall closes its outer end.
		K.box(n,P.point(137,56,high-.40),Vector3(.35,.08,.85),"e0dfcf",false,22)
	K.finish(n)
