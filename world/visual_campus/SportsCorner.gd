extends RefCounted
## V206 anniversary aerial: hard corner forecourt, roadside planters and crossing.
## Relative location, outline and levels are fitted; photo capture date is unknown.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const FLOOR:=-1.66
const OUTLINE:Array[Vector2]=[Vector2(-129.8,-1086),Vector2(-129.8,-1097),Vector2(-128,-1101.7),Vector2(-108,-1101.7),Vector2(-116,-1086)]

static func crossing_lift(x:float,z:float,lift:float)->float:
	# Keep mesh finish and solid footway on the same shallow, flared dropped kerb.
	if x< -110 or x> -103:return lift
	var inset:float=1.0-smoothstep(2.5,3.5,absf(x+106.5))
	var depth:float=100.0
	if z> -1110 and z< -1106:depth=z+1109
	elif z> -1130 and z< -1126:depth=-1127-z
	if depth==100:return lift
	var limit:float=lerpf(.045,.10,smoothstep(0,1.7,depth))
	return lerpf(lift,minf(lift,limit),inset)

static func sign_bank(x:float,z:float)->bool:
	return x> -111 and x< -83 and z> -1101 and z< -1084

static func fitted_height(x:float,z:float,base:float)->float:
	if x< -135 or x> -103 or z< -1107 or z> -1081:return base
	var p:=Vector2(x,z);var boundary:=100.0
	for i in OUTLINE.size():
		var a:=OUTLINE[i];var d:Vector2=OUTLINE[(i+1)%OUTLINE.size()]-a
		boundary=minf(boundary,p.distance_to(a+d*clampf((p-a).dot(d)/d.length_squared(),0,1)))
	var influence:=1.0 if Geometry2D.is_point_in_polygon(p,PackedVector2Array(OUTLINE)) else 1.0-smoothstep(0,3.5,boundary)
	return lerpf(base,FLOOR-.10,influence)

static func patch(n:Node3D,builder,poly:Array[Vector2],color:String,kind:int,lift:float,solid:bool=false)->MeshInstance3D:
	var vertices:=PackedVector3Array();var packed:=PackedVector2Array(poly)
	var indices:=Geometry2D.triangulate_polygon(packed)
	for i in range(0,indices.size(),3):
		var a:Vector2=poly[indices[i]];var b:Vector2=poly[indices[i+1]];var c:Vector2=poly[indices[i+2]]
		# One-metre subdivisions follow the sculpted transition instead of spanning grass.
		var count:=maxi(1,ceili(maxf(a.distance_to(b),maxf(b.distance_to(c),c.distance_to(a)))))
		for u in count:
			for v in count-u:
				var p:=a+(b-a)*float(u)/count+(c-a)*float(v)/count
				var q:=p+(b-a)/count;var r:=p+(c-a)/count
				for s:Vector2 in [p,q,r]:vertices.append(Vector3(s.x,builder.height(s.x,s.y)+crossing_lift(s.x,s.y,lift),s.y))
				if u+v<count-1:
					for s:Vector2 in [q,q+(c-a)/count,r]:vertices.append(Vector3(s.x,builder.height(s.x,s.y)+crossing_lift(s.x,s.y,lift),s.y))
	# Godot's clockwise front face points upward when the XZ cross product is negative.
	# Opposite duplicates would share vertices during normal generation and cancel them.
	for i in range(0,vertices.size(),3):
		if (vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i]).y>0:
			var swap:=vertices[i+1];vertices[i+1]=vertices[i+2];vertices[i+2]=swap
	return K.surface(n,vertices,color,kind,solid)

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"SportsCornerForecourtV206")
	patch(n,builder,OUTLINE,"7e8582",26,.105)
	# Pale border against the retained planted bank, with no kerb across the footway.
	for span:Array in [[OUTLINE[0],OUTLINE[4]],[OUTLINE[4],OUTLINE[3]]]:
		var a:Vector2=span[0];var b:Vector2=span[1];var normal:=Vector2(-(b-a).y,(b-a).x).normalized()*.16
		patch(n,builder,[a-normal,b-normal,b+normal,a+normal],"a4aaa3",26,.12)
	# Rectangular raised planters sit along the roadside strip, keeping a clear walking lane.
	for x:float in [-124,-116]:
		var p:=Vector3(x,builder.height(x,-1107.8),-1107.8)
		K.box(n,p+Vector3.UP*.30,Vector3(3.4,.6,1.6),"9b9a8c",true,26)
		K.box(n,p+Vector3.UP*.605,Vector3(3.05,.02,1.25),"514a38",false,8)
		V.shrub(n,p+Vector3.UP*.62,Vector3(2.9,.45,1.15),206000+int(x))
	# Crossing on the straight arm adjoining the corner. No invented textual road labels.
	# Existing road and footway colliders leave a 0.20 m gutter gap; bridge it only at the crossing.
	for z:float in [-1109,-1127]:
		var finish:=patch(n,builder,[Vector2(-109.5,z-.26),Vector2(-103.5,z-.26),Vector2(-103.5,z+.26),Vector2(-109.5,z+.26)],"969d94",26,.045)
		finish.position.y=.003 # Finish alone clears the coplanar asphalt; solid stays at +0.045.
		# This flat joint uses one box, avoiding exact shared-edge gaps in triangle ray queries.
		var support:=StaticBody3D.new();support.name="CrossingJointSupport";n.add_child(support)
		var shape:=BoxShape3D.new();shape.size=Vector3(6,.045,.52)
		var collision:=CollisionShape3D.new();collision.shape=shape
		collision.position=Vector3(-106.5,builder.height(-106.5,z)+.0225,z);support.add_child(collision)
	for z in range(-1125,-1110):
		if z%2!=0:continue
		patch(n,builder,[Vector2(-109,z),Vector2(-104,z),Vector2(-104,z+.75),Vector2(-109,z+.75)],"d0d1c4",22,.085)
	# Short tactile branch and terminal warning pads align the existing strip with the crossing.
	patch(n,builder,[Vector2(-109,-1109),Vector2(-104,-1109),Vector2(-104,-1101.7),Vector2(-109,-1101.7)],"7e8582",26,.112)
	patch(n,builder,[Vector2(-106.8,-1108.6),Vector2(-106.2,-1108.6),Vector2(-106.2,-1103.7),Vector2(-106.8,-1103.7)],"968660",22,.12)
	var bump_mesh:=CylinderMesh.new();bump_mesh.top_radius=.033;bump_mesh.bottom_radius=.041;bump_mesh.height=.014;bump_mesh.radial_segments=8
	for rect:Rect2 in [Rect2(-109,-1108.1,5,.8),Rect2(-109,-1128.7,5,.8)]:
		patch(n,builder,[rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)],"968660",22,.116)
		for ix in 19:
			for iz in 3:
				var x:float=rect.position.x+.22+ix*.24;var z:float=rect.position.y+.2+iz*.24
				var bump:=MeshInstance3D.new();bump.mesh=bump_mesh;bump.material_override=K.material("a3946e",22)
				bump.position=Vector3(x,builder.height(x,z)+crossing_lift(x,z,.116)+.012,z);n.add_child(bump)
	# Directional ribs continue to the warning pad, with their relief following the ramp.
	for x:float in [-106.72,-106.58,-106.44,-106.30]:
		patch(n,builder,[Vector2(x,-1107.3),Vector2(x+.035,-1107.3),Vector2(x+.035,-1103.7),Vector2(x,-1103.7)],"a3946e",22,.131)
	welcome_bank(n,builder)
	K.finish(n)

