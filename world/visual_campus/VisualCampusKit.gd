extends RefCounted
## Authored geometry in the East Gate frame; collision follows the actual meshes.
const SURFACE := preload("res://world/visual_campus/CampusSurface.gdshader")
const FONT := preload("res://systems/ChineseText.gd").FONT
const V := preload("res://world/visual_campus/CampusVegetation.gd")
static var materials: Dictionary = {}

static func material(hex: String,kind: int=0) -> Material:
	var key:=hex+str(kind)
	if not materials.has(key):
		if kind==48:
			# ICC daylight glazing: visible cool panes while retaining the public lobby view.
			var glass:=StandardMaterial3D.new();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			glass.albedo_color=Color(Color(hex),.52);glass.roughness=.20;glass.metallic=.08;glass.cull_mode=BaseMaterial3D.CULL_DISABLED
			materials[key]=glass
			return glass
		if kind in [79,80]:
			# V242 dedicated study-pod glazing; other campus glass remains unchanged.
			var glass:=StandardMaterial3D.new();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			glass.albedo_color=Color(Color(hex),.76 if kind==79 else .16)
			glass.roughness=.82 if kind==79 else .18;glass.metallic=.02
			glass.cull_mode=BaseMaterial3D.CULL_DISABLED;materials[key]=glass
			return glass
		if kind==19:
			var glass:=StandardMaterial3D.new();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;glass.albedo_color=Color(Color(hex),.28);glass.roughness=.24;glass.metallic=.04;glass.cull_mode=BaseMaterial3D.CULL_DISABLED
			materials[key]=glass
			return glass
		var m:=ShaderMaterial.new();m.shader=SURFACE
		m.set_shader_parameter("base_color",Color(hex));m.set_shader_parameter("surface_kind",kind)
		var tile_size:=Vector2(.9,.45)
		if kind==0:tile_size=Vector2(1.2,.6)
		elif kind==6:tile_size=Vector2(1.2,.8)
		elif kind==7:tile_size=Vector2(.24,.12)
		elif kind==26:tile_size=Vector2(.8,.4)
		elif kind==53:tile_size=Vector2(.60,.60)
		m.set_shader_parameter("tile_size",tile_size)
		m.set_shader_parameter("variation",.06 if kind in [1,6,7] else .035);m.set_shader_parameter("joint_width",.004)
		materials[key]=m
	return materials[key]

static func holder(parent: Node3D,id: String,p: Vector3=Vector3.ZERO) -> Node3D:
	var n:=Node3D.new();n.name=id;n.position=p;parent.add_child(n);return n

static func box(root: Node3D,p: Vector3,size: Vector3,hex: String="b9bcb6",solid: bool=false,kind: int=0,yaw: float=0.0) -> void:
	var groups: Dictionary=root.get_meta("box_groups",{})
	var key:=hex+":"+str(kind)
	if not groups.has(key):groups[key]=[]
	groups[key].append(Transform3D(Basis(Vector3.UP,yaw)*Basis.from_scale(size),p));root.set_meta("box_groups",groups)
	if solid:
		var body: StaticBody3D
		if root.has_node("Solid"):body=root.get_node("Solid")
		else:body=StaticBody3D.new();body.name="Solid";root.add_child(body)
		var c:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=size;c.shape=shape;c.position=p;c.rotation.y=yaw;body.add_child(c)

static func finish(root: Node3D) -> void:
	var groups: Dictionary=root.get_meta("box_groups",{})
	for key: String in groups:
		var transforms: Array=groups[key];var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D
		var mesh:=BoxMesh.new();mesh.size=Vector3.ONE;mm.mesh=mesh;mm.instance_count=transforms.size()
		for i in transforms.size():mm.set_instance_transform(i,transforms[i])
		var node:=MultiMeshInstance3D.new();node.multimesh=mm
		var pieces:=key.split(":");node.material_override=material(pieces[0],int(pieces[1]));root.add_child(node)
	root.remove_meta("box_groups")
	V.finish(root)

static func surface(root: Node3D,vertices: PackedVector3Array,hex: String,kind: int=0,solid: bool=false) -> MeshInstance3D:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v: Vector3 in vertices:st.add_vertex(v)
	st.generate_normals();var node:=MeshInstance3D.new();node.mesh=st.commit();node.material_override=material(hex,kind);root.add_child(node)
	if solid:node.create_trimesh_collision()
	return node

