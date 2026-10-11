extends RefCounted
## V84 user photographs 2026-10-10, 222429/440/453/519, and architect masterplan043.
## Relative location supported; metre dimensions, grades and shoreline are fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const Lake:=preload("res://world/visual_campus/EntranceLakeSite.gd")
const G:=2.24
const LOW:=1.04
const WATER:=.67
static var shore:PackedVector2Array=PackedVector2Array()

static func smooth_path(points:Array[Vector2],closed:bool=false) -> PackedVector2Array:
	var result:=PackedVector2Array()
	var count:int=points.size() if closed else points.size()-1
	for i in count:
		var a:Vector2=points[posmod(i-1,points.size())] if closed else points[maxi(0,i-1)]
		var b:Vector2=points[i];var c:Vector2=points[(i+1)%points.size()]
		var d:Vector2=points[(i+2)%points.size()] if closed else points[mini(points.size()-1,i+2)]
		for j in 8:
			var t:float=j/8.0
			result.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
	if not closed:result.append(points[-1])
	return result

static func outline() -> PackedVector2Array:
	if shore.is_empty():shore=smooth_path([Vector2(-1,-529),Vector2(8,-532),Vector2(13,-539),Vector2(12,-547),Vector2(17,-555),Vector2(13,-565),Vector2(4,-574),Vector2(-5,-575),Vector2(-12,-569),Vector2(-9,-559),Vector2(-14,-550),Vector2(-11,-540),Vector2(-8,-533)],true)
	return shore

static func stair_height(z:float) -> float:
	var travel:float=clampf(-z-511,0,16)
	var flight:int=mini(3,int(travel/4))
	return G-flight*.30-clampf((travel-flight*4)/1.2,0,1)*.30

static func fitted_height(x:float,z:float,base:float) -> float:
	if absf(x)>=27 or z>=-510 or z<=-582:return base
	var low:float=stair_height(z) if z>-527 else LOW
	low=lerpf(low,G,1.0-smoothstep(-582,-577,z))
	var across:float=smoothstep(16,27,absf(x))
	return lerpf(low,base,across)

static func clipped_cell(builder,x:float,xx:float,z:float,zz:float) -> PackedVector3Array:
	var polys:=Geometry2D.clip_polygons(PackedVector2Array([Vector2(x,z),Vector2(xx,z),Vector2(xx,zz),Vector2(x,zz)]),outline())
	var verts:=PackedVector3Array()
	for poly:PackedVector2Array in polys:
		var indices:=Geometry2D.triangulate_polygon(poly)
		for i in range(0,indices.size(),3):
			var ps:Array[Vector3]=[]
			for j in 3:
				var p:Vector2=poly[indices[i+j]];ps.append(Vector3(p.x,builder.height(p.x,p.y),p.y))
			verts.append_array(K.quad(ps[0],ps[1],ps[2],ps[0]))
	return verts

static func reverse_faces(verts:PackedVector3Array) -> PackedVector3Array:
	var result:=PackedVector3Array()
	for i in range(0,verts.size(),3):result.append_array(PackedVector3Array([verts[i],verts[i+2],verts[i+1]]))
	return result

static func vault_height(x:float,z:float) -> float:
	var ax:float=clampf(absf(x)/3.68,0,1);var az:float=clampf(absf(z)/3.68,0,1)
	return 5.15*sqrt(maxf(0,1-minf(ax*ax,az*az)))