static func welcome_bank(n:Node3D,builder)->void:
	# Photo-era installation, not evidence of a permanent building or a surveyed plaque.
	var x:float=-98;var z:float=-1093.8
	var dx:float=(builder.height(x+1,z)-builder.height(x-1,z))/2
	var dz:float=(builder.height(x,z+1)-builder.height(x,z-1))/2
	var right:=Vector3(-1,-dx,0).normalized();var up:=Vector3(0,maxf(dz,.55),1).normalized()
	var normal:=right.cross(up).normalized();up=normal.cross(right).normalized()
	var sign:=K.holder(n,"AnniversaryWelcomeBankV207",Vector3(x,builder.height(x,z)+.18,z))
	sign.basis=Basis(right,up,normal)
	# Lift only enough to avoid the non-planar grass at the installation's ends.
	var clearance:=0.0
	for u:float in [-10,0,10]:
		for v:float in [-.6,.6]:
			var p:Vector3=sign.transform*Vector3(u,v,0)
			clearance=maxf(clearance,builder.height(p.x,p.z)+.06-p.y)
	sign.position.y+=clearance
	K.box(sign,Vector3.ZERO,Vector3(20,1.15,.09),"c6c8c0",false,22)
	var line:=K.label(sign,"The Chinese University of Hong Kong, Shenzhen",Vector3(0,0,.08),.011)
	line.modulate=Color("253962");line.no_depth_test=false
	var title:=K.label(sign,"Welcome",Vector3(-5.3,1.15,.08),.025)
	title.modulate=Color("e5e7dd");title.no_depth_test=false
	# Pale lavender falling ribbon is visible beside the lettering; exact motif unknown.
	var ribbon:=PackedVector3Array()
	for i in 32:
		var t:float=float(i)/32;var next:float=float(i+1)/32
		var centre:=Vector3(9.3+sin(t*PI)*.65,.7-t*3.4,.025)
		var after:=Vector3(9.3+sin(next*PI)*.65,.7-next*3.4,.025)
		var half:float=(.7+t*.65)/2;var next_half:float=(.7+next*.65)/2
		ribbon.append_array(K.quad(centre-Vector3.RIGHT*half,centre+Vector3.RIGHT*half,after+Vector3.RIGHT*next_half,after-Vector3.RIGHT*next_half))
	K.surface(sign,ribbon,"777b9f",22)
	K.finish(sign)
