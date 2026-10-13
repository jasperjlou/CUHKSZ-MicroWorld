extends RefCounted
## User-confirmed lower interior beneath the entrance stair (official public 1F / tour G).
## Public functions come from the floor map; coordinates fit the retained shell, not a survey.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Ceiling=preload("res://world/visual_campus/LibraryLowerCeiling.gd")
const Lobby := preload("res://world/visual_campus/LibraryLobbyDetail.gd")

static func sign_at(b: Node3D,text: String,p: Vector3,size: Vector2) -> void:
	K.box(b,p,Vector3(size.x,size.y,.055),"566556",false,22)
	K.label(b,text,p+Vector3(0,0,.04),.0045)

static func chair(b: Node3D,p: Vector3,yaw: float=0,color: String="78918b") -> void:
	var n:=K.holder(b,"StudyChair",p);n.rotation.y=yaw
	K.box(n,Vector3(0,.47,0),Vector3(.48,.08,.48),color,false,22)
	K.box(n,Vector3(0,.76,.22),Vector3(.48,.53,.07),color,false,22)
	for x in [-.18,.18]:
		for z in [-.18,.18]:K.box(n,Vector3(x,.22,z),Vector3(.035,.44,.035),"90998f",false,11)
	K.finish(n)

static func study_table(b: Node3D,p: Vector3,width: float=3.8) -> void:
	K.box(b,p+Vector3.UP*.76,Vector3(width,.09,1.35),"bca47a",true,4)
	for x in [-width/2+.16,width/2-.16]:
		K.box(b,p+Vector3(x,.37,0),Vector3(.075,.74,1.15),"d2d1c5",false,11)
	for x in [-width*.27,width*.27]:
		for side in [-1,1]:chair(b,p+Vector3(x,0,side*1.05),0 if side>0 else PI)
	K.box(b,p+Vector3(0,.835,0),Vector3(.44,.055,.15),"5b655e",false,11)

static func ceiling(b: Node3D,x: float,width: float,z: float,depth: float) -> void:
	Ceiling.panel(b,Ceiling.rectangle(x,z,width,depth),4.025)
	for i in range(int(width/2)+1):
		Ceiling.bar(b,Vector3(x-width/2+i*2,3.9675,z),Vector2(.055,depth))
	for j in range(int(depth/2)+1):
		Ceiling.bar(b,Vector3(x,3.9675,z-depth/2+j*2),Vector2(width,.055))
	for i in range(int(width/4)):
		for j in range(int(depth/4)):
			preload("res://world/visual_campus/LibraryLowerCeiling.gd").light(b,Vector3(x-width/2+2+i*4,3.98,z-depth/2+2+j*4))

static func group_room(b: Node3D,p: Vector3,title: String,width: float=5.6,depth: float=6,yaw: float=0) -> void:
	var n:=K.holder(b,"LowerRoom"+title,p)
	n.rotation.y=yaw
	# White returns, glazed front and open 1.8 m door match the public panorama language.
	K.box(n,Vector3(0,.105,0),Vector3(width-.15,.04,depth-.15),"a9a48c",false,25)
	for side in [-1,1]:
		K.box(n,Vector3(side*width/2,1.95,0),Vector3(.15,3.9,depth),"c6c7b9",true,22)
	K.box(n,Vector3(0,1.95,-depth/2),Vector3(width,3.9,.15),"c6c7b9",true,22)
	var pane_width: float=(width-1.8)/2
	for side in [-1,1]:
		var x: float=side*(.9+pane_width/2)
		K.box(n,Vector3(x,1.90,depth/2),Vector3(pane_width,3.8,.075),"a6b5a5",true,19)
		for edge in [-1,1]:K.box(n,Vector3(x+edge*pane_width/2,1.95,depth/2+.035),Vector3(.055,3.9,.11),"c5c8bb",false,11)
	K.box(n,Vector3(0,3.63,depth/2),Vector3(width,.55,.19),"bbbda9",false,16)
	sign_at(n,title,Vector3(0,3.60,depth/2+.13),Vector2(maxf(1.65,title.length()*.33),.32))
	if width<4.5:
		K.box(n,Vector3(0,.76,-depth/2+.55),Vector3(width-.8,.09,.65),"bca47a",true,4)
		for x in [-.5,.5]:chair(n,Vector3(x,0,-depth/2+1.55))
	else:study_table(n,Vector3(0,0,-.45),minf(3.5,width-2))
	K.box(n,Vector3(0,2.0,-depth/2+.11),Vector3(width*.65,1.25,.05),"e0dfd1",false,22)
	K.box(n,Vector3(.85,1.70,depth/2-.66),Vector3(.055,3.35,1.3),"a6b5a5",false,19)
	K.finish(n)

