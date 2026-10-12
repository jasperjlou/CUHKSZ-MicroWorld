extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(Vector3(118.5,3.17,-340),Vector3(119.5,3.17,-340),false,"round opening is real",checks)
	probe(Vector3(118.5,2.35,-340),Vector3(119.5,2.35,-340),true,"round opening low wall",checks)
	probe(Vector3(118.5,3.17,-345),Vector3(119.5,3.17,-345),true,"screen solid span",checks)
	probe(Vector3(118.5,2.60,-357.9),Vector3(119.5,2.60,-357.9),false,"lattice aperture is real",checks)
	probe(Vector3(118.5,2.60,-357.8),Vector3(119.5,2.60,-357.8),true,"lattice mullion",checks)
	probe(Vector3(63.9,2.9,-350),Vector3(64.8,2.9,-350),true,"mall rail retains dry edge",checks)
	probe(Vector3(90,2.7,-350),Vector3(90,2.0,-350),false,"pond surface has no walking lid",checks)
	var route:Array=[]
	for q in [[75,-365.8],[94,-365.8],[112,-365.8],[124,-365.8],[124,-352],[124,-334],[112,-332.5],[104,-333.0],[95,-334.0],[86,-333.0],[70,-333.0],[61,-333.0],[61,-345],[61,-357],[61,-365.8]]:route.append([Vector3(q[0],2.24,q[1]),"pond perimeter "+str(q)])
	await fixture(Vector3(61,2.55,-365.8),route)
	await capture("pond-v161-screen",Vector3(105,4.15,-346),Vector3(119,3.15,-350))
	await capture("pond-v161-moon",Vector3(115,3.2,-339),Vector3(119,3.17,-340))
	await capture("pond-v161-student-shore",Vector3(62,4.0,-338),Vector3(92,5,-369))
	await capture("pond-v161-mall-rail",Vector3(60.5,4,-341),Vector3(64.4,2.8,-359))
	FileAccess.open("res://tests/artifacts/lotus_pond_edges_v161.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Retained pond perimeter and photo-informed screen/paving; not site survey or whole-campus validation."},"\t"))
	print("LOTUS_POND_EDGES_V161 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
