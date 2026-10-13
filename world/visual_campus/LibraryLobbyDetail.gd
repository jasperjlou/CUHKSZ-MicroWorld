extends RefCounted
## G collaboration room and 2F stair hall details from official panoramas.
## Room dimensions and furniture positions fit the retained layout, not a measured interior plan.
const Ceiling=preload("res://world/visual_campus/LibraryLowerCeiling.gd")
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func pane(b: Node3D,p: Vector3,width: float,yaw: float=0) -> void:
	var n:=K.holder(b,"LibraryGroundGlazing",p);n.rotation.y=yaw
	K.box(n,Vector3(0,2,0),Vector3(width-.07,3.95,.085),"91a69a",true,19)
	for x in [-width/2,width/2]:K.box(n,Vector3(x,2,.035),Vector3(.065,4,.15),"9ba798",false,11)
	for y in [.13,3.05,4.02]:K.box(n,Vector3(0,y,.04),Vector3(width,.09,.15),"9ba798",false,11)
	K.finish(n)

static func cylinder(b: Node3D,p: Vector3,radius: float,height: float,hex: String,solid: bool=false) -> void:
	var node:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=24
	node.mesh=mesh;node.position=p;node.material_override=K.material(hex,22);b.add_child(node)
	if solid:
		var body:=StaticBody3D.new();var shape:=CollisionShape3D.new();var cylinder_shape:=CylinderShape3D.new()
		cylinder_shape.radius=radius;cylinder_shape.height=height;shape.shape=cylinder_shape;body.position=p;body.add_child(shape);b.add_child(body)

static func collaborative_table(b: Node3D,p: Vector3) -> void:
	cylinder(b,p+Vector3.UP*.76,1.25,.08,"bba77a")
	for side in [-1,1]:
		K.box(b,p+Vector3(side*.76,.36,0),Vector3(.08,.72,.08),"bfc3b2",false,11)
		K.box(b,p+Vector3(side*.76,.11,0),Vector3(.09,.06,1.10),"bfc3b2",false,11)
		for zz in [-.5,.5]:cylinder(b,p+Vector3(side*.76,.065,zz),.07,.11,"515b51")
	for i in 4:
		var angle: float=i*PI/2;var q:=p+Vector3(cos(angle)*1.75,0,sin(angle)*1.75)
		var seat:=K.holder(b,"CollaborativeChair",q);seat.rotation.y=-angle+PI/2
		var color: String="718c9b" if i%2==0 else "b48b5c"
		K.box(seat,Vector3(0,.47,0),Vector3(.48,.09,.46),color,false,22)
		K.box(seat,Vector3(0,.78,.20),Vector3(.48,.56,.065),color,false,22)
		for xx in [-.18,.18]:
			for zz in [-.17,.17]:K.box(seat,Vector3(xx,.23,zz),Vector3(.045,.46,.045),"aeb6a5",false,11)
		K.finish(seat)

static func ground(b: Node3D) -> void:
	var ground_plan:=preload("res://world/visual_campus/LibraryLowerRearPlan.gd")
	var stair:=preload("res://world/visual_campus/LibraryGroundStair.gd")
	var outline:=PackedVector2Array([Vector2(-15,-19.65),Vector2(15,-19.65),Vector2(15,-2.35),Vector2(-15,-2.35)])
	for registered:PackedVector2Array in Geometry2D.intersect_polygons(outline,ground_plan.public_polygon()):
		preload("res://world/visual_campus/LibraryUpperLevels.gd").sheet(b,registered,.081,"c4c5c1",46)
		for part:PackedVector2Array in stair.cut_opening(registered):
			Ceiling.panel(b,part,4.10)
	for x in range(-15,16,2):
		for z in range(-19,-2):
			if ground_plan.contains(x,z+.5) and not stair.in_opening(x,z+.5,.75):Ceiling.bar(b,Vector3(x,3.975,z+.5),Vector2(.04,1.01))
	for z in [-19,-16,-13,-10,-7,-4]:
		for x in range(-15,15):
			if ground_plan.contains(x+.5,z) and not stair.in_opening(x+.5,z,.75):Ceiling.bar(b,Vector3(x+.5,3.975,z),Vector2(1.01,.04))
		for x in [-10,-4,4,10]:
			if ground_plan.contains(x,z+1) and not stair.in_opening(x,z+1,1):preload("res://world/visual_campus/LibraryLowerCeiling.gd").light(b,Vector3(x,3.99,z+1))
	# V72: the public 1F plan has open circulation around individual glazed rooms.
	# Retire the earlier generic glass box and central counter; rooms own their partitions.
	K.label(b,"G · 共享学习空间",Vector3(-7,2.9,-16.42),.006)
	# These former generic tables occupied the map's actual group-room clusters.
	# The plan-based lower-level module now owns their furniture and partitions.
	for x in [-8,8]:
		var light:=OmniLight3D.new();light.position=Vector3(x,3.2,-11);light.light_color=Color("fff1cf");light.light_energy=.72;light.omni_range=12;b.add_child(light)

static func upper_ceiling(b: Node3D) -> void:
	# Densely spaced blades follow the entry panorama; the 3F stair void stays open.
	for i in 116:
		var x: float=-14.5+(i+.5)*.25
		var spans: Array[Vector2]=[Vector2(-19,10)]
		if x>5.0 and x<11.0:spans=[Vector2(-19,-17.3),Vector2(-2.7,10)]
		for span: Vector2 in spans:K.box(b,Vector3(x,8.28,(span.x+span.y)/2),Vector3(.065,.24,span.y-span.x),"babaa6",false,22)
	for x in [-10,-3,3,13]:
		for z in [-13,-5,5]:K.box(b,Vector3(x,8.16,z),Vector3(.12,.045,2.7),"e3e0ca",false,17)
	# Low white stair cheek follows the normal flight; the timber rail remains above it.
	var a:=Vector3(-3.34,0,10);var c:=Vector3(-3.34,4.4,-2)
	var vertices:=PackedVector3Array()
	var quad:=PackedVector3Array([a,c,c+Vector3.UP,a,c+Vector3.UP,a+Vector3.UP])
	vertices.append_array(quad)
	for i in range(0,quad.size(),3):vertices.append_array(PackedVector3Array([quad[i],quad[i+2],quad[i+1]]))
	K.surface(b,vertices,"c0bfae",22)

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"LibraryLobbyObservedDetail")
	ground(b);K.finish(b)
