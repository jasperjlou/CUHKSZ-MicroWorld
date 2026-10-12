extends RefCounted
## Shared V187 dry apron mask. Keeps local and world finishes from drawing twice.
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")

static func outer_strip()->PackedVector2Array:
	var poly:=P.ground_front().duplicate();var front:=P.front3()
	for i in range(10,3,-1):poly.append(front[i])
	poly.append_array(PackedVector2Array([Vector2(-36,21.4),Vector2(-36,12),Vector2(-40.5,12),Vector2(-40.5,5)]))
	return poly

static func areas()->Array[PackedVector2Array]:
	# Union the old V115 apron, V120 strip and side return before drawing the finish.
	# Their former coplanar surfaces overlapped and could alternate colours in motion.
	var apron:=P.ground_front().duplicate()
	apron.append(Vector2(apron[-1].x,30));apron.append(Vector2(apron[0].x,30))
	var areas:Array[PackedVector2Array]=[outer_strip()]
	for addition in [apron,PackedVector2Array([Vector2(-43,12),Vector2(-32.2,12),Vector2(-32.2,24),Vector2(-43,24)])]:
		var joined:=Geometry2D.merge_polygons(areas[0],addition)
		if joined.size()==1:areas[0]=joined[0]
		else:areas.append(addition)
	return areas

static func world_areas()->Array[PackedVector2Array]:
	var result:Array[PackedVector2Array]=[]
	for polygon in areas():
		var points:=PackedVector2Array()
		for p in polygon:points.append(Vector2(78-p.y,-290+p.x))
		result.append(points)
	return result
