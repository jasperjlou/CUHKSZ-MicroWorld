extends RefCounted
## V59: standard 400 m model, nine lanes confirmed by school's 2023 opening guide.
## WA dimensions are a modelling basis, not an as-built campus survey/certification.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const HALF_STRAIGHT := 42.195
const INNER := 36.5
const LANE_WIDTH := 1.22
const LANES := 9
const OUTER := INNER+LANES*LANE_WIDTH
const ARC_SEGMENTS := 256

static func oval(radius: float,segments:int=ARC_SEGMENTS) -> PackedVector3Array:
	var points:=PackedVector3Array()
	for side in [1,-1]:
		for i in segments+1:
			var a: float=-PI/2+PI*i/segments+(PI if side<0 else 0)
			points.append(Vector3(side*HALF_STRAIGHT+cos(a)*radius,0,sin(a)*radius))
	return points

static func band(b: Node3D,outer: float,inner: float,y: float,color: String,kind: int) -> void:
	var a:=oval(outer);var c:=oval(inner);var v:=PackedVector3Array()
	for i in a.size():
		var j: int=(i+1)%a.size()
		v.append_array(K.quad(a[i]+Vector3.UP*y,a[j]+Vector3.UP*y,c[j]+Vector3.UP*y,c[i]+Vector3.UP*y))
	K.surface(b,v,color,kind)

static func line(b: Node3D,a: Vector3,c: Vector3,width: float=.10,color: String="d8dccb") -> void:
	var n: Vector3=(c-a).normalized().cross(Vector3.UP)*width/2
	K.surface(b,K.quad(a+n,c+n,c-n,a-n),color)

static func member(b: Node3D,a: Vector3,c: Vector3,w: float,color: String) -> void:
	var n:=K.holder(b,"FieldMember",(a+c)/2);n.quaternion=Quaternion(Vector3.UP,(c-a).normalized())
	K.box(n,Vector3.ZERO,Vector3(w,a.distance_to(c),w),color,false,11);K.finish(n)

static func perimeter(b: Node3D) -> void:
	# V175: anniversary aerial and 2023 meet photos show red runoff, outside mesh,
	# and an open stone forecourt along the Sports Complex, not a fence across that facade.
	band(b,50.4,OUTER,.070,"89463d",8)
	band(b,50.95,50.4,.074,"a5aaa0",26)
	band(b,50.75,50.55,.080,"4b5652",11)
	band(b,53.3,50.95,.070,"969f93",26)
	var points:=oval(53.6,64)
	var wire:=SurfaceTool.new();wire.begin(Mesh.PRIMITIVE_TRIANGLES)
	var guard:=StaticBody3D.new();guard.name="BoundaryFenceCollision";b.add_child(guard)
	var fence_height:float=3.2 # fitted to photo human/tree scale, not surveyed
	for i in points.size():
		var a:Vector3=points[i];var c:Vector3=points[(i+1)%points.size()]
		var count:=maxi(1,ceili(a.distance_to(c)/2.5))
		for j in count:
			var p:=a.lerp(c,float(j)/count);var q:=a.lerp(c,float(j+1)/count);var mid:Vector3=(p+q)/2
			# V176 continuous photographed outer fence; retire the three unsupported V59 bays.
			var opening:bool=(mid.z>0 and absf(mid.x)<68)
			if opening:continue
			var d:float=p.distance_to(q)
			var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(.08,fence_height,d+.015)
			collider.shape=shape;collider.position=mid+Vector3.UP*(fence_height/2);collider.rotation.y=atan2(q.x-p.x,q.z-p.z);guard.add_child(collider)
			var vertices:Array[Vector3]=[p,q,q+Vector3.UP*fence_height,p,q+Vector3.UP*fence_height,p+Vector3.UP*fence_height]
			var uvs:Array[Vector2]=[Vector2.ZERO,Vector2(d,0),Vector2(d,fence_height),Vector2.ZERO,Vector2(d,fence_height),Vector2(0,fence_height)]
			for k in 6:wire.set_uv(uvs[k]);wire.add_vertex(vertices[k])
			for h:float in [.10,1.6,3.2]:K.box(b,mid+Vector3.UP*h,Vector3(d+.035,.05,.05),"376657",false,11,-atan2(q.z-p.z,q.x-p.x))
			for end:Vector3 in [p,q]:K.box(b,end+Vector3.UP*1.61,Vector3(.07,3.22,.07),"376657",false,11)
	wire.generate_normals()
	var mesh:=MeshInstance3D.new();mesh.name="OuterGreenMeshV175";mesh.mesh=wire.commit()
	var material:=ShaderMaterial.new();material.shader=preload("res://world/visual_campus/CourtFence.gdshader")
	material.set_shader_parameter("dimensions",Vector2.ONE);mesh.material_override=material;b.add_child(mesh)
	# Open full-width apron ties the curved track edge to the existing undercroft paving.
	# Ground remains at the existing fitted campus datum; no invented stair to the field.
	K.box(b,Vector3(0,.078,55.44),Vector3(136,.020,15.12),"afb0a4",false,26)
	for x in range(-66,67,3):K.box(b,Vector3(x,.091,55.44),Vector3(.035,.006,15.12),"899388",false,22)
	S.drain(b,Vector3(0,.025,60.5),134)
	# End light towers are outside the enlarged track and pedestrian strip.
	for x in [-66,66]:
		for z in [-54.5,54.5]:
			var ground:float=preload("res://world/visual_campus/TrackOuterSite.gd").fitted_height(b.position.x+x,b.position.z+z,b.position.y)-b.position.y
			K.box(b,Vector3(x,ground+10,z),Vector3(.26,20,.26),"aeb8ac",true,11)
			for dx in [-.8,0,.8]:
				for y in [19.5,20.2]:K.box(b,Vector3(x+dx,ground+y,z),Vector3(.55,.42,.28),"d0d5c2",false,11)
	# V176 old floating benches removed from the newly sloping bank; exact street furniture pending.
	# No invented concrete end bleachers: their placement was unsupported by built views.