static func pavilion(n:Node3D) -> void:
	var b:=K.holder(n,"FourArchPavilion",Vector3(0,G+.08,-503))
	K.box(b,Vector3(0,-.04,0),Vector3(12,.08,14),"90958e",true,26)
	var mesh:=PackedVector3Array();var a:float=4.2;var segments:int=48
	for i in segments:
		for j in segments:
			var x:float=-a+2*a*i/segments;var xx:float=-a+2*a*(i+1)/segments
			var z:float=-a+2*a*j/segments;var zz:float=-a+2*a*(j+1)/segments
			mesh.append_array(reverse_faces(K.quad(Vector3(x,vault_height(x,z),z),Vector3(xx,vault_height(xx,z),z),Vector3(xx,vault_height(xx,zz),zz),Vector3(x,vault_height(x,zz),zz))))
	# Four exterior arch faces close the volume between the vault and the flat roof edge.
	for side in [-1,1]:
		for axis in 2:
			for i in segments:
				var p:float=-a+2*a*i/segments;var q:float=-a+2*a*(i+1)/segments
				var v1:=Vector3(p,vault_height(p,side*a),side*a);var v2:=Vector3(q,vault_height(q,side*a),side*a)
				if axis==1:v1=Vector3(v1.z,v1.y,v1.x);v2=Vector3(v2.z,v2.y,v2.x)
				var top1:=Vector3(v1.x,5.48,v1.z);var top2:=Vector3(v2.x,5.48,v2.z)
				var face:=K.quad(v1,v2,top2,top1);mesh.append_array(face);mesh.append_array(reverse_faces(face))
	K.surface(b,mesh,"dfdfd5",22,true)
	K.box(b,Vector3(0,5.50,0),Vector3(a*2,.06,a*2),"d4d4c9",true,22)
	K.finish(b)

static func path(n:Node3D,points:PackedVector2Array,width:float,color:String,kind:int,builder,fixed_y:float=-100) -> void:
	var verts:=PackedVector3Array()
	for i in points.size()-1:
		var a:Vector2=points[i];var c:Vector2=points[i+1]
		var ta:Vector2=(points[mini(i+1,points.size()-1)]-points[maxi(i-1,0)]).normalized()
		var tc:Vector2=(points[mini(i+2,points.size()-1)]-points[i]).normalized()
		var na:=Vector2(ta.y,-ta.x)*width/2;var nc:=Vector2(tc.y,-tc.x)*width/2
		var ps:Array[Vector3]=[]
		for p:Vector2 in [a-na,a+na,c+nc,c-nc]:ps.append(Vector3(p.x,fixed_y if fixed_y>-99 else builder.height(p.x,p.y)+.055,p.y))
		verts.append_array(K.quad(ps[0],ps[1],ps[2],ps[3]))
		if fixed_y>-99:
			for edge in [Vector2i(0,3),Vector2i(1,2)]:
				var face:=K.quad(ps[edge.x],ps[edge.y],ps[edge.y]-Vector3.UP*.18,ps[edge.x]-Vector3.UP*.18)
				verts.append_array(face);verts.append_array(reverse_faces(face))
	K.surface(n,verts,color,kind,true)

