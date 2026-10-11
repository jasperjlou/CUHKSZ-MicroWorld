extends "res://tests/CourtyardRefinementCapture.gd"
var checks:Array=[]
func probe(label:String,a:Vector3,b:Vector3,expected:bool) -> void:
	var q:=PhysicsRayQueryParameters3D.create(a,b,1)
	var hit:=not world.get_world_3d().direct_space_state.intersect_ray(q).is_empty()
	checks.append({"label":label,"valid":hit==expected,"hit":hit})
	if hit!=expected:failures.append(label)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("student-north-v129-service-out",Vector3(28,-.03,-411),Vector3(28,-.15,-372))
		await capture("student-north-v129-court-arrival",Vector3(28,-.04,-382),Vector3(30,-.15,-356))
		await capture("student-north-v129-return",Vector3(37,1.5,-359),Vector3(28,-.20,-391))
		await capture("student-north-v129-overview",Vector3(3,31,-382),Vector3(29,.4,-360))
		FileAccess.open("res://tests/artifacts/student_north_v129_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(Vector3(18,2.54,-412),[
		[Vector3(18,-1.76,-431),"service main stair down"],[Vector3(29,-1.76,-431),"east lower aisle"],
		[Vector3(29,-1.76,-413),"card forecourt north side"],[Vector3(28,-1.76,-403),"new southern wall opening"],
		[Vector3(28,-1.76,-393),"under upper mall"],[Vector3(28,-1.76,-383),"court passage threshold"],
		[Vector3(28,-1.76,-377),"new northern wall opening"],[Vector3(38,-1.76,-377),"lawn south apron"],
		[Vector3(38,-1.76,-366.8),"lawn side to gallery"],[Vector3(50.5,-1.76,-366.8),"existing lower room entry"],
		[Vector3(50.5,-1.76,-353.2),"lower room through route"],[Vector3(38,-1.76,-353.2),"room exit toward stair"],
		[Vector3(32,-1.76,-352),"court main stair foot"],[Vector3(32,2.24,-336),"court main stair up"],
		[Vector3(32,2.24,-334.4),"library-side stone shore"],[Vector3(15,2.24,-334.4),"shore joins mall"],
		[Vector3(32,2.24,-334.4),"shore return to stair"],[Vector3(32,-1.76,-352),"court stair return down"],
		[Vector3(38,-1.76,-352),"lawn north apron return"],[Vector3(38,-1.76,-377),"lawn side return"],
		[Vector3(28,-1.76,-377),"connection return approach"],[Vector3(28,-1.76,-393),"covered passage return"],
		[Vector3(28,-1.76,-413),"service hall return"],[Vector3(29,-1.76,-431),"service lightwell side"],
		[Vector3(18,-1.76,-431),"service main stair foot"],[Vector3(18,2.24,-413),"service main stair up"],
		[Vector3(28,2.24,-413),"upper mall approach"],[Vector3(28,2.24,-392),"upper route above new passage"]])
	probe("connection roof retains upper floor",Vector3(28,3,-393),Vector3(28,1.9,-393),true)
	probe("south doorway clear at head level",Vector3(28,.5,-409),Vector3(28,.5,-404),false)
	probe("north doorway clear at head level",Vector3(28,.5,-382),Vector3(28,.5,-378),false)
	probe("lawn remains solid ground",Vector3(27,.2,-362),Vector3(27,-2,-362),true)
	FileAccess.open("res://tests/artifacts/student_north_v129_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
