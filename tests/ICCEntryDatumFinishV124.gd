extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	await capture("icc-v124-finish-site",Vector3(-4,51,-146),Vector3(94,9,-96))
	await capture("icc-v124-finish-approach",b.to_global(Vector3(-3.2,5.7,80)),b.to_global(Vector3(-1.75,10,35)))
	await capture("icc-v124-finish-lower",b.to_global(Vector3(10,1.8,54)),b.to_global(Vector3(18.5,2.4,30)))
	await capture("icc-v124-finish-underbridge",b.to_global(Vector3(-7,1.8,55)),b.to_global(Vector3(-3,3,40)))
	await capture("icc-v124-finish-stair",b.to_global(Vector3(38,9,71)),b.to_global(Vector3(25,1,50)))
	var checks:Array=[]
	var route:Array=[]
	for pair:Array in [[Vector3(-1.75,5,37),"short threshold to foyer"],[Vector3(-1.75,5,28),"foyer interior"],[Vector3(-1.75,5,37),"foyer exit"],[Vector3(-1.75,4.8,43),"short threshold descent"],[Vector3(-3.2,MALL,77.5),"bridge descent to mall"],[Vector3(25.5,MALL,72),"upper walk to lower stair"],[Vector3(25.5,0,48),"side stair lower court"],[Vector3(18.5,0,46),"lower lounge approach"],[Vector3(18.5,.1,32),"lower lounge entrance"],[Vector3(18.5,0,46),"lower lounge exit"],[Vector3(0,0,46),"under raised forecourt"],[Vector3(-6,0,28),"under foyer lower passage"],[Vector3(0,0,46),"lower passage return"],[Vector3(25.5,0,48),"side stair toe"],[Vector3(25.5,MALL,72),"side stair ascent"],[Vector3(37,MALL,72),"side street outer bypass"],[Vector3(37,MALL,-43),"outer street to rear"],[Vector3(13,MALL,-40),"raised rear door arcade"],[Vector3(-17,MALL,-40),"rear arcade traverse"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(Vector3(56.40672,3.54,-103.9115),route)
	FileAccess.open("res://tests/artifacts/icc_entry_datum_v124_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"physical_legs":legs,"fixtures":1,"scope":"Coupled entry datum, terrain holes, bridge, lower lounge/stair and relocated exterior routes; historical levels and fitted horizontal registration, not whole-campus completion."},"\t"))
	quit(0 if failures.is_empty() else 1)
const MALL:=3.8
