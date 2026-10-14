extends "res://tests/LibraryTrainingDoorwayV227.gd"
func run()->void:
	root.disable_3d=true
	root.size=Vector2i(1440,900)
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(5)
	product.world.player.set_physics_process(false);product.world.player.hide()
	var d:=T.size();var door:float=(435.-326.)/137.*d.x
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	eye.position=room(door,d.y-1.4,1.7);eye.look_at(room(door,d.y+1,1.5));await frames(2)
	var origin:=eye.project_ray_origin(root.get_visible_rect().size*Vector2(765./1440.,380./900.));var direction:=eye.project_ray_normal(root.get_visible_rect().size*Vector2(765./1440.,380./900.))
	var hits:Array=[]
	for node in product.world.find_children("*","GeometryInstance3D",true,false):
		if node.get_parent().name=="Terrain" or node.get_parent().name=="DistantGroundBackdrop":continue
		if node is MultiMeshInstance3D:
			for i in node.multimesh.instance_count:
				probe(node,node.global_transform*node.multimesh.get_instance_transform(i),node.multimesh.mesh.get_aabb(),origin,direction,hits,i)
		elif node is MeshInstance3D:probe(node,node.global_transform,node.mesh.get_aabb(),origin,direction,hits,-1)
	hits.sort_custom(func(a,b):return a.distance<b.distance)
	print("DOOR_RAY ",JSON.stringify(hits.slice(0,12)))
	FileAccess.open("res://tests/artifacts/library_training_v227_door_probe_scaled.json",FileAccess.WRITE).store_string(JSON.stringify(hits.slice(0,12),"\t"))
	root.disable_3d=false;product.world.ui.hide()
	var selected:MultiMeshInstance3D=root.get_node(hits[0].path)
	var mat:=StandardMaterial3D.new();mat.albedo_color=Color.MAGENTA;mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	selected.material_override=mat
	await frames(8);await shot("diagnostic-wall-highlight")
	eye.position=room(door,d.y+4,1.7);eye.look_at(lib(Vector3(-26.6,6,4.17)))
	await frames(8);await shot("diagnostic-corridor")
	quit()
func probe(node:Node3D,t:Transform3D,a:AABB,origin:Vector3,dir:Vector3,hits:Array,index:int)->void:
	var inv:=t.affine_inverse();var hit=a.intersects_ray(inv*origin,inv.basis*dir)
	if hit==null:return
	var pos:Vector3=t*hit
	if (pos-origin).dot(dir)<0:return
	hits.append({"path":str(node.get_path()),"instance":index,"distance":origin.distance_to(pos),"centre":str(t*a.get_center()),"size":str(a.size*t.basis.get_scale()),"library_centre":str(Vector3((t*a.get_center()).z+290,(t*a.get_center()).y-2.24,78-(t*a.get_center()).x))})
