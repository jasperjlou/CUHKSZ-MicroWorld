extends "res://tests/CardBankRoomV130.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("card-bank-v130-entry",at(0,3,.0),at(-1,-4,.1))
	await capture("card-bank-v130-card",at(1.6,-1.4,-.06),at(4.7,-6.3,-.15))
	FileAccess.open("res://tests/artifacts/card_bank_v130_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
