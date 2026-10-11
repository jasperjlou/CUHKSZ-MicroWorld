extends RefCounted
## 4F/5F map topology and published atrium photographs. All metre dimensions remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
const Stairs := preload("res://world/visual_campus/LibraryStairKit.gd")
const WELL := Rect2(-16,-4,29,16)

static func plane(n: Node3D,p: PackedVector2Array,y: float,down: bool=false) -> void:
	var ids:=Geometry2D.triangulate_polygon(p);var vertices:=PackedVector3Array()
	for i in range(0,ids.size(),3):
		var a:=Vector3(p[ids[i]].x,y,p[ids[i]].y);var b:=Vector3(p[ids[i+1]].x,y,p[ids[i+1]].y);var c:=Vector3(p[ids[i+2]].x,y,p[ids[i+2]].y)
		vertices.append_array(PackedVector3Array([a,c,b] if ((b-a).cross(c-a).y>0)!=down else [a,b,c]))
	if not vertices.is_empty():K.surface(n,vertices,"d1d0c5" if down else "999b94",22 if down else (45 if absf(y-12.8)<.01 else 25),not down)

static func floors(n: Node3D,p: PackedVector2Array) -> void:
	# Four disjoint strips preserve the open atrium; each remaining slab also clears both cores.
	for rect: Rect2 in [Rect2(-150,-150,134,300),Rect2(13,-150,137,300),Rect2(-16,-150,29,146),Rect2(-16,12,29,138)]:
		for part: PackedVector2Array in Geometry2D.intersect_polygons(p,Core.rect_poly(rect)):
			for fragment: PackedVector2Array in Core.cut_openings(part):
				for y in [12.8,16.8]:
					plane(n,fragment,y);plane(n,fragment,y-.28,true)

static func rail(n: Node3D,a: Vector3,b: Vector3) -> void:
	var delta:=b-a;var count:=maxi(2,int(delta.length()/.24))
	for i in count+1:K.box(n,a.lerp(b,float(i)/count)+Vector3.UP*.53,Vector3(.036,1.06,.036),"e5e1d3",false,22)
	var frame:=K.holder(n,"TimberHandrail",(a+b)/2+Vector3.UP*1.08)
	frame.basis=Basis.looking_at(delta.normalized(),Vector3.UP)
	K.box(frame,Vector3.ZERO,Vector3(.10,.08,delta.length()),"b08b52",false,4)
	var body:=StaticBody3D.new();var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(.10,1.08,delta.length());shape.shape=box;shape.position.y=-.52;body.add_child(shape);frame.add_child(body);K.finish(frame)

static func edge_piece(n: Node3D,a: Vector3,b: Vector3) -> void:
	rail(n,a,b)
	var frame:=K.holder(n,"WhiteGalleryFascia",(a+b)/2-Vector3.UP*.23);frame.basis=Basis.looking_at((b-a).normalized(),Vector3.UP)
	K.box(frame,Vector3.ZERO,Vector3(.20,.46,a.distance_to(b)),"d9d8cc",false,22);K.finish(frame)

static func core_guard_points()->Array[Vector3]:
	var a=Core.local_point(1,Vector3(-7.6,0,-7.6));var tip=Core.local_point(1,Vector3(7.6,0,-7.6));var c=Core.local_point(1,Vector3(7.6,0,7.6))
	if minf(a.z,minf(tip.z,c.z))>=12:return []
	return [a.lerp(tip,(12.0-a.z)/(tip.z-a.z)),tip,tip.lerp(c,(12.0-tip.z)/(c.z-tip.z))]

static func edge(n:Node3D,a:Vector3,b:Vector3)->void:
	if a.y>=12.8 and absf(a.z-12)<.01 and absf(b.z-12)<.01:
		var points=core_guard_points();var low=minf(a.x,b.x);var high=maxf(a.x,b.x)
		if points.is_empty():edge_piece(n,a,b);return
		if low<points[0].x:edge_piece(n,Vector3(low,a.y,12),Vector3(minf(high,points[0].x),a.y,12))
		if high>points[2].x:edge_piece(n,Vector3(maxf(low,points[2].x),a.y,12),Vector3(high,a.y,12))
		return
	edge_piece(n,a,b)

static func core_guard(n:Node3D,y:float)->void:
	var points=core_guard_points()
	for i in range(points.size()-1):edge_piece(n,points[i]+Vector3.UP*y,points[i+1]+Vector3.UP*y)

static func flight(n: Node3D,p: Vector3,yaw: float) -> void:
	var b:=K.holder(n,"AtriumPublicFlight",p);b.rotation.y=yaw
	Stairs.flight(b,16,4,3,false)
	for side in [-1,1]:
		rail(b,Vector3(side*1.64,0,0),Vector3(side*1.64,4,16))
		var fascia:=K.holder(b,"WhiteInclinedStringer",Vector3(side*1.62,1.78,8));fascia.rotation.x=-atan2(4,16)
		K.box(fascia,Vector3.ZERO,Vector3(.20,.42,sqrt(272.0)),"dad9cb",false,22);K.finish(fascia)
	K.finish(b)

