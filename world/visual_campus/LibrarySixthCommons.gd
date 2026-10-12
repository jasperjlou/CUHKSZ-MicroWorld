extends RefCounted
## V148: official 2025-08 map topology + 2025-09-17 published commons photograph.
## Room envelopes/door sides are schematic; fitout positions and dimensions are fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const S=preload("res://world/visual_campus/LibrarySixthFloor.gd")
const L=preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const Y:=20.8
const YAW:=-.0453849
const WIDTH:=5.4
const DEPTH:=5.2
const HEIGHT:=3.2
const GROUPS:=[[[628,627,626,629,630],876,458,0.0],[[618,617,616,619,620],730,579,PI],[[625,624,623,621,622],1020,540,PI/4],[[615,614,613,611,612],810,802,PI/4],[[610,609,608,606,607],934,884,0.0]]

static func pane(n:Node3D,a:Vector2,b:Vector2)->void:
	var d:=b-a;var h:=K.holder(n,"CommonsGlassPanel",Vector3((a.x+b.x)/2,0,(a.y+b.y)/2));h.rotation.y=-atan2(d.y,d.x)
	K.box(h,Vector3(0,1.35,0),Vector3(d.length(),2.7,.065),"bfcec9",true,19)
	# The photograph shows a dotted pale upper band, thin frames and clear lower panes.
	K.box(h,Vector3(0,2.93,0),Vector3(d.length(),.54,.08),"dbded6",true,50)
	for y in [.07,2.7,3.2]:K.box(h,Vector3(0,y,0),Vector3(d.length()+.02,.04,.09),"a7b0a9",false,11)
	for p in [a,b]:K.box(n,Vector3(p.x,1.6,p.y),Vector3(.045,3.2,.08),"a7b0a9",false,11)
	K.finish(h)

static func frontage(n:Node3D,id:int,x:float,z:float,width:float,side:float)->void:
	var h:=K.holder(n,"CommonsDoor"+str(id),Vector3(x,0,z));h.rotation.y=PI if side<0 else 0
	h.set_meta("room_id",id);h.set_meta("door_approach",Vector3(0,0,1.0))
	for span in [Vector2(-width/2,-.52),Vector2(.52,width/2)]:pane(h,Vector2(span.x,0),Vector2(span.y,0))
	K.box(h,Vector3(0,1.22,0),Vector3(1.0,2.44,.07),"bdcbc7",true,19)
	K.box(h,Vector3(0,2.83,0),Vector3(1.06,.76,.08),"dbded6",true,50)
	for x2 in [-.53,.53]:K.box(h,Vector3(x2,1.25,.04),Vector3(.045,2.5,.07),"9aa69f",false,11)
	K.box(h,Vector3(.39,1.08,.075),Vector3(.026,.34,.03),"697d76",false,11)
	K.box(h,Vector3(.67,1.25,.09),Vector3(.13,.24,.055),"334a49",false,22)
	if id>0:
		var plaque:=K.label(h,str(id),Vector3(0,2.43,.08),.0034);plaque.modulate=Color("3d5050")
		if id in S.GROUP_ROOMS:
			var use_label:=K.label(h,"小组学习室",Vector3(0,2.18,.08),.0019);use_label.modulate=Color("55634f")
	K.finish(h)

static func cluster(n:Node3D,record:Array)->void:
	var h:=K.holder(n,"CommonsSharedCluster"+str(record[0][0]),P.point6(record[1],record[2],Y));h.rotation.y=record[3]+YAW
	h.set_meta("room_ids",record[0]);h.set_meta("shared_partition_count",4)
	# One back-to-back partition, two dividers in the three-room row, one in the pair.
	K.box(h,Vector3(0,HEIGHT/2,0),Vector3(WIDTH,HEIGHT,.12),"d9dcd4",true,22)
	for x in [-WIDTH/6,WIDTH/6]:K.box(h,Vector3(x,HEIGHT/2,-DEPTH/4),Vector3(.12,HEIGHT,DEPTH/2),"d9dcd4",true,22)
	K.box(h,Vector3(0,HEIGHT/2,DEPTH/4),Vector3(.12,HEIGHT,DEPTH/2),"d9dcd4",true,22)
	for side in [-1,1]:pane(h,Vector2(side*WIDTH/2,-DEPTH/2),Vector2(side*WIDTH/2,DEPTH/2))
	for i in 3:frontage(h,record[0][i],(i-1)*WIDTH/3,-DEPTH/2,WIDTH/3,-1)
	for i in 2:frontage(h,record[0][i+3],(i-.5)*WIDTH/2,DEPTH/2,WIDTH/2,1)
	K.box(h,Vector3(0,HEIGHT+.05,0),Vector3(WIDTH+.1,.1,DEPTH+.1),"e0e0d8",false,22)
	K.finish(h)

