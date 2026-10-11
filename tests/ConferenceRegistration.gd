extends "res://tests/CourtyardRefinementCapture.gd"
const Lake:=preload("res://world/visual_campus/EntranceLakeSite.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("conference-plan-v69",Vector3(192,96,80),Vector3(72,10,-28))
	await capture("conference-lake-v69",Vector3(154,20,47),Vector3(115,15,-32))
	await capture("conference-rear-v69",Vector3(103,9,-79),Vector3(102,9,-35))
	var icc:Node3D=world.builder.buildings.conference
	var route:Array=[[icc.to_global(Vector3(5,4.4,13)),"foyer return clears doors"],[icc.to_global(Vector3(5,4.4,24)),"ICC outer landing return"],[icc.to_global(Vector3(5,0,36)),"ICC outer stair descent"],[Vector3(40,2.24,-70),"ICC north approach"],[Vector3(97.5,2.24,-70),"ICC rear crosswalk"],[Vector3(97.5,2.24,-22),"ICC to CxII rear gap"],[Vector3(112,2.24,-22),"CxII public platform approach"],[Vector3(123.8,2.24,-22),"CxII court aisle"],[Vector3(123.8,2.24,-26.4),"registered spiral lower landing"],[Vector3(120.6,2.24,-26.4),"registered spiral entry"]]
	for turn in 2:
		for i in range(1,25):
			var a:float=i*TAU/24
			route.append([Vector3(118.2+cos(a)*2.4,2.24+turn*4.4+4.4*i/24,-26.4+sin(a)*2.4),"CxII spiral ascent %d-%02d"%[turn,i]])
	route.append_array([[Vector3(123.8,11.04,-26.4),"CxII top radial exit"],[Vector3(123.8,11.04,-20.8),"CxII top front aisle"],[Vector3(112.6,11.04,-20.8),"CxII upper crosswalk"],[Vector3(112.6,11.04,-32),"CxII rear approach"],[Vector3(109.4,11.04,-32),"CxII stair side"],[Vector3(109.4,11.04,-35.2),"CxII stair lower landing"],[Vector3(103,11.04,-35.2),"CxII upper stair toe"],[Vector3(103,15.44,-17.6),"CxII upper stair ascent"],[Vector3(107,15.44,-17.6),"registered curved link approach"]])
	for i in range(1,11):
		var t:float=float(i)/10
		route.append([Vector3(107+sin(t*PI)*3.04,15.44,-19.2-t*15.2),"registered curved link %02d"%i])
	route.append_array([[Vector3(107.8,15.44,-43.2),"tower joining platform"],[Vector3(122.2,15.44,-47.2),"registered CxII tower gallery"]])
	await fixture(icc.to_global(Vector3(-6,4.4,18.5))+Vector3.UP*.3,route)
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"moved/scaled ICC,registered CxII public ascent/bridge and curved shoreline;old absolute ICC/V68 site records retired"}
	FileAccess.open("res://tests/artifacts/conference_registration_connections_v69.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("CONFERENCE_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
