extends RefCounted
## A low-cost canopy layer for the continuous back-hill forest visible in official/architect aerials.
## No road, building, surveyed contour or walkable area is introduced by this visual layer.
static func crown_mesh() -> ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var slices:=13;var rings:=8
	for row in rings:
		for col in slices:
			var quad: Array[Vector3]=[]
			for ij: Vector2i in [Vector2i(col,row),Vector2i(col+1,row),Vector2i(col+1,row+1),Vector2i(col,row+1)]:
				var angle: float=ij.x*TAU/slices;var theta: float=ij.y*PI/rings
				var ripple: float=1+.14*sin(angle*5+theta*3)+.08*cos(angle*3-theta*7)
				quad.append(Vector3(cos(angle)*sin(theta)*ripple,cos(theta)*.57,sin(angle)*sin(theta)*ripple))
			for index in [0,2,1,0,3,2]:
				var p: Vector3=quad[index];st.set_normal(Vector3(p.x,p.y/0.3249,p.z).normalized())
				st.set_color(Color("546848").lerp(Color("84925c"),clampf((p.y+.65)*.66,0,1)))
				st.add_vertex(p)
	return st.commit()

static func build(root: Node3D,builder: RefCounted) -> void:
	var forest:=Node3D.new();forest.name="BackHillContinuousCanopy";root.add_child(forest)
	var mesh:=crown_mesh();var material:=StandardMaterial3D.new()
	material.vertex_color_use_as_albedo=true;material.roughness=1;material.metallic_specular=.08
	material.albedo_color=Color("86967b")
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	var rng:=RandomNumberGenerator.new();rng.seed=70040618
	var cells: Dictionary={}
	# Interior forest begins behind all retained campus footprints; existing detailed edge trees remain visible.
	for row in range(-1110,45,14):
		for col in range(194,594,14):
			var x: float=col+rng.randf_range(-3,3);var z: float=row+rng.randf_range(-3,3)
			if x<212+sin(z*.031)*15+cos(z*.067)*9:continue
			var radius:=rng.randf_range(7.5,11.5)
			var ground: float=builder.backdrop_height(x,z)
			var height:=rng.randf_range(9,16)
			var key:=Vector2i(floori(x/56),floori(z/56))
			if not cells.has(key):cells[key]=[]
			# Several offset lobes make a branched crown silhouette, rather than repeated identical spheres.
			for lobe in 3:
				var a: float=lobe*TAU/3+rng.randf_range(-.5,.5)
				var offset:=Vector3(cos(a)*radius*.29,rng.randf_range(-1.1,1.1),sin(a)*radius*.29)
				var size:=Vector3(radius*.94,height*.65,radius*.94)
				var transform:=Transform3D(Basis(Vector3.UP,rng.randf()*TAU)*Basis.from_scale(size),Vector3(x,ground+height*.76,z)+offset)
				cells[key].append([transform,Color(1,1,1)*rng.randf_range(.77,1.06)])
	for key: Vector2i in cells:
		var entries: Array=cells[key];var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true
		mm.mesh=mesh;mm.instance_count=entries.size()
		var origin:=Vector3(key.x*56+28,0,key.y*56+28)
		for i in entries.size():
			var transform: Transform3D=entries[i][0];transform.origin-=origin
			mm.set_instance_transform(i,transform);mm.set_instance_color(i,entries[i][1])
		var node:=MultiMeshInstance3D.new();node.name="CanopyCell";node.multimesh=mm;node.position=origin;node.material_override=material
		node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		forest.add_child(node)
