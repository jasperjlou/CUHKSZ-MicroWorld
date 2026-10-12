extends "res://tests/LibraryEntryApproachV117.gd"
const Gallery=preload("res://world/visual_campus/LibraryOuterGallery.gd")
func gp(p:Vector3)->Vector3:return wp(p.x,p.y,p.z)
var resume_upper:=false
func walk(target:Vector3,label:String)->bool:
	var player:CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y;var walls:Dictionary={}
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.12 and count<600:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
		for i in player.get_slide_collision_count():
			var hit:=player.get_slide_collision(i)
			if absf(hit.get_normal().y)<.7:walls[str(hit.get_collider().get_path())]=str(hit.get_position())
	player.navigation_direction=Vector2.ZERO;await frames(8)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:bool=count<600 and distance<.35 and absf(player.position.y-target.y)<.6
	if not valid:failures.append(label)
	legs.append({"goal":label,"valid":valid,"distance":distance,"end":[player.position.x,player.position.y,player.position.z],"lowest_y":lowest,"walls":walls if not valid else {}})
	print("GALLERY_LEG ",label," ",valid," ",walls if not valid else {})
	return valid

func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-gallery-v188-front",wp(-23,11,45),wp(-13,3.5,25))
	await capture("library-gallery-v188-foot",wp(-37,1.8,18.9),wp(-24,2.7,19.3))
	await capture("library-gallery-v188-upper",wp(7,6.2,27),ep(-1,1,6))
	var route:Array=[]
	var aisle:Array[Vector3]=[Vector3(-35,0,16),Vector3(-31,0,16),Vector3(-24,0,17),Vector3(-17,0,17),Vector3(-12,0,20),Vector3(-12,0,13)]
	for p in aisle:route.append([gp(p),"retained G aisle "+str(p)])
	for i in range(aisle.size()-2,-1,-1):route.append([gp(aisle[i]),"G aisle return "+str(i)])
	route.append([wp(-39,0,18.9),"open side to gallery foot"])
	var rising:=Gallery.route()
	if resume_upper:route.clear()
	for i in range(6 if resume_upper else 0,rising.size()):route.append([gp(rising[i]),"outer gallery ascent "+str(i)])
	route.append([ep(0,1),"gallery meets main terrace"])
	route.append([ep(0,-2),"public2F threshold"])
	route.append([ep(0,1),"exit2F to gallery"])
	for i in range(rising.size()-1,-1,-1):route.append([gp(rising[i]),"outer gallery descent "+str(i)])
	route.append([wp(-39,0,18.9),"ground return"])
	for p in aisle:route.append([gp(p),"G aisle after descent "+str(p)])
	await fixture(gp(rising[6]+Vector3.UP*.3) if resume_upper else wp(-40,.3,18.9),route)
	var checks:Array=[]
	var mid:Vector3=rising[4];var side:Vector3=Gallery.side_vectors(rising)[4]
	for item in [[gp(mid+Vector3.UP*.5),gp(mid-Vector3.UP*.3),true,"inclined deck"],[gp(mid+Vector3.UP*2.1),gp(mid+Vector3.UP*1.8),false,"clear head above ramp"],[gp(mid+Vector3.UP*.5),gp(mid+side*1.5+Vector3.UP*.5),true,"continuous outer guard"],[wp(-12,.6,17),wp(-12,-.2,17),true,"G threshold floor remains"],[ep(0,1,6),ep(0,-1,6),false,"2F entry remains open"]]:
		var q=PhysicsRayQueryParameters3D.create(item[0],item[1]);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==item[2]
		checks.append({"case":item[3],"valid":valid,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"})
		if not valid:failures.append(item[3])
	var report={"version":world.data.version,"physical_legs":legs,"planned_legs":route.size(),"checks":checks,"captures":captures,"fixtures":1,"failures":failures,"scope":"Ginneraisle plus exterior rising gallery G-2F and threshold roundtrip;dimensions fitted,grey shortcut stair unresolved"}
	FileAccess.open("res://tests/artifacts/library_gallery_v188.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_GALLERY_V188 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
