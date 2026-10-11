extends RefCounted
## V60: public details from school's 2023 guide/current facility photos.
## Room sequence and metric plan are fitted, not an as-built floor plan.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const L := preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const A := preload("res://world/visual_campus/AthleticsGround.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const Y := 4.8

static func lamp(b: Node3D,p: Vector3,reach: float=12.0) -> void:
	var light:=OmniLight3D.new();light.position=p;light.omni_range=reach
	light.light_color=Color("f1f0e7");light.light_energy=.55;light.shadow_enabled=false;b.add_child(light)

static func doorway(b: Node3D,lo: float,hi: float,x: float,z: float,y: float,h: float,width: float=2.8,color: String="d8dcd5") -> void:
	for ends: Vector2 in [Vector2(lo,x-width/2),Vector2(x+width/2,hi)]:
		K.box(b,Vector3((ends.x+ends.y)/2,y+h/2,z),Vector3(ends.y-ends.x,h,.20),color,true,22)
	K.box(b,Vector3(x,y+(2.8+h)/2,z),Vector3(width,h-2.8,.20),color,true,22)
	for dx in [-width/2,width/2]:K.box(b,Vector3(x+dx,y+1.4,z),Vector3(.09,2.8,.26),"8f7952",false,11)
	K.box(b,Vector3(x,y+2.8,z),Vector3(width+.1,.09,.26),"8f7952",false,11)

static func slats(b: Node3D,center: Vector3,size: Vector2) -> void:
	K.box(b,center+Vector3.UP*.13,Vector3(size.x,.05,size.y),"333937",false,22)
	for i in ceili(size.x/.48):
		K.box(b,center+Vector3(-size.x/2+i*.48,0,0),Vector3(.15,.18,size.y),"ad9765",false,22)
	for x in range(0,int(size.x),6):
		K.box(b,center+Vector3(-size.x/2+x,-.13,0),Vector3(1.2,.04,.22),"f1f0d9",false,17)

static func chair(b: Node3D,p: Vector3,yaw: float=0,color: String="718b99") -> void:
	var n:=K.holder(b,"PublicChair",p);n.rotation.y=yaw
	K.box(n,Vector3(0,.46,0),Vector3(.48,.08,.48),color,true,22)
	K.box(n,Vector3(0,.74,.22),Vector3(.48,.5,.065),color,false,22)
	for x in [-.19,.19]:
		for z in [-.19,.19]:K.box(n,Vector3(x,.22,z),Vector3(.035,.44,.035),"41484b",false,11)
	K.finish(n)

static func lockers(b: Node3D,p: Vector3,count: int=6) -> void:
	K.box(b,p+Vector3(0,1,0),Vector3(count*.42,2,.52),"c3caca",true,22)
	for i in count:
		for row in 4:
			var q:=p+Vector3((i-(count-1)*.5)*.42,.28+row*.48,.27)
			K.box(b,q,Vector3(.39,.45,.035),"659bb5" if row%2==1 else "bdc7c8",false,11)
			K.box(b,q+Vector3(.11,0,.028),Vector3(.035,.13,.025),"667172",false,11)

