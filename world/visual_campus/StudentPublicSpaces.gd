extends RefCounted
## Canteen arcade details read from official panorama 116440789; room dimensions inferred.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")

static func table(b: Node3D,p: Vector3) -> void:
	K.box(b,p+Vector3.UP*.78,Vector3(2.6,.10,1.05),"655d50",true,4)
	for x in [-1.05,1.05]:
		for z in [-.35,.35]:K.box(b,p+Vector3(x,.38,z),Vector3(.06,.76,.06),"434e48",false,11)
	for x in [-.8,.8]:
		for side in [-1,1]:
			var q:=p+Vector3(x,0,side*.95)
			K.box(b,q+Vector3.UP*.45,Vector3(.55,.07,.55),"746a55",false,4)
			for a in [-.22,.22]:
				for c in [-.22,.22]:K.box(b,q+Vector3(a,.22,c),Vector3(.045,.44,.045),"434e48",false,11)
			for a in [-.21,-.07,.07,.21]:K.box(b,q+Vector3(a,.78,side*.23),Vector3(.055,.59,.05),"766c56",false,4)
			K.box(b,q+Vector3(0,1.1,side*.23),Vector3(.57,.065,.07),"766c56",false,4)

static func glazed_bay(b: Node3D,x: float,door: bool) -> void:
	# Dark tall glazing, a low transom and separate clerestory replace repeated residential windows.
	if not door:K.box(b,Vector3(x,2.05,-.11),Vector3(4.25,3.8,.09),"60777b",true,19)
	for dx in [-2.15,0,2.15]:
		if door and dx==0:continue
		K.box(b,Vector3(x+dx,2.07,0),Vector3(.11,4.14,.17),"4f5c59",true,11)
	for y in [.13,1.15,4.12]:
		if not door or y>4:K.box(b,Vector3(x,y,0),Vector3(4.4,.10,.17),"4f5c59",not door,11)
	if door:
		# Door leaves stand to each side; keep the central walking opening clear.
		for side in [-1,1]:K.box(b,Vector3(x+side*1.92,1.95,-.45),Vector3(.10,3.8,.85),"6b8582",false,19)
	K.box(b,Vector3(x,4.8,-.15),Vector3(4.4,1.25,.20),"7b7b6d",false,15)
	K.box(b,Vector3(x,6.7,-.11),Vector3(4.25,2.5,.09),"526a6f",false,5)
	for dx in [-2.15,0,2.15]:K.box(b,Vector3(x+dx,6.7,0),Vector3(.1,2.6,.17),"4f5c59",false,11)

static func canteen_wall(b: Node3D,side: int) -> void:
	var n:=K.holder(b,"CanteenYellowArcade",Vector3(side*25,0,-2));n.rotation.y=-side*PI/2
	for i in 6:
		var u: float=-15+i*6
		glazed_bay(n,u,i==2)
		for dx in [-2.62,2.62]:K.box(n,Vector3(u+dx,4.4,-.17),Vector3(.76,8.8,.48),"c6b15d",true,21)
		K.box(n,Vector3(u,8.55,-.17),Vector3(6,.5,.48),"c6b15d",false,21)
	K.box(n,Vector3(0,5.30,.09),Vector3(36,.24,.22),"a6aca0",false,6)
	# Noticeboards use neutral shapes, not reproduced student photos or poster text.
	for u in [-9,9]:
		K.box(n,Vector3(u+2.63,1.8,.105),Vector3(.62,1.2,.06),"e0ddc9",false,12)
		for j in 4:K.box(n,Vector3(u+2.63,1.4+j*.21,.145),Vector3(.49,.03,.01),"65807a",false,11)
	K.finish(n)

