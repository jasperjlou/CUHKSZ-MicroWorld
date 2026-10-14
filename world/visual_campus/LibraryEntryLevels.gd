extends RefCounted
## Official 1F/2F/3F plans distinguish the outdoor entry stair from the indoor seating stair.
## Local anchors and metre dimensions remain fitted to the retained shell.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
# V228:3F public-map walk-strip centre (980,669)->(1104,552), registered
# through LibraryLowerFrontPlan.point3. Schematic metres, not a survey.
const ORIGIN := Vector3(5.3172043,4.4,2.6400422)
const YAW := 2.2682352
const RUN := 9.5022884
const VOID_LEFT := -1.40
const VOID_RIGHT := 7.90
static func outside_strips()->Array[Rect2]:
	return [Rect2(-100,-100,100+VOID_LEFT,200),Rect2(VOID_RIGHT,-100,100,200),Rect2(VOID_LEFT,-100,VOID_RIGHT-VOID_LEFT,99.6),Rect2(VOID_LEFT,RUN+.25,VOID_RIGHT-VOID_LEFT,100)]

static func horizontal(p: Vector3) -> Vector3:
	return ORIGIN+Basis(Vector3.UP,YAW)*p

static func rail(b: Node3D,a: Vector3,c: Vector3) -> void:
	var delta:=c-a
	for i in 10:
		K.box(b,a.lerp(c,i/9.0)+Vector3.UP*.55,Vector3(.055,1.1,.055),"728078",false,11)
	var n:=K.holder(b,"SlopingLibraryRail",(a+c)/2+Vector3.UP*1.08)
	n.rotation.x=-atan2(delta.y,delta.z)
	K.box(n,Vector3.ZERO,Vector3(.08,.08,delta.length()),"a5916d",false,11);K.finish(n)

static func flight(n: Node3D,length: float,rise: float,width: float,wood_finish:bool=false) -> void:
	for i in 28:
		var z: float=(i+.5)*length/28;var y: float=(i+1)*rise/28
		K.box(n,Vector3(0,y-.07,z),Vector3(width,.14,length/28+.02),"c2a271" if wood_finish else "d3cfbd",false,43 if wood_finish else 70)
		K.box(n,Vector3(0,y-.15,z-length/56),Vector3(width,.16,.06),"bc9561" if wood_finish else "cbc8b9",false,43 if wood_finish else 70)
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
	for rect: Rect2 in outside_strips():
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
	# Both side walking strips and the central seating tiers appear in2F/3F maps.
	for x in [0.0,6.6]:
		var walk:=K.holder(hall,"PublicSideFlight",Vector3(x,0,0));flight(walk,RUN,4.4,2.2);K.finish(walk)
	for i in 8:
		var h:float=(i+1)*.55
		K.box(hall,Vector3(3.3,h-.14,(i+.5)*RUN/8),Vector3(4.2,.28,RUN/8),"d3cfbd",true,70)
		# Narrow pale front strip is visible in the official stair photograph; width fitted.
		K.box(hall,Vector3(3.3,h+.003,i*RUN/8+.06),Vector3(4.2,.006,.10),"d7c89e",false,22)
		# Close the visible tier riser while retaining hollow space below the slope.
		K.box(hall,Vector3(3.3,h-.275,i*RUN/8+.025),Vector3(4.2,.55,.05),"ccc9bb",true,70)
	var soffit:=K.quad(Vector3(1.2,-.32,0),Vector3(5.4,-.32,0),Vector3(5.4,4.08,RUN),Vector3(1.2,4.08,RUN));var underside:=PackedVector3Array()
	for i in range(0,soffit.size(),3):underside.append_array(PackedVector3Array([soffit[i],soffit[i+2],soffit[i+1]]))
	K.surface(hall,underside,"bebcaf",22,true)
	K.box(hall,Vector3(3.25,4.275,RUN+.55),Vector3(9.3,.25,1.10),"d3cfbd",true,70)
	for x in [VOID_LEFT,VOID_RIGHT]:
		K.box(hall,Vector3(x,4.92,RUN/2),Vector3(.10,1.04,RUN),"a9b8ac",true,19)
		K.box(hall,Vector3(x,5.47,RUN/2),Vector3(.10,.08,RUN),"718276",false,11)
	K.box(hall,Vector3(3.25,4.92,-.4),Vector3(9.3,1.04,.10),"a9b8ac",true,19)
	K.box(hall,Vector3(3.25,5.47,-.4),Vector3(9.3,.08,.10),"718276",false,11)
	K.finish(hall)
	preload("res://world/visual_campus/LibraryEntryCeiling.gd").build(b,ORIGIN,YAW,RUN,VOID_LEFT,VOID_RIGHT)
	for x in [-10,23]:
		for z in [-12,-4,6]:K.box(b,Vector3(x,8.13,z),Vector3(.13,.04,2.0),"e3e0ce",false,17)
	K.finish(b)