static func desk(b: Node3D) -> void:
	# Ground service centre replaces the former solid coloured core, retaining its footprint.
	K.box(b,Vector3(31,.096,1),Vector3(21.8,.04,17.8),"a3aaa6",false,29)
	doorway(b,20,42,31,10,0,4.35,4,"b7aa69")
	var side:=K.holder(b,"ServiceSideDoor",Vector3(42,0,0));side.rotation.y=PI/2
	doorway(side,-10,8,0,0,0,4.35,4,"b7aa69");K.finish(side)
	K.box(b,Vector3(20,2.17,1),Vector3(.2,4.35,18),"d5d9d5",true,22)
	K.box(b,Vector3(31,2.17,-8),Vector3(22,4.35,.2),"bd9958",true,22)
	K.box(b,Vector3(31,2.1,-7.87),Vector3(21.8,4.2,.04),"d8ddd7",false,22)
	for i in 18:K.box(b,Vector3(20.5+i*1.23,2.15,-8.13),Vector3(.055,4.3,.04),"917440",false,11)
	K.box(b,Vector3(40.2,2,-7.8),Vector3(3.2,4,.05),"c6c264",false,22)
	slats(b,Vector3(31,4.10,1),Vector2(21.8,17.8))
	# L-shaped pale reception counter, with open staff access from the left.
	K.box(b,Vector3(26.3,.55,-.7),Vector3(6.8,1.1,1.1),"d9ddda",true,22)
	K.box(b,Vector3(29.15,.55,-2.05),Vector3(1.1,1.1,3.8),"d9ddda",true,22)
	K.box(b,Vector3(26.3,1.12,-.7),Vector3(6.9,.08,1.2),"edf0e7",false,22)
	K.box(b,Vector3(29.15,1.12,-2.05),Vector3(1.2,.08,3.8),"edf0e7",false,22)
	K.box(b,Vector3(26,.08,-.13),Vector3(6.5,.16,.07),"494945",false,11)
	K.box(b,Vector3(27.8,1.42,-.8),Vector3(.5,.38,.05),"354047",false,11)
	var title:=K.label(b,"综合运动馆服务中心\nSports Complex Service Centre",Vector3(25,2.6,-7.7),.006);title.modulate=Color("594462")
	# Brown waiting sofa and low table stay outside the door-to-stair circulation.
	K.box(b,Vector3(35.4,.38,-5.9),Vector3(4.0,.7,.85),"61564f",true,22)
	K.box(b,Vector3(35.4,.83,-6.25),Vector3(4.0,.65,.18),"61564f",false,22)
	K.box(b,Vector3(35.4,.48,-4.1),Vector3(2.1,.12,.8),"a1a9a4",true,11)
	for x in [34.5,36.3]:K.box(b,Vector3(x,.22,-4.1),Vector3(.07,.44,.65),"949e99",false,11)
	lockers(b,Vector3(24,0,7.8),6)
	# Open access posts represent the photographed reception gates; no account access logic.
	for x in [34,36.6]:
		K.box(b,Vector3(x,.48,2),Vector3(.25,.96,1.4),"aab5b3",true,11)
		K.box(b,Vector3(x,1.13,2.4),Vector3(.08,.36,.08),"333c41",false,11)
	for p: Vector3 in [Vector3(22,0,-5.8),Vector3(39.4,0,-5.8)]:
		K.box(b,p+Vector3.UP*.35,Vector3(.55,.7,.55),"d8ddd8",true,22)
		V.shrub(b,p+Vector3.UP*.72,Vector3(.85,.9,.85),int(p.x)*71)
	lamp(b,Vector3(30,3.6,1),16)
	var sign:=K.label(b,"综合运动馆 · 服务中心",Vector3(31,3.42,10.14),.007);sign.modulate=Color("594462")

static func table_tennis(b: Node3D,p: Vector3) -> void:
	# Table dimensions 2.74 x 1.525; arrangement is fitted to this model room.
	K.box(b,p+Vector3.UP*.76,Vector3(1.525,.045,2.74),"514d77",true,22)
	for x in [-.752,.752]:K.box(b,p+Vector3(x,.786,0),Vector3(.02,.004,2.72),"d5dcca",false,22)
	for z in [-1.36,1.36]:K.box(b,p+Vector3(0,.786,z),Vector3(1.525,.004,.02),"d5dcca",false,22)
	K.box(b,p+Vector3(0,.787,0),Vector3(.016,.004,2.72),"d5dcca",false,22)
	K.box(b,p+Vector3(0,.85,0),Vector3(1.68,.16,.018),"8a93a2",false,19)
	K.box(b,p+Vector3(0,.94,0),Vector3(1.68,.015,.015),"d9dbcb",false,22)
	for x in [-.65,.65]:
		for z in [-.92,.92]:K.box(b,p+Vector3(x,.38,z),Vector3(.045,.71,.045),"434f4d",false,11)

