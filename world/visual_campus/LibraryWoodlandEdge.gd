extends RefCounted
## Official rear-road panorama and architect courtyard aerial: planted bank
## directly behind the road, not an open lawn. Dates/metric placement unresolved.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const B:=preload("res://world/visual_campus/RearRoadBank.gd")

static func edge(z:float,route:Array)->float:
	var road:float=B.road_x(z,route)
	return road+(9.8 if z>=B.BANK_MIN else 8.8)

static func contains(x:float,z:float,route:Array)->bool:
	return z> -435 and z< -232 and x>edge(z,route) and x<220

static func landing_clear(x:float,z:float,route:Array)->bool:
	return absf(z-B.STAIR_Z)<2.1 and x<edge(z,route)+13

static func build(root:Node3D,builder:RefCounted)->void:
	var n:=K.holder(root,"LibraryStudentWoodlandEdgeV182")
	var rng:=RandomNumberGenerator.new();rng.seed=70037189
	var tree_count:=0;var shrub_count:=0;var background_trees:=0
	# Leaf geometry close to the road, leaving the existing bank stair unobscured.
	for z in range(-429,-234,4):
		for row in 2:
			var zz:float=z+rng.randf_range(-.6,.6)
			var x:float=edge(zz,builder.rear_route)+1.7+row*3.4+rng.randf_range(-.5,.5)
			if landing_clear(x,zz,builder.rear_route):continue
			V.shrub(n,Vector3(x,builder.height(x,zz),zz),Vector3(2.9,rng.randf_range(.85,1.6),3.6),18200+shrub_count)
			shrub_count+=1
	for z in range(-425,-237,8):
		for row in 2:
			var zz:float=z+row*3+rng.randf_range(-2,2)
			var x:float=edge(zz,builder.rear_route)+7+row*7+rng.randf_range(-2,2)
			if landing_clear(x,zz,builder.rear_route):continue
			K.tree(n,Vector3(x,builder.height(x,zz),zz),rng.randf_range(9,14),18200+tree_count,1.65)
			tree_count+=1
	K.finish(n)
	# Farther infill also uses branched leaf geometry. Solid crown ellipsoids
	# looked like an artificial embankment when visible between roadside trunks.
	var far:=K.holder(n,"WoodlandInteriorLeafBatches")
	for z in range(-430,-232,8):
		for x in range(130,220,7):
			var xx:float=x+rng.randf_range(-2.4,2.4);var zz:float=z+rng.randf_range(-2.4,2.4)
			if xx<edge(zz,builder.rear_route)+22:continue
			K.tree(far,Vector3(xx,builder.height(xx,zz),zz),rng.randf_range(12,18),182500+background_trees,.85)
			background_trees+=1
	K.finish(far)
	for node:GeometryInstance3D in far.find_children("*","GeometryInstance3D",true,false):
		node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.set_meta("counts",{"near_trees":tree_count,"shrubs":shrub_count,"background_trees":background_trees})
