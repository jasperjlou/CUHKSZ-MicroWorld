extends "res://tests/CourtyardRefinementCapture.gd"
const G:=2.24
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-corner-plan-v50",Vector3(-15,105,-650),Vector3(72,3,-587))
	await capture("shaw-corner-street-v50",Vector3(28,4.5,-603),Vector3(77,9,-568))
	await capture("shaw-title-stone-v50",Vector3(57,4.6,-593),Vector3(75,6,-571))
	await capture("shaw-to-old-square-v50",Vector3(44,32,-568),Vector3(-4,3,-667))
	var student_route: Array=[]
	for r: Dictionary in world.data.routes:
		if r.id=="student_south_garden":
			for i in r.points.size():
				if i>0 and (i<5 or (i-5)%6==0 or i==r.points.size()-1):
					student_route.append([Vector3(r.points[i][0],G,r.points[i][2]),"student outer walk %d"%i])
	student_route.append_array([[Vector3(-8.1,G,-697),"old square west sidewalk"],[Vector3(-8.1,G,-735),"old library axis"],[Vector3(-78,G,-735),"old library forecourt"]])
	await fixture(Vector3(30,G+.3,-400),student_route)
	await fixture(Vector3(42,G+.3,-571),[[Vector3(44,G,-576),"Shaw corner landing"],[Vector3(56,G,-578),"crossing north landing"],[Vector3(56,G,-594),"Shaw road crossing"],[Vector3(61,G,-597),"Shaw West garden entry"],[Vector3(92,G,-605),"Shaw West approach"],[Vector3(110,G,-620),"West street side"],[Vector3(110,G,-640),"West front turn"],[Vector3(121,G,-640),"West public entrance"]])
	await fixture(Vector3(48,G+.3,-583),[[Vector3(68,G,-586),"new connector west"],[Vector3(88,G,-586),"new connector middle"],[Vector3(104,G,-582),"new connector east bend"],[Vector3(113,G,-575),"library rear junction"],[Vector3(122,G,-558),"library rear road connection"],[Vector3(113,G,-575),"junction return"],[Vector3(110,G,-605),"research service branch"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"V50 continuous student-to-old-library sidewalk, Shaw West crossing/entry, rear-road connector. Route passes do not verify measured placement or building fidelity."}
	FileAccess.open("res://tests/artifacts/shaw_corner_v50.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_CORNER ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
