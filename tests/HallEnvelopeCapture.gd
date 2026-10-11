extends "res://tests/CourtyardRefinementCapture.gd"
const O:=Vector3(-10,2.24,-890)
func wp(x: float,y: float,z: float) -> Vector3:return O+Vector3(x,y,z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-rear-panels-v62",wp(-65,6,-49),wp(-15,9,-23))
	await capture("hall-side-ribbon-v62",wp(-67,6,17),wp(-45,8,-9))
	await capture("hall-roof-v62",wp(-50,45,-42),wp(0,13,-5))
	await capture("between-halls-campus-face-v62",Vector3(28,7,-926),Vector3(-34,12,-934))
	await capture("complex-field-colour-v62",Vector3(-15,9,-1030),Vector3(-10,12,-947))
	await fixture(wp(10,.3,40),[
		[wp(10,.84,32),"front stair retained"],[wp(10,.84,21),"front portal retained"],
		[wp(10,.84,12),"reception retained"],[wp(10,.84,32),"reception return"],[wp(10,0,40),"front stair descent"],
		[wp(-47,0,40),"front forecourt to side"],[wp(-47,0,17),"side paving start"],
		[wp(-47,0,-27),"side ribbon wall promenade"],[wp(-47,0,-35),"rear corner"],
		[wp(0,0,-35),"rear glazed strip frontage"],[wp(47,0,-35),"rear promenade opposite end"],
		[wp(47,0,17),"opposite side promenade"],[wp(47,0,39),"side to front connection"],
		[wp(33,0,39),"lower wing approach"],[wp(33,0,30),"existing side arcade"],[wp(33,0,39),"arcade return"],
		[wp(47,0,39),"return to outer side"],[wp(47,0,-35),"hall to between-halls court"],
		[wp(47,0,-38),"clear canopy column row"],[wp(0,0,-38),"between-halls continuous paving"],
		[wp(0,0,-57),"complex open ground passage"],[wp(0,0,-73),"complex to field"],
		[wp(0,0,-80),"field promenade retained"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V62 hall side/rear envelope,perimeter hardscape and Complex campus/field facade;selected continuous ground route only;absolute positions,grades,unseen side symmetry and roof modules fitted"}
	FileAccess.open("res://tests/artifacts/hall_envelope_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_ENVELOPE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
