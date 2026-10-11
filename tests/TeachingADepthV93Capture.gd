extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("ta-v93-massing",Vector3(-180,126,-23),Vector3(-90,7,-116))
	await capture("ta-v93-court",Vector3(-112,6,-117),Vector3(-59,13,-108))
	await capture("ta-v93-rear",Vector3(-175,8,-158),Vector3(-139,12,-109))
	await capture("ta-v93-gate-interface",Vector3(-127,18,-63),Vector3(-52,9,-80))
	await fixture(Vector3(-34,2.54,-115),[
		[Vector3(-48,2.24,-115),"arcade retained"],[Vector3(-67,2.24,-115),"glazed entry to inner court"],
		[Vector3(-103,2.24,-115),"deepened open court"],[Vector3(-157.32,2.24,-115),"rear central passage"],
		[Vector3(-157.32,2.24,-75),"rear path to gate side"],[Vector3(-157.32,2.24,-71.5),"gate side corner"],
		[Vector3(-54,2.24,-71.5),"gate-left rear stair landing interface"],[Vector3(-35,2.24,-71.5),"gate upper path"],
		[Vector3(-35,2.24,-115),"front promenade return"],[Vector3(-35,2.24,-155),"downstream short return"],
		[Vector3(-157.32,2.24,-155),"downstream perimeter"],[Vector3(-147,2.24,-155),"name wall bypass approach"],[Vector3(-147,2.24,-167),"A B rear connector corner"],
		[Vector3(-135.12,2.24,-167),"inter-block avenue"],[Vector3(-135.12,2.24,-181.5),"B rear loop joins"],
		[Vector3(-135.12,2.24,-167),"B rear return"],[Vector3(-35,2.24,-167),"avenue to promenade"],
		[Vector3(-34,2.24,-115),"TA entry return"],[Vector3(-67,2.24,-115),"entry stair approach"],
		[Vector3(-73.4,2.24,-98.72),"switchback foot"],[Vector3(-55,7.165,-98.72),"first flight"],
		[Vector3(-55,7.165,-102.72),"first landing transfer"],[Vector3(-73,10.865,-102.72),"return flight"],
		[Vector3(-74,10.865,-106.92),"upper landing"],[Vector3(-52,10.865,-106.92),"upper gallery front wing"],
		[Vector3(-74,10.865,-106.92),"upper gallery return"],[Vector3(-74,10.865,-102.72),"return flight head"],
		[Vector3(-55,7.165,-102.72),"return flight descent"],[Vector3(-55,7.165,-98.72),"lower landing return"],
		[Vector3(-74,2.24,-98.72),"first flight descent"],[Vector3(-67,2.24,-115),"court return"],
		[Vector3(-34,2.24,-115),"entry exit"]])
	var report:Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"V93 TA deeper rectangle, four-wing court, gate-side/rear links and retained observed switchback; metric fidelity remains partial"}
	FileAccess.open("res://tests/artifacts/teaching_a_depth_v93.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_DEPTH_V93 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
