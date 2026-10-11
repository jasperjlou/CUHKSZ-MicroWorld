extends RefCounted
## V69: architect 065/067/068, 2025-12-24 publication. Curved pond and rear
## CxII arrangement fitted to retained East Gate; not surveyed contours.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const Site := preload("res://world/visual_campus/EastGatePortal.gd")

static func outline() -> PackedVector2Array:
	var anchors: Array[Vector2]=[Vector2(101,4),Vector2(106,-2),Vector2(116,-5),Vector2(126,-7),Vector2(137,-2),Vector2(143,8),Vector2(140,21),Vector2(131,30),Vector2(119,33),Vector2(109,29),Vector2(102,20),Vector2(100,11)]
	var poly:=PackedVector2Array()
	for i in anchors.size():
		var a:=anchors[posmod(i-1,anchors.size())];var b:=anchors[i];var c:=anchors[(i+1)%anchors.size()];var d:=anchors[(i+2)%anchors.size()]
		for j in 4:
			var t: float=float(j)/4
			poly.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
	return poly

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<100 or x>141 or z< -70 or z> -10:return base
	var weight: float=smoothstep(100,105,x)*(1-smoothstep(136,141,x))*(1-smoothstep(-20,-10,z))
	return lerpf(base,2.24,weight)

static func clipped_cell(builder,x: float,xx: float,z: float,zz: float) -> PackedVector3Array:
	var polys:=Geometry2D.clip_polygons(PackedVector2Array([Vector2(x,z),Vector2(xx,z),Vector2(xx,zz),Vector2(x,zz)]),outline())
	var vertices:=PackedVector3Array()
	for poly: PackedVector2Array in polys:
		var indexes:=Geometry2D.triangulate_polygon(poly)
		for i in range(0,indexes.size(),3):
			var pts: Array[Vector3]=[]
			for j in 3:
				var p:=poly[indexes[i+j]];pts.append(Vector3(p.x,builder.height(p.x,p.y),p.y))
			if (pts[1]-pts[0]).cross(pts[2]-pts[0]).y>0:vertices.append_array(PackedVector3Array([pts[0],pts[2],pts[1]]))
			else:vertices.append_array(PackedVector3Array(pts))
	return vertices

static func polygon_surface(n: Node3D,poly: PackedVector2Array,y: float,color: String,kind: int,solid: bool=false) -> void:
	var indexes:=Geometry2D.triangulate_polygon(poly);var verts:=PackedVector3Array()
	for i in range(0,indexes.size(),3):
		var a:=Vector3(poly[indexes[i]].x,y,poly[indexes[i]].y);var b:=Vector3(poly[indexes[i+1]].x,y,poly[indexes[i+1]].y);var c:=Vector3(poly[indexes[i+2]].x,y,poly[indexes[i+2]].y)
		if (b-a).cross(c-a).y>0:verts.append_array(PackedVector3Array([a,c,b]))
		else:verts.append_array(PackedVector3Array([a,b,c]))
	K.surface(n,verts,color,kind,solid)

