extends RefCounted
## Shared low-poly vocabulary. Facades are batched per volume, never per window.
const COLORS := {"light_stone":"c8c9bc", "warm_white":"e4e1d4", "concrete_gray":"a5aaa4", "glass_bluegray":"547576", "dark_frame":"364947", "roof_gray":"7e8b84", "railing_metal":"687a74", "wood_accent":"ad7853"}
static var materials: Dictionary = {}

static func material(key: String) -> StandardMaterial3D:
	if not materials.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color=Color(COLORS.get(key,key));m.roughness=.84
		if key=="glass_bluegray":m.albedo_color=Color("749094");m.roughness=.24;m.metallic=.32
		materials[key]=m
	return materials[key]

static func box(root: Node3D, pos: Vector3, size: Vector3, key: String, solid: bool=false) -> MeshInstance3D:
	var mesh := BoxMesh.new();mesh.size=size
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=material(key);node.position=pos;root.add_child(node)
	if solid:
		var body := StaticBody3D.new();node.add_child(body)
		var collision := CollisionShape3D.new();var shape := BoxShape3D.new();shape.size=size;collision.shape=shape;body.add_child(collision)
	return node

static func batch(root: Node3D, transforms: Array[Transform3D], size: Vector3, key: String) -> void:
	if transforms.is_empty():return
	var mm := MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D
	var mesh := BoxMesh.new();mesh.size=size;mm.mesh=mesh;mm.instance_count=transforms.size()
	for i in transforms.size():mm.set_instance_transform(i,transforms[i])
	var node := MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=material(key);root.add_child(node)
	if key in ["wood_accent","dark_frame"]:node.visibility_range_end=420;node.visibility_range_end_margin=40

static func facade(root: Node3D, pos: Vector3, size: Vector3, residential: bool=false) -> void:
	var pitch := 3.6 if residential else 5.0
	var rows := maxi(1,int(size.y/3.4));var transforms: Array[Transform3D]=[]
	for side in [-1,1]:
		for axis in [0,1]:
			var length: float=size.x if axis==0 else size.z
			var count := maxi(1,int(length/pitch))
			for row in rows:
				for col in count:
					var point := pos+Vector3(0,-size.y/2+(row+.5)*size.y/rows,0)
					var offset := (col+.5)*length/count-length/2
					if axis==0:point+=Vector3(offset,0,side*(size.z/2+.035))
					else:point+=Vector3(side*(size.x/2+.035),0,offset)
					var basis := Basis(Vector3.UP,PI/2 if axis==1 else 0.0)
					transforms.append(Transform3D(basis,point))
	batch(root,transforms,Vector3(pitch*.59,1.65,.07),"glass_bluegray")

static func volume(root: Node3D, pos: Vector3, size: Vector3, key: String="light_stone", residential: bool=false) -> void:
	box(root,pos,size,key,true);facade(root,pos,size,residential)
	box(root,pos+Vector3(0,size.y/2+.2,0),Vector3(size.x,.4,size.z),"roof_gray")
	# Low parapets give a legible roof silhouette without projecting beyond the envelope.
	for side in [-1,1]:
		box(root,pos+Vector3(0,size.y/2+.7,side*(size.z/2-.18)),Vector3(size.x,1,.35),key)
		box(root,pos+Vector3(side*(size.x/2-.18),size.y/2+.7,0),Vector3(.35,1,size.z),key)
	# Conservative rear/roof continuation; small screen is not a modeled HVAC system.
	box(root,pos+Vector3(0,size.y/2+1,0),Vector3(size.x*.22,1.4,size.z*.24),"roof_gray")

static func arcade(root: Node3D,pos: Vector3,width: float,depth: float,height: float=4.5) -> void:
	box(root,pos+Vector3(0,height+.22,0),Vector3(width,.44,depth),"warm_white",true)
	var count := clampi(int(width/9),2,5)
	for i in range(count+1):
		if absf(-width/2+i*width/count)<1.6:continue # Keep the centre pedestrian opening clear.
		for side in [-1,1]:
			box(root,pos+Vector3(-width/2+i*width/count,height/2,side*(depth/2-.65)),Vector3(.65,height,.65),"concrete_gray",true)
	root.set_meta("walkable_opening",true)

static func screen(root: Node3D,pos: Vector3,width: float,height: float,key: String="wood_accent") -> void:
	var transforms: Array[Transform3D]=[]
	for i in maxi(2,int(width/1.4)):
		transforms.append(Transform3D(Basis.IDENTITY,pos+Vector3(-width/2+i*1.4,height/2,0)))
	batch(root,transforms,Vector3(.22,height,.36),key)

static func entrance(root: Node3D,width: float,depth: float,text: String) -> void:
	# Forecourt is level with the original terrain; canopy and side posts leave the middle open.
	arcade(root,Vector3(0,0,depth/2-2.5),minf(12,width*.35),4,4.2)
	var label := Label3D.new();label.text=text;label.font=preload("res://systems/ChineseText.gd").FONT
	label.font_size=72;label.pixel_size=.009;label.position=Vector3(0,5.3,depth/2+.28)
	label.modulate=Color("304940");label.outline_size=4;label.no_depth_test=false
	label.visibility_range_end=170;root.add_child(label)
	root.set_meta("entrance_local",Vector3(0,0,depth/2-2.5))

static func bake(root: Node3D) -> void:
	# Combine authored boxes by shared material; retain simple physics separately.
	var groups: Dictionary={}
	for child: Node in root.get_children():
		if not child is MeshInstance3D or not child.mesh is BoxMesh or not child.visible:continue
		var key: Material=child.material_override
		if not groups.has(key):
			var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);groups[key]=st
		groups[key].append_from(child.mesh,0,child.transform)
		for body: Node in child.get_children():
			if body is StaticBody3D:
				var shared: StaticBody3D=root.get_node_or_null("ArchitectureCollision")
				if shared==null:shared=StaticBody3D.new();shared.name="ArchitectureCollision";root.add_child(shared)
				for collision: Node in body.get_children():
					var transform: Transform3D=child.transform*body.transform*collision.transform
					body.remove_child(collision);shared.add_child(collision);collision.transform=transform
		root.remove_child(child);child.free()
	for key: Material in groups:
		var node := MeshInstance3D.new();node.mesh=groups[key].commit();node.material_override=key;root.add_child(node)
