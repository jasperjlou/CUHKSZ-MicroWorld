extends RefCounted
## A low-cost canopy layer for the continuous back-hill forest visible in official/architect aerials.
## No road, building, surveyed contour or walkable area is introduced by this visual layer.
const Research:=preload("res://world/visual_campus/ResearchSite.gd")
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func sports_woodland(x:float,z:float,research_transform:Transform3D)->bool:
	# Anniversary sports aerial: woodland reaches the research/field-side margin.
	# Retain the registered research bench, stairs and service road clearance.
	if z< -1110 or z> -818 or x>245:return false
	var edge:float=130 if z< -978 else 168
	return x>edge and Research.distance_to_bench(x,z,research_transform)>18

static func crown_mesh() -> ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Porous, folded foliage clusters replace the continuous ellipsoid skin.
	# Shared once by the existing spatial MultiMeshes; no texture billboard.
	var rng:=RandomNumberGenerator.new();rng.seed=1837004
	for i in 230:
		var angle:float=rng.randf()*TAU
		var vertical:float=rng.randf_range(-1,1)
		var radial:float=sqrt(1-vertical*vertical)*rng.randf_range(.68,1.04)
		var p:=Vector3(cos(angle)*radial,vertical*.57,sin(angle)*radial)
		var normal:Vector3=(Vector3(p.x,p.y*2.3,p.z)+Vector3.UP*.35).normalized()
		var side:Vector3=normal.cross(Vector3.FORWARD).normalized()
		if side.length_squared()<.1:side=Vector3.RIGHT
		var forward:Vector3=side.cross(normal).normalized()
		var size:float=rng.randf_range(.12,.23)
		var ring:Array[Vector3]=[p+forward*size,p+side*size*.72,p-forward*size,p-side*size*.72]
		var center:Vector3=p+normal*size*.23
		var tint:Color=Color("425b38").lerp(Color("81925d"),rng.randf()*.75+clampf(vertical,0,1)*.15)
		for j in 4:
			var a:Vector3=ring[j];var b:Vector3=ring[(j+1)%4]
			var face_normal:Vector3=(a-center).cross(b-center).normalized()
			for v:Vector3 in [center,a,b]:st.set_normal(face_normal);st.set_color(tint);st.add_vertex(v)
	return st.commit()

static func build(root: Node3D,builder: RefCounted) -> void:
	var forest:=Node3D.new();forest.name="BackHillContinuousCanopy";root.add_child(forest)
	var mesh:=crown_mesh();var material:=StandardMaterial3D.new()
	material.vertex_color_use_as_albedo=true;material.roughness=1;material.metallic_specular=.08
	material.albedo_color=Color("d6dccb")
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	var rng:=RandomNumberGenerator.new();rng.seed=70040618
	var cells: Dictionary={}
	# Interior forest begins behind all retained campus footprints; existing detailed edge trees remain visible.
	var edge_trees:=0;var edge:=K.holder(forest,"SportsWoodlandEdgeV184")
	for row in range(-1110,45,14):
		for col in range(194,594,14):
			var x: float=col+rng.randf_range(-3,3);var z: float=row+rng.randf_range(-3,3)
			if x<212+sin(z*.031)*15+cos(z*.067)*9:continue
			# V195 replaces this close-facing coarse crown strip with branched trees.
			var replaced:bool=x<238 and (preload("res://world/visual_campus/UpperRearWoodland.gd").contains(x,z) or preload("res://world/visual_campus/ShawRoadGarden.gd").contains(x,z))
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
				# Consume the original random stream even for replaced cells, so
				# unrelated forest positions do not move when this patch changes.
				var tint:Color=Color(1,1,1)*rng.randf_range(.77,1.06)
				if not replaced:cells[key].append([transform,tint])
	# Independent seed keeps all pre-existing forest positions unchanged.
	var edge_rng:=RandomNumberGenerator.new();edge_rng.seed=184176
	for z0 in range(-1104,-818,12):
		for x0 in range(134,215,12):
			var x:float=x0+edge_rng.randf_range(-2,2);var z:float=z0+edge_rng.randf_range(-2,2)
			if not sports_woodland(x,z,builder.research_site_transform):continue
			if x>207+sin(z*.031)*15+cos(z*.067)*9:continue
			var ground:float=builder.height(x,z);var height:float=edge_rng.randf_range(10,15)
			K.tree(edge,Vector3(x,ground,z),height,184000+edge_trees,.8);edge_trees+=1
			var key:=Vector2i(floori(x/56),floori(z/56))
			if not cells.has(key):cells[key]=[]
			var radius:float=edge_rng.randf_range(5.8,8.2)
			var transform:=Transform3D(Basis(Vector3.UP,edge_rng.randf()*TAU)*Basis.from_scale(Vector3(radius,height*.67,radius)),Vector3(x,ground+height*.76,z))
			cells[key].append([transform,Color(1,1,1)*edge_rng.randf_range(.86,1.06)])
	K.finish(edge);edge.set_meta("tree_count",edge_trees)
	for node:GeometryInstance3D in edge.find_children("*","GeometryInstance3D",true,false):
		node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