static func stairs(n:Node3D) -> void:
	for flight in 4:
		var z:float=-511-flight*4;var y:float=G-flight*.30
		for step in 2:
			K.box(n,Vector3(0,y-(step+1)*.15+.015,z-(step+.5)*.6),Vector3(4.6,.06,.61),"9b9f95",false,26)
		K.surface(n,K.quad(Vector3(-2.3,y+.045,z),Vector3(2.3,y+.045,z),Vector3(2.3,y-.255,z-1.2),Vector3(-2.3,y-.255,z-1.2)),"969b8f",26,true).hide()
		K.box(n,Vector3(0,y-.275,z-2.60),Vector3(4.6,.05,2.8),"707768",true,38)
		for side in [-1,1]:K.box(n,Vector3(side*2.36,y-.16,z-2.0),Vector3(.14,.3,4),"c4c6b9",true,22)

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"PavilionPondV84")
	pavilion(n);stairs(n)
	path(n,PackedVector2Array([Vector2(0,-490),Vector2(0,-511)]),5.5,"949990",26,builder)
	var poly:=outline();Lake.polygon_surface(n,poly,.12,"555b48",22,true);Lake.polygon_surface(n,poly,WATER,"40574e",10)
	# Low continuous rim: visible edge and actual ground/water separation.
	var bank:=PackedVector3Array()
	for i in poly.size():
		var a:Vector2=poly[i];var c:Vector2=poly[(i+1)%poly.size()]
		var face:=K.quad(Vector3(a.x,.12,a.y),Vector3(c.x,.12,c.y),Vector3(c.x,LOW,c.y),Vector3(a.x,LOW,a.y))
		bank.append_array(face);bank.append_array(reverse_faces(face))
	K.surface(n,bank,"5c6655",22,true)
	var boardwalk:=smooth_path([Vector2(-2,-527),Vector2(-9,-532),Vector2(-13,-541),Vector2(-16,-550),Vector2(-11,-559),Vector2(-14,-568),Vector2(-6,-577),Vector2(4,-577)])
	path(n,boardwalk,1.75,"776953",35,builder,LOW+.10)
	var crossing:=smooth_path([Vector2(-16,-550),Vector2(-8,-544),Vector2(0,-550),Vector2(9,-555),Vector2(17,-549),Vector2(16,-545)])
	path(n,crossing,1.7,"615d4b",35,builder,LOW+.10)
	# Stone paths meet the low deck and climb through the planted banks to the outer walks.
	for row:Array in [[Vector2(-29,-550),Vector2(-21,-550),Vector2(-16,-550)],[Vector2(16,-545),Vector2(24,-545),Vector2(29,-545)],[Vector2(4,-577),Vector2(7,-580),Vector2(10,-584)]]:
		var points:Array[Vector2]=[];points.assign(row)
		path(n,smooth_path(points),2.8,"83897a",37,builder)
	# Planted margins follow the retained upper walk; avoid the photographed open pond centre.
	for p:Vector2 in [Vector2(-9,-499),Vector2(10,-501),Vector2(-15,-493),Vector2(16,-494),Vector2(-22,-515),Vector2(22,-516),Vector2(-22,-524),Vector2(22,-525),Vector2(-22,-533),Vector2(22,-534),Vector2(-22,-542),Vector2(23,-559),Vector2(-22,-559),Vector2(23,-568),Vector2(-22,-568),Vector2(20,-576),Vector2(-21,-577)]:
		var y:float=builder.height(p.x,p.y)
		K.tree(n,Vector3(p.x,y,p.y),8.0,8400+absi(int(p.y)),1.3)
		V.shrub(n,Vector3(p.x,y+.05,p.y+2),Vector3(3.1,.5,2.0),8400+absi(int(p.y)))
		for a in [0.0,2.094,4.189]:V.branch(n,Vector3(p.x+cos(a)*1.05,y,p.y+sin(a)*1.05),Vector3(p.x,y+2.3,p.y),.025)
	# Sparse perimeter lily patches retain clear water/reflections, not a grass-textured pool.
	var leaves:=PackedVector3Array();var rng:=RandomNumberGenerator.new();rng.seed=84261010
	for i in 250:
		var index:int=rng.randi_range(0,poly.size()-1);var p:Vector2=poly[index].lerp(Vector2(1,-551),rng.randf_range(.04,.14))
		if not Geometry2D.is_point_in_polygon(p,poly):continue
		var radius:float=rng.randf_range(.18,.36);var center:=Vector3(p.x,WATER+.018,p.y)
		for j in 9:
			var a:float=.15+j*(TAU-.3)/9;var c:float=.15+(j+1)*(TAU-.3)/9
			leaves.append_array(K.quad(center,center+Vector3(cos(a)*radius,0,sin(a)*radius),center+Vector3(cos(c)*radius,0,sin(c)*radius),center))
	K.surface(n,leaves,"63774a",14)
	for p:Vector2 in [Vector2(-3.3,-512),Vector2(-3.3,-516),Vector2(-3.3,-520),Vector2(-3.3,-524),Vector2(-19,-544),Vector2(-17,-564),Vector2(20,-551)]:
		var y:float=builder.height(p.x,p.y)
		K.box(n,Vector3(p.x,y+.43,p.y),Vector3(.16,.86,.16),"505b54",true,11)
		K.box(n,Vector3(p.x,y+.66,p.y),Vector3(.17,.29,.17),"dedac1",false,17)
	K.finish(n)
