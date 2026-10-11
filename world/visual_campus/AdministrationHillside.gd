extends RefCounted
## A continuous fitted grade behind the retained admin terrace; not surveyed topography.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<=99 or x>=190 or z<=-242 or z>=-118:return base
	var across: float=smoothstep(99,117,x)*(1.0-smoothstep(145,190,x))
	var along: float=smoothstep(-242,-202,z)*(1.0-smoothstep(-158,-118,z))
	return preload("res://world/visual_campus/AdministrationGarden.gd").fitted_height(x,z,base+maxf(0,14.64-base)*across*along)

static func build(root: Node3D,builder: RefCounted) -> void:
	var n:=K.holder(root,"AdministrationPlantedHillside")
	# The existing rear wall becomes the terrace's buried retaining structure.
	# Short flush threshold bridges its top to the same-height new soil bench.
	K.box(n,Vector3(119,14.53,-180),Vector3(4,.22,7.8),"aaa99c",true,6)
	for z in [-184,-176]:
		K.box(n,Vector3(122,14.72,z),Vector3(10,.16,.22),"a1aa92",false,6)
	# Plant clusters are excluded from the new walk and the existing service-road corridor.
	var rng:=RandomNumberGenerator.new();rng.seed=116443781
	for i in 64:
		var x:=rng.randf_range(121,173);var z:=rng.randf_range(-228,-132)
		if absf(x-137)<5.5 and z<-175:continue
		if x>119 and x<171 and z> -193 and z< -165:continue
		if x<132 and absf(x-124)<4 and z< -177:continue
		var p:=Vector3(x,builder.height(x,z),z)
		if i%3==0:K.tree(n,p,rng.randf_range(6.5,10.5),781+i)
		V.shrub(n,p,Vector3(rng.randf_range(2,4.4),rng.randf_range(.55,1.15),rng.randf_range(1.8,3.5)),1900+i)
	K.finish(n)
	preload("res://world/visual_campus/AdministrationGarden.gd").build(root,builder)
