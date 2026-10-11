extends RefCounted
## Built room identity/finishes from school facility photos; exact plan and roof levels fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const A := preload("res://world/visual_campus/AthleticsGround.gd")
const I := preload("res://world/visual_campus/SportsPublicInterior.gd")
const L := preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const SECTION := preload("res://world/visual_campus/SportsSection.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const Y := 9.2
const CENTRES := [-55.0,-46.0,-37.0,-28.0,-19.0,-10.0]

static func line(b: Node3D,a: Vector3,c: Vector3,w: float=.04) -> void:
	A.line(b,a,c,w,"e7e9d9")

static func net(b: Node3D,x: float,z: float,low: bool) -> void:
	var height: float=.914 if low else 1.55
	var sag: float=.05 if low else .026
	var bottom: float=.10 if low else .79
	for dx in [-3.18,3.18]:
		K.box(b,Vector3(x+dx,Y+height/2,z),Vector3(.045,height,.045),"c0c6c2" if low else "486394",true,11)
		K.box(b,Vector3(x+dx,Y+.07,z),Vector3(.27,.13,.7),"525f69" if low else "486394",true,11)
	# Real fine net strands leave visual holes. A thin invisible box supplies two-sided collision.
	var body:=StaticBody3D.new();body.name="CourtNetCollision";b.add_child(body)
	var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(6.36,height-bottom,.035)
	collision.shape=shape;collision.position=Vector3(x,Y+(height+bottom)/2,z);body.add_child(collision)
	for i in 80:
		var px: float=x-3.18+i*6.36/79
		var top: float=height-sag*(1-pow((px-x)/3.18,2))
		K.box(b,Vector3(px,Y+(bottom+top)/2,z),Vector3(.005,top-bottom,.005),"b2c0b3" if low else "9eada6",false,22)
	for row in 9:
		var h: float=bottom+(height-bottom)*row/8
		A.member(b,Vector3(x-3.18,Y+h,z),Vector3(x,Y+h-sag,z),.007,"adbab2")
		A.member(b,Vector3(x,Y+h-sag,z),Vector3(x+3.18,Y+h,z),.007,"adbab2")
	A.member(b,Vector3(x-3.18,Y+height,z),Vector3(x,Y+height-sag,z),.03,"e1e3d7")
	A.member(b,Vector3(x,Y+height-sag,z),Vector3(x+3.18,Y+height,z),.03,"e1e3d7")

static func court(b: Node3D,x: float,pickle: bool=false) -> void:
	var centre:=Vector3(x,Y+.075,-2)
	var half_length: float=6.705 if pickle else 6.7
	var width: float=.0508 if pickle else .04
	for dx in [-3.05,3.05]:line(b,centre+Vector3(dx,0,-half_length),centre+Vector3(dx,0,half_length),width)
	for z in [-half_length,half_length]:line(b,centre+Vector3(-3.05,0,z),centre+Vector3(3.05,0,z),width)
	var service: float=2.1336 if pickle else 1.98
	for z in [-service,service]:line(b,centre+Vector3(-3.05,0,z),centre+Vector3(3.05,0,z),width)
	for sign_value in [-1,1]:line(b,centre+Vector3(0,0,sign_value*service),centre+Vector3(0,0,sign_value*half_length),width)
	if not pickle:
		for dx in [-2.59,2.59]:line(b,centre+Vector3(dx,0,-half_length),centre+Vector3(dx,0,half_length),width)
		for z in [-5.94,5.94]:line(b,centre+Vector3(-3.05,0,z),centre+Vector3(3.05,0,z),width)
	net(b,x,-2,pickle)

static func wall(b: Node3D,a: float,c: float,z: float,color: String) -> void:
	# Low coloured wall band and darker upper acoustic wall are visible through outer glazing.
	K.box(b,Vector3((a+c)/2,Y+1.51,z),Vector3(c-a,3.02,.18),color,true,22)
	upper_wall(b,a,c,z,Y+3)
	K.box(b,Vector3((a+c)/2,Y+.10,z-.11),Vector3(c-a,.18,.045),"38484b",false,22)

static func upper_wall(b: Node3D,a: float,c: float,z: float,base: float) -> void:
	for span: Vector2 in [Vector2(a,minf(c,5)),Vector2(maxf(a,5),minf(c,22)),Vector2(maxf(a,22),c)]:
		if span.y<=span.x:continue
		var p:=Vector3(span.x,base,z);var q:=Vector3(span.y,base,z)
		var r:=Vector3(span.y,SECTION.roof_height(span.y)-.25,z);var s:=Vector3(span.x,SECTION.roof_height(span.x)-.25,z)
		K.surface(b,PackedVector3Array([p,q,r,p,r,s,r,q,p,s,r,p]),"556e76",22,true)

static func side_wall(b: Node3D,x: float,color: String,glazed: bool=false,clerestory: bool=false) -> void:
	var top: float=SECTION.roof_height(x)-.4
	if glazed:
		C.glazing(b,Vector3(x,(Y+top)/2,-2),20,top-Y,PI/2)
		return
	var wall_top: float=top-1.5 if clerestory else top
	K.box(b,Vector3(x,(Y+wall_top)/2,-2),Vector3(.18,wall_top-Y,20),"546d76",true,22)
	if clerestory:C.glazing(b,Vector3(x,top-.75,-2),20,1.5,PI/2)
	K.box(b,Vector3(x+.12,Y+1.48,-2),Vector3(.045,2.96,19.9),color,false,22)
	K.box(b,Vector3(x-.12,Y+1.48,-2),Vector3(.045,2.96,19.9),color,false,22)

static func services(b: Node3D,a: float,c: float) -> void:
	# Exposed cross beams, purlins and foil-clad ducts follow the newly registered sloping roof.
	for x in range(ceili(a)+2,int(c),9):
		var top: float=SECTION.roof_height(x)
		K.box(b,Vector3(x,top-.66,-2),Vector3(.20,.68,20),"4e6970",true,11)
		for z in [-11.5,7.4]:
			K.box(b,Vector3(x,(Y+top-.7)/2,z),Vector3(.55,top-Y-.7,.55),"738b8b",true,22)
		K.box(b,Vector3(x,top-1.18,-2),Vector3(.65,.52,19),"b4c5bd",true,11)
		for z in range(-11,8,2):K.box(b,Vector3(x,top-1.18,z),Vector3(.68,.56,.045),"7c9996",false,11)
		for z in [-10,6]:
			K.box(b,Vector3(x,Y+4.8,z),Vector3(.62,.7,.62),"8eaaa9",false,11)
			var lower: float=Y+5.1;var upper: float=top-1.18
			K.box(b,Vector3(x,(lower+upper)/2,z),Vector3(.55,upper-lower,.55),"becbc0",false,11)
		for z in [-7,3]:
			A.member(b,Vector3(x-2,top-.6,z),Vector3(x-2,top-1.65,z),.035,"3d5056")
			L.cylinder(b,Vector3(x-2,top-1.7,z),.26,.12,"a7b6af")
			K.box(b,Vector3(x-2,top-1.77,z),Vector3(.35,.025,.35),"edf1dd",false,17)
			I.lamp(b,Vector3(x-2,top-1.9,z),11)
	for z in range(-11,9,3):
		for span: Vector2 in [Vector2(a,minf(c,5)),Vector2(maxf(a,5),minf(c,22)),Vector2(maxf(a,22),c)]:
			if span.y<=span.x:continue
			A.member(b,Vector3(span.x,SECTION.roof_height(span.x)-.35,z),Vector3(span.y,SECTION.roof_height(span.y)-.35,z),.12,"4f6e77")
	for z in [-9.2,5.2]:
		A.member(b,Vector3(a,Y+6.55,z),Vector3(c,Y+6.55,z),.055,"9d5645")

static func build(b: Node3D) -> void:
	# Source programme: six-court badminton hall plus separate two-court sports room.
	K.box(b,Vector3(-32.5,Y+.037,-2),Vector3(55,.06,20),"339d7e",false,22)
	K.box(b,Vector3(19.5,Y+.037,-2),Vector3(21,.06,20),"35967e",false,22)
	wall(b,-60,-5,-12,"c6bd3e")
	wall(b,9,30,-12,"8bb7c3")
	for x in [-60,-5]:side_wall(b,x,"c6bd3e")
	side_wall(b,9,"8bb7c3",false,true);side_wall(b,30,"8bb7c3",true)
	I.doorway(b,-60,-5,-33,8,Y,6.8,3,"c2bd53")
	I.doorway(b,9,30,17,8,Y,7.2,3,"8fb9c3")
	# Upper wall infill follows each roof slope; no gap above the high room portals.
	for span: Vector2 in [Vector2(-60,-5),Vector2(9,30)]:
		var base: float=Y+(6.8 if span.x<0 else 7.2)
		upper_wall(b,span.x,span.y,8,base)
	for x in CENTRES:court(b,x)
	for x in [14.5,24.5]:court(b,x,true)
	services(b,-60,-5);services(b,9,30)
	# Padded intermediate columns occupy the gaps between courts, not their playing lines.
	for x in [-50.5,-32.5,-14.5,19.5]:
		var top: float=SECTION.roof_height(x)-.8
		K.box(b,Vector3(x,(Y+top)/2,-2),Vector3(.62,top-Y,.62),"738a88",true,22)
		K.box(b,Vector3(x,Y+1.25,-2),Vector3(.74,2.5,.74),"7b8d87",true,22)
	# Main court sequence is fitted. The separate room's 9/10 wall numerals are visible in its photo.
	for i in CENTRES.size():
		var sign:=K.label(b,str(i+1),Vector3(CENTRES[i],Y+1.8,-11.85),.031);sign.modulate=Color("e2e4cb")
	for i in 2:
		var sign:=K.label(b,str(9+i),Vector3(14.5+i*10,Y+1.8,-11.85),.031);sign.modulate=Color("d4dfd7")
	# Folded acoustic curtains are kept against the wall, clear of court run-off areas.
	for x in [-46,-19]:
		K.box(b,Vector3(x,Y+3,-11.86),Vector3(4.9,5.7,.035),"596f80",false,22)
		for i in 24:K.box(b,Vector3(x-2.4+i*.2,Y+3.0,-11.72+sin(i*PI/2)*.10),Vector3(.2,5.7,.08),"596f80",false,22)
	# Continuous upper lobby links the existing stair landing and both rooms.
	K.box(b,Vector3(-8.5,Y+.022,11.7),Vector3(105,.035,7.35),"9aa6a3",false,29)
	for x in [-33,17]:
		var sign:=K.label(b,"羽毛球馆" if x<0 else "体育运动室",Vector3(x,Y+3.05,8.15),.008);sign.modulate=Color("e5e5ce")
	K.box(b,Vector3(1,Y+.58,4),Vector3(5.3,1.16,1.1),"c8d0c7",true,22)
	K.box(b,Vector3(1,Y+1.18,4),Vector3(5.4,.07,1.2),"e3e4d3",false,22)
	for x in [-56,-43,-24,0,26]:
		for dx in [-.7,0,.7]:I.chair(b,Vector3(x+dx,Y,14.2),PI,"7f949b")
		I.lamp(b,Vector3(x,Y+4.8,11.5),12)
	b.set_meta("upper_sports",{"badminton_courts":6,"multipurpose_courts":2,"floor":Y,"roof_min":17.0,"roof_max":21.5,"room_sequence_surveyed":false,"references":"school current facility photos; capture date unknown"})
