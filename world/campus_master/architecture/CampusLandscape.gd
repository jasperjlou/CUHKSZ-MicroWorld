extends RefCounted
const G := preload("res://world/campus_master/CampusGeometry.gd")
const K := preload("res://world/campus_master/architecture/modules/ArchitectureKit.gd")

static func clear_point(x: float,z: float) -> bool:
	if Geometry2D.is_point_in_polygon(Vector2(x,z),G.shore()):return false
	for o: Dictionary in G.master.objects:
		if o.category in ["building","track","court"] and absf(x-o.center[0])<o.footprint_width/2+5 and absf(z-o.center[2])<o.footprint_depth/2+5:return false
	for route: Dictionary in G.paths.paths:
		var points: Array=route.geometry
		for i in range(points.size()-1):
			var a:=Vector2(points[i][0],points[i][2]);var b:=Vector2(points[i+1][0],points[i+1][2])
			if Vector2(x,z).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(x,z),a,b))<float(route.width)/2+3:return false
	return true

static func build(world: Node3D,objects: Dictionary) -> void:
	var root := Node3D.new();root.name="ArchitectureLandscape";world.add_child(root)
	root.set_meta("confidence","inferred");root.set_meta("replaceable",true)
	root.set_meta("inference_basis","Regional planting vocabulary and existing guide layout; tree positions are illustrative.")
	var trees: Array[Transform3D]=[];var trunks: Array[Transform3D]=[]
	# Deliberate regional rows and lake-edge groups, not random campus scatter.
	for zone: Array in [[310,-200,700,70,42],[350,610,1020,970,65],[-175,-120,150,245,36]]:
		for x in range(zone[0],zone[2],zone[4]):
			for z in range(zone[1],zone[3],zone[4]):
				if not clear_point(x,z):continue
				var height := 6.0 if z>500 else 8.0
				var pos := Vector3(x,G.height_at(x,z),z)
				trunks.append(Transform3D(Basis.IDENTITY,pos+Vector3.UP*height*.3))
				trees.append(Transform3D(Basis.IDENTITY.scaled(Vector3(3,height*.55,3)),pos+Vector3.UP*height*.75))
	K.batch(root,trunks,Vector3(.5,4,.5),"wood_accent")
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D
	var mesh:=SphereMesh.new();mesh.radius=1;mesh.height=2;mesh.radial_segments=8;mesh.rings=4
	mm.mesh=mesh;mm.instance_count=trees.size()
	for i in trees.size():mm.set_instance_transform(i,trees[i])
	var canopy:=MultiMeshInstance3D.new();canopy.multimesh=mm;canopy.material_override=K.material("718969");root.add_child(canopy)
	for o: Dictionary in G.master.objects:
		if o.category in ["stone","sign","gate"]:
			var landmark: Node3D=objects[o.id]
			var label:=Label3D.new();label.text=o.name_zh;label.font=preload("res://systems/ChineseText.gd").FONT
			label.font_size=64;label.pixel_size=.022;label.position=Vector3(0,3,1.6);label.modulate=Color("33594a");label.visibility_range_end=100;landmark.add_child(label)
		if o.category=="pavilion":
			var pavilion: Node3D=objects[o.id]
			for i in range(1,5):
				var angle: float=i*TAU/6
				var rail:=K.box(pavilion,Vector3(cos(angle)*3,1,sin(angle)*3),Vector3(2.8,.18,.18),"warm_white")
				rail.rotation.y=PI/2-angle
			K.bake(pavilion)
		if o.category!="building":continue
		var building: Node3D=objects[o.id]
		if building.has_meta("courtyard_local"):
			var w: float=o.footprint_width*.3;var d: float=o.footprint_depth*.3
			var vertices:=G.quad(Vector3(-w/2,.06,-d/2),Vector3(w/2,.06,-d/2),Vector3(w/2,.06,d/2),Vector3(-w/2,.06,d/2))
			G.surface(building,vertices,Color("bdbcb0"))
			K.box(building,Vector3(-w*.25,.35,0),Vector3(3,.7,3),"concrete_gray")
			K.box(building,Vector3(-w*.25,1,0),Vector3(2.5,.8,2.5),"718969")
			K.box(building,Vector3(w*.25,.65,0),Vector3(3,.25,1),"wood_accent")
			K.bake(building)
	# Existing pedestrian route, furniture placed outside the travel strip.
	for index in range(G.paths.physical_traversal_points.size()):
		var p:=G.vec(G.paths.physical_traversal_points[index]);p.x+=7;p.y=G.height_at(p.x,p.z)
		K.box(root,p+Vector3.UP*3.2,Vector3(.2,6.4,.2),"railing_metal")
		K.box(root,p+Vector3(0,6.5,0),Vector3(1,.2,.8),"warm_white")
		if index%3==0:
			K.box(root,p+Vector3(2,.7,0),Vector3(3,.25,1),"wood_accent")
	K.bake(root)