static func book_wall(n: Node3D,z0: float,z1: float) -> void:
	var b:=K.holder(n,"TallOakBookGrid",Vector3(-17.5,8.8,(z0+z1)/2));b.rotation.y=PI/2
	var width:=z1-z0;var height:=16.2
	K.box(b,Vector3(0,height/2,-.22),Vector3(width,height,.30),"b59a6c",true,4)
	var cols:=maxi(1,int(width/1.1));var rows:=27
	for col in cols+1:K.box(b,Vector3(-width/2+col*width/cols,height/2,.02),Vector3(.055,height,.46),"c7ab79",false,4)
	for row in rows+1:K.box(b,Vector3(0,row*height/rows,.02),Vector3(width,.055,.46),"cfb37d",false,4)
	# Sparse volumes preserve the large exposed timber grid visible in historical structural photos.
	for col in cols:
		for row in rows:
			if (col*3+row)%7!=0:continue
			for j in 4:K.box(b,Vector3(-width/2+(col+.2)*width/cols+j*.12,row*height/rows+.22,.12),Vector3(.085,.36,.17),["737b73","9f8867","64737b","b4a57e"][j],false,4)
	K.finish(b)

static func stacks(n: Node3D,p: Vector3) -> void:
	K.box(n,p+Vector3.UP*.95,Vector3(5.2,1.9,.58),"c1aa7f",false,4)
	for row in 4:
		K.box(n,p+Vector3.UP*(.15+row*.46),Vector3(5.35,.045,.88),"ccb88e",false,4)
		for j in 24:
			for side in [-1,1]:K.box(n,p+Vector3(-2.45+j*.21,.34+row*.46,side*.34),Vector3(.13,.31,.19),["8c8267","647777","aa9e7c","85736b"][j%4],false,4)

static func round_column(n: Node3D,p: Vector3) -> void:
	var column:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=.30;mesh.bottom_radius=.30;mesh.height=16.4;mesh.radial_segments=20;column.mesh=mesh;column.position=p+Vector3.UP*8.2;column.material_override=K.material("c6c8bf",22);n.add_child(column)
	# Retain the already tested support footprint; only the visible surface becomes circular.
	var body:=StaticBody3D.new();var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(.6,16.4,.6);collision.shape=shape;collision.position=column.position;body.add_child(collision);n.add_child(body)

static func build(n: Node3D,p: PackedVector2Array) -> void:
	var b:=K.holder(n,"LibraryUpperAtrium");floors(b,p)
	flight(b,Vector3(-12,8.8,12),PI)
	flight(b,Vector3(9,12.8,-4),0)
	for y in [12.8,16.8]:
		core_guard(b,y)
		edge(b,Vector3(-16,y,-4),Vector3(-16,y,12));edge(b,Vector3(13,y,-4),Vector3(13,y,12))
		if y==12.8:
			for span: Vector2 in [Vector2(-16,-13.8),Vector2(-10.2,7.2),Vector2(10.8,13)]:edge(b,Vector3(span.x,y,-4),Vector3(span.y,y,-4))
			edge(b,Vector3(-16,y,12),Vector3(13,y,12))
		else:
			edge(b,Vector3(-16,y,-4),Vector3(13,y,-4))
			for span: Vector2 in [Vector2(-16,-13.8),Vector2(-10.2,7.2),Vector2(10.8,13)]:edge(b,Vector3(span.x,y,12),Vector3(span.y,y,12))
		for x in [-29.0,28.0]:
			for z in [-17.0,-10.0,-3.0]:
				if y!=12.8 and (x<0 or z>-17):
					K.box(b,Vector3(x,y+.76,z),Vector3(4.5,.10,1.25),"bba884",false,4)
					for dx in [-1.7,1.7]:K.box(b,Vector3(x+dx,y+.36,z),Vector3(.10,.72,.9),"809084",false,11)
					for dx in [-1.4,0,1.4]:K.box(b,Vector3(x+dx,y+.44,z+1),Vector3(.56,.08,.52),"91a28c",false,22)
			K.box(b,Vector3(x,y+3.55,-9),Vector3(.12,.045,19),"e5dfca",false,17)
			var light:=OmniLight3D.new();light.position=Vector3(x,y+2.8,-8);light.light_energy=.6;light.omni_range=19;light.light_color=Color("ecebdc");b.add_child(light)
		K.label(b,("4F · 图书阅览" if y==12.8 else "5F · 图书阅览"),Vector3(16,y+2.4,10),.006)
	# Door-size interruption lets the left wing reach the gallery through the tall book wall.
	book_wall(b,-4,2);book_wall(b,7,12)
	for x in [-18.5,15.0]:
		for z in [-6.0,14.0]:round_column(b,Vector3(x,8.8,z))
	# Suspended baffles under the opened skylight: airy slats rather than an opaque second roof.
	for x in [-13.0,-3.0,7.0,17.0]:
		var z: float=-3+absf(x+5)*.22
		var panel:=K.surface(b,K.quad(Vector3(x,25.9,z-2.6),Vector3(x,25.9,z+2.6),Vector3(x,27.3,z+2.6),Vector3(x,27.3,z-2.6)),"dce3d9",19)
		panel.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in 30:K.box(b,Vector3(x,26.6,z-2.6+i*5.2/29),Vector3(.045,1.4,.025),"d8ddcf",false,22)
		for y in [25.9,26.6,27.3]:K.box(b,Vector3(x,y,z),Vector3(.05,.035,5.2),"d8ddcf",false,22)
		for side in [-1,1]:K.box(b,Vector3(x,27.75,z+side*2.6),Vector3(.025,.9,.025),"c8d2ca",false,11)
	var skylight:=OmniLight3D.new();skylight.position=Vector3(0,24.2,3);skylight.light_energy=1.15;skylight.omni_range=30;skylight.light_color=Color("e6eef0");b.add_child(skylight)
	K.finish(b)
