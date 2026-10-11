extends RefCounted
## Geometry foliage shared by the campus; no solid ellipsoids or photographic billboards.
const SHADER := preload("res://world/visual_campus/CampusFoliage.gdshader")
static var spray: ArrayMesh
static var branch_mesh: CylinderMesh
static var leaf_material: ShaderMaterial
static var bark: StandardMaterial3D

static func setup() -> void:
	if spray!=null:return
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng:=RandomNumberGenerator.new();rng.seed=661942
	for i in 40:
		var p:=Vector3(rng.randf_range(-.75,.75),rng.randf_range(-.48,.48),rng.randf_range(-.75,.75))
		var orientation:=Basis.from_euler(Vector3(rng.randf_range(-.65,.65),rng.randf_range(0,TAU),rng.randf_range(-.55,.55)))
		var length:=rng.randf_range(.21,.34);var width:=length*rng.randf_range(.38,.56)
		var points: Array[Vector3]=[Vector3(0,0,-length/2),Vector3(-width/2,0,0),Vector3(0,0,length/2),Vector3(width/2,0,0)]
		var uv: Array[Vector2]=[Vector2(.5,0),Vector2(0,.5),Vector2(.5,1),Vector2(1,.5)]
		var tint:=Color("537146").lerp(Color("87924c"),rng.randf()*.65)
		for j in 4:
			st.set_color(tint);st.set_uv(Vector2(.5,.5));st.add_vertex(p+orientation*Vector3(0,length*.06,0))
			st.set_uv(uv[j]);st.add_vertex(p+orientation*points[j])
			st.set_uv(uv[(j+1)%4]);st.add_vertex(p+orientation*points[(j+1)%4])
	st.generate_normals();spray=st.commit()
	branch_mesh=CylinderMesh.new();branch_mesh.top_radius=.68;branch_mesh.bottom_radius=1;branch_mesh.height=1;branch_mesh.radial_segments=7
	leaf_material=ShaderMaterial.new();leaf_material.shader=SHADER
	bark=StandardMaterial3D.new();bark.albedo_color=Color("736d5b");bark.roughness=.96

static func queue_instance(root: Node3D,kind: String,transform: Transform3D,tint: Color=Color.WHITE) -> void:
	var groups: Dictionary=root.get_meta("vegetation_groups",{})
	# Spatial batches retain frustum culling; a visible corner must not draw an entire grove.
	var cell:=Vector2i(floori(transform.origin.x/48),floori(transform.origin.z/48))
	var key:=kind+":"+str(cell.x)+":"+str(cell.y)
	if not groups.has(key):groups[key]=[]
	groups[key].append([transform,tint]);root.set_meta("vegetation_groups",groups)

static func branch(root: Node3D,a: Vector3,c: Vector3,radius: float) -> void:
	var delta:=c-a
	queue_instance(root,"wood",Transform3D(Basis(Quaternion(Vector3.UP,delta.normalized()))*Basis.from_scale(Vector3(radius,delta.length(),radius)),(a+c)/2))

static func tree(root: Node3D,p: Vector3,height: float,seed: int,density: float=1.0) -> void:
	setup();var rng:=RandomNumberGenerator.new();rng.seed=absi(seed)+87
	var spreading: bool=absi(seed)%3!=0
	var spread: float=height*(.30 if spreading else .20)
	var trunk_top:=p+Vector3(rng.randf_range(-.03,.03)*height,height*.60,rng.randf_range(-.03,.03)*height)
	branch(root,p,trunk_top,height*.015)
	for i in 10:
		var angle:=i*2.39996+rng.randf_range(-.24,.24)
		var tier: float=.55+i*.031
		var distance: float=spread*(1.0 if i<7 else .62)*rng.randf_range(.8,1.1)
		var end:=p+Vector3(cos(angle)*distance,height*tier,sin(angle)*distance)
		var start:=p.lerp(trunk_top,.65+i*.025)
		branch(root,start,end,height*.0055)
		for j in int(5*density):
			var a: float=angle+j*1.7
			var q:=end+Vector3(cos(a)*height*.085,rng.randf_range(-.035,.055)*height,sin(a)*height*.085)
			var scale:=Vector3(rng.randf_range(.085,.125),rng.randf_range(.08,.12),rng.randf_range(.085,.125))*height
			queue_instance(root,"leaf",Transform3D(Basis(Vector3.UP,a)*Basis.from_scale(scale),q),Color(1,1,1)*rng.randf_range(.78,1.08))
	# Higher sprays break the outline without forming a second spherical crown.
	for i in 9:
		var a:=i*2.4;var q:=trunk_top+Vector3(cos(a)*height*.10,height*(.12+i*.015),sin(a)*height*.10)
		queue_instance(root,"leaf",Transform3D(Basis(Vector3.UP,a)*Basis.from_scale(Vector3.ONE*height*.10),q))

static func shrub(root: Node3D,p: Vector3,size: Vector3,seed: int) -> void:
	setup();var rng:=RandomNumberGenerator.new();rng.seed=seed+631
	var nx:=maxi(1,ceili(size.x/.52));var nz:=maxi(1,ceili(size.z/.52))
	for x in nx:
		for z in nz:
			var q:=p+Vector3(-size.x/2+(x+.5)*size.x/nx,size.y*.58+rng.randf_range(-.06,.06),-size.z/2+(z+.5)*size.z/nz)
			var basis:=Basis(Vector3.UP,rng.randf()*TAU)*Basis.from_scale(Vector3(.62,maxf(.34,size.y*.9),.62))
			queue_instance(root,"leaf",Transform3D(basis,q),Color(1.08,1.04,.83)*rng.randf_range(.83,1.08))

static func finish(root: Node3D) -> void:
	if not root.has_meta("vegetation_groups"):return
	var groups: Dictionary=root.get_meta("vegetation_groups")
	for key: String in groups:
		var parts:=key.split(":");var kind: String=parts[0]
		var origin:=Vector3(int(parts[1])*48+24,0,int(parts[2])*48+24)
		var entries: Array=groups[key];var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true
		mm.mesh=spray if kind=="leaf" else branch_mesh;mm.instance_count=entries.size()
		for i in entries.size():
			var transform: Transform3D=entries[i][0];transform.origin-=origin
			mm.set_instance_transform(i,transform);mm.set_instance_color(i,entries[i][1])
		var node:=MultiMeshInstance3D.new();node.name="LeafSprays" if kind=="leaf" else "BranchedTrunks";node.position=origin;node.multimesh=mm;node.material_override=leaf_material if kind=="leaf" else bark;root.add_child(node)
	root.remove_meta("vegetation_groups")