static func entry_stair(parent: Node3D) -> void:
	preload("res://world/visual_campus/LibraryGroundStair.gd").build(parent)

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"LibraryLowerPublicWings")
	# Preserve a broad through-aisle at z=-8 and the two x=+-18 front entrances.
	for side in [-1]:
		var cx: float=-27 if side<0 else 25
		var width: float=24 if side<0 else 20
		K.box(b,Vector3(cx,.081,-2.9 if side<0 else -5),Vector3(width,.045,27.8 if side<0 else 32),"c4c5c1",false,46)
		if side<0:
			# V73 leave the remote stair shaft open instead of running a ceiling through it.
			ceiling(b,-24.5,19,-5.65,22.1)
			ceiling(b,-36.5,5,-.8,12.4)
			ceiling(b,-35.7,6.6,8.2,5.6)
			ceiling(b,-19.3,8.6,8.2,5.6)
		else:ceiling(b,cx,width,-5,32)
		for z in [-16,3]:
			var light:=OmniLight3D.new();light.position=Vector3(side*27,3.35,z);light.light_color=Color("fff5de");light.light_energy=.65;light.omni_range=14;b.add_child(light)
	preload("res://world/visual_campus/LibraryLowerRearPlan.gd").build(b)
	# The map's paired small rooms sit in the left study wing. Fine positions remain fitted.
	# Keep the island clear of the front core at z=5.45 and the remote-core aisle.
	study_island(b,Vector3(-27.5,0,-1.8),8.9,7.95,101)
	# V102: map-relative programme positions. Both islands share the same study band;
	# 105 is behind them,110 alongside,111 towards the exhibition/arrival side.
	round_room(b,Vector3(-14.7,0,-10.4),"105")
	study_island(b,Vector3(-15.7,0,-1.8),5.5,6.2,106)
	round_room(b,Vector3(-6.9,0,-.65),"110",PI/2)
	round_room(b,Vector3(-6.9,0,6.3),"111",PI*.75)
	for i in 4:group_room(b,Vector3(4.1+i*1.59,0,.3-i*1.59),str(112+i),2.2,2.6,PI/4)
	for z in [-5,1]:study_table(b,Vector3(-36.5,0,z),2.6)
	sign_at(b,"开放学习区 / OPEN STUDY",Vector3(-23,3.45,-16.68),Vector2(7.8,.50))
	preload("res://world/visual_campus/LibraryLowerRightPlan.gd").build(b)
	preload("res://world/visual_campus/LibraryInteractive119.gd").build(b)
	preload("res://world/visual_campus/LibraryLowerRightWing.gd").build(b)
	# The tapered tip has perimeter desks, leaving its centre and booth doors clear.
	for p in [Vector3(32,0,-6),Vector3(36,0,-3)]:study_table(b,p,2.4)
	# V103 former table now lies inside relocated119; the room owns its furniture.
	for p:Vector3 in [Vector3(14,0,-1),Vector3(18,0,-3)]:triangle_table(b,p)
	preload("res://world/visual_campus/LibraryLowerServices.gd").build(b)
	preload("res://world/visual_campus/LibraryLowerArrival.gd").build(b)
	preload("res://world/visual_campus/LibraryLowerColumn.gd").build(b)
	# Recessed G threshold/sign now follows the1F map in LibraryLowerFrontFacade.
	K.finish(b)

static func study_island(parent: Node3D,p: Vector3,width: float,depth: float,first_room: int) -> void:
	var b:=preload("res://world/visual_campus/LibraryStudyPods.gd").build(parent,p,width,depth,first_room)
	for sx in [-1,1]:
		for sz in [-1,1]:
			if first_room==106:
				# Small cells use a side workstation, leaving the shared-door aisle clear.
				K.box(b,Vector3(sx*(width/2-.42),.76,sz*depth/4),Vector3(.65,.09,2.0),"bca47a",true,4)
				chair(b,Vector3(sx*(width/2-1.15),0,sz*depth/4),PI/2 if sx<0 else -PI/2)
			else:study_table(b,Vector3(sx*width/4,0,sz*depth/4),2.1)
			# Shared partition carries the room whiteboards; transparent outer walls stay legible.
			K.box(b,Vector3(sx*width/4,2.05,sz*.085),Vector3(width/2-1.1,1.20,.035),"e0e0d5",false,22)
	K.finish(b)

static func round_room(parent:Node3D,p:Vector3,title:String,yaw:float=0) -> void:
	var b:=preload("res://world/visual_campus/LibraryStudyPods.gd").single(parent,p,title,3.2,3.2,yaw)
	K.box(b,Vector3(0,.76,-.95),Vector3(2.2,.09,.62),"bca47a",true,4)
	chair(b,Vector3(-.48,0,.02));chair(b,Vector3(.48,0,.02))
	K.box(b,Vector3(0,2.0,-1.49),Vector3(1.8,1.05,.04),"deded3",false,22)
	K.finish(b)

static func triangle_table(parent:Node3D,p:Vector3) -> void:
	var b:=K.holder(parent,"GroundTriangularWorktable",p)
	var corners:=PackedVector2Array([Vector2(-1.4,.8),Vector2(1.4,.8),Vector2(0,-1.25)])
	preload("res://world/visual_campus/LibraryUpperLevels.gd").sheet(b,corners,.76,"b9925f",4,true)
	for q:Vector2 in corners:
		K.box(b,Vector3(q.x*.8,.38,q.y*.8),Vector3(.05,.72,.05),"c9cbc2",false,11)
		Lobby.cylinder(b,Vector3(q.x*.8,.07,q.y*.8),.06,.08,"52615a")
	chair(b,Vector3(0,0,1.32),0,"ad6857")
	chair(b,Vector3(-1.35,0,-.35),-PI*.65,"b8bcae")
	chair(b,Vector3(1.35,0,-.35),PI*.65,"b8bcae")
	# 2024 official equipment update locates computers/monitors at1F triangular tables.
	K.box(b,Vector3(0,.99,-.35),Vector3(.045,.45,.045),"666f68",false,11)
	K.box(b,Vector3(0,1.21,-.35),Vector3(.75,.44,.045),"313a3a",false,22)
	K.box(b,Vector3(0,1.21,-.321),Vector3(.68,.36,.012),"526e72",false,5)
	K.finish(b)
