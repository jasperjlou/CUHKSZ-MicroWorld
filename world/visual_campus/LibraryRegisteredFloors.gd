extends RefCounted
## Continuous lower/2F wing surfaces share the same plan outline as the upper shell.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"LibraryRegisteredLowerFloors");var outline:=P.outline(r.width,r.depth)
	
	for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(outline):P.sheet(n,dry,.012,"b9b4a4",12)
	var plan=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
	# V116: whole independently registered2F footprint, including the right exhibition tip.
	var polygons:Array[PackedVector2Array]=Geometry2D.merge_polygons(plan.second_outline(),preload("res://world/visual_campus/LibraryEntryPavilion.gd").exhibition_outline())
	# Retain the verified external gallery to the central courtyard and union it with the wing.
	for rect: Rect2 in [Rect2(-39.8,-11,6,33),Rect2(-43.3,11.5,9,11),Rect2(-43,-12.2,31,4.4)]:
		var candidate:=Core.rect_poly(rect);var merged:=false
		for i in polygons.size():
			var joined:=Geometry2D.merge_polygons(polygons[i],candidate)
			if joined.size()==1:polygons[i]=joined[0];merged=true;break
		if not merged:polygons.append(candidate)
	for polygon in polygons:
		# V103 replace the old straight slot with the diagonal lower public stair opening.
		for part:PackedVector2Array in preload("res://world/visual_campus/LibraryGroundStair.gd").cut_opening(polygon):
			for fragment: PackedVector2Array in Core.cut_openings(part):
				for exterior_piece:PackedVector2Array in preload("res://world/visual_campus/LibraryEntryApproach.gd").cut_upper_floor(fragment):
					P.sheet(n,exterior_piece,4.4,"b8b9ad",12,true)
					P.sheet(n,exterior_piece,4.12,"b8b9ad",22,false,false,86,58,true)
	# Official built frontage shows a hard forecourt, not lawn between the fins and mall.
	for i in 72:
		var x0: float=-36+i;var x1: float=x0+1
		if x0>=-36 and x1<=-22:continue # V48: reflecting water, not a stone apron.
		var z0: float=P.front(x0,r.width,r.depth);var z1: float=P.front(x1,r.width,r.depth)
		var apron:=PackedVector2Array([Vector2(x0,z0),Vector2(x1,z1),Vector2(x1,36),Vector2(x0,36)])
		for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(apron):P.sheet(n,dry,.135,"a5a89f",26)
	var border:=PackedVector2Array([Vector2(-22,35.49),Vector2(36,35.49),Vector2(36,35.71),Vector2(-22,35.71)])
	for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(border):P.sheet(n,dry,.16,"69746a",11)
	K.finish(n)
