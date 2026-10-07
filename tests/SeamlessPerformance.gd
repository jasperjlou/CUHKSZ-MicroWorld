extends Node
var world: Node3D
var reports: Array=[]
var entries: Array=[]
func _ready() -> void:
 run.call_deferred()
func measure(label: String) -> void:
 for i in 30:await get_tree().process_frame
 var start:=Time.get_ticks_usec()
 for i in 120:await get_tree().process_frame
 var elapsed: float=(Time.get_ticks_usec()-start)/120000.0
 var meshes:=0;var batches:=0;var shapes:=0;var lights:=0;var queue: Array[Node]=[world]
 while not queue.is_empty():
  var n: Node=queue.pop_back()
  if n is MeshInstance3D and n.is_visible_in_tree():meshes+=1
  if n is MultiMeshInstance3D and n.is_visible_in_tree():batches+=1
  if n is StaticBody3D and n.collision_layer!=0:shapes+=n.get_child_count()
  if n is Light3D:lights+=1
  for c: Node in n.get_children():queue.append(c)
 reports.append({"label":label,"frame_ms":elapsed,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"visible_meshes":meshes,"visible_batches":batches,"active_collider_children":shapes,"lights":lights})
func run() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var args:=OS.get_cmdline_user_args();var v4: bool="--baseline-v4" in args
 world=load("res://world/campus_exterior/CampusExterior.tscn" if v4 else "res://world/campus_seamless/CampusSeamless.tscn").instantiate();add_child(world)
 var startup:=Time.get_ticks_msec();world.top_down=true;world.update_mode();world.frame(Vector3(450,0,385),1420)
 await measure("V4 baseline" if v4 else "V5 inactive interiors")
 if not v4:
  for d: Dictionary in world.interiors.definitions:
   if d.zone_type not in ["library","music","student","college","teaching"] or d.building_id in ["muse","shaw_east"]:continue
   var root: Node3D=world.objects[d.building_id];world.player.global_position=root.to_global(Vector3(0,.1,d.center_local[2]));world.player.velocity=Vector3.ZERO
   world.top_down=false;world.update_mode();world.player.set_physics_process(false)
   var first:=Time.get_ticks_usec();var previous:=first;var peak:=0.0
   for i in 30:
    await get_tree().process_frame
    world.player.update_camera(get_process_delta_time())
    var now:=Time.get_ticks_usec();peak=maxf(peak,(now-previous)/1000.0);previous=now
   entries.append({"building_id":d.building_id,"first_30_frame_peak_ms":peak,"first_30_frame_total_ms":(Time.get_ticks_usec()-first)/1000.0})
   world.player.update_camera(1,true)
   await measure("V5 active "+d.building_id)
 var report: Dictionary={"startup_ms":startup,"first_entry_frames":entries,"measurements":reports,"same_machine":true,"sample_frames":120,"vsync":false,"cross_machine_fps_claim":false}
 if not v4:report["activation_ms"]=world.interiors.activation_ms
 var path: String="res://tests/artifacts/v5_perf_baseline.json" if v4 else "res://tests/artifacts/v5_perf_current.json"
 FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("V5_PERF ",JSON.stringify(report));get_tree().quit()
