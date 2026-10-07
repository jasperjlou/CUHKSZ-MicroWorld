extends RefCounted
## Ground-level modules share materials and bake by zone; no decorative trimesh.
const K := preload("res://world/campus_master/architecture/modules/ArchitectureKit.gd")
const G := preload("res://world/campus_master/CampusGeometry.gd")
const FONT := preload("res://systems/ChineseText.gd").FONT
const PALETTE := {"Campus_Asphalt":"626c69","Campus_Concrete":"aeb7ad","Campus_LightStone":"d8d5c8","Campus_DarkStone":"89958b","Campus_WarmPaving":"b68b77","Campus_CourtPaving":"c4c4b3","Campus_LakePath":"c6bca2","Campus_SportsSurface":"ad7563","Campus_Metal":"516862","Campus_Wood":"977052","Campus_SignDark":"294d45","Campus_SignLight":"eee6cf","Campus_Greenery":"648268"}
const MODULES := ["SIDEWALK_STANDARD","SIDEWALK_WIDE","STONE_PAVING","PLAZA_PAVING","ROAD_ASPHALT","CURB","LOW_RETAINING_EDGE","STAIR_SMALL","STAIR_WIDE","RAMP","RAILING_SIMPLE","COVERED_WALKWAY","COLONNADE_LIGHT","BENCH_STANDARD","BENCH_BACKLESS","TRASH_BIN","LAMP_POST","BOLLARD","PLANTER_LOW","PLANTER_LONG","TREE_PIT","BIKE_RACK","NOTICE_BOARD","WAYFINDING_POST","BUILDING_SIGN","SHUTTLE_STOP_SIGN","SHUTTLE_WAITING_PAD","ROAD_SIGN","CROSSWALK","ROAD_MARKING","TREE_SMALL","TREE_MEDIUM","TREE_LARGE","SHRUB_CLUSTER"]

static func box(root: Node3D,pos: Vector3,size: Vector3,key: String,solid: bool=false) -> MeshInstance3D:
	return K.box(root,pos,size,PALETTE.get(key,key),solid)

static func ground(x: float,z: float) -> Vector3:
	return Vector3(x,G.height_at(x,z),z)

static func label(root: Node3D,pos: Vector3,text: String,color: Color=Color("eee6cf"),scale: float=.009) -> Label3D:
	var node:=Label3D.new();node.font=FONT;node.text=text;node.font_size=64;node.pixel_size=scale
	node.position=pos;node.modulate=color;node.outline_size=2;node.no_depth_test=false
	node.visibility_range_end=85;node.visibility_range_end_margin=15;root.add_child(node);return node

static func patch(root: Node3D,center: Vector3,w: float,d: float,key: String,lift: float=.28) -> void:
	var pts: Array[Vector3]=[center+Vector3(0,0,-d/2),center+Vector3(0,0,d/2)]
	ribbon(root,pts,w,key,lift)

static func ribbon(root: Node3D,points: Array[Vector3],w: float,key: String,lift: float=.28) -> void:
	var mesh:=G.strip(root,points,w,Color(PALETTE[key]),false,lift)
	# Match the underlying ten-unit terrain triangles exactly. Merely sampling
	# ribbon vertices can cut through a sloped pad between samples.
	var original: PackedVector3Array=mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var vertices:=PackedVector3Array()
	for i in range(0,original.size(),3):
		var a: Vector3=original[i];var b: Vector3=original[i+1];var c: Vector3=original[i+2]
		var poly:=PackedVector2Array([Vector2(a.x,a.z),Vector2(b.x,b.z),Vector2(c.x,c.z)])
		var minx:=floori((minf(a.x,minf(b.x,c.x))+220)/10)*10-220
		var maxx:=floori((maxf(a.x,maxf(b.x,c.x))+220)/10)*10-220
		var minz:=floori((minf(a.z,minf(b.z,c.z))+290)/10)*10-290
		var maxz:=floori((maxf(a.z,maxf(b.z,c.z))+290)/10)*10-290
		for x in range(minx,maxx+1,10):
			for z in range(minz,maxz+1,10):
				var triangles: Array=[PackedVector2Array([Vector2(x,z),Vector2(x+10,z),Vector2(x+10,z+10)]),PackedVector2Array([Vector2(x,z),Vector2(x+10,z+10),Vector2(x,z+10)])]
				for triangle: PackedVector2Array in triangles:
					for clipped: PackedVector2Array in Geometry2D.intersect_polygons(poly,triangle):
						var indices:=Geometry2D.triangulate_polygon(clipped)
						for index in indices:
							var p: Vector2=clipped[index];vertices.append(Vector3(p.x,G.height_at(p.x,p.y)+lift,p.y))
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for p: Vector3 in vertices:st.add_vertex(p)
	st.generate_normals();mesh.mesh=st.commit()
	mesh.material_override=K.material(PALETTE[key])

static func bench(root: Node3D,p: Vector3,back: bool=true) -> void:
	box(root,p+Vector3(0,.55,0),Vector3(2.6,.16,.7),"Campus_Wood",true)
	for x in [-.95,.95]:box(root,p+Vector3(x,.25,0),Vector3(.13,.5,.6),"Campus_Metal")
	if back:box(root,p+Vector3(0,1.0,-.3),Vector3(2.6,.55,.1),"Campus_Wood")

