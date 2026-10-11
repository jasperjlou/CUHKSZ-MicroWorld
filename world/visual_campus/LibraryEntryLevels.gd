extends RefCounted
## Official 1F/2F/3F plans distinguish the outdoor entry stair from the indoor seating stair.
## Local anchors and metre dimensions remain fitted to the retained shell.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const ORIGIN := Vector3(0,4.4,9)
const YAW := PI*.75
const RUN := 14.142136

static func horizontal(p: Vector3) -> Vector3:
	return ORIGIN+Basis(Vector3.UP,YAW)*p

static func rail(b: Node3D,a: Vector3,c: Vector3) -> void:
	var delta:=c-a
	for i in 10:
		K.box(b,a.lerp(c,i/9.0)+Vector3.UP*.55,Vector3(.055,1.1,.055),"728078",false,11)
	var n:=K.holder(b,"SlopingLibraryRail",(a+c)/2+Vector3.UP*1.08)
	n.rotation.x=-atan2(delta.y,delta.z)
	K.box(n,Vector3.ZERO,Vector3(.08,.08,delta.length()),"a5916d",false,11);K.finish(n)

static func flight(n: Node3D,length: float,rise: float,width: float) -> void:
	for i in 28:
		var z: float=(i+.5)*length/28;var y: float=(i+1)*rise/28
		K.box(n,Vector3(0,y-.07,z),Vector3(width,.14,length/28+.02),"bdbcae",false,12)
		K.box(n,Vector3(0,y-.15,z-length/56),Vector3(width,.16,.06),"b5b5a7",false,12)
	var a:=Vector3(0,0,0);var c:=Vector3(0,rise,length)
	var ramp:=K.surface(n,K.quad(a-Vector3.RIGHT*width/2,a+Vector3.RIGHT*width/2,c+Vector3.RIGHT*width/2,c-Vector3.RIGHT*width/2),"bdbcae",12,true);ramp.visible=false
	var v:=K.quad(a+Vector3(-width/2,-.32,0),a+Vector3(width/2,-.32,0),c+Vector3(width/2,-.32,0),c+Vector3(-width/2,-.32,0));var down:=PackedVector3Array()
	for i in range(0,v.size(),3):down.append_array(PackedVector3Array([v[i],v[i+2],v[i+1]]))
	K.surface(n,down,"b8b9ac",22,true)
	for x in [-width/2-.15,width/2+.15]:rail(n,Vector3(x,0,0),Vector3(x,rise,length))

static func third_floor(b: Node3D,p: PackedVector2Array) -> void:
	# Split the slab in stair coordinates, leaving the whole diagonal walking/seating void clear.
	var inverse:=Basis(Vector3.UP,-YAW);var local:=PackedVector2Array()
	for q in p:
		var t: Vector3=inverse*(Vector3(q.x,4.4,q.y)-ORIGIN);local.append(Vector2(t.x,t.z))
	for rect: Rect2 in [Rect2(-100,-100,97.1,200),Rect2(12.0,-100,100,200),Rect2(-2.9,-100,14.9,99.6),Rect2(-2.9,RUN+.25,14.9,100)]:
		var poly:=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
		for part: PackedVector2Array in Geometry2D.intersect_polygons(local,poly):
			var building_part:=PackedVector2Array()
			for point in part:
				var transformed:=horizontal(Vector3(point.x,0,point.y));building_part.append(Vector2(transformed.x,transformed.z))
			for fragment: PackedVector2Array in preload("res://world/visual_campus/LibraryServiceCores.gd").cut_openings(building_part):
				var ids:=Geometry2D.triangulate_polygon(fragment);var up:=PackedVector3Array();var down:=PackedVector3Array()
				for j in range(0,ids.size(),3):
					var tri: Array[Vector3]=[]
					for k in 3:
						var q:=fragment[ids[j+k]];tri.append(Vector3(q.x,8.8,q.y))
					if (tri[1]-tri[0]).cross(tri[2]-tri[0]).y>0:tri.reverse()
					up.append_array(PackedVector3Array(tri))
					down.append_array(PackedVector3Array([tri[0]-Vector3.UP*.28,tri[2]-Vector3.UP*.28,tri[1]-Vector3.UP*.28]))
				K.surface(b,up,"b6b4a7",12,true);K.surface(b,down,"b8b9ac",22)

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"LibraryRegisteredEntryLevels")
	# V117 independently oriented exterior approach owns the short main stair and forecourt.
	preload("res://world/visual_campus/LibraryEntryApproach.gd").build(b)
	# The panorama's broad seating tiers belong in the 2F hall, beside the ascent to 3F.
	var hall:=K.holder(b,"LibrarySecondToThirdPublicStair",ORIGIN);hall.rotation.y=YAW
	flight(hall,RUN,4.4,4.6)
	for i in 8:
		var h: float=(i+1)*.55
		K.box(hall,Vector3(7.2,h-.14,(i+.5)*RUN/8),Vector3(8.2,.28,RUN/8),"bcb9ab",true,12)
	# Hollow inclined seating structure preserves headroom above the lower public stair.
	var soffit:=K.quad(Vector3(3.1,-.32,0),Vector3(11.3,-.32,0),Vector3(11.3,4.08,RUN),Vector3(3.1,4.08,RUN));var underside:=PackedVector3Array()
	for i in range(0,soffit.size(),3):underside.append_array(PackedVector3Array([soffit[i],soffit[i+2],soffit[i+1]]))
	K.surface(hall,underside,"bebcaf",22,true)
	for x in [2.65,11.55]:rail(hall,Vector3(x,0,0),Vector3(x,4.4,RUN))
	for i in [1,4,6]:K.planter(hall,Vector3(3.6,(i+1)*.55,(i+.5)*RUN/8))
	K.box(hall,Vector3(4.4,4.275,RUN+.9),Vector3(15,.25,1.8),"bcb9ab",true,12)
	# Side guards protect the 3F void without putting a cross-rail over either stair mouth.
	for x in [-2.9,12.0]:
		K.box(hall,Vector3(x,4.92,RUN/2),Vector3(.12,1.04,RUN),"a9b8ac",true,19)
		K.box(hall,Vector3(x,5.47,RUN/2),Vector3(.12,.08,RUN),"718276",false,11)
	K.finish(hall)
	# Dense ceiling blades stop at the diagonal void, rather than cutting across its stairs.
	var inverse:=Basis(Vector3.UP,-YAW)
	for x in range(-15,31):
		for z in range(-18,16):
			var q:=inverse*(Vector3(x,4.4,z)-ORIGIN)
			if q.x>-3.15 and q.x<12.25 and q.z>-.7 and q.z<RUN+.5:continue
			var core=preload("res://world/visual_campus/LibraryDiagonalCore.gd")
			var cq=core.inverse_point(Vector3(x,0,z))
			if core.WELL.grow(.6).has_point(Vector2(cq.x,cq.z)):continue
			for sub in 3:K.box(b,Vector3(x+sub*.30,8.27,z),Vector3(.06,.20,.94),"bebdaf",false,22)
	for x in [-10,23]:
		for z in [-12,-4,6]:K.box(b,Vector3(x,8.13,z),Vector3(.13,.04,2.0),"e3e0ce",false,17)
	K.finish(b)
