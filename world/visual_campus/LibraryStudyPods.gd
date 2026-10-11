extends RefCounted
## Shared four-room islands: public 1F map + recovered level24 geometry + G panorama.
## Footprints/height are fitted; legacy units and capture year remain unregistered.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func strip(b: Node3D,a: Vector2,c: Vector2,y: float,height: float,thickness: float,color: String,kind: int,solid: bool=false) -> void:
	var delta:=c-a
	K.box(b,Vector3((a.x+c.x)/2,y,(a.y+c.y)/2),Vector3(delta.length()+.012,height,thickness),color,solid,kind,-atan2(delta.y,delta.x))

static func panel(b: Node3D,a: Vector2,c: Vector2,posts: bool=true) -> void:
	strip(b,a,c,1.8,3.5,.065,"b7c1b7",19,true)
	# The panorama shows clear glass above/below a broad opaque privacy film.
	strip(b,a,c,1.45,.95,.074,"b9beb2",22)
	for y in [.12,2.87,3.52]:strip(b,a,c,y,.055,.095,"969f94",11)
	strip(b,a,c,3.73,.38,.13,"c6c9bb",16)
	if posts:
		for v in [a,c]:K.box(b,Vector3(v.x,1.79,v.y),Vector3(.047,3.55,.08),"aeb7aa",false,11)

static func build(parent: Node3D,centre: Vector3,width: float,depth: float,first_room: int) -> Node3D:
	var b:=K.holder(parent,"SharedStudyIsland"+str(first_room),centre)
	var hx:=width/2;var hz:=depth/2;var radius:=.85 if width>10 else .60
	var outline:=PackedVector2Array()
	for corner in 4:
		var sign_x:float=1 if corner in [0,3] else -1
		var sign_z:float=1 if corner<2 else -1
		var origin:=Vector2(sign_x*(hx-radius),sign_z*(hz-radius))
		for j in 9:
			var angle:float=(corner*90+j*90.0/8)*PI/180
			outline.append(origin+Vector2(cos(angle),sin(angle))*radius)
	var floor_vertices:=PackedVector3Array()
	for i in outline.size():
		var a:=outline[i];var c:=outline[(i+1)%outline.size()]
		floor_vertices.append_array(K.quad(Vector3(0,.11,0),Vector3(a.x,.11,a.y),Vector3(c.x,.11,c.y),Vector3(0,.11,0)))
	K.surface(b,floor_vertices,"a8a593",25)
	# Shared cross partitions replace the old duplicated returns and gaps.
	K.box(b,Vector3(0,1.81,0),Vector3(.13,3.62,depth),"c9cbbb",true,22)
	K.box(b,Vector3(0,1.81,0),Vector3(width,3.62,.13),"c9cbbb",true,22)
	for side in [-1,1]:
		panel(b,Vector2(side*hx,-hz+radius),Vector2(side*hx,hz-radius))
		# Paired doors beside the shared divider; each clear width is 1.10 m.
		for span in [Vector2(-hx+radius,-1.18),Vector2(1.18,hx-radius)]:
			panel(b,Vector2(span.x,side*hz),Vector2(span.y,side*hz))
		strip(b,Vector2(-1.18,side*hz),Vector2(1.18,side*hz),3.73,.38,.13,"c6c9bb",16)
		for sx in [-1,1]:
			var room:int=first_room+(0 if side<0 else 2)+(0 if sx<0 else 1)
			var door:=K.holder(b,"Door"+str(room),Vector3(sx*.63,0,side*hz))
			door.rotation.y=PI if side<0 else 0
			K.box(door,Vector3(0,3.32,.08),Vector3(.8,.28,.035),"6b7868",false,22)
			K.label(door,str(room),Vector3(0,3.32,.105),.004)
			# Open leaf rests beside the dividing wall, outside the clear doorway.
			K.box(door,Vector3(-sx*side*.51,1.77,-.55),Vector3(.045,3.40,1.03),"b7c1b7",false,19)
			K.box(door,Vector3(-sx*side*.51,1.45,-.55),Vector3(.052,.95,1.03),"b9beb2",false,22)
			K.finish(door)
	for corner in 4:
		for j in 8:panel(b,outline[corner*9+j],outline[corner*9+j+1],false)
		var v:=outline[corner*9+4]
		K.box(b,Vector3(v.x,1.79,v.y),Vector3(.047,3.55,.08),"aeb7aa",false,11)
	K.finish(b)
	return b

static func single(parent:Node3D,p:Vector3,title:String,width:float=3.2,depth:float=3.2,yaw:float=0) -> Node3D:
	var b:=K.holder(parent,"RoundedStudyRoom"+title,p);b.rotation.y=yaw
	var hx:=width/2;var hz:=depth/2;var radius:=.5
	panel(b,Vector2(-hx,-hz+radius),Vector2(-hx,hz-radius))
	panel(b,Vector2(hx,-hz+radius),Vector2(hx,hz-radius))
	panel(b,Vector2(-hx+radius,-hz),Vector2(hx-radius,-hz))
	for span:Vector2 in [Vector2(-hx+radius,-.7),Vector2(.7,hx-radius)]:panel(b,Vector2(span.x,hz),Vector2(span.y,hz))
	for corner in 4:
		var centre:=Vector2((1 if corner in [0,3] else -1)*(hx-radius),(1 if corner<2 else -1)*(hz-radius))
		for j in 8:
			var angle:float=(corner*90+j*90.0/8)*PI/180
			panel(b,centre+Vector2(cos(angle),sin(angle))*radius,centre+Vector2(cos(angle+PI/16),sin(angle+PI/16))*radius,false)
	K.box(b,Vector3(0,3.73,hz),Vector3(1.4,.38,.13),"c6c9bb",false,16)
	K.box(b,Vector3(0,3.28,hz+.065),Vector3(.85,.3,.035),"65745f",false,22)
	K.label(b,title,Vector3(0,3.28,hz+.09),.004)
	K.box(b,Vector3(.64,1.72,hz-.52),Vector3(.045,3.35,1.0),"b7c1b7",false,19)
	K.box(b,Vector3(.64,1.45,hz-.52),Vector3(.05,.95,1.0),"b9beb2",false,22)
	K.finish(b)
	return b
