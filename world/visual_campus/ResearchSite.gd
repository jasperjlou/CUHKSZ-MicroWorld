extends RefCounted
## V172: relative registration from architect image043; metric controls/grade remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")

static func placement(data:Dictionary)->Transform3D:
	for r:Dictionary in data.buildings:
		if r.id=="research":return Transform3D(Basis(Vector3.UP,deg_to_rad(float(r.yaw))),Vector3(r.position[0],r.position[1],r.position[2]))
	return Transform3D.IDENTITY

static func distance_to_bench(x:float,z:float,t:Transform3D)->float:
	var p:Vector3=t.affine_inverse()*Vector3(x,t.origin.y,z)
	# Include both exterior stairs and rear service lane; the hillside blends beyond this bench.
	return Vector2(maxf(-72-p.x,maxf(p.x-57,0)),maxf(-61-p.z,maxf(p.z-87,0))).length()

static func fitted_height(x:float,z:float,base:float,t:Transform3D)->float:
	var result:float=base
	if z<t.origin.z+110 and z>t.origin.z-120 and x>t.origin.x-125 and x<t.origin.x+115:
		result=lerpf(t.origin.y,base,smoothstep(0,26,distance_to_bench(x,z,t)))
	# The new service connector crosses the old planted bank diagonally. Give the whole
	# carriageway a continuous grade instead of draping asphalt over the old bank break.
	if z>=t.origin.z+60 and z<=-771 and x>120 and x<170:
		var end:Vector3=t*Vector3(50,0,-54)
		var points:Array[Vector3]=[Vector3(130,t.origin.y+2.4,-781),Vector3(156,t.origin.y,-818),end]
		var best:=1000.0;var target:=base;var p:=Vector2(x,z)
		for i in 2:
			var a:=Vector2(points[i].x,points[i].z);var c:=Vector2(points[i+1].x,points[i+1].z);var delta:=c-a
			var fraction:=clampf((p-a).dot(delta)/delta.length_squared(),0,1)
			var gap:=p.distance_to(a+delta*fraction)
			if gap<best:best=gap;target=lerpf(points[i].y,points[i+1].y,fraction)
		result=lerpf(target,result,smoothstep(4.5,9,best))
	return result

static func build(root:Node3D,builder)->void:
	var b:=K.holder(root,"ResearchRegisteredSiteV172")
	b.transform=builder.research_site_transform
	# Hard perimeter pavement follows the same transform as doors, not the old world-axis apron.
	for side in [-1,1]:
		K.box(b,Vector3(side*49,-.025,-1),Vector3(7,.11,86),"aaa99c",true,26)
	K.box(b,Vector3(0,-.025,-42),Vector3(105,.11,8),"aaa99c",true,26)
	K.box(b,Vector3(0,-.025,-47),Vector3(12,.11,6),"aaa99c",true,26)
	# Flush drains stay outside door axes and side-stair landings.
	for x in [-46,53]:
		K.box(b,Vector3(x,.055,-5),Vector3(.24,.045,66),"535e58",false,22)
	for x in [-34,-18,18,34]:
		K.box(b,Vector3(x,.055,-40.8),Vector3(6,.045,.26),"535e58",false,22)
	K.finish(b)
	# Match the existing garden road's collision surface at its .132 m asphalt lift;
	# fade the far end down into the flat rear lane to avoid a raised-surface lip.
	var road:=K.holder(root,"ResearchServiceGradeJoinV172")
	var tail:Vector3=builder.research_site_transform*Vector3(40,0,-54)
	var bend:Vector3=builder.research_site_transform*Vector3(50,0,-54)
	var points:Array=[[130,2.24,-781],[156,2.24,-818],[bend.x,bend.y,bend.z],[tail.x,tail.y,tail.z]]
	var left:Array=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(points,-3)
	var right:Array=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(points,3)
	var vertices:=PackedVector3Array()
	for i in range(points.size()-1):
		var a:=Vector2(points[i][0],points[i][2]);var c:=Vector2(points[i+1][0],points[i+1][2]);var steps:=ceili(a.distance_to(c))
		for j in steps:
			var quad:Array[Vector3]=[]
			for uv:Vector2 in [Vector2(0,float(j)/steps),Vector2(1,float(j)/steps),Vector2(1,float(j+1)/steps),Vector2(0,float(j+1)/steps)]:
				var p:=Vector2(left[i][0],left[i][2]).lerp(Vector2(right[i][0],right[i][2]),uv.x).lerp(Vector2(left[i+1][0],left[i+1][2]).lerp(Vector2(right[i+1][0],right[i+1][2]),uv.x),uv.y)
				var end_distance:float=(p-Vector2(tail.x,tail.z)).dot(Vector2(bend.x-tail.x,bend.z-tail.z).normalized())
				var lift:=lerpf(.008,.132,smoothstep(0,6,end_distance))
				quad.append(Vector3(p.x,builder.height(p.x,p.y)+lift,p.y))
			vertices.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	K.surface(road,vertices,"414b4c",2,true)
	K.finish(road)
