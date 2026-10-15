extends "res://tests/OldLibraryCoresV165.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(op(-25.5,-16,1.2),op(-25.5,-18,1.2),false,"cozy open entry",checks)
	probe(op(-22,-16,1.2),op(-22,-18,1.2),true,"cozy solid partition",checks)
	probe(op(-22.8,-18.7,.6),op(-22.8,-20.3,.6),true,"soft seat body",checks)
	await fixture(op(0,-7,.35),[[op(0,-10),"enter hall"],[op(-3.4,-10),"atrium side approach"],[op(-3.4,-15),"around central stair guard"],[op(-25.5,-15),"front aisle"],[op(-25.5,-18),"cozy doorway"],[op(-25.5,-20.5),"cozy inner aisle"],[op(-25.5,-18),"return inside door"],[op(-25.5,-15),"exit cozy"],[op(-29.1,-15),"core approach"],[op(-29.1,-20.5),"retained core side aisle"],[op(-29.1,-15),"return core aisle"],[op(-3.4,-15),"return hall"],[op(-3.4,-10),"return around stair guard"],[op(0,-10),"return main door"],[op(0,-7),"return court"]])
	await capture("old-library-cozy-v255-hall",op(-16,-12.5,2.0),op(-23,-19.5,1.5))
	await capture("old-library-cozy-v255-inside",op(-25.5,-17.7,1.8),op(-21,-20.2,.6))
	await capture("old-library-cozy-v255-door",op(-27,-13.5,1.8),op(-25.5,-18,1.2))
	await capture("old-library-cozy-v255-street",op(-31.92,31,1.9),op(-31.92,25.2,2.0))
	FileAccess.open("res://tests/artifacts/old_library_cozy_v255.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"physical_legs":legs,"captures":captures,"failures":failures,"scope":"fitted2026 cozy enclosure access/core approach and closed street leaves;not whole floor/current metric registration"},"\t"))
	print("OLD_LIBRARY_COZY_V255 ",legs.size()," legs checks=",checks.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
