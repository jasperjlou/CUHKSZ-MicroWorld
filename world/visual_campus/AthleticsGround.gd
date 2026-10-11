extends RefCounted
## V59: standard 400 m model, nine lanes confirmed by school's 2023 opening guide.
## WA dimensions are a modelling basis, not an as-built campus survey/certification.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const HALF_STRAIGHT := 42.195
const INNER := 36.5
const LANE_WIDTH := 1.22
const LANES := 9
const OUTER := INNER+LANES*LANE_WIDTH
const ARC_SEGMENTS := 256

static func oval(radius: float) -> PackedVector3Array:
	var points:=PackedVector3Array()
	for side in [1,-1]:
		for i in ARC_SEGMENTS+1:
			var a: float=-PI/2+PI*i/ARC_SEGMENTS+(PI if side<0 else 0)
			points.append(Vector3(side*HALF_STRAIGHT+cos(a)*radius,0,sin(a)*radius))
	return points

static func band(b: Node3D,outer: float,inner: float,y: float,color: String,kind: int) -> void:
	var a:=oval(outer);var c:=oval(inner);var v:=PackedVector3Array()
	for i in a.size():
		var j: int=(i+1)%a.size()
		v.append_array(K.quad(a[i]+Vector3.UP*y,a[j]+Vector3.UP*y,c[j]+Vector3.UP*y,c[i]+Vector3.UP*y))
	K.surface(b,v,color,kind)

static func line(b: Node3D,a: Vector3,c: Vector3,width: float=.10,color: String="d8dccb") -> void:
	var n: Vector3=(c-a).normalized().cross(Vector3.UP)*width/2
	K.surface(b,K.quad(a+n,c+n,c-n,a-n),color)

static func member(b: Node3D,a: Vector3,c: Vector3,w: float,color: String) -> void:
	var n:=K.holder(b,"FieldMember",(a+c)/2);n.quaternion=Quaternion(Vector3.UP,(c-a).normalized())
	K.box(n,Vector3.ZERO,Vector3(w,a.distance_to(c),w),color,false,11);K.finish(n)

static func perimeter(b: Node3D) -> void:
	# Flat strip/slot drain adjacent to the rubber, followed by stone circulation and fence.
	band(b,OUTER+.65,OUTER,.070,"a5aaa0",26)
	band(b,OUTER+.42,OUTER+.23,.078,"4b5652",11)
	band(b,52.5,OUTER+.65,.060,"969f93",26)
	# The built aerial shows green mesh; four access bays are fitted, not surveyed.
	var points:=oval(53.6)
	var mesh:=PackedVector3Array()
	var guard:=StaticBody3D.new();guard.name="BoundaryFenceCollision";b.add_child(guard)
	for i in points.size():
		var a: Vector3=points[i];var c: Vector3=points[(i+1)%points.size()]
		var d: float=a.distance_to(c);var count:=maxi(1,ceili(d/.8))
		for j in count:
			var p:=a.lerp(c,float(j)/count);var q:=a.lerp(c,float(j+1)/count);var mid: Vector3=(p+q)/2
			var gate: bool=(mid.z>52 and absf(mid.x-14)<4.4) or (absf(mid.x)>94 and absf(mid.z)<4.3) or (mid.z< -52 and absf(mid.x-14)<4.4)
			if gate:continue
			# Collision is a thin box per short panel, not a one-sided triangle.
			var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new()
			shape.size=Vector3(.065,1.7,p.distance_to(q));collider.shape=shape
			collider.position=mid+Vector3.UP*.85;collider.rotation.y=atan2(q.x-p.x,q.z-p.z);guard.add_child(collider)
			for h in [.13,.85,1.7]:
				var strip:=K.quad(p+Vector3.UP*h,q+Vector3.UP*h,q+Vector3.UP*(h+.018),p+Vector3.UP*(h+.018))
				mesh.append_array(strip)
			K.box(b,p+Vector3.UP*.86,Vector3(.035,1.72,.035),"516853",false,11)
	# The solid guard itself is wire-thin and its visual pattern stays light at a distance.
	K.surface(b,mesh,"64785f",11)
	# Clear connectors through actual breaks in the boundary, with fitted gate positions.
	for z in [-55,55]:
		S.paving(b,Vector3(14,.035,z),Vector2(8,14))
		for x in [9.5,18.5]:K.box(b,Vector3(x,1.05,z-signf(z)*1.4),Vector3(.12,2.1,.12),"566954",true,11)
	for x in [-99,99]:S.paving(b,Vector3(x,.035,0),Vector2(13,8))
	# End light towers are outside the enlarged track and pedestrian strip.
	for x in [-66,66]:
		for z in [-54.5,54.5]:
			K.box(b,Vector3(x,10,z),Vector3(.26,20,.26),"aeb8ac",true,11)
			for dx in [-.8,0,.8]:
				for y in [19.5,20.2]:K.box(b,Vector3(x+dx,y,z),Vector3(.55,.42,.28),"d0d5c2",false,11)
	for x in [-65,-45,45,65]:K.bench(b,Vector3(x,0,-59),0)
	# No invented concrete end bleachers: their placement was unsupported by built views.