static func front_row(n:Node3D)->void:
	var h:=K.holder(n,"CommonsFrontSharedRow",P.point6(798,1043,Y));h.rotation.y=PI/4+YAW
	var pitch:=P.point6(753,1088).distance_to(P.point6(783,1058));var width:=pitch*4;var depth:float=2.6
	K.box(h,Vector3(0,1.6,depth/2),Vector3(width,3.2,.12),"d9dcd4",true,22)
	for i in 5:K.box(h,Vector3(-width/2+i*pitch,1.6,0),Vector3(.12,3.2,depth),"d9dcd4",true,22)
	# Map doors face the aisle between the row and the diagonal core, not the facade.
	for i in 4:frontage(h,602+i,(i-1.5)*pitch,-depth/2,pitch,-1)
	K.box(h,Vector3(0,3.25,0),Vector3(width+.1,.1,depth+.1),"e0e0d8",false,22);K.finish(h)
	# The isolated map cell says401 on6F. Build its visible envelope without inventing601.
	# Its door opens along the end of the row, towards602; the NW side borders the void.
	var room:=K.holder(n,"CommonsUnnumberedFrontRoom",P.point6(696,1141,Y));room.rotation.y=-PI/4+YAW
	for side in [-1,1]:K.box(room,Vector3(side*1.4,1.6,0),Vector3(.12,3.2,2.9),"d9dcd4",true,22)
	K.box(room,Vector3(0,1.6,1.45),Vector3(2.8,3.2,.12),"d9dcd4",true,22)
	frontage(room,0,0,-1.45,2.8,-1)
	K.box(room,Vector3(0,3.25,0),Vector3(2.9,.1,3),"e0e0d8",false,22);K.finish(room)

static func swivel_chair(n:Node3D,p:Vector3,yaw:float)->void:
	var h:=K.holder(n,"CommonsMeshChair",p);h.rotation.y=yaw
	K.box(h,Vector3(0,.47,0),Vector3(.49,.08,.48),"687966",false,22)
	K.box(h,Vector3(0,.81,-.24),Vector3(.49,.59,.035),"939a8c",false,51)
	L.cylinder(h,Vector3(0,.24,0),.036,.42,"8d9b98")
	for i in 5:
		var angle:float=i*TAU/5;var v:=Vector3(sin(angle),0,cos(angle))
		K.box(h,v*.16+Vector3.UP*.07,Vector3(.038,.03,.32),"8d9b98",false,11,angle)
		L.cylinder(h,v*.29+Vector3.UP*.035,.045,.045,"45554f")
	for side in [-1,1]:K.box(h,Vector3(side*.3,.65,0),Vector3(.05,.04,.32),"8d9b98",false,11)
	K.finish(h)

static func round_table(n:Node3D,x:float,z:float)->void:
	var h:=K.holder(n,"CommonsRoundTable",P.point6(x,z,Y))
	L.cylinder(h,Vector3(0,.75,0),.65,.065,"b99566",true)
	L.cylinder(h,Vector3(0,.36,0),.055,.72,"a1aba7")
	L.cylinder(h,Vector3(0,.035,0),.36,.05,"a1aba7")
	for i in 3:
		var a:float=i*TAU/3;swivel_chair(h,Vector3(sin(a),0,cos(a))*1.02,PI+a)
	K.finish(h)

static func sofa(n:Node3D,x:float,z:float,yaw:float)->void:
	var h:=K.holder(n,"CommonsBurgundySofa",P.point6(x,z,Y));h.rotation.y=yaw
	K.box(h,Vector3(0,.35,0),Vector3(1.75,.40,.76),"512d32",true,22)
	K.box(h,Vector3(0,.69,-.38),Vector3(1.75,.50,.17),"5d353c",true,22)
	for side in [-1,1]:
		K.box(h,Vector3(side*.84,.58,0),Vector3(.15,.37,.84),"613b40",true,22)
		K.box(h,Vector3(side*.4,.565,.02),Vector3(.72,.05,.62),"663c43",false,22)
	K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibrarySixthCommonsV148")
	for record in GROUPS:cluster(n,record)
	front_row(n)
	for p in [[850,660],[1000,720],[1090,510],[1100,420]]:round_table(n,p[0],p[1])
	sofa(n,1040,795,-PI/2+YAW);sofa(n,1040,755,-PI/2+YAW)
	# Photograph-backed suspended flat ceiling over the occupied right wing only.
	var parts:Array[PackedVector2Array]=[]
	var right:=P.map_polygon([[640,110],[1350,110],[1350,1280],[640,1280]],6)
	for part in P.pieces(6):parts.append_array(Geometry2D.intersect_polygons(part,right))
	K.surface(n,P.floor_vertices(parts,Y+3.45,true),"e0e0d7",22)
	for x in range(700,1200,70):
		for z in range(300,1100,75):
			var p:=P.point6(x,z,Y+3.39);var fits:bool=true
			for offset in [Vector2(-.85,-.08),Vector2(.85,-.08),Vector2(.85,.08),Vector2(-.85,.08)]:
				var inside:bool=false
				for poly in parts:
					if Geometry2D.is_point_in_polygon(Vector2(p.x,p.z)+offset,poly):inside=true;break
				if not inside:fits=false;break
			if fits:K.box(n,p,Vector3(1.65,.025,.09),"f0ede1",false,17,YAW)
	K.finish(n)
