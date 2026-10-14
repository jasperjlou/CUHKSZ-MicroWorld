extends RefCounted
## V72 public 1F entrance programme and official G panorama material cues.
## Relative function order follows the map; all dimensions/positions remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Lobby := preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const Services := preload("res://world/visual_campus/LibraryLowerServices.gd")

static func counter(parent: Node3D,p: Vector3,title: String,width: float,yaw: float=0) -> void:
	var b:=K.holder(parent,"ArrivalCounter",p);b.rotation.y=yaw
	K.box(b,Vector3(0,.47,0),Vector3(width,.94,1.1),"c6c5b6",true,22)
	K.box(b,Vector3(0,.97,0),Vector3(width+.12,.07,1.2),"c7b797",false,12)
	K.box(b,Vector3(-width/2-.65,.37,0),Vector3(1.25,.74,1.1),"c6c5b6",true,22)
	K.box(b,Vector3(-width/2-.65,.77,0),Vector3(1.32,.06,1.2),"c7b797",false,12)
	Services.plaque(b,title,Vector3(0,.58,.57),minf(width-.3,3.4))
	for x in [-width*.25,width*.25]:
		K.box(b,Vector3(x,1.24,-.18),Vector3(.56,.37,.055),"343c3d",false,22)
		K.box(b,Vector3(x,1.05,-.18),Vector3(.06,.18,.06),"555f5c",false,11)
	K.finish(b)

static func lounge_chair(parent: Node3D,p: Vector3,yaw: float,hex: String) -> void:
	var b:=K.holder(parent,"ExhibitionChair",p);b.rotation.y=yaw
	K.box(b,Vector3(0,.44,0),Vector3(.73,.10,.64),hex,false,22)
	K.box(b,Vector3(0,.73,.28),Vector3(.78,.56,.08),hex,false,22)
	for x in [-.30,.30]:
		for z in [-.24,.24]:K.box(b,Vector3(x,.22,z),Vector3(.025,.44,.025),"9ea69f",false,11)
	K.finish(b)

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"LibraryLowerArrivalV72")
	# V115 public1F points place the exhibit behind the recessed glass, not outside it.
	var plan=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
	var exhibit:=PackedVector2Array()
	for q in [[370,702],[545,702],[545,765],[510,837],[370,837]]:
		var v:Vector3=plan.point1(q[0],q[1]);exhibit.append(Vector2(v.x,v.z))
	# V241 unified public carpet includes the exhibit footprint.
	K.box(b,Vector3(-22.1,1.93,8.9),Vector3(.16,3.86,6.7),"b69c72",true,24)
	K.box(b,Vector3(-21.98,1.52,8.9),Vector3(.07,2.48,5.8),"bdab80",false,24)
	var title:=K.label(b,"OPEN YOUR MIND",Vector3(-21.91,2.93,8.9),.004);title.rotation.y=PI/2
	K.box(b,Vector3(-21.97,1.8,5.6),Vector3(.10,3.55,.22),"4e805b",false,22)
	for i in 3:
		lounge_chair(b,Vector3(-20.1,0,6.8+i*1.8),-PI/2,["ae5746","b6a142","729369"][i])
		Lobby.cylinder(b,Vector3(-18.7,.64,6.8+i*1.8),.48,.045,"c8c7b2")
		Lobby.cylinder(b,Vector3(-18.7,.31,6.8+i*1.8),.035,.62,"a3a79e")
	K.box(b,Vector3(-17.6,4.035,9),Vector3(8.4,.07,6.7),"cfcec0",false,22)
	for x in [-20,-16]:
		for z in [6.8,9.5,11.7]:Lobby.cylinder(b,Vector3(x,3.985,z),.13,.025,"eee9cf")
	var lamp:=OmniLight3D.new();lamp.position=Vector3(-18,3.5,9);lamp.light_color=Color("fff3db");lamp.light_energy=.85;lamp.omni_range=12;b.add_child(lamp)
	counter(b,plan.point1(450,850),"安保 / SECURITY",4.1)
	counter(b,plan.point1(670,902),"ITSO · 服务台",3.4,-PI/4)
	var terminal:=K.holder(b,"StudentSelfServiceTerminal",plan.point1(580,835));terminal.rotation.y=-PI/4
	K.box(terminal,Vector3(0,.72,0),Vector3(.62,1.44,.52),"b9c1b6",true,22)
	K.box(terminal,Vector3(0,1.35,.30),Vector3(.68,.55,.09),"303c3d",false,22)
	K.box(terminal,Vector3(0,1.35,.35),Vector3(.58,.43,.018),"607875",false,5)
	Services.plaque(terminal,"自助终端",Vector3(0,.70,.30),.92);K.finish(terminal)
	# Big-screen location follows room111, not an unrelated barrier in the right-wing aisle.
	var screen:=K.holder(b,"Room111Display",Vector3(-6.9,0,6.3)+Basis(Vector3.UP,-PI/4)*Vector3(0,0,1.78))
	screen.rotation.y=-PI/4
	K.box(screen,Vector3(0,1.96,0),Vector3(3.6,3.8,.16),"303532",true,22)
	K.box(screen,Vector3(0,1.98,.11),Vector3(3.2,2.10,.025),"202723",false,22)
	K.box(screen,Vector3(0,.105,.22),Vector3(3.8,.08,.38),"777c70",false,11)
	K.finish(screen)
	# Green low phone-rest strip, clear of the normal stair foot and right entrance.
	var rest:=K.holder(b,"CellphoneRestArea",plan.point1(760,820));rest.rotation.y=-PI/4
	K.box(rest,Vector3(0,.46,0),Vector3(3.4,.24,.70),"5e8770",true,22)
	for x in [-1.3,1.3]:K.box(rest,Vector3(x,.18,0),Vector3(.10,.36,.50),"909c8c",false,11)
	K.finish(rest)
	# Extend neutral carpet into the formerly bare central frontage; no lawn default here.
	# Central public strips are now built once by LibraryLowerFloor.
	K.finish(b)
