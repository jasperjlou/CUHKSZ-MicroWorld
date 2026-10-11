extends Node3D
## Reference-led V6 exterior detail. Runtime visual meshes, no collision rebuild.
const G := preload("res://world/campus_exterior/ExteriorGeometry.gd")
const Env := preload("res://world/campus_exterior/ExteriorEnvironment.gd")
const FONT := preload("res://systems/ChineseText.gd").FONT
const SURFACE := preload("res://world/unified/SurfaceDetail.gdshader")
const FOCUS := ["ling","muse","diligentia","harmonia","duan","library","student_centre","administration","conference","teaching_a","teaching_b","sports_hall","music","shaw_east"]
var world: Node3D
var materials: Dictionary = {}
var stats := {"buildings":0,"window_frames":0,"sills":0,"solar_fins":0,"road_edges":0,"entry_guides":0,"material_meshes":0}

func _ready() -> void:
	name="ExteriorPolish"
	set_meta("confidence","reference-led interpretation; details not surveyed")
	for building: Dictionary in G.master.objects:
		if building.category != "building" or not world.objects.has(building.id): continue
		var root: Node3D=world.objects[building.id]
		var meshes: Array[Node]=descendants(root)
		if building.id in FOCUS: add_window_detail(root,meshes,building)
		for node: Node in meshes: apply_surface(node,building.id)
		if building.id=="ling":ling_identity(root,building)
		if building.id=="library":library_screens(root,building)
		stats.buildings+=1
	for node: Node in descendants(world.get_node("CampusEnvironmentV3")):apply_surface(node,"")
	# Terrain and lake stay the original meshes; only their material changes.
	for group_name: String in ["Terrain","ExteriorContext"]:
		for node: Node in descendants(world.get_node(group_name)):apply_surface(node,"")
	add_walkway_edges()
	set_meta("statistics",stats)

func descendants(root: Node) -> Array[Node]:
	var result: Array[Node]=[];var todo: Array[Node]=[root]
	while not todo.is_empty():
		var node: Node=todo.pop_back()
		if node is GeometryInstance3D:result.append(node)
		for child: Node in node.get_children():todo.append(child)
	return result

func detail_material(color: Color,kind: int,tiles:=Vector2(.8,.4)) -> ShaderMaterial:
	var key:=color.to_html()+str(kind)+str(tiles)
	if not materials.has(key):
		var material:=ShaderMaterial.new();material.shader=SURFACE
		material.set_shader_parameter("base_color",color);material.set_shader_parameter("surface_kind",kind);material.set_shader_parameter("tile_size",tiles)
		material.set_shader_parameter("variation",.10 if kind==1 else .05)
		materials[key]=material
	return materials[key]

func apply_surface(node: Node,building_id: String) -> void:
	if not node is GeometryInstance3D or not node.material_override is StandardMaterial3D:return
	var original: StandardMaterial3D=node.material_override
	var hex:=original.albedo_color.to_html(false)
	var result: Material
	match hex:
		"e4e1d4","c8c9bc","a5aaa4":
			var color:=Color("e5e7e0") if hex=="e4e1d4" else Color("bfc2b9")
			if building_id=="library":color=Color("5a676b") if hex=="e4e1d4" else Color("8a9290")
			if building_id=="student_centre":color=Color("b3bbb9")
			result=detail_material(color,0,Vector2(1.2,.6))
		"749094","547576":result=detail_material(Color("62828c"),5)
		"ad7853","977052":result=detail_material(Color("ad8055"),4)
		"b68b77","c6bca2","d8d5c8","c4c4b3","d7cdb4":
			var color:=Color("b9aa94") if hex=="b68b77" else Color("d2d0c5") if hex in ["d8d5c8","c4c4b3"] else Color("c7bca6")
			result=detail_material(color,1,Vector2(.8,.4))
		"626c69","777f7b":result=detail_material(Color("515b5d"),2)
		"aeb7ad","89958b":result=detail_material(Color("a9b0a7"),0,Vector2(1.4,.7))
		"93a77a":result=detail_material(Color("708960"),3)
		"648268":result=detail_material(Color("65845e"),3)
	if result!=null:node.material_override=result;stats.material_meshes+=1

func push_box(list: Array[Transform3D],base: Transform3D,offset: Vector3,size: Vector3) -> void:
	list.append(base*Transform3D(Basis.from_scale(size),offset))

func batch(root: Node3D,list: Array[Transform3D],color: Color,label: String) -> void:
	if list.is_empty():return
	var mesh:=BoxMesh.new();mesh.size=Vector3.ONE
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=list.size()
	for i in list.size():mm.set_instance_transform(i,list[i])
	var node:=MultiMeshInstance3D.new();node.name=label;node.multimesh=mm
	var material:=StandardMaterial3D.new();material.albedo_color=color;material.roughness=.66
	node.material_override=material;node.visibility_range_end=190;node.visibility_range_end_margin=25;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(node)

