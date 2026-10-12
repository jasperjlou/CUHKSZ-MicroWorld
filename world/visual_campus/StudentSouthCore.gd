extends RefCounted
## V158 south staircase/closed lift from historic029/030/031; compact envelope/levels fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")
static func turn(u:float,v:float,y:float)->Vector3:
	return Vector3((u-245)/P.PIXELS_PER_METRE,y,(646-v)/P.PIXELS_PER_METRE)
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"RegisteredSouthCoreV158")
	Core.rect(n,222,602,224,690,0,23.2,"b8b9ad")
	Core.rect(n,267,602,269,690,0,23.2,"b8b9ad")
	Core.rect(n,224,688,267,690,0,23.2,"b8b9ad")
	for i in Core.LEVELS.size():
		var y:float=Core.LEVELS[i];var ceiling:float=Core.LEVELS[i+1] if i<Core.LEVELS.size()-1 else 23.2
		Core.rect(n,224,602,229,604,y,ceiling,"b8b9ad")
		Core.rect(n,262,602,267,604,y,ceiling,"b8b9ad")
		Core.rect(n,229,602,262,604,y+2.95,ceiling,"b8b9ad")
		Core.deck(n,225,604,266,626,y+.015)
	# Service lift is a closed shaft, not a claim that the cabin is functional.
	Core.rect(n,270,638,311,686,.075,23.2,"b8b9ad")
	for y in Core.LEVELS:
		Core.rect(n,277,637.5,304,638,y+.10,y+2.8,"78827e",false,11)
		Core.rect(n,290,637.3,290.6,637.5,y+.10,y+2.8,"454f4b",false,11)
	# Rotated flight frame keeps the builder's stair axis and upright collision guards consistent.
	var stairs:=K.holder(n,"SouthStairFlights",P.point(245,646));stairs.rotation.y=PI/2
	for i in range(Core.LEVELS.size()-1):
		var low:float=Core.LEVELS[i];var high:float=Core.LEVELS[i+1];var half:float=(low+high)/2
		var a:=turn(235,626,low+.015);var b:=turn(235,672,half)
		var c:=turn(256,672,half);var d:=turn(256,626,high+.015)
		builder.stairs(stairs,a,b,1.25,16);builder.stairs(stairs,c,d,1.25,16)
		Core.deck(n,225,672,266,688,half)
		for offset in [-.67,.67]:
			Core.guard(stairs,a+Vector3(offset,0,0),b+Vector3(offset,0,0))
			Core.guard(stairs,c+Vector3(offset,0,0),d+Vector3(offset,0,0))
		K.box(n,P.point(245,614,high-.40),Vector3(.7,.08,.3),"dfdece",false,22)
	K.finish(stairs);K.finish(n)