static func room(b: Node3D,a: float,c: float,name_text: String,kind: int,color: String) -> void:
	var door: float=(a+c)/2
	K.box(b,Vector3(door,Y+.025,0),Vector3(c-a-.2,.045,15.8),color,false,kind)
	doorway(b,a,c,door,8,Y,4.03)
	K.box(b,Vector3(a,Y+2,0),Vector3(.20,4,16),"d5d9d1",true,22)
	K.box(b,Vector3(door,8.67,0),Vector3(c-a-.2,.08,15.9),"d7dbcf",false,22)
	var sign:=K.label(b,name_text,Vector3(door,Y+3.22,8.13),.0055);sign.modulate=Color("594462")
	C.glazing(b,Vector3(door,Y+2,-8),c-a-.2,3.95)
	for x in range(ceili(a)+3,int(c)-1,6):
		for z in [-5,1,6]:
			K.box(b,Vector3(x,8.60,z),Vector3(1.4,.035,.5),"f0f0d9",false,17)
			K.box(b,Vector3(x+1.6,8.60,z),Vector3(.75,.04,.45),"838c82",false,11)
		lamp(b,Vector3(x,8,0),8)
	if name_text!="乒乓球室":
		# Mirror-like finish and protected diagonal steel members visible in the source photos.
		K.box(b,Vector3(a+.13,Y+1.5,0),Vector3(.035,2.4,13),"8daba9",false,11)
		for x in [a+1,c-1]:
			K.box(b,Vector3(x,Y+2,-7.5),Vector3(.65,4,.65),"82897c",true,22)
		A.member(b,Vector3(a+1,Y+.3,-7.3),Vector3(a+7,Y+3.8,-7.3),.5,"838a7b")
		A.member(b,Vector3(c-1,Y+.3,7.5),Vector3(c-7,Y+3.8,7.5),.5,"838a7b")

static func upper_public(b: Node3D) -> void:
	room(b,-61,-29,"体操室",30,"b8a574")
	room(b,-29,-4,"武术室",22,"a1aaa0")
	room(b,-4,17,"形体室",30,"baa975")
	room(b,17,40,"乒乓球室",22,"a8b0a7")
	K.box(b,Vector3(40,Y+2,0),Vector3(.2,4,16),"c8d7d8",true,22)
	# Current facility image adds pale-blue walls, divider screens and waiting chairs.
	for x in [17.15,39.85]:K.box(b,Vector3(x,Y+1.8,0),Vector3(.04,3.6,15.8),"b3c9cb",false,22)
	for x in [21,27.5,34]:
		for z in [-5.4,-1.8,1.8,5.4]:table_tennis(b,Vector3(x,Y,z))
	for x in [23.9,30.7]:
		for z in [-5.7,-1.9,1.9,5.7]:K.box(b,Vector3(x,Y+.4,z),Vector3(.06,.8,3.0),"3d6492",true,22)
	for z in [-6,-4,-2,0,2,4,6]:chair(b,Vector3(38.9,Y,z),PI/2,"828f92")
	for x in [24.6,31.2]:K.box(b,Vector3(x,Y+2,0),Vector3(.7,4,.7),"858d80",true,22)
	# Long glazed public corridor; original render left this as an outdoor blank slab.
	K.box(b,Vector3(-8.5,Y+.023,11.75),Vector3(105,.04,7.5),"9ea8a6",false,29)
	slats(b,Vector3(-8.5,8.6,11.7),Vector2(105,7.4))
	C.glazing(b,Vector3(-8.5,Y+1.98,15.6),105,3.96)
	for x in [-54,-34,-10,14,36]:
		L.cylinder(b,Vector3(x,Y+.73,14),.58,.07,"d8e0dc")
		K.box(b,Vector3(x,Y+.35,14),Vector3(.08,.7,.08),"556065",false,11)
		chair(b,Vector3(x-1,Y,14),-PI/2);chair(b,Vector3(x+1,Y,14),PI/2)
		lamp(b,Vector3(x,8.1,11.7),10)
	lockers(b,Vector3(12,Y,8.45),8);lockers(b,Vector3(-8,Y,8.45),6)
	# Named room list metadata records fitted areas, not measured floor-plan locations.
	b.set_meta("public_interior",{"ground_service":true,"rooms":["gymnastics","martial_arts","dance","table_tennis"],"table_count":12,"room_sequence_surveyed":false,"photo_dates":"2023 guide; current directory capture date unknown"})

static func build(b: Node3D) -> void:
	desk(b)
	upper_public(b)