func add_window_detail(root: Node3D,meshes: Array[Node],building: Dictionary) -> void:
	var frames: Array[Transform3D]=[];var sills: Array[Transform3D]=[];var aircon: Array[Transform3D]=[]
	for node: Node in meshes:
		if not node is MultiMeshInstance3D or not node.multimesh.mesh is BoxMesh or not node.material_override is StandardMaterial3D:continue
		if node.material_override.albedo_color.to_html(false)!="749094":continue
		var box_size: Vector3=node.multimesh.mesh.size
		for i in node.multimesh.instance_count:
			var base: Transform3D=root.global_transform.affine_inverse()*node.global_transform*node.multimesh.get_instance_transform(i)
			var w:=box_size.x;var h:=box_size.y
			for side in [-1,1]:
				push_box(frames,base,Vector3(side*(w/2+.05),0,.06),Vector3(.10,h+.22,.12))
				push_box(frames,base,Vector3(0,side*(h/2+.05),.06),Vector3(w+.20,.10,.12))
			push_box(frames,base,Vector3(0,0,.075),Vector3(.055,h,.13))
			push_box(sills,base,Vector3(0,-h/2-.16,.10),Vector3(w+.28,.16,.38))
			if building.region=="upper" and i%5==0:push_box(aircon,base,Vector3(w/2+.40,.2,.18),Vector3(.62,.48,.48))
			stats.window_frames+=1;stats.sills+=1
	batch(root,frames,Color("dce3df") if building.region=="upper" else Color("687875"),"PolishWindowFrames")
	batch(root,sills,Color("c7cec4"),"PolishWindowSills")
	batch(root,aircon,Color("adb6b2"),"PolishAirConditioners")

func ling_identity(root: Node3D,building: Dictionary) -> void:
	var sign:=Label3D.new();sign.text="道\n扬\n书\n院";sign.font=FONT;sign.font_size=90;sign.pixel_size=.022
	sign.position=Vector3(-building.footprint_width*.34,building.estimated_height*.68,building.footprint_depth*.15+.6)
	sign.modulate=Color("283b43");sign.outline_size=0;sign.visibility_range_end=230;root.add_child(sign)

func library_screens(root: Node3D,building: Dictionary) -> void:
	# Side screens follow the photographed dark C-block / warm vertical screen vocabulary.
	var fins: Array[Transform3D]=[]
	var half: float=(building.estimated_height-4.8)*.5
	var height: float=half*.94
	for side in [-1,1]:
		for i in 29:
			var pos:=Vector3(side*(building.footprint_width/2+.18),4.8+half*1.5,(i-14)*1.35)
			push_box(fins,Transform3D.IDENTITY,pos,Vector3(.48,height,.12))
	batch(root,fins,Color("a98b5c"),"PolishLibrarySolarScreens")
	stats.solar_fins=fins.size()

func ribbon(points: Array[Vector3],width: float,color: Color,lift: float) -> void:
	var vertices:=PackedVector3Array()
	for i in range(points.size()-1):
		var a: Vector3=points[i];var b: Vector3=points[i+1];var normal:=Vector3(b.z-a.z,0,a.x-b.x).normalized()*width/2
		var count:=maxi(1,ceili(a.distance_to(b)/2))
		for j in count:
			var p:=a.lerp(b,float(j)/count);var q:=a.lerp(b,float(j+1)/count)
			var quad: Array[Vector3]=[p-normal,p+normal,q+normal,q-normal]
			for k in 4:quad[k].y=G.height_at(quad[k].x,quad[k].z)+lift
			vertices.append_array(G.quad(quad[0],quad[1],quad[2],quad[3]))
	var node:=G.surface(self,vertices,color)
	node.material_override=detail_material(color,0,Vector2(.5,.5));node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func add_walkway_edges() -> void:
	for road: Dictionary in Env.data.routes:
		if road.category!="pedestrian":continue
		var points: Array[Vector3]=[]
		for p: Array in road.geometry:points.append(G.vec(p))
		for side in [-1,1]:
			var gutter: Array[Vector3]=[]
			for i in points.size():
				var tangent:=points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]
				var normal:=Vector3(tangent.z,0,-tangent.x).normalized()
				gutter.append(points[i]+normal*side*(road.width/2-.18))
			ribbon(gutter,.16,Color("6f7871"),.36);stats.road_edges+=1
	# Ground-level arrival detail is flat visual paving, never a new step/collider.
	for entry: Dictionary in Env.data.entrance_connections:
		if entry.building_id not in FOCUS:continue
		var pts: Array[Vector3]=[]
		for p: Array in entry.geometry:pts.append(G.vec(p))
		for side in [-1,1]:
			var edge: Array[Vector3]=[]
			for i in pts.size():
				var tangent:=pts[mini(i+1,pts.size()-1)]-pts[maxi(0,i-1)]
				edge.append(pts[i]+Vector3(tangent.z,0,-tangent.x).normalized()*side*(entry.width/2-.12))
			ribbon(edge,.13,Color("d9d3bd"),.37)
		stats.entry_guides+=1
