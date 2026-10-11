extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tower-garden-axis-v64",Vector3(23,8,-721),Vector3(23,17,-802))
	await capture("tower-garden-plan-v64",Vector3(-4,80,-732),Vector3(23,2,-796))
	await capture("tower-covered-route-v64",Vector3(19,9,-860),Vector3(10,5,-804))
	await capture("tower-research-road-v64",Vector3(69,43,-787),Vector3(23,4,-842))
	await fixture(Vector3(15,2.54,-746),[
		[Vector3(15,2.24,-765),"garden side walk"],[Vector3(15,2.84,-770),"first garden stair"],
		[Vector3(15,2.84,-776),"first raised lawn edge"],[Vector3(15,3.44,-781),"second garden stair"],
		[Vector3(18,3.44,-787),"second raised lawn edge"],[Vector3(18,4.04,-792),"third garden stair"],
		[Vector3(23,4.04,-797),"tower raised entry apron"],[Vector3(23,4.04,-800),"tower door threshold"],
		[Vector3(23,4.04,-794),"entry return"],[Vector3(17,4.04,-794),"side entry stair top"],
		[Vector3(6,2.24,-794),"side entry descent"],[Vector3(6,2.24,-798),"around side entry guard"],
		[Vector3(9.4,2.24,-803),"covered walk start"],[Vector3(9.4,2.24,-829),"covered walk tower section"],
		[Vector3(9.4,2.24,-865),"covered walk Hall section"],[Vector3(27,2.24,-876),"covered bend to Hall"],
		[Vector3(27,2.24,-890),"Hall canopy interface"],[Vector3(27,2.24,-876),"return covered bend"],
		[Vector3(38,2.24,-876),"road footpath connection"],[Vector3(44,2.24,-865),"road below Research stair"],
		[Vector3(35,2.24,-861),"road curved lower leg"],[Vector3(24,2.24,-857),"road bend southwest"],
		[Vector3(20,2.24,-852),"road beside stair foot"],[Vector3(20,2.24,-839),"road before stair foot"],
		[Vector3(23,2.24,-834),"road corner return"],[Vector3(35,2.24,-831),"road upper curve"],
		[Vector3(43,2.24,-827),"road upper bend"],[Vector3(45,2.24,-823),"road eastern side"],
		[Vector3(45,2.24,-782),"road parallel to axial garden"],[Vector3(55,2.24,-778),"hill road junction"],
		[Vector3(78,2.24,-778),"hill road continuation"],[Vector3(105,2.24,-781),"hill-side connection"],
		[Vector3(130,2.24,-781),"existing service route junction"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"continuous axial garden/raised entry/side descent/canopy/road-to-hillside;V63 absolute tower routes superseded"}
	FileAccess.open("res://tests/artifacts/tower_plaza_v64.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TOWER_PLAZA ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
