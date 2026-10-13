extends RefCounted
## V195: observed woodland beyond the rear-road bend, not the maintained pavilion lawn.
## Boundaries/species/density are fitted to retained road and garden anchors.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
static func edge(z:float)->float:
	return lerpf(148,180,smoothstep(-208,-194,z))
static func contains(x:float,z:float)->bool:
	return z> -234 and z< -126 and x>edge(z) and x<245
static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"UpperRearWoodlandV195")
	var far:=K.holder(n,"InteriorTrees")
	var rng:=RandomNumberGenerator.new();rng.seed=195700371
	var trees:=0;var shrubs:=0
	for z0 in range(-229,-129,10):
		for x0 in range(151,243,10):
			var x:float=x0+rng.randf_range(-2.2,2.2);var z:float=z0+rng.randf_range(-2.2,2.2)
			if not contains(x,z) or x<edge(z)+3.5:continue
			var near:bool=x<edge(z)+23
			K.tree(n if near else far,Vector3(x,builder.height(x,z),z),rng.randf_range(8.5,15.5),195000+trees,1.3 if near else .8)
			trees+=1
	for z0 in range(-230,-128,5):
		for row in 3:
			var z:float=z0+rng.randf_range(-.8,.8);var x:float=edge(z)+1.9+row*4.0+rng.randf_range(-.6,.6)
			if not contains(x,z):continue
			V.shrub(n,Vector3(x,builder.height(x,z),z),Vector3(rng.randf_range(3,4.2),rng.randf_range(.7,1.45),4.6),195800+shrubs)
			shrubs+=1
	K.finish(far);K.finish(n)
	for node:GeometryInstance3D in far.find_children("*","GeometryInstance3D",true,false):node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.set_meta("counts",{"trees":trees,"shrubs":shrubs})
