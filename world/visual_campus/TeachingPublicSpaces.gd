extends RefCounted
## Distinct public spaces visible in official TA square, Teaching B lobby and Teaching C arcade.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func rail(b: Node3D,p: Vector3,length: float,yaw: float=0) -> void:
	var basis:=Basis(Vector3.UP,yaw)
	K.box(b,p+Vector3.UP*1.08,Vector3(length,.06,.06),"687069",false,11,yaw)
	for i in int(length/.45):K.box(b,p+basis*Vector3(-length/2+(i+.5)*.45,.52,0),Vector3(.035,1.04,.035),"687069",false,11)

static func table(b: Node3D,p: Vector3) -> void:
	K.box(b,p+Vector3.UP*.76,Vector3(1.7,.10,1.1),"a28e6c",false,4)
	for x in [-.65,.65]:K.box(b,p+Vector3(x,.36,0),Vector3(.07,.72,.82),"5e645b",false,11)
	for side in [-1,1]:
		for x in [-.47,.47]:
			var q:=p+Vector3(x,0,side*.91)
			K.box(b,q+Vector3.UP*.43,Vector3(.46,.07,.46),"a28e6c",false,4)
			K.box(b,q+Vector3(0,.75,side*.20),Vector3(.46,.60,.06),"a28e6c",false,4)
			for edge in [-1,1]:K.box(b,q+Vector3(edge*.17,.22,0),Vector3(.04,.44,.38),"62685e",false,11)

static func flight(b: Node3D,start: Vector3,end: Vector3,width: float,stone:String="adafa5",kind:int=15) -> void:
	var count:=24;var rise:=end.y-start.y;var tread:=absf(end.z-start.z)/count
	for i in count:
		var p:=start.lerp(end,(i+.5)/count);p.y=start.y+rise*(i+1)/count-.10
		K.box(b,p,Vector3(width,.20,tread+.01),stone,false,kind)
	var ramp:=K.surface(b,K.quad(start+Vector3(-width/2,0,0),start+Vector3(width/2,0,0),end+Vector3(width/2,0,0),end+Vector3(-width/2,0,0)),stone,kind,true);ramp.hide()
	var slab:=K.holder(b,"SwitchbackConcreteFlight",(start+end)/2-Vector3.UP*.25)
	slab.rotation.x=-atan2(rise,end.z-start.z)
	K.box(slab,Vector3.ZERO,Vector3(width,.30,start.distance_to(end)),"aaa99f",false,15)
	for side in [-1,1]:
		for j in 18:
			var p:=start.lerp(end,j/17.0)+Vector3(side*(width/2+.06),.53,0)
			K.box(b,p,Vector3(.035,1.06,.035),"686f65",false,11)
		var hand:=K.holder(b,"SwitchbackRail",(start+end)/2+Vector3(side*(width/2+.06),1.1,0));hand.rotation.x=slab.rotation.x
		K.box(hand,Vector3.ZERO,Vector3(.055,.055,start.distance_to(end)),"686f65",false,11);K.finish(hand)
	K.finish(slab)

static func ta(b: Node3D,r: Dictionary) -> void:
	var stair_x: float=-float(r.width)*.22
	preload("res://world/visual_campus/TeachingAEntry.gd").build(b,r)
	# Return flight and landing read as one concrete switchback, not floating stair rungs.
	K.box(b,Vector3(stair_x+2,4.80,10.15),Vector3(6.5,.25,2.3),"b0b0a5",true,15)
	flight(b,Vector3(stair_x+4,4.925,9),Vector3(stair_x+4,8.625,-8),2.4)
	K.box(b,Vector3(stair_x+6.1,8.5,-9.1),Vector3(6.6,.25,2.5),"b0b0a5",true,15)
	# Separate return walk avoids putting a low ceiling across the rising flight.
	K.box(b,Vector3(stair_x+8.2,8.5,1.4),Vector3(2.4,.25,23.5),"b0b0a5",true,15)
	rail(b,Vector3(stair_x+9.45,8.625,1.4),22.5,PI/2)
	rail(b,Vector3(stair_x+6.1,8.625,-10.35),6.6)
	for x in [-22,20]:
		for z in [15,19]:table(b,Vector3(x,0,z))

