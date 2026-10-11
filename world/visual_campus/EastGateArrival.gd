extends RefCounted
## Official East Gate vehicle-entry scene 116410030 / 70013461.
## Keep the established origin. This is not registration of the ceremonial gate photo.
## V66 relocates the observed vehicle equipment beside the ceremonial axis.
## Sidewalk widths, tree spacing and equipment offsets are fitted, not surveyed.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func slab(b: Node3D,x0: float,x1: float,z0: float,z1: float,color: String) -> void:
	K.box(b,Vector3((x0+x1)/2,.092,(z0+z1)/2),Vector3(x1-x0,.035,z1-z0),color,false,31)

static func tree_pit(b: Node3D,x: float,z: float,seed_value: int) -> void:
	# Four stone coping pieces and a planted opening, rather than grass over paving.
	K.box(b,Vector3(x,.10,z),Vector3(3.7,.10,4.7),"4b603b",false,3)
	for side in [-1,1]:
		K.box(b,Vector3(x+side*1.95,.19,z),Vector3(.20,.20,5.1),"aeb4aa",true,26)
		K.box(b,Vector3(x,.19,z+side*2.45),Vector3(3.7,.20,.20),"aeb4aa",true,26)
	K.tree(b,Vector3(x,.15,z),7.3,seed_value)
	# The source has tripod braces around young street trees.
	for angle in [0.0,TAU/3,TAU*2/3]:
		var foot:=Vector3(x+cos(angle)*1.3,.24,z+sin(angle)*1.3)
		var top:=Vector3(x,2.6,z)
		var brace:=K.holder(b,"TreeBrace")
		brace.look_at_from_position((foot+top)/2,top,Vector3.UP)
		K.box(brace,Vector3.ZERO,Vector3(.065,.065,foot.distance_to(top)),"a1ac98",false,22)
		K.finish(brace)

static func build(gate: Node3D,builder) -> void:
	var b:=K.holder(gate,"VehicleEntrySidewalks")
	var portal=preload("res://world/visual_campus/EastGatePortal.gd")
	# Camera 70013461 stands by the right-hand vehicle entrance; campus origin stays 0.
	portal.field(b,builder,18.5,24.5,-35,43,"858c88")
	portal.field(b,builder,33.5,42,-55,43,"858c88")
	portal.field(b,builder,-26,-20,-14,43,"858c88")
	for x in [24.5,33.5]:
		builder.ribbon(b,[[x,0,43],[x,0,-55]],.25,"adb3a7",26,.128)
		builder.ribbon(b,[[x+.19,0,43],[x+.19,0,-55]],.045,"424943",22,.13)
	# Wide route ribbons only sample the two edges and cut through the crowned
	# fitted grade. Subdivide the asphalt at its terrain knee instead.
	portal.field(b,builder,24.5,25,-55,60,"414b4c",2)
	portal.field(b,builder,25,33.5,-55,60,"414b4c",2)
	for z in range(-53,60,9):
		if z>=-5 and z<=4:continue
		var a:=Vector3(28.94,builder.height(29,z-1.3)+.148,z-1.3)
		var c:=Vector3(29.06,builder.height(29,z+1.3)+.148,z+1.3)
		K.surface(b,K.quad(a,Vector3(c.x,a.y,a.z),c,Vector3(a.x,c.y,c.z)),"d1b462",22)
	# Guide strip and tree pits stay out of both the ceremonial paths and roadway.
	for x in [-23.0,21.3,39.2]:
		builder.ribbon(b,[[x,0,42],[x,0,17]],.36,"989984",31,.12)
	for item in [Vector2(-23,28),Vector2(19,28),Vector2(39,30)]:tree_pit(b,item.x,item.y,6600+int(item.x+item.y))
	var equipment:=K.holder(b,"RightVehicleEquipment",Vector3(29,0,0))
	K.box(equipment,Vector3(0,.20,-.5),Vector3(1.0,.28,5.8),"b3ac92",true,26)
	K.box(equipment,Vector3(0,1.15,0),Vector3(.45,1.9,.48),"505951",true,22)
	K.box(equipment,Vector3(0,2.22,0),Vector3(.48,.32,.52),"9a9e8b",false,22)
	for side in [-1,1]:
		var arm:=K.holder(equipment,"RaisedVehicleArm",Vector3(side*.30,1.55,0))
		arm.rotation.z=side*.30
		K.box(arm,Vector3(0,1.85,0),Vector3(.09,3.7,.10),"cecba9",false,22)
		for y in [.5,1.3,2.1,2.9]:K.box(arm,Vector3(0,y,.06),Vector3(.095,.26,.035),"954e3c",false,22)
		K.finish(arm)
	K.finish(equipment)
	# Full official cube face, including its right-hand tile, locates the booth on the right.
	K.box(b,Vector3(37.0,1.45,9),Vector3(3.2,2.9,4.5),"aeb4a7",true,22)
	K.window(b,Vector3(37.0,1.8,11.29),2.5,1.25)
	K.window(b,Vector3(35.36,1.8,9),3.2,1.25,-PI/2)
	K.box(b,Vector3(37.0,2.94,9),Vector3(3.7,.14,5.0),"d0d2c5",false,22)
	for x in [-19.0,-10.0,10.0,19.0]:
		K.box(b,Vector3(x,.38,17),Vector3(.22,.56,.22),"aeb5a9",true,22)
	K.finish(b)
