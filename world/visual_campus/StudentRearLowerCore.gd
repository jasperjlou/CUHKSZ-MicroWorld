extends RefCounted
## Historic029/030 support this separate lower core; no independent fourth-floor termination drawing.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")
const LEVELS=[0.,4.4,8.8]
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"RegisteredRearLowerCoreV160")
	Core.rect(n,830,464,922,466,0,12.4,"b8b9ad")
	Core.rect(n,920,466,922,505,0,12.4,"b8b9ad")
	Core.rect(n,850,503,920,505,0,12.4,"b8b9ad")
	for i in LEVELS.size():
		var y:float=LEVELS[i];var ceiling:float=LEVELS[i+1] if i<2 else 12.4
		Core.rect(n,828,466,830,475,y,ceiling,"b8b9ad")
		Core.rect(n,828,502,830,505,y,ceiling,"b8b9ad")
		Core.rect(n,828,475,830,502,y+2.95,ceiling,"b8b9ad")
		Core.deck(n,830,467,850,502,y+.015)
	for i in range(2):
		var low:float=LEVELS[i];var high:float=LEVELS[i+1];var half:float=(low+high)/2
		var a:=P.point(850,475,low+.015);var b:=P.point(902,475,half)
		var c:=P.point(902,494,half);var d:=P.point(850,494,high+.015)
		builder.stairs(n,a,b,1.10,16);builder.stairs(n,c,d,1.10,16)
		Core.deck(n,902,467,920,502,half)
		for offset in [-.595,.595]:
			Core.guard(n,a+Vector3(offset,0,0),b+Vector3(offset,0,0))
			Core.guard(n,c+Vector3(offset,0,0),d+Vector3(offset,0,0))
	# Third-floor service enclosure follows030; the other floors have different room plans.
	Core.rect(n,793,505,795,599,8.8,12.4,"b8b9ad")
	Core.rect(n,852,505,854,599,8.8,12.4,"b8b9ad")
	Core.rect(n,795,505,920,507,8.8,12.4,"b8b9ad")
	for span in [[795,802],[829,865],[892,920]]:Core.rect(n,span[0],599,span[1],601,8.8,12.4,"b8b9ad")
	for span in [[802,829],[865,892]]:Core.rect(n,span[0],599,span[1],601,11.75,12.4,"b8b9ad")
	K.finish(n)
