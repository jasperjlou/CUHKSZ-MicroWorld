extends RefCounted
## V205: legacy perimeter + architect043 support the return topology; radii/grade fitted.
## Built image011 and anniversary aerial retain a dense hill edge, not bare default lawn.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")

static func wooded(x:float,z:float,t:Transform3D)->bool:
	var p:Vector3=t.affine_inverse()*Vector3(x,t.origin.y,z)
	return (p.z< -65 and p.z> -91 and p.x> -76 and p.x<67) or (p.x< -75 and p.x> -95 and p.z> -60 and p.z<57)

static func ground_point(builder,t:Transform3D,x:float,z:float,lift:float)->Vector3:
	var p:Vector3=t*Vector3(x,0,z);p.y=builder.height(p.x,p.z)+lift;return p

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"ResearchPerimeterV205");var t:Transform3D=builder.research_site_transform
	# Own the finish of the new return: old decorative paths cross this road band.
	# A separate draped wearing surface resolves the overlap without changing collision.
	for route:Dictionary in builder.data.routes:
		if route.id!="research_service":continue
		var points:Array=route.points.slice(11)
		builder.ribbon(n,points,6,"525955",32,.132)
		for i in points.size()-1:
			var p:=Vector3(points[i][0],points[i][1],points[i][2])
			var q:=Vector3(points[i+1][0],points[i+1][1],points[i+1][2])
			var length:=p.distance_to(q)
			for station in range(3,int(length)-2,9):
				var mark:=p.lerp(q,float(station)/length)
				mark.y=builder.height(mark.x,mark.z)+.153
				K.box(n,mark,Vector3(.12,.02,3),"cbb35d",false,22,atan2(q.x-p.x,q.z-p.z))
	# Match the retained front street's 0.140 m collision lift across its full mouth.
	# Without this short ramp, the new ground-level road hits the old asphalt end face.
	var a:Vector3=t*Vector3(43,0,69);var end:=Vector3(44,t.origin.y,-894)
	var tangent:Vector3=(end-a).normalized();var crosswise:=Vector3(tangent.z,0,-tangent.x)*3
	var join:=PackedVector3Array()
	for i in 16:
		var quad:Array[Vector3]=[]
		for uv:Vector2 in [Vector2(-1,float(i)/16),Vector2(1,float(i)/16),Vector2(1,float(i+1)/16),Vector2(-1,float(i+1)/16)]:
			var p:Vector3=a.lerp(end,uv.y)+crosswise*uv.x
			p.y=builder.height(p.x,p.z)+lerpf(.008,.146,smoothstep(0,1,uv.y));quad.append(p)
		join.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	K.surface(n,join,"525955",32,true)
	# Inside edge of the rounded service return. Runs outside the retained podium.
	var walk:Array=[]
	for p:Vector2 in [Vector2(-46,-43),Vector2(-52,-43),Vector2(-56,-39),Vector2(-56,15),Vector2(-56,45),Vector2(-53,55),Vector2(-45,63),Vector2(-31,69),Vector2(-12,70),Vector2(0,70)]:
		var q:Vector3=t*Vector3(p.x,0,p.y);walk.append([q.x,q.y,q.z])
	builder.ribbon(n,walk,2.8,"7e8580",26,.07)
	# A small aligned solid top, rather than changing the whole terrain into a collider offset.
	var offsets:Array=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(walk,1.4)
	var opposite:Array=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(walk,-1.4)
	var verts:=PackedVector3Array()
	for i in walk.size()-1:
		var steps:=maxi(1,ceili(Vector2(walk[i][0],walk[i][2]).distance_to(Vector2(walk[i+1][0],walk[i+1][2]))))
		for j in steps:
			var quad:Array[Vector3]=[]
			for uv:Vector2 in [Vector2(0,float(j)/steps),Vector2(1,float(j)/steps),Vector2(1,float(j+1)/steps),Vector2(0,float(j+1)/steps)]:
				var l:Vector2=Vector2(opposite[i][0],opposite[i][2]).lerp(Vector2(opposite[i+1][0],opposite[i+1][2]),uv.y)
				var r:Vector2=Vector2(offsets[i][0],offsets[i][2]).lerp(Vector2(offsets[i+1][0],offsets[i+1][2]),uv.y)
				var p:=l.lerp(r,uv.x);quad.append(Vector3(p.x,builder.height(p.x,p.y)+.065,p.y))
			verts.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	var collider:=K.surface(n,verts,"7e8580",26,true);collider.visible=false
	# Narrow stone/metal runoff channel on the hill-side edge of the existing rear lane.
	var drain:Array=[]
	for x in range(-48,51,2):
		var q:Vector3=ground_point(builder,t,x,-58.3,.052);drain.append([q.x,q.y,q.z])
	builder.ribbon(n,drain,.28,"495650",22,.052)
	for x in range(-47,51,2):
		var q:Vector3=ground_point(builder,t,x,-58.3,.063)
		K.box(n,q,Vector3(.055,.016,.27),"829086",false,11,t.basis.get_euler().y)
	var plants:=K.holder(n,"HillToeWoodland")
	var rng:=RandomNumberGenerator.new();rng.seed=205116443
	var trees:=0;var shrubs:=0
	for z0 in range(-86,57,8):
		for x0 in range(-90,67,8):
			var p:Vector3=ground_point(builder,t,x0+rng.randf_range(-1.6,1.6),z0+rng.randf_range(-1.6,1.6),0)
			if not wooded(p.x,p.z,t):continue
			K.tree(plants,p,rng.randf_range(8,13),205000+trees,1.1);trees+=1
	for z0 in range(-87,57,4):
		for x0 in range(-91,67,4):
			var p:Vector3=ground_point(builder,t,x0+rng.randf_range(-.8,.8),z0+rng.randf_range(-.8,.8),0)
			if not wooded(p.x,p.z,t):continue
			V.shrub(plants,p,Vector3(rng.randf_range(2.7,4.1),rng.randf_range(.9,2),3.5),205800+shrubs);shrubs+=1
	K.finish(plants);K.finish(n)
	n.set_meta("counts",{"trees":trees,"shrubs":shrubs})