static func quad(a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> PackedVector3Array:
	# All callers are ground/ramp ribbons. Godot uses clockwise front faces.
	# Normalize winding so a route changing direction cannot become a ceiling collider.
	if (b-a).cross(c-a).y>0:return PackedVector3Array([a,c,b,a,d,c])
	return PackedVector3Array([a,b,c,a,c,d])

static func label(root: Node3D,text: String,p: Vector3,pixel: float=.012) -> Label3D:
	var n:=Label3D.new();n.font=FONT;n.text=text;n.position=p;n.font_size=64;n.pixel_size=pixel;n.modulate=Color("e9e3cd");n.outline_size=0;root.add_child(n);return n

static func column(root: Node3D,p: Vector3,height: float,width: float=.65) -> void:
	box(root,p+Vector3.UP*height/2,Vector3(width,height,width),"b9bcb6",true)

static func screen(root: Node3D,p: Vector3,width: float,height: float,pitch: float=.65) -> void:
	for i in int(width/pitch):box(root,p+Vector3(-width/2+(i+.5)*pitch,height/2,0),Vector3(.12,height,.34),"a18458",false,4)

static func window(root: Node3D,p: Vector3,width: float,height: float,yaw: float=0.0) -> void:
	box(root,p,Vector3(width,height,.10),"516d79",false,5,yaw)
	var b:=Basis(Vector3.UP,yaw)
	for side in [-1,1]:
		box(root,p+b*Vector3(side*(width/2+.035),0,.06),Vector3(.07,height+.14,.13),"596563",false,0,yaw)
		box(root,p+b*Vector3(0,side*(height/2+.035),.06),Vector3(width+.14,.07,.13),"596563",false,0,yaw)
	box(root,p+b*Vector3(0,0,.075),Vector3(.055,height,.14),"707b79",false,0,yaw)

static func facade(root: Node3D,p: Vector3,size: Vector3,levels: Array,pitch: float=3.4) -> void:
	for axis in [0,1]:
		var length: float=size.x if axis==0 else size.z
		var count:=maxi(2,int(length/pitch))
		for side in [-1,1]:
			for f in range(levels.size()-1):
				var height: float=float(levels[f+1])-float(levels[f])
				for i in count:
					var offset: float=(i+.5)*length/count-length/2
					var q:=p+Vector3(0,(float(levels[f])+float(levels[f+1]))/2,0)
					q+=Vector3(offset,0,side*(size.z/2+.07)) if axis==0 else Vector3(side*(size.x/2+.07),0,offset)
					window(root,q,pitch*.38,height*.56,0.0 if axis==0 else PI/2)

static func volume(root: Node3D,p: Vector3,size: Vector3,hex: String,levels: Array=[]) -> void:
	box(root,p+Vector3.UP*size.y/2,size,hex,true)
	box(root,p+Vector3.UP*(size.y+.12),Vector3(size.x,.24,size.z),"787e79")
	for side in [-1,1]:
		box(root,p+Vector3(0,size.y+.52,side*(size.z/2-.13)),Vector3(size.x,.7,.26),hex)
		box(root,p+Vector3(side*(size.x/2-.13),size.y+.52,0),Vector3(.26,.7,size.z),hex)
	if not levels.is_empty():facade(root,p,size,levels)

static func gallery(root: Node3D,p: Vector3,width: float,depth: float,height: float=4.4) -> void:
	box(root,p+Vector3.UP*(height+.16),Vector3(width,.32,depth),"d1d2c9",true)
	for x in range(-int(width/2)+2,int(width/2),7):
		for side in [-1,1]:column(root,p+Vector3(x,0,side*(depth/2-.65)),height)
	for x in range(-int(width/2),int(width/2)+1,4):box(root,p+Vector3(x,height-.2,0),Vector3(.22,.44,depth),"aeb6af")

static func bench(root: Node3D,p: Vector3,yaw: float=0.0) -> void:
	var b:=Basis(Vector3.UP,yaw)
	for x in [-1,1]:box(root,p+b*Vector3(x*.85,.35,0),Vector3(.16,.7,.8),"485a50",false,0,yaw)
	for z in [-.28,0.0,.28]:box(root,p+b*Vector3(0,.76,z),Vector3(2.6,.12,.22),"99734e",false,4,yaw)
	box(root,p+b*Vector3(0,1.08,.4),Vector3(2.6,.55,.10),"99734e",false,4,yaw)

static func planter(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3.UP*.42,Vector3(1.2,.84,1.2),"766653")
	box(root,p+Vector3.UP*.85,Vector3(1.10,.05,1.10),"544b37",false,4)
	V.shrub(root,p+Vector3.UP*.85,Vector3(1.1,.55,1.1),absi(int(p.x*13+p.z*7)))

static func tree(root: Node3D,p: Vector3,height: float,seed: int,density: float=1.0) -> void:
	V.tree(root,p,height,seed,density)

static func lamp(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3.UP*2.8,Vector3(.13,5.6,.13),"495751")
	box(root,p+Vector3(.55,5.55,0),Vector3(1.2,.12,.16),"495751")
	box(root,p+Vector3(1.05,5.5,0),Vector3(.48,.09,.3),"dadbc8")