static func goal(b: Node3D,x: float,side: int) -> void:
	for z in [-3.66,3.66]:K.box(b,Vector3(x,1.22,z),Vector3(.10,2.44,.10),"d8ded0",false,11)
	K.box(b,Vector3(x,2.44,0),Vector3(.10,.10,7.42),"d8ded0",false,11)
	for z in range(-12,13):K.box(b,Vector3(x+side*1.8,1.22,z*.3),Vector3(.012,2.44,.012),"bac4b5",false,11)
	for y in 9:K.box(b,Vector3(x+side*1.8,y*.3,0),Vector3(.012,.012,7.32),"bac4b5",false,11)
	for z in [-3.66,3.66]:member(b,Vector3(x,2.44,z),Vector3(x+side*1.8,0,z),.05,"bcc4b3")

static func build(b: Node3D) -> void:
	# Red surface and ten white boundaries enclose exactly nine lanes.
	band(b,OUTER,INNER,.070,"a34f43",8)
	var points:=oval(INNER);var v:=PackedVector3Array()
	for i in points.size():v.append_array(K.quad(Vector3(0,.052,0),points[i]+Vector3.UP*.052,points[(i+1)%points.size()]+Vector3.UP*.052,Vector3(0,.052,0)))
	K.surface(b,v,"587d45",3)
	for lane in LANES+1:
		var radius: float=INNER+lane*LANE_WIDTH
		band(b,radius+.025,radius-.025,.084,"dadccd",0)
	# Standard full-size pitch model; actual paint/portable 7-a-side layouts remain date-sensitive.
	for z in [-34,34]:line(b,Vector3(-52.5,.092,z),Vector3(52.5,.092,z))
	for x in [-52.5,0,52.5]:line(b,Vector3(x,.092,-34),Vector3(x,.092,34))
	for i in 96:
		var a: float=TAU*i/96;var c: float=TAU*(i+1)/96
		line(b,Vector3(cos(a)*9.15,.092,sin(a)*9.15),Vector3(cos(c)*9.15,.092,sin(c)*9.15))
	for side in [-1,1]:
		for size: Vector2 in [Vector2(5.5,18.32),Vector2(16.5,40.32)]:
			var gx: float=side*52.5;var ex: float=side*(52.5-size.x)
			for z in [-size.y/2,size.y/2]:line(b,Vector3(gx,.092,z),Vector3(ex,.092,z))
			line(b,Vector3(ex,.092,-size.y/2),Vector3(ex,.092,size.y/2))
		goal(b,side*52.5,side)
	# Finish is at the tangent, not an arbitrary location halfway down the straight.
	line(b,Vector3(HALF_STRAIGHT,.096,-OUTER),Vector3(HALF_STRAIGHT,.096,-INNER),.05)
	for lane in LANES:
		var number:=K.label(b,str(lane+1),Vector3(HALF_STRAIGHT-2,.104,-INNER-(lane+.5)*LANE_WIDTH),.010)
		number.rotation.x=-PI/2;number.rotation.z=-PI/2
	perimeter(b)
	# Machine-readable geometry is exported by the same constructor the scene uses.
	b.set_meta("track_geometry",{"straight":HALF_STRAIGHT*2,"inner_radius":INNER,"lane_width":LANE_WIDTH,"lanes":LANES,"outer_radius":OUTER,"lane1_measurement_radius":INNER+.30,"lane1_analytic_length":HALF_STRAIGHT*4+TAU*(INNER+.30),"arc_segments":ARC_SEGMENTS,"surveyed":false})