static func lamp(root: Node3D,p: Vector3,short: bool=false) -> void:
	var h:=3.6 if short else 5.5
	box(root,p+Vector3.UP*h/2,Vector3(.14,h,.14),"Campus_Metal")
	box(root,p+Vector3(.3,h,0),Vector3(.85,.15,.35),"Campus_SignLight")
	box(root,p+Vector3(.3,h-.09,0),Vector3(.65,.04,.25),"Campus_Wood")

static func planter(root: Node3D,p: Vector3,long: bool=false) -> void:
	var w:=4.0 if long else 2.4
	box(root,p+Vector3.UP*.3,Vector3(w,.6,2),"Campus_Concrete",true)
	box(root,p+Vector3.UP*.67,Vector3(w-.3,.24,1.7),"Campus_Greenery")

static func bin(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3.UP*.55,Vector3(.55,1.1,.55),"Campus_Metal")
	box(root,p+Vector3(0,.91,.28),Vector3(.33,.16,.02),"Campus_SignDark")

static func wayfinding(root: Node3D,p: Vector3,text: String) -> void:
	box(root,p+Vector3.UP*1.5,Vector3(.12,3,.12),"Campus_Metal")
	box(root,p+Vector3(0,2.5,0),Vector3(3.8,1.5,.13),"Campus_SignDark")
	label(root,p+Vector3(0,2.5,.085),text,Color("eee6cf"),.007)

static func notice(root: Node3D,p: Vector3) -> void:
	for x in [-1.7,1.7]:box(root,p+Vector3(x,1,0),Vector3(.12,2,.12),"Campus_Metal")
	box(root,p+Vector3(0,1.95,0),Vector3(3.8,2,.18),"Campus_Wood")
	var posters: Array=["招募被试\n决策与认知实验","从问题到研究\n计算 × 哲学","高桌晚宴\n书院活动","失物招领\n请到服务台"]
	for i in 4:
		var x: float=-1.35+i*.9
		box(root,p+Vector3(x,1.95,.12),Vector3(.77,1.55,.03),"Campus_SignLight" if i%2==0 else "Campus_WarmPaving")
		box(root,p+Vector3(x,2.48,.145),Vector3(.62,.08,.02),"Campus_SignDark")
		label(root,p+Vector3(x,1.95,.15),posters[i],Color("294d45"),.0045)

static func corridor(root: Node3D,a: Vector3,b: Vector3) -> void:
	var length:=a.distance_to(b)
	if length<3:return
	var holder:=Node3D.new();holder.position=(a+b)/2;holder.rotation.y=atan2(b.x-a.x,b.z-a.z);root.add_child(holder)
	# A light roof is visual only: spring camera rays must not snag on eaves.
	box(holder,Vector3(0,4.9,0),Vector3(5.8,.3,length),"Campus_SignLight")
	for z in range(0,int(length)+1,5):
		for side in [-1,1]:
			box(holder,Vector3(side*2.65,2.35,z-length/2),Vector3(.24,4.7,.24),"Campus_Concrete",true)
		box(holder,Vector3(0,4.62,z-length/2),Vector3(5.5,.17,.16),"Campus_Wood")
	K.bake(holder)

static func bake(root: Node3D) -> void:
	K.bake(root)
	# Ground ribbons are combined per palette after construction.
	var groups: Dictionary={}
	for child: Node in root.get_children():
		if not child is MeshInstance3D or child.mesh is BoxMesh:continue
		if child.has_meta("keep_mesh"):continue
		var mat: Material=child.material_override
		if not groups.has(mat):var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);groups[mat]=st
		groups[mat].append_from(child.mesh,0,child.transform)
		root.remove_child(child);child.free()
	for mat: Material in groups:
		var node:=MeshInstance3D.new();node.mesh=groups[mat].commit();node.material_override=mat;root.add_child(node)

static func consolidate(root: Node3D) -> void:
	# Static environment surfaces only. Keep logical records, labels, MultiMeshes
	# and simple physics bodies independent from the merged rendering layer.
	var groups: Dictionary={};var queue: Array[Node]=[root];var sources: Array[MeshInstance3D]=[]
	while not queue.is_empty():
		var current: Node=queue.pop_back()
		for child: Node in current.get_children():queue.append(child)
		if current is MeshInstance3D and current.get_child_count()==0:
			var mat: Material=current.material_override
			if not groups.has(mat):var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);groups[mat]=st
			for surface in current.mesh.get_surface_count():groups[mat].append_from(current.mesh,surface,root.global_transform.affine_inverse()*current.global_transform)
			sources.append(current)
	for current: MeshInstance3D in sources:current.get_parent().remove_child(current);current.free()
	for mat: Material in groups:
		var mesh:=MeshInstance3D.new();mesh.name="EnvironmentMaterialBatch";mesh.mesh=groups[mat].commit();mesh.material_override=mat;root.add_child(mesh)
