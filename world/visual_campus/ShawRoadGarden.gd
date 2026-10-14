extends RefCounted
## V244: official70040609 side branch shows lawn, clipped hedge and spaced trees,
## with wooded hill beyond. Photographic registration/dimensions remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const Road=preload("res://world/visual_campus/RearRoadBank.gd")

static func contains(x:float,z:float)->bool:
	return z> -579 and z< -472 and x>137 and x<238

static func wooded(x:float,z:float)->bool:
	# Preserve the maintained lawn and scattered trees at the roadside.
	return contains(x,z) and x>171+sin((z+510)*.045)*4

static func border(builder,n:Node3D,edge:Array)->void:
	# Clip the side-path border at the actual rear carriageway, not its centre.
	# Keeping a curb across the T-junction made the public connection look blocked.
	var run:Array=[]
	for i in range(edge.size()-1):
		var a:=Vector2(edge[i][0],edge[i][2]);var b:=Vector2(edge[i+1][0],edge[i+1][2])
		var count:int=maxi(1,ceili(a.distance_to(b)/.35))
		for j in count+1:
			var p:Vector2=a.lerp(b,float(j)/count)
			if p.x<Road.road_x(p.y,builder.rear_route)-3.35:
				if run.is_empty() or Vector2(run[-1][0],run[-1][2]).distance_to(p)>.01:run.append([p.x,2.24,p.y])
			else:
				if run.size()>1:builder.ribbon(n,run,.18,"8d9995",26,.157)
				run=[]
	if run.size()>1:builder.ribbon(n,run,.18,"8d9995",26,.157)

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"ShawRoadGardenV244")
	var rng:=RandomNumberGenerator.new();rng.seed=244700406
	var plants:Array=[];var trees:int=0;var shrubs:int=0
	# Scattered, braced small trees retain grass between them, as the side view shows.
	for z0 in range(-568,-479,12):
		for row in 2:
			var z:float=z0+row*3+rng.randf_range(-1,1)
			var x:float=maxf(138,Road.road_x(z,builder.rear_route)+10)+row*12+rng.randf_range(-1.2,1.2)
			var p:=Vector3(x,builder.height(x,z),z)
			var h:float=rng.randf_range(6.5,9.3)
			K.tree(n,p,h,244000+trees,1.5);trees+=1;plants.append([x,z])
			for a:float in [0,2.094,4.189]:V.branch(n,p+Vector3(cos(a)*.85,0,sin(a)*.85),p+Vector3(0,2.0,0),.028)
	# Low clipped roadside hedge; the side-path head is a separate planted margin.
	for z0 in range(-571,-481,3):
		var z:float=z0
		var x:float=maxf(135,Road.road_x(z,builder.rear_route)+7.1)
		V.shrub(n,Vector3(x,builder.height(x,z),z),Vector3(1.7,.55,3.0),244200+shrubs);shrubs+=1;plants.append([x,z])
	# Branched woodland replaces the visible generic canopy wall only in this patch.
	for z0 in range(-576,-472,9):
		for x0 in range(174,237,10):
			var x:float=x0+rng.randf_range(-2,2);var z:float=z0+rng.randf_range(-2,2)
			if not wooded(x,z):continue
			K.tree(n,Vector3(x,builder.height(x,z),z),rng.randf_range(9,15),244000+trees,.95);trees+=1
			if x<196:
				V.shrub(n,Vector3(x,builder.height(x,z),z),Vector3(3.6,1.05,3.8),244200+shrubs);shrubs+=1
	K.finish(n);n.set_meta("inventory",{"trees":trees,"shrubs":shrubs,"near_plant_centres":plants,"collision_added":false})
