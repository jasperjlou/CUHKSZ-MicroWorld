extends RefCounted
const G:=preload("res://world/campus_exterior/ExteriorGeometry.gd")
const E:=preload("res://world/campus_exterior/ExteriorEnvironmentKit.gd")
const K:=preload("res://world/campus_exterior/ExteriorArchitectureKit.gd")

static func build(world: Node3D) -> void:
	var root:=Node3D.new();root.name="ExteriorContext";world.add_child(root)
	root.set_meta("confidence","inferred");root.set_meta("replaceable",true)
	root.set_meta("basis","Campus guide/field-photo mountainous context; visual ridge only, no measured bearing/elevation.")
	# Three layered low-poly ridge ribbons close the void beyond the campus.
	for layer in 3:
		var verts:=PackedVector3Array();var points: Array[Vector3]=[]
		for i in 25:
			var angle: float=(i/24.0)*PI*1.25+PI*.30
			var radius: float=1000+layer*230
			var height: float=90+layer*45+sin(i*1.71+layer)*28+cos(i*.61)*25
			points.append(Vector3(450+cos(angle)*radius,height,300+sin(angle)*radius))
		for i in range(points.size()-1):
			var a: Vector3=points[i];var b: Vector3=points[i+1]
			verts.append_array(G.quad(Vector3(a.x,-30,a.z),Vector3(b.x,-30,b.z),b,a))
		var mesh:=G.surface(root,verts,Color(["617963","758c77","91a595"][layer]));mesh.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED
	# Ground continuation is scenery only; playable collision remains within authored terrain.
	var apron:=G.surface(root,G.quad(Vector3(-1600,-15,-1300),Vector3(2300,-15,-1300),Vector3(2300,-15,1900),Vector3(-1600,-15,1900)),Color("8e9e78"))
	apron.set_meta("visual_context_only",true)
	for id: String in ["lake_stone","lake_pavilion","reservoir_sign"]:
		var o: Dictionary=world.objects[id].get_meta("spatial_record");var p:=G.vec(o.center)
		# Low white/grey lake edge with open approaches, inspired by field photos.
		for side in [-1,1]:
			var q:=E.ground(p.x+side*8,p.z+4)
			E.box(root,q+Vector3.UP*.35,Vector3(3,.7,.35),"Campus_Concrete")
	# Terrace edging on the outer side of platform grades; no blocked door/route axes.
	for o: Dictionary in G.master.objects:
		if o.category!="building" or o.region=="lower":continue
		var w: float=o.footprint_width;var d: float=o.footprint_depth;var p:=G.vec(o.center)
		var edge:=E.ground(p.x-w/2-3,p.z-d*.23)
		var height: float=clampf(p.y-edge.y,.4,3.5)
		if height>.65:
			E.box(root,edge+Vector3.UP*height/2,Vector3(.5,height,d*.42),"Campus_Concrete")
	# Confirmed guide gates only; no new gate locations.
	for o: Dictionary in G.master.objects:
		if o.category!="gate":continue
		var p:=G.vec(o.center)
		for side in [-1,1]:
			E.box(root,p+Vector3(side*10,1,0),Vector3(4,2,1),"Campus_Concrete")
			E.planter(root,E.ground(p.x+side*15,p.z+3),true)
		E.label(root,p+Vector3(0,4.8,1.3),o.name_zh,Color("eee6cf"),.013)
	# Photo-inspired gravel and low planting around the inscription, kept off paths.
	var stone: Vector3=world.objects.lake_stone.position
	E.patch(root,stone,7,6,"Campus_LakePath",.12)
	var foliage:=SphereMesh.new();foliage.radius=1;foliage.height=2;foliage.radial_segments=7;foliage.rings=3
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=foliage;mm.instance_count=9
	for i in 9:
		var angle: float=i*PI/8+PI
		var p:=E.ground(stone.x+cos(angle)*3.3,stone.z+sin(angle)*2.8)
		mm.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3(1.1,.65,.8)),p+Vector3.UP*.7))
	var shrubs:=MultiMeshInstance3D.new();shrubs.multimesh=mm;shrubs.material_override=K.material("648268");root.add_child(shrubs)
	E.bake(root)
	# A cheap opaque animated response; no real reflections or water physics.
	var water: MeshInstance3D=world.get_node("Regions/FairyLake/ApproximateLakePolygon")
	var shader:=Shader.new();shader.code="shader_type spatial; render_mode cull_disabled; varying vec2 water_pos; void vertex(){water_pos=VERTEX.xz;} void fragment(){float rip=(sin(water_pos.x*.7+TIME*.3)+sin(water_pos.y*.8-TIME*.4))*.007; ALBEDO=vec3(.27,.48,.50)+rip; ROUGHNESS=.30; METALLIC=.25;}"
	var material:=ShaderMaterial.new();material.shader=shader;water.material_override=material
	# Palette polish is shared, restrained and opaque: no alpha overdraw.
	var glass:=K.material("glass_bluegray");glass.roughness=.24;glass.metallic=.32
