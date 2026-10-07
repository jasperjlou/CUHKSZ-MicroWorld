extends Node
const Builder:=preload("res://world/campus_seamless/InteriorBuilder.gd")
const I:=preload("res://world/campus_seamless/InteriorKit.gd")
var world: Node3D
var definitions: Array=[]
var loaded: Dictionary={}
var activation_ms: Dictionary={}
var active_id: String=""
var camera_blend:=0.0
var presentation_index:=0
var details: Label
var doors: Dictionary={}

func _ready() -> void:
	definitions=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_interiors.json"))
	details=Label.new();details.position=Vector2(22,225);details.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);world.ui.add_child(details)
	for d: Dictionary in definitions:
		if d.door_type!="AUTO_SLIDE":continue
		var door:=Node3D.new();world.objects[d.building_id].add_child(door)
		door.position=Vector3(0,0,d.center_local[2]+d.depth/2)
		var leaves: Array=[]
		for side in [-1,1]:
			var leaf:=I.box(door,Vector3(side*1.28,2.15,0),Vector3(2.5,4.3,.15),"glass_bluegray",true);leaves.append(leaf)
		doors[d.building_id]={"root":door,"leaves":leaves,"open":false,"amount":0.0}

func activate(d: Dictionary) -> Node3D:
	if loaded.has(d.building_id):return loaded[d.building_id]
	var start:=Time.get_ticks_usec()
	var path: String="res://world/campus_seamless/generated/"+d.interior_id+".scn"
	var root: Node3D=load(path).instantiate() if FileAccess.file_exists(path) else Builder.build(d)
	root.position=Vector3(d.center_local[0],d.center_local[1],d.center_local[2]);world.objects[d.building_id].add_child(root)
	loaded[d.building_id]=root;activation_ms[d.building_id]=(Time.get_ticks_usec()-start)/1000.0
	return root

func _physics_process(delta: float) -> void:
	active_id=""
	for d: Dictionary in definitions:
		var building: Node3D=world.objects[d.building_id];var p:=building.to_local(world.player.global_position)
		var center:=Vector3(d.center_local[0],0,d.center_local[2])
		var camera_p: Vector3=building.to_local(world.overview.global_position)
		var near: bool=Vector2(p.x-center.x,p.z-center.z).length()<d.depth+22 or (world.top_down and absf(camera_p.x)<d.width/2 and absf(camera_p.z-center.z)<d.depth/2 and camera_p.y<d.height)
		if near:activate(d)
		if loaded.has(d.building_id):
			var root: Node3D=loaded[d.building_id];root.visible=near
			if root.get_meta("enabled",true)!=near:
				root.set_meta("enabled",near)
				var queue: Array[Node]=[root]
				while not queue.is_empty():
					var node: Node=queue.pop_back()
					if node is StaticBody3D:node.collision_layer=1 if near else 0
					for child: Node in node.get_children():queue.append(child)
		if absf(p.x)<d.width/2 and absf(p.z-center.z)<d.depth/2 and p.y>=-.4 and p.y<d.height:active_id=d.building_id
		if doors.has(d.building_id):
			var door: Dictionary=doors[d.building_id]
			var opened: bool=absf(p.x)<8 and absf(p.z-(center.z+d.depth/2))<9
			door.open=opened;door.amount=move_toward(float(door.amount),1.0 if opened else 0.0,delta*3)
			for j in 2:
				var leaf: MeshInstance3D=door.leaves[j];leaf.position.x=(-1 if j==0 else 1)*(1.28+door.amount*2.6)
				leaf.get_child(0).collision_layer=0 if opened or door.amount>.01 else 1
	var indoors: bool=not active_id.is_empty() and not world.top_down
	camera_blend=move_toward(camera_blend,1.0 if indoors else 0.0,delta*3)
	world.player.camera_offset=world.player.CAMERA_OFFSET.lerp(Vector3(0,3.6,4.2),camera_blend)
	details.visible=world.show_labels
	details.text="室内："+("室外" if active_id.is_empty() else world.objects[active_id].get_meta("display_name",active_id))+"\n室内置信：推断 · 可替换\n已加载：%s / 10\n高桌晚宴：原型活动室内，非真实固定场地"%loaded.size()

func present_next() -> void:
	var d: Dictionary=definitions[presentation_index%definitions.size()];presentation_index+=1
	var root:=activate(d);root.visible=true
	world.top_down=true;world.update_mode();world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
	world.overview.global_position=root.to_global(Vector3(0,3.8,d.depth/2-4))
	world.overview.look_at(root.to_global(Vector3(-3,2,-6)))