static func tb(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"TeachingBLobby",Vector3(-13,0,float(r.depth)*.35))
	K.box(n,Vector3(0,.155,0),Vector3(16,.025,8.8),"a1a69f",false,12)
	for side in [-1,1]:K.box(n,Vector3(side*5.4,2.12,-4.4),Vector3(5.2,4.24,.20),"c4c6bf",true,15)
	for side in [-1,1]:
		if side<0:K.box(n,Vector3(-8,2.12,0),Vector3(.18,4.24,8.8),"bdc1b8",true,15)
		else:
			# The photographed corridor leaves the lobby sideways, under the promenade.
			for z in [-3.6,3.6]:K.box(n,Vector3(8,2.12,z),Vector3(.18,4.24,1.6),"bdc1b8",true,15)
		K.box(n,Vector3(side*5,2.1,4.3),Vector3(5.6,4.0,.10),"809f9d",true,19)
		for x in [-2.75,0,2.75]:K.box(n,Vector3(side*5+x,2.1,4.36),Vector3(.07,4.0,.18),"506057",false,11)
		K.box(n,Vector3(side*2.1,2,4.3),Vector3(.13,4,.15),"39463f",true)
		K.box(n,Vector3(side*2.55,1.95,3.68),Vector3(1.7,3.8,.10),"789b98",false,19,side*PI/3)
	K.box(n,Vector3(0,4.27,0),Vector3(16,.12,8.8),"454b49",false,44)
	for x in range(-8,9,2):K.box(n,Vector3(x,4.16,0),Vector3(.045,.06,8.8),"929b93",false,11)
	for z in range(-4,5,2):
		K.box(n,Vector3(0,4.16,z),Vector3(16,.06,.045),"929b93",false,11)
		for x in [-5,3]:K.box(n,Vector3(x,4.10,z),Vector3(1.1,.05,.24),"eee9d6",false,17)
	K.box(n,Vector3(-5,2.4,-4.2),Vector3(4.5,2.4,.08),"718797",false,15)
	K.label(n,"人文社科学院\nHUMANITIES AND\nSOCIAL SCIENCE",Vector3(-5,2.85,-4.13),.0038)
	var light:=OmniLight3D.new();light.position=Vector3(0,3.25,0);light.light_color=Color("f1f2df");light.light_energy=.65;light.omni_range=11;light.shadow_enabled=false;n.add_child(light)
	for x in [-6.0,-4.2,4.2,6.0]:
		K.box(n,Vector3(x,1.15,-2.8),Vector3(1.25,2.3,.08),"bfcbd0")
		K.box(n,Vector3(x,1.7,-2.73),Vector3(1.02,.46,.035),"737990")
		for j in 5:K.box(n,Vector3(x,1.3-j*.19,-2.72),Vector3(.92,.045,.025),"8a989b")
		K.box(n,Vector3(x,.12,-2.8),Vector3(1.4,.08,.50),"929b8d",false,11)
	K.label(n,"B",Vector3(2.8,3.4,4.48),.028)
	var corridor:=K.holder(n,"SidewaysTeachingBCorridor",Vector3(3.6,0,0));corridor.rotation.y=-PI/2
	preload("res://world/visual_campus/TeachingArcades.gd").b_corridor(corridor);K.finish(corridor)
	K.finish(n)

static func tc(b: Node3D,r: Dictionary) -> void:
	preload("res://world/visual_campus/TeachingArcades.gd").c_arcade(b,r)

static func build(b: Node3D,r: Dictionary) -> void:
	match r.id:
		"teaching_a":ta(b,r)
		"teaching_b":tb(b,r)
		"teaching_c":tc(b,r)
	if r.id in ["teaching_b","teaching_c"]:return # Deeper courts/front edges are authored by TeachingBSite.
	forecourt(b,r)
	# Low continuous planting edges, transverse drains and sheltered seats at human scale.
	for side in [-1,1]:
		K.box(b,Vector3(side*7,.2,-6),Vector3(3.1,.4,6.4),"919987",false,15)
		K.box(b,Vector3(side*7,.44,-6),Vector3(2.7,.08,6),"5c7049",false,3)
		K.tree(b,Vector3(side*7,.5,-6),5.5,absi(int(r.position[2]))+side)
		K.box(b,Vector3(side*7,.06,float(r.depth)*.44),Vector3(7,.025,.25),"647365",false,11)
		for i in 27:K.box(b,Vector3(side*7-3.25+i*.25,.079,float(r.depth)*.44),Vector3(.035,.015,.20),"a0ada0",false,11)

static func forecourt(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	K.box(b,Vector3(0,.041,d*.49),Vector3(w*.85,.045,d*.10),"aaa99d",false,6)
	K.box(b,Vector3(0,.055,d*.64),Vector3(w*.86,.045,d*.28),"a6a799",false,6)
	for side in [-1,1]:
		K.box(b,Vector3(side*w*.28,.25,d*.79),Vector3(w*.30,.5,2.3),"919b89",false,15)
		K.box(b,Vector3(side*w*.28,.55,d*.79),Vector3(w*.29,.12,1.9),"5b7446",false,3)
		for i in 8:K.box(b,Vector3(side*w*.28+(i-3.5)*w*.035,.77,d*.79),Vector3(w*.034,.35,1.6),"526a43",false,3)
		K.tree(b,Vector3(side*w*.28,0,d*.84),6.5,absi(int(r.position[2]))+side*11)
		K.bench(b,Vector3(side*w*.28,0,d*.71))
		for x in [-1.2,1.2]:K.box(b,Vector3(side*w*.28+x,.075,d*.66),Vector3(.04,.02,3.1),"737e70")
	K.box(b,Vector3(0,.078,d*.59),Vector3(w*.82,.02,.28),"657365",false,11)
	for i in int(w*.82/.20):K.box(b,Vector3(-w*.41+i*.20,.092,d*.59),Vector3(.028,.012,.22),"a2aa9c",false,11)