static func seven_goal(b:Node3D,centre:float,side:int)->void:
	var z:float=side*30
	for x:float in [-2.5,2.5]:
		K.box(b,Vector3(centre+x,1,z),Vector3(.08,2,.08),"d8ded0",false,11)
		member(b,Vector3(centre+x,2,z),Vector3(centre+x,0,z+side*1.3),.045,"bcc4b3")
	K.box(b,Vector3(centre,2,z),Vector3(5.08,.08,.08),"d8ded0",false,11)
	for x in range(-10,11):K.box(b,Vector3(centre+x*.25,1,z+side*1.3),Vector3(.012,2,.012),"bac4b5",false,11)
	for y in 9:K.box(b,Vector3(centre,y*.25,z+side*1.3),Vector3(5,.012,.012),"bac4b5",false,11)

static func build(b: Node3D) -> void:
	# Red surface and ten white boundaries enclose exactly nine lanes.
	band(b,OUTER,INNER,.070,"89463d",8)
	var points:=oval(INNER);var v:=PackedVector3Array()
	for i in points.size():v.append_array(K.quad(Vector3(0,.052,0),points[i]+Vector3.UP*.052,points[(i+1)%points.size()]+Vector3.UP*.052,Vector3(0,.052,0)))
	# Red D-shaped event areas surround the rectangular pitch; grass is not an oval.
	K.surface(b,v,"89463d",8)
	for i in 14:
		var z0:float=-34+i*68.0/14;var z1:float=-34+(i+1)*68.0/14
		K.surface(b,K.quad(Vector3(-52.5,.077,z0),Vector3(52.5,.077,z0),Vector3(52.5,.077,z1),Vector3(-52.5,.077,z1)),"63864a" if i%2==0 else "5d8045",3)
	for lane in LANES+1:
		var radius: float=INNER+lane*LANE_WIDTH
		band(b,radius+.025,radius-.025,.115,"dadccd",0)
	# Official2023 guide confirms two seven-a-side pitches; anniversary aerial shows
	# them across the rectangular turf, with four portable goals. Exact line dimensions fitted.
	for z in [-34,34]:line(b,Vector3(-52.5,.120,z),Vector3(52.5,.120,z))
	for x in [-52.5,52.5]:line(b,Vector3(x,.120,-34),Vector3(x,.120,34))
	for centre:float in [-26,26]:
		for z in [-30,0,30]:line(b,Vector3(centre-24,.120,z),Vector3(centre+24,.120,z))
		for x in [-24,24]:line(b,Vector3(centre+x,.120,-30),Vector3(centre+x,.120,30))
		for i in 96:
			var a:float=TAU*i/96;var c:float=TAU*(i+1)/96
			line(b,Vector3(centre+cos(a)*6,.120,sin(a)*6),Vector3(centre+cos(c)*6,.120,sin(c)*6))
		for side in [-1,1]:
			for x:float in [-11.5,11.5]:line(b,Vector3(centre+x,.120,side*30),Vector3(centre+x,.120,side*20))
			line(b,Vector3(centre-11.5,.120,side*20),Vector3(centre+11.5,.120,side*20))
			seven_goal(b,centre,side)
	# Finish is at the tangent, not an arbitrary location halfway down the straight.
	line(b,Vector3(HALF_STRAIGHT,.125,-OUTER),Vector3(HALF_STRAIGHT,.125,-INNER),.05)
	for lane in LANES:
		var number:=K.label(b,str(lane+1),Vector3(HALF_STRAIGHT-2,.135,-INNER-(lane+.5)*LANE_WIDTH),.010)
		number.rotation.x=-PI/2;number.rotation.z=-PI/2
	perimeter(b)
	# Machine-readable geometry is exported by the same constructor the scene uses.
	b.set_meta("track_geometry",{"straight":HALF_STRAIGHT*2,"inner_radius":INNER,"lane_width":LANE_WIDTH,"lanes":LANES,"outer_radius":OUTER,"lane1_measurement_radius":INNER+.30,"lane1_analytic_length":HALF_STRAIGHT*4+TAU*(INNER+.30),"arc_segments":ARC_SEGMENTS,"surveyed":false,"infield":"rectangular turf with red D ends","grandstand_side_fence":false,"outer_fence_height_fitted":3.2,"football_pitches":2,"seven_a_side_dimensions_fitted":[48,60]})