static func build(b: Node3D) -> void:
	var n:=K.holder(b,"StudentOccupiedArcades")
	for side in [-1,1]:
		canteen_wall(n,side)
		# Ground arcade and its full upper walking deck; columns leave a generous middle aisle.
		K.box(n,Vector3(side*20,4.24,-1),Vector3(10,.32,30),"b6bcaf",true,6)
		K.box(n,Vector3(side*20,4.06,-1),Vector3(9.95,.03,29.95),"b9bdb1",false,15)
		K.box(n,Vector3(side*20,.045,-1),Vector3(9.8,.065,30),"9b9a8d",false,1)
		for z in [-15,-9,-3,3,9,14]:
			K.column(n,Vector3(side*16.6,0,z),4.1,.50)
			K.box(n,Vector3(side*20,3.96,z),Vector3(10,.35,.24),"aeb4a9",false,15)
			K.box(n,Vector3(side*20,3.74,z+.55),Vector3(.20,.10,.32),"dfd8c1",false,17)
		K.box(n,Vector3(side*16.6,3.99,-1),Vector3(.28,.30,30),"b0b7ac",false,6)
		# Upper rails stop where the transverse landing crosses the side galleries.
		L.guardrail(n,Vector3(side*15,4.4,4.75),18.5,PI/2)
		L.guardrail(n,Vector3(side*15,4.4,-13.75),4.5,PI/2)
		for z in [-12,6,12]:table(n,Vector3(side*22,0,z))
		# Recessed dining rooms inside the side wings; external doors are genuinely usable.
		K.box(n,Vector3(side*29.5,.05,0),Vector3(9.6,.08,50),"b7b1a0",false,12)
		K.box(n,Vector3(side*29.5,4.065,0),Vector3(9.5,.03,50),"b9bdb1",false,15)
		for z in [-12,8,14]:table(n,Vector3(side*29.4,0,z))
		for z in [-12,0,10]:
			K.box(n,Vector3(side*29.5,4.07,z),Vector3(5.8,.06,.24),"e0d7b9",false,17)
			var light:=OmniLight3D.new();light.position=Vector3(side*29.5,3.1,z);light.light_color=Color("f1e4c9");light.light_energy=.6;light.omni_range=8;n.add_child(light)
		# A rail of suspended plain fabric panels conveys the arcade rhythm seen in the panorama.
		for i in 5:
			var z: float=-12+i*5.5
			K.box(n,Vector3(side*18.7,3.72,z),Vector3(3.6,.04,.04),"66756d",false,11)
			K.box(n,Vector3(side*18.7,3.11,z),Vector3(2.6,1.2,.035),["8d615a","a99865","58746a","667986","927766"][i],false,15)
	# Long red wall behind the tall portal. Lower openings lead into the rear bar.
	for side in [-1,1]:
		var back:=K.holder(n,"PortalRearWall",Vector3(side*13,0,-17.8))
		for interval: Vector2 in [Vector2(-12,-4),Vector2(4,12)]:K.box(back,Vector3((interval.x+interval.y)/2,4.4,0),Vector3(interval.y-interval.x,8.8,.28),"95695e" if side==1 else "b6a15f",true,15)
		K.box(back,Vector3(0,6.55,0),Vector3(8,4.5,.28),"95695e" if side==1 else "b6a15f",true,15)
		for x in [-4,4]:K.box(back,Vector3(x,2.1,.18),Vector3(.13,4.2,.25),"4b625b",true,11)
		for j in 32:K.box(back,Vector3(-11.8+j*.76,6.6,.19),Vector3(.05,4.3,.07),"b78c78" if side==1 else "c2b077",false,11)
		K.box(back,Vector3(0,4.18,.18),Vector3(8.2,.16,.25),"4b625b",false,11)
		K.label(back,"学生餐厅",Vector3(0,4.8,.22),.01)
		K.finish(back)
	# Small planting beds remain in the open courts, not underneath the new decks.
	for x in [-11,11]:
		K.box(n,Vector3(x,.24,-14),Vector3(6,.48,3.6),"929b86",false,6)
		K.box(n,Vector3(x,.51,-14),Vector3(5.7,.06,3.3),"526548",false,3)
		for dx in [-1.7,0,1.7]:K.planter(n,Vector3(x+dx,.5,-14))
	K.tree(n,Vector3(9,0,5),6,913)
	K.bench(n,Vector3(11,0,10),PI/2)
	# Slim sunshade over the upper portal, with warm soffit and structural jambs.
	for x in [-12.6,12.6]:K.box(n,Vector3(x,4.4,18),Vector3(.35,8.8,4),"aa956a",false,15)
	K.box(n,Vector3(0,8.46,21),Vector3(25.8,.15,9.6),"b1aa89",false,16)
	for x in range(-12,13,2):K.box(n,Vector3(x,8.29,21),Vector3(.10,.18,9.6),"ad9b73",false,11)
	# Front paving terminates at the sunken-court edge (local x=20), never caps the pit.
	K.box(n,Vector3(0,.027,30),Vector3(40,.045,14),"aaa897",false,6)
	for x in [-19.7,19.7]:K.box(n,Vector3(x,.056,30),Vector3(.16,.016,13.5),"65776b",false,11)
	K.box(n,Vector3(0,.056,36.7),Vector3(39.5,.016,.16),"65776b",false,11)
	for x in [-18,18]:
		K.bench(n,Vector3(x,0,33),PI/2);K.planter(n,Vector3(x,0,35.4))
	K.finish(n)