static func lake(n: Node3D,builder) -> void:
	var poly:=outline();polygon_surface(n,poly,-1.1,"505947",22,true);polygon_surface(n,poly,-.27,"405b4b",10)
	var bank:=PackedVector3Array();var paved:=PackedVector3Array()
	for i in poly.size():
		var j: int=(i+1)%poly.size();var outer: Array[Vector2]=[]
		for index in [i,j]:
			var tangent: Vector2=(poly[(index+1)%poly.size()]-poly[posmod(index-1,poly.size())]).normalized()
			var normal:=Vector2(tangent.y,-tangent.x)
			if normal.dot(poly[index]-Vector2(121,12))<0:normal=-normal
			outer.append(poly[index]+normal*3.0)
		var a:=Vector3(poly[i].x,.10,poly[i].y);var c:=Vector3(poly[j].x,.10,poly[j].y)
		var aa:=Vector3(outer[0].x,builder.height(outer[0].x,outer[0].y)+.108,outer[0].y);var cc:=Vector3(outer[1].x,builder.height(outer[1].x,outer[1].y)+.108,outer[1].y)
		paved.append_array(K.quad(a,c,cc,aa))
		var wall:=K.quad(a+Vector3.DOWN*1.2,c+Vector3.DOWN*1.2,c,a)
		var back:=PackedVector3Array()
		for k in range(wall.size()-1,-1,-1):back.append(wall[k])
		wall.append_array(back);bank.append_array(wall)
		# Timber-toned fence only at the long outer shore; keep the building approaches open.
		if (a.x+c.x)/2>135 or (a.z+c.z)/2>26:
			var delta:=c-a;var yaw:=atan2(delta.x,delta.z)
			var body:=StaticBody3D.new();body.position=(a+c)/2+Vector3.UP*.60;body.rotation.y=yaw;n.add_child(body)
			var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(.09,1.12,delta.length()+.025);collision.shape=shape;body.add_child(collision)
			for h in [.38,1.12]:K.box(n,(a+c)/2+Vector3.UP*h,Vector3(.10,.09,delta.length()+.025),"866a48",false,4,yaw)
			var count:=maxi(1,ceili(delta.length()/.85))
			for k in count:K.box(n,a.lerp(c,float(k)/count)+Vector3.UP*.61,Vector3(.07,1.10,.07),"866a48",false,4)
	K.surface(n,paved,"929b8d",26,true);K.surface(n,bank,"818b7c",26,true)
	# The axonometric shows a retained small tree island, not a lawn-filled pond.
	var island:=PackedVector2Array()
	for i in 24:
		var angle:float=i*TAU/24;island.append(Vector2(124+cos(angle)*1.8,15+sin(angle)*1.5))
	polygon_surface(n,island,.04,"65764d",3)
	K.tree(n,Vector3(124,.08,15),7.6,69124)
	for p: Vector2 in [Vector2(106,36),Vector2(118,39),Vector2(133,36),Vector2(145,27),Vector2(149,12),Vector2(147,-2),Vector2(137,-12),Vector2(96,26),Vector2(99,35)]:K.tree(n,Vector3(p.x,builder.height(p.x,p.y),p.y),10.5,69000+absi(int(p.x*7+p.y)))

static func build(root: Node3D,builder) -> void:
	var n:=K.holder(root,"RegisteredConferenceLakeLandscape")
	lake(n,builder)
	# Rear group ground meets the ICC rear aisle, and a fitted public stair meets the pond.
	Site.field(n,builder,109.6,120,-68,-18,"9ca497",31)
	Site.field(n,builder,98,152,-68,-62,"9ca497",31)
	Site.field(n,builder,147.5,152,-64,-12,"9ca497",31)
	Site.field(n,builder,117,148,-19,-12,"9ca497",31)
	# Reach the platform height before its front slab edge at z=-19.2.
	P.stair(n,Vector3(127,0,-9),Vector3(127,2.24,-18.6),7)
	K.box(n,Vector3(127,2.11,-19.6),Vector3(7,.26,2.0),"a4a89e",true,22)
	K.box(n,Vector3(127,2.248,-19.6),Vector3(7,.016,2.0),"919990",false,26)
	# Narrow light pergola links hall-side paving and the conference lower platform.
	for z in [-10.0,-18.0]:
		K.box(n,Vector3(123,7.4,z),Vector3(18,.35,.35),"b8beb2",false,22)
		for x in [114.5,131.5]:K.column(n,Vector3(x,builder.height(x,z),z),7.4-builder.height(x,z),.32)
	for x in range(115,132,2):K.box(n,Vector3(x,7.55,-14),Vector3(.20,.30,8.5),"c1c7ba",false,22)
	# Field follows the actual fitted grade, closing the former grass seams.
	Site.field(n,builder,95,99.5,-20,25,"959e90",31)
	Site.field(n,builder,38,99.5,18,25,"939c91",31)
	K.finish(n)
