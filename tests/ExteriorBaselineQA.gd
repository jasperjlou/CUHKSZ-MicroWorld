extends "res://tests/ExteriorReverseQA.gd"
const Env := preload("res://world/campus_exterior/ExteriorEnvironment.gd")
var side_reports: Array=[]

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(10)
	var report: Dictionary={"startup_msec":Time.get_ticks_msec(),"used_cache":false}
	var nodes: Array[Node]=[world];var shapes:=0;var meshes:=0;var batches:=0
	while not nodes.is_empty():
		var node: Node=nodes.pop_back()
		if node is CollisionShape3D:shapes+=1
		if node is MeshInstance3D:meshes+=1
		if node is MultiMeshInstance3D:batches+=1
		for child: Node in node.get_children():nodes.append(child)
	report.merge({"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),"collision_shapes":shapes,"mesh_instances":meshes,"batches":batches})
	await frames(30);var start:=Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	report["frame_ms"]=(Time.get_ticks_usec()-start)/120000.0
	report["draw_calls"]=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	world.status.visible=false;world.show_labels=false;world.top_down=true;world.update_mode()
	for entry: Array in [["V3_compare_full_campus_aerial",Vector3(450,0,385),1420.0,false],["V3_compare_upper_overview",Vector3(470,54,-90),570.0,true],["V3_compare_fairy_lake_aerial",Vector3(0,24,55),480.0,true],["V3_compare_lower_overview",Vector3(600,8,730),750.0,true]]:
		world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.frame(entry[1],entry[2],entry[3]);await capture(entry[0])
	for entry: Array in [["V3_compare_upper_ground","ling",Vector3(18,8,65)],["V3_compare_college_cluster","muse",Vector3(40,24,75)],["V3_compare_upper_to_middle","harmonia",Vector3(-65,15,80)],["V3_compare_fairy_lake_ground","lake_stone",Vector3(18,6,14)],["V3_compare_music","music",Vector3(55,32,95)],["V3_compare_middle_to_lower","research",Vector3(40,12,55)],["V3_compare_library","library",Vector3(35,12,70)],["V3_compare_student_centre","student_centre",Vector3(30,9,60)],["V3_compare_admin_conference","administration",Vector3(85,14,80)],["V3_compare_shaw","shaw_east",Vector3(25,10,60)],["V3_compare_sports","sports_hall",Vector3(0,8,48)],["V3_compare_corridor","ling",Vector3(10,6,53)],["V3_compare_shuttle_stop","upper_stop",Vector3(14,8,19)],["V3_compare_distant_mountain_context","lake_pavilion",Vector3(25,10,25)]]:
		world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
		var root: Node3D=world.objects[entry[1]];world.overview.position=root.position+entry[2];world.overview.look_at(root.position+Vector3.UP*3);await capture(entry[0])
	FileAccess.open("res://tests/artifacts/v3_comparison.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("V3_COMPARISON ",JSON.stringify(report));get_tree().quit()
