extends "res://tests/LibraryGroundStairV103Capture.gd"
const Floor241=preload("res://world/visual_campus/LibraryLowerFloor.gd")
func area(poly:PackedVector2Array)->float:
	var a:float=0
	for i in poly.size():a+=poly[i].cross(poly[(i+1)%poly.size()])
	return absf(a)*.5
func bounds(poly:PackedVector2Array)->Rect2:
	var box:=Rect2(poly[0],Vector2.ZERO)
	for p in poly:box=box.expand(p)
	return box
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(30)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var pieces:=Floor241.pieces();var boxes:Array[Rect2]=[];var overlaps:Array=[];var wood_overlaps:Array=[]
	for p in pieces:boxes.append(bounds(p))
	for i in pieces.size():
		for j in range(i+1,pieces.size()):
			if not boxes[i].intersects(boxes[j]):continue
			for poly in Geometry2D.intersect_polygons(pieces[i],pieces[j]):
				if area(poly)>.0001:overlaps.append({"a":i,"b":j,"area":area(poly)})
		for wood in Floor241.timber_rooms():
			if not boxes[i].intersects(bounds(wood)):continue
			for poly in Geometry2D.intersect_polygons(pieces[i],wood):
				if area(poly)>.0001:wood_overlaps.append(area(poly))
	if not overlaps.is_empty():failures.append("overlapping public finish pieces")
	if not wood_overlaps.is_empty():failures.append("carpet crosses timber room boundary")
	await capture("library-floor-v241-west",wp(-20.4,1.8,-7),wp(-32,.8,-9))
	await capture("library-floor-v241-pod",wp(-26.85,1.6,3.3),wp(-26.85,.2,.8))
	await capture("library-floor-v241-single",wp(-14.7,1.6,-7),wp(-14.7,.35,-10.4))
	await capture("library-floor-v241-arrival",wp(-16.5,1.8,10),wp(-21.8,.3,8.9))
	await capture("library-floor-v241-right",wp(28.9,1.8,-6.1),wp(32,.3,-2))
	FileAccess.open("res://tests/artifacts/library_lower_floor_v241.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"fragments":pieces.size(),"public_overlaps":overlaps,"timber_overlaps":wood_overlaps,"scope":"Visual-only public carpet union and5timber room exclusions;3single-room floors added;unchanged collision,no new route acceptance"},"\t"))
	print("LIBRARY_FLOOR_V241 fragments=",pieces.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
