extends "res://tests/StudentRegisteredV153.gd"
var rt:=Transform3D.IDENTITY
func rp(x:float,y:float,z:float)->Vector3:return rt*Vector3(x,y,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	var checks:Array=[]
	probe(Vector3(91,4,-845),Vector3(91,18,-845),false,"former podium anchor no longer contains building",checks)
	probe(rp(0,1.7,37),rp(0,1.7,-37),false,"relocated G axial hall clear",checks)
	probe(rp(-14,1,0),rp(-14,18,0),false,"relocated podium well remains open",checks)
	probe(rp(42,12.3,4),rp(42,12.3,0),false,"side stair upper join remains clear",checks)
	probe(rp(0,1.7,-41),rp(0,1.7,-35),false,"rear doorway and new pavement align",checks)
	probe(rp(0,.2,-43),rp(0,-.2,-43),true,"rear pavement support",checks)
	probe(rp(50,1.7,-54),rp(-50,1.7,-54),false,"rear road outside podium no walls or trees",checks)
	probe(rp(45,20,1),rp(39,20,1),true,"campus-facing ribbon facade retains enclosure",checks)
	var route:Array=[]
	for p in [Vector3(9.4,2.24,-829),Vector3(16,2.24,-835),Vector3(23,2.24,-845),Vector3(32,2.24,-858),Vector3(45,2.24,-873),rp(48,0,54),rp(48,0,44),rp(48,5.5,28),rp(48,11.5,4),rp(42,11.5,4),rp(42,11.5,-35.5),rp(0,11.5,-35.5),rp(42,11.5,-35.5),rp(42,11.5,4),rp(48,11.5,4),rp(48,5.5,28),rp(48,0,44),rp(32,0,48),rp(32,0,40),rp(32,0,35),rp(0,0,35),rp(0,0,-37),rp(0,0,-44),rp(0,0,-54),rp(-50,0,-54),rp(50,0,-54),Vector3(156,2.24,-818),Vector3(130,world.builder.height(130,-781),-781)]:route.append([p,"tower side-stair and rear-lane circuit"])
	await fixture(Vector3(9.4,2.54,-805),route)
	var main:Array=[]
	for p in [Vector3(44,2.24,-899),Vector3(62,2.24,-922),rp(0,0,70),rp(0,0,65),rp(0,5.5,49),rp(0,11.5,37),rp(0,11.5,24),rp(0,11.5,3),rp(0,11.5,24),rp(0,11.5,37),rp(0,5.5,49),rp(0,0,65),rp(0,0,70),Vector3(62,2.24,-922),Vector3(44,2.24,-899),Vector3(27,2.24,-893.889)]:main.append([p,"sports approach and showcase stair circuit"])
	await fixture(Vector3(27,2.54,-893.889),main)
	await capture("research-v172-site",Vector3(-123,164,-982),Vector3(102,13,-889))
	await capture("research-v172-tower",Vector3(-8,21,-762),Vector3(106,32,-912))
	await capture("research-v172-front",rp(83,34,105),rp(3,24,8))
	await capture("research-v172-rear",rp(-59,10,-66),rp(8,14,-35))
	FileAccess.open("res://tests/artifacts/research_site_v172.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Relative site relocation, exterior interfaces, side/main stairs and rear lane on foot. Not surveyed grade, elevated tower bridge or vehicle acceptance."},"\t"))
	print("RESEARCH_V172 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
