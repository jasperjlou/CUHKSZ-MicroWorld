extends RefCounted
## Named G/2F tours guide visible furnishings; the reusable interior plan is inferred.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")

static func light_panel(b: Node3D,p: Vector3,size: Vector3) -> void:
	var m:=StandardMaterial3D.new();m.albedo_color=Color("eee9d5");m.emission_enabled=true;m.emission=Color("eee4c4");m.emission_energy_multiplier=.7
	var n:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=size;n.mesh=mesh;n.material_override=m;n.position=p;b.add_child(n)

static func stair_rail(b: Node3D,start: Vector3,end: Vector3,x: float) -> void:
	for i in 9:
		var p:=start.lerp(end,i/8.0);p.x=x
		K.box(b,p+Vector3.UP*.54,Vector3(.055,1.08,.055),"758378",false,11)
	var a:=start;var c:=end;a.x=x;c.x=x
	var rail:=K.holder(b,"LibraryStairRail",(a+c)/2+Vector3.UP*1.08)
	rail.rotation.x=-atan2(c.y-a.y,c.z-a.z)
	K.box(rail,Vector3.ZERO,Vector3(.08,.08,a.distance_to(c)),"ac8a5c",false,4);K.finish(rail)

static func detail(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	var w: float=r.width;var d: float=r.depth
	# The continuous LibraryEnvelope owns all exterior return walls.
	# Stone/plaster/metal have distinct scales instead of a brick grid on every surface.
	var base:=PackedVector2Array([Vector2(-w*.445,-1-d*.36),Vector2(w*.445,-1-d*.36),Vector2(w*.445,-1+d*.36),Vector2(-w*.445,-1+d*.36)])
	for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(base):
		K.surface(b,preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd").floor_vertices([dry],.056),"b9b4a4",12)
	for x in [-w*.425,w*.425]:K.box(b,Vector3(x,.062,-1),Vector3(.22,.015,d*.72),"5c7067")
	for z in [-d*.36,d*.34]:K.box(b,Vector3(0,.062,z),Vector3(w*.86,.015,.22),"5c7067")
	# V44: the broad seating stair belongs to the 2F hall; LibraryEntryLevels owns it.
	preload("res://world/visual_campus/LibrarySecondRooms.gd").retained_rail(b,Vector3(-15,4.4,-16),8,PI/2)
	preload("res://world/visual_campus/LibrarySecondRooms.gd").retained_rail(b,Vector3(-15,4.4,-5),6,PI/2)
	# Gallery returns join the inter-building link to the already built 2F landing.
	L.guardrail(b,Vector3(-33.8,4.4,.8),14.6,PI/2)
	# V209 opens the old decorative cross-rail at the mapped grey-stair landing.
	# Keep guarded edges on both sides; a walkable stair must not visually cross a fence.
	var grey=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
	var stair_z:float=grey.points()[-1].z
	for span:Vector2 in [Vector2(10.7,stair_z-grey.WIDTH/2-.12),Vector2(stair_z+grey.WIDTH/2+.12,18.5)]:
		grey.guard(b,Vector3(-33.8,4.4,span.x),Vector3(-33.8,4.4,span.y))
	# V73 trim the old decorative gallery rail out of the new remote stair shaft.
	preload("res://world/visual_campus/LibrarySecondRooms.gd").retained_rail(b,Vector3(-24.4,4.4,-12.2),18.8)
	L.guardrail(b,Vector3(15,4.4,-11),18,PI/2)
	L.guardrail(b,Vector3(0,4.4,-20),30)
	preload("res://world/visual_campus/LibrarySecondRooms.gd").retained_rail(b,Vector3(-9.2,4.4,-2),11.2)
	# Visible lower lobby, kept below the existing 2F landing and off the cross passage.
	preload("res://world/visual_campus/LibraryLobbyDetail.gd").build(b)
	preload("res://world/visual_campus/LibraryLowerLevel.gd").build(b)
	for x in [-4.3,4.3]:K.box(b,Vector3(x,6.4,-18.6),Vector3(.16,4,.24),"3a4b45",true)
	K.box(b,Vector3(0,8.3,-18.6),Vector3(9,.22,.26),"3a4b45")
	for x in [-10,-7,7,10]:
		K.box(b,Vector3(x,6.4,-18.6),Vector3(2.8,3.8,.09),"78988c",true,19)
		for dx in [-1.45,1.45]:K.box(b,Vector3(x+dx,6.4,-18.5),Vector3(.08,3.9,.17),"3a4b45",false,11)
	K.box(b,Vector3(0,6.50,-20.4),Vector3(30,4.2,.24),"a6afa5",true,6)
	K.box(b,Vector3(0,6.50,-20.25),Vector3(29.8,4.1,.035),"ac926d",false,4)
	K.box(b,Vector3(0,6.9,-20.22),Vector3(12,2.4,.08),"d3c5a2",false,12)
	K.label(b,"大学图书馆\nUNIVERSITY LIBRARY",Vector3(0,6.9,-20.15),.008)
	for x in [-13,13]:K.planter(b,Vector3(x,4.4,-17.2))
	# V115 the independent1F frontage owns the recessed ground entry frame.
	preload("res://world/visual_campus/LibraryPoolFrontage.gd").pavilion(b)

static func public_base(b: Node3D,r: Dictionary) -> void:
	if r.id=="student_centre":return # V153 traced footprint owns its paving.
	if r.id in ["zhang_lingbin","teaching_c","teaching_b"]:return # V137 owns a split structural platform/core opening.
	if r.id not in ["teaching_b","teaching_c","zhang_lingbin","administration","student_centre","hl_tu","lee_yin_yee"]:return
	var w: float=r.width;var d: float=r.depth
	# Paving, column plinths and drainage close the crude grass-to-arcade seams.
	K.box(b,Vector3(0,.025,0),Vector3(w*.94,.04,d*.94),"afa99a",false,6)
	for side in [-1,1]:
		K.box(b,Vector3(side*w*.45,.052,0),Vector3(.18,.018,d*.90),"687c70")
		K.box(b,Vector3(0,.052,side*d*.45),Vector3(w*.9,.018,.18),"687c70")
	for x in [-w*.30,w*.30]:
		K.box(b,Vector3(x,.065,d*.42),Vector3(3,.022,.28),"64746a",false,11)
		for i in 12:K.box(b,Vector3(x-1.35+i*.24,.080,d*.42),Vector3(.025,.010,.22),"a3b2a1")
