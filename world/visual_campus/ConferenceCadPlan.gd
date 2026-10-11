extends RefCounted
## V95: coordinates read from ICC DWG middle 1F sheet, millimetres -> metres.
## x=CAD_X/1000-1290; z=-CAD_Y/1000-1244. Site registration remains fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const STONE := "c2baaa"

static func slab(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.16,(z0+z1)/2),Vector3(x1-x0,.32,z1-z0),"b9bdb2",true,12)

static func build(b: Node3D,builder,detail) -> void:
	# Auditorium and stage form the broad rear arm; music hall is the narrower return.
	K.box(b,Vector3(3,12.5,-16),Vector3(50,15,40),STONE,true,47)
	K.box(b,Vector3(3,20.12,-16),Vector3(50.5,.24,40.5),"a6aa9c",true,18)
	K.box(b,Vector3(18,22.1,-16),Vector3(20,10.8,25),STONE,true,47)
	K.box(b,Vector3(18,27.6,-16),Vector3(20.3,.20,25.3),"a5aa9e",true,18)
	# Lower enclosure, with the observed recessed door arcade on the outward hall edge.
	K.box(b,Vector3(3,2.5,-15.5),Vector3(50,5,39),STONE,true,47)
	var arcade:=K.holder(b,"HallRearDoorArcade",Vector3(0,3.8,-36));arcade.rotation.y=PI
	for x in [-17.0,-7.0,3.0,13.0]:
		detail.closed_door(arcade,Vector3(x,0,.18),4,"947345",22)
		for i in 4:K.box(arcade,Vector3(x-1.5+i,.13,2.2),Vector3(.94,.025,1.46),"375b50",false,27)
	for x in [-22.0,-12.0,-2.0,8.0,18.0,23.0]:K.column(arcade,Vector3(x,0,2.4),5,.58)
	K.box(arcade,Vector3(.5,4.82,1.6),Vector3(51,.32,5.1),"bfc2b6",true,15)
	for x in range(-23,25,2):
		for z in range(0,4,2):K.box(arcade,Vector3(x,4.64,z+1),Vector3(1.97,.035,1.97),"bec2b8",false,20)
	K.finish(arcade)
	for y in [10.6,13.7,16.8]:
		for x in [-15,-12,0,3,16,19]:K.window(b,Vector3(x,y,-36.08),1.35,.82,PI)
	# Hill-side service strip has a setback in the original plan.
	K.box(b,Vector3(-25,5,-11),Vector3(6,10,30),STONE,true,47)
	K.box(b,Vector3(-16.8,7.5,8),Vector3(10,5,8),STONE,true,47)
	K.box(b,Vector3(18.6,10.4,15),Vector3(20.8,10.8,22),STONE,true,47)
	K.box(b,Vector3(18.6,15.95,21.3),Vector3(21.4,.3,35.2),"a4aa9e",true,18)
	# Long, off-centre foyer: floor +0.000, five metres above the lower lounge in the CAD.
	slab(b,-11.7,8.2,4.2,40,5)
	K.box(b,Vector3(-1.75,19.42,21.4),Vector3(20.3,.24,34.8),"a5a99d",true,18)
	K.box(b,Vector3(-11.7,12.1,21.4),Vector3(.4,14.2,34.4),STONE,true,47)
	K.box(b,Vector3(8.2,12.1,21.4),Vector3(.4,14.2,34.4),STONE,true,47)
	K.box(b,Vector3(-1.75,12.1,4.2),Vector3(19.9,14.2,.3),"ab9270",true,4)
	# Entrance curtain wall and name fascia are supported by the official entrance panorama.
	detail.glazing(b,Vector3(-1.75,13.65,38.6),19.9,9.3)
	for span:Vector2 in [Vector2(-11.7,-4.5),Vector2(1.0,8.2)]:detail.glazing(b,Vector3((span.x+span.y)/2,6.9,38.6),span.y-span.x,3.8)
	for x in [-10,-4,2,7]:
		K.box(b,Vector3(x,13.65,38.73),Vector3(.62,9.3,.10),"b4bbb5",false,11)
		K.column(b,Vector3(x,5,37.6),14.1,.42)
	K.box(b,Vector3(-1.75,8.9,38.78),Vector3(20,.18,.7),"aeb5aa",false,11)
	K.box(b,Vector3(-1.75,18.6,38.77),Vector3(20,1.4,.22),"d1cec0",false,15)
	var cn:=K.label(b,"逸夫国际会议中心",Vector3(-1.75,18.87,38.94),.014);cn.modulate=Color("465151")
	var en:=K.label(b,"Run Run Shaw International Conference Centre",Vector3(-1.75,18.34,38.94),.0047);en.modulate=Color("465151")
	for x in [-4.5,1.0]:K.box(b,Vector3(x,6.9,38.77),Vector3(.12,3.8,.25),"4b5851",true,11)
	# Ground supports under the actual narrow foyer, leaving the outside avenue uncovered.
	for x in [-11.7,8.2]:
		for z in [7,17,27,38]:K.column(b,Vector3(x,0,z),4.84,.6)
	for z in [7,17,27,37]:K.box(b,Vector3(-1.75,4.60,z),Vector3(19.9,.40,.45),"b8bcaf",false,22)
	for x in range(-10,8,2):
		for z in range(6,40,2):K.box(b,Vector3(x,4.79,z),Vector3(1.97,.025,1.97),"bdc1b6",false,20)
	# CAD 9# stair position is retained approximately; unseen fit-out stays simple.
	builder.stairs(b,Vector3(-7,5,21),Vector3(-7,10,12),2.8,30)
	slab(b,-11.7,8.2,4.3,12,10)
	for span:Vector2 in [Vector2(-11.7,-8.7),Vector2(-5.3,8.2)]:P.rail(b,Vector3(span.x,10,12),Vector3(span.y,10,12))
	for x in [-5,3]:detail.closed_door(b,Vector3(x,5,4.42),2.8)
	for z in [9,17,25,33]:K.box(b,Vector3(-1.75,19.18,z),Vector3(18,.07,.18),"e1dfcc",false,17)
	# Lower public lounge beneath the projecting glazed volume; no false 1F slab across its void.
	slab(b,8.2,29,4,38.6,.10)
	K.box(b,Vector3(18.6,2.55,26),Vector3(20.8,4.9,.30),STONE,true,47)
	K.box(b,Vector3(8.2,2.55,32.3),Vector3(.30,4.9,12.6),STONE,true,47)
	K.box(b,Vector3(29,7.85,32.3),Vector3(.36,15.5,12.6),STONE,true,47)
	detail.glazing(b,Vector3(18.6,9.8,38.6),20.8,11.8)
	for span:Vector2 in [Vector2(8.2,16),Vector2(21,29)]:detail.glazing(b,Vector3((span.x+span.y)/2,2,38.6),span.y-span.x,3.8)
	K.box(b,Vector3(8.6,9.3,38.85),Vector3(1.15,12.7,.42),STONE,true,47)
	K.box(b,Vector3(8.6,10.3,39.09),Vector3(.80,8.3,.035),"786387",false,4)
	K.label(b,"博\n文\n约\n礼",Vector3(8.6,10.3,39.15),.013)
	# Internal level difference remains5m; outdoor approach uses the independent CAD datums.
	for x in [-8.65,-5.35]:P.rail(b,Vector3(x,5,21),Vector3(x,10,12))
	preload("res://world/visual_campus/ConferenceEntrySite.gd").build(b,builder)
	preload("res://world/visual_campus/ConferenceEnvelope.gd").build(b)
