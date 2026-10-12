extends RefCounted
## V156 rear staircase traced from historic 1F/5F. Floor heights remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")

static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"RegisteredRearCoreV156")
	Core.rect(n,710,26,796,28,0,23.2,"b8b9ad")
	Core.rect(n,794,28,796,80,0,23.2,"b8b9ad")
	Core.rect(n,732,78,794,80,0,23.2,"b8b9ad")
	for i in Core.LEVELS.size():
		var y:float=Core.LEVELS[i];var ceiling:float=Core.LEVELS[i+1] if i<Core.LEVELS.size()-1 else 23.2
		# The upper wing's outer wall is retained; its stair vestibule opens south to its side aisle.
		if y<16:
			Core.rect(n,708,28,710,49,y,ceiling,"b8b9ad")
			Core.rect(n,708,75,710,80,y,ceiling,"b8b9ad")
			Core.rect(n,708,49,710,75,y+2.95,ceiling,"b8b9ad")
		Core.deck(n,710,29,730,77,y+.015)
	for i in range(Core.LEVELS.size()-1):
		var low:float=Core.LEVELS[i];var high:float=Core.LEVELS[i+1];var half:float=(low+high)/2
		var a:=P.point(730,40,low+.015);var b:=P.point(778,40,half)
		var c:=P.point(778,66,half);var d:=P.point(730,66,high+.015)
		builder.stairs(n,a,b,1.25,16);builder.stairs(n,c,d,1.25,16)
		Core.deck(n,778,29,794,77,half)
		for offset in [-.67,.67]:
			Core.guard(n,a+Vector3(offset,0,0),b+Vector3(offset,0,0))
			Core.guard(n,c+Vector3(offset,0,0),d+Vector3(offset,0,0))
		K.box(n,P.point(720,56,high-.40),Vector3(.3,.08,.65),"dfdece",false,22)
	K.finish(n)
