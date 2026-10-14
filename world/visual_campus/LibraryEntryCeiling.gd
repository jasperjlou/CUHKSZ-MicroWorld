extends RefCounted
## V229: continuous linear ceiling read against the official entry panorama.
## Blade pitch, fascia depth and colour remain fitted; no new walking collision.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")

static func rectangle(x:float,z:float,w:float,d:float)->PackedVector2Array:
	return PackedVector2Array([Vector2(x,z),Vector2(x+w,z),Vector2(x+w,z+d),Vector2(x,z+d)])

static func transformed(poly:PackedVector2Array,pose:Transform3D)->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in poly:
		var q:=pose*Vector3(p.x,0,p.y);result.append(Vector2(q.x,q.z))
	return result

static func prism(poly:PackedVector2Array,low:float,high:float)->PackedVector3Array:
	var vertices:=PackedVector3Array();var ids:=Geometry2D.triangulate_polygon(poly)
	for i in range(0,ids.size(),3):
		var a:=Vector3(poly[ids[i]].x,high,poly[ids[i]].y)
		var b:=Vector3(poly[ids[i+1]].x,high,poly[ids[i+1]].y)
		var c:=Vector3(poly[ids[i+2]].x,high,poly[ids[i+2]].y)
		if (b-a).cross(c-a).y>0:
			var swap:=b;b=c;c=swap
		var down:=Vector3.DOWN*(high-low)
		vertices.append_array(PackedVector3Array([a,b,c,a+down,c+down,b+down]))
	# Polygon winding determines which side of the closed extrusion faces outward.
	var outline:=poly.duplicate()
	if Geometry2D.is_polygon_clockwise(outline):outline.reverse()
	for i in outline.size():
		var p:=outline[i];var q:=outline[(i+1)%outline.size()]
		var a:=Vector3(p.x,low,p.y);var b:=Vector3(q.x,low,q.y)
		var c:=Vector3(q.x,high,q.y);var d:=Vector3(p.x,high,p.y)
		vertices.append_array(PackedVector3Array([a,b,c,a,c,d]))
	return vertices

static func build(parent:Node3D,origin:Vector3,yaw:float,run:float,left:float,right:float)->void:
	var n:=K.holder(parent,"LibraryEntryCeilingV229")
	var pose:=Transform3D(Basis(Vector3.UP,yaw),origin)
	# Use the same exact void as the3F slab. Thin slats are cut as polygons,
	# not by their cell centres, so no slat can protrude into the opening.
	var hole:=transformed(rectangle(left,-.4,right-left,run+.65),pose)
	var core=load("res://world/visual_campus/LibraryDiagonalCore.gd")
	var core_hole:=PackedVector2Array()
	for p in rectangle(core.WELL.position.x-.6,core.WELL.position.y-.6,core.WELL.size.x+1.2,core.WELL.size.y+1.2):
		var q:Vector3=core.point(Vector3(p.x,0,p.y));core_hole.append(Vector2(q.x,q.z))
	var vertices:=PackedVector3Array();var pieces:int=0
	for index in 153:
		var x:float=-15+index*.30
		var parts:Array[PackedVector2Array]=[rectangle(x-.03,-18.47,.06,33.94)]
		parts=Plan.subtract(parts,hole);parts=Plan.subtract(parts,core_hole)
		for part in parts:
			vertices.append_array(prism(part,8.17,8.37));pieces+=1
	var blades:=K.surface(n,vertices,"bebdaf",22)
	blades.name="ClippedContinuousBlades"
	# Four closed fascia strips cover the previously exposed slab edge and blade ends.
	# They stay outside the registered opening and under the existing3F walking slab.
	var rim:=PackedVector3Array()
	for rect in [rectangle(left-.10,-.50,.10,run+.85),rectangle(right,-.50,.10,run+.85),rectangle(left,-.50,right-left,.10),rectangle(left,run+.25,right-left,.10)]:
		rim.append_array(prism(transformed(rect,pose),8.17,8.795))
	K.surface(n,rim,"bfc0b4",22).name="ClosedSlabFascia"
	n.set_meta("blade_fragments",pieces)
	n.set_meta("fit_limits","panorama linear ceiling; pitch .30m and fascia .625m fitted; inherited stair registration")
