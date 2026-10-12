extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	# Initial probe atx=-35 hit the retained WC back wall, not the removed facade.
	probe(wp(-30,1.8,-26),wp(-30,1.8,-24.4),false,"old rear doorway clear",checks)
	var terrace:Array=[]
	for v in [[850,235],[915,282],[950,300],[915,340],[910,375]]:terrace.append([p3(v[0],v[1],8.8),"terrace via actual diagonal door "+str(v)])
	await fixture(p3(760,200,9.1),terrace)
	# Side ramp is now relocated with the porch; do not use the retired V105 approach.
	var ramp:Array=[]
	for v in [[12,0,-2.4],[8,.24,-2.4],[4,.48,-2.4],[0,.48,-2.4],[0,.48,1.8],[0,0,4.8],[0,0,12]]:ramp.append([dp(v[0],v[1],v[2]),"relocated side ramp "+str(v)])
	await fixture(dp(13.5,.3,-2.4),ramp)
	for i in 3:
		var edge:=LowerP.polygon3([[608,74],[764,74],[1013,329],[978,361]])
		var a:=edge[i];var b:=edge[i+1];var mid:Vector2=(a+b)/2;var d:Vector2=(b-a).normalized();var normal:=Vector2(-d.y,d.x)
		probe(wp(mid.x-normal.x*.4,9.3,mid.y-normal.y*.4),wp(mid.x+normal.x*.4,9.3,mid.y+normal.y*.4),true,"outdoor terrace guard "+str(i),checks)
	await capture("library-lower-rear-v150-vestibule-final",dp(0,1.75,10),dp(0,1.75,-2))
	await capture("library-lower-rear-v150-terrace-final",p3(790,130,11),p3(630,235,10.6))
	await capture("library-lower-rear-v150-diagonal-door",p3(960,300,10.4),p3(900,352,10.4))
	FileAccess.open("res://tests/artifacts/library_lower_rear_v150_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2},"\t"))
	print("LIBRARY_LOWER_REAR_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
