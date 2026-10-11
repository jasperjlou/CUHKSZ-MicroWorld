extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	await capture("icc-v124-site",Vector3(-4,51,-146),Vector3(94,9,-96))
	await capture("icc-v124-approach",b.to_global(Vector3(-3.2,5.7,80)),b.to_global(Vector3(-1.75,10,35)))
	await capture("icc-v124-lower",b.to_global(Vector3(10,1.8,54)),b.to_global(Vector3(18.5,2.4,30)))
	await capture("icc-v124-underbridge",b.to_global(Vector3(-7,1.8,55)),b.to_global(Vector3(-3,3,40)))
	await capture("icc-v124-stair",b.to_global(Vector3(38,9,71)),b.to_global(Vector3(25,1,50)))
	var checks:Array=[]
	for pair:Array in [[Vector3(-3.2,7,65),Vector3(-3.2,3,65),4.8-(65-47.75)/27.4,"bridge slope"],[Vector3(10,3,50),Vector3(10,-1,50),0.0,"lower court terrain hole"],[Vector3(25.5,7,65),Vector3(25.5,0,65),2.93,"stair trench clear"],[Vector3(-3.2,3,53),Vector3(-3.2,4.5,53),null,"bridge underside exists"]]:
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(b.to_global(pair[0]),b.to_global(pair[1])))
		var valid:bool=not hit.is_empty()
		if valid and pair[2]!=null:valid=absf(hit.position.y-(b.global_position.y+pair[2]))<.18
		checks.append({"name":pair[3],"valid":valid,"world_hit_y":hit.get("position",Vector3.ZERO).y})
		if not valid:failures.append(pair[3])
	var route:Array=[[Vector3(24,2.24,-64),"gate upper walk to mall"],[Vector3(24,2.24,-105.2),"stone band to bridge foot"]]
	for pair:Array in [[Vector3(-3.2,4.8,47.75),"gentle entry bridge ascent"],[Vector3(-1.75,4.8,42),"raised forecourt"],[Vector3(-1.75,5,37),"short threshold to foyer"],[Vector3(-1.75,5,28),"foyer interior"],[Vector3(-1.75,5,37),"foyer exit"],[Vector3(-1.75,4.8,43),"short threshold descent"],[Vector3(-3.2,MALL,75.5),"bridge descent to mall"],[Vector3(25.5,MALL,72),"upper walk to lower stair"],[Vector3(25.5,0,48),"side stair lower court"],[Vector3(18.5,0,46),"lower lounge approach"],[Vector3(18.5,.1,32),"lower lounge entrance"],[Vector3(18.5,0,46),"lower lounge exit"],[Vector3(0,0,46),"under raised forecourt"],[Vector3(-6,0,28),"under foyer lower passage"],[Vector3(0,0,46),"lower passage return"],[Vector3(25.5,0,48),"side stair toe"],[Vector3(25.5,MALL,72),"side stair ascent"],[Vector3(37,MALL,72),"side street outer bypass"],[Vector3(37,MALL,-43),"outer street to rear"],[Vector3(13,MALL,-40),"raised rear door arcade"],[Vector3(-17,MALL,-40),"rear arcade traverse"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(Vector3(29,2.54,-58),route)
	FileAccess.open("res://tests/artifacts/icc_entry_datum_v124.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"physical_legs":legs,"fixtures":1,"scope":"Coupled entry datum, terrain holes, bridge, lower lounge/stair and relocated exterior routes; historical levels and fitted horizontal registration, not whole-campus completion."},"\t"))
	quit(0 if failures.is_empty() else 1)
const MALL:=3.8
