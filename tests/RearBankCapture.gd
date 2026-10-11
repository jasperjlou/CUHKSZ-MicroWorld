extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-bank-stair",Vector3(108,4.2,-405),Vector3(118,5,-405))
	await capture("rear-bank-road",Vector3(114,4.2,-368),Vector3(110,4,-436))
	await capture("rear-bank-canopy",Vector3(115,5,-459),Vector3(99,5,-421))
	await capture("rear-bank-overall",Vector3(191,88,-341),Vector3(112,4,-433))
	await fixture(site(132,-310)+Vector3.UP*.3,[
		[site(122,-350),"library to student bend"],[site(105,-380),"student rear approach"],
		[site(105,-405),"student rear sidewalk"],[site(110,-405),"cross to bank"],
		[site(114.3,-405),"narrow stair foot"],[Vector3(119.1,5.64,-405),"narrow stair ascent"],
		[site(114.2,-405),"narrow stair descent"],[site(110,-405),"bank road return"],
		[site(105,-405),"sidewalk return"],[site(105,-435),"SC back corner"],
		[site(102,-448),"white canopy approach"],[site(108,-448),"canopy to sidewalk"],
		[site(115,-475),"Shaw approach bend"],[site(117,-510),"Shaw back approach"],
		[site(125,-540),"Shaw rear link"],[site(108,-575),"Shaw existing rear junction"]])
	await fixture(site(108,-575)+Vector3.UP*.3,[
		[site(125,-540),"reverse Shaw link"],[site(117,-510),"reverse rear approach"],
		[site(115,-475),"reverse bend"],[site(108,-448),"reverse canopy corner"],
		[site(105,-435),"reverse SC corner"],[site(105,-380),"reverse SC sidewalk"],
		[site(122,-350),"reverse library bend"],[site(132,-310),"return to retained library slope"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"re-aligned SC rear road, fitted bank and narrow stair, canopy and Shaw rear connection; mural colours approximate and date unknown"}
	FileAccess.open("res://tests/artifacts/rear_bank_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_BANK ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
