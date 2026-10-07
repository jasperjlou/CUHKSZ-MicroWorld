extends RefCounted
const K:=preload("res://world/campus_exterior/ExteriorArchitectureKit.gd")
const Text:=preload("res://systems/ChineseText.gd")
const MODULES: Array[String]=["InteriorFloorLight","InteriorFloorDark","InteriorWallWhite","InteriorStoneWall","InteriorGlassWall","InteriorColumn","InteriorCeilingGrid","InteriorCeilingFlat","InteriorLightPanel","InteriorDoorSingle","InteriorDoorDouble","InteriorGlassDoor","InteriorStairStraight","InteriorStairWide","InteriorLanding","InteriorRamp","InteriorRailing","InteriorReceptionDesk","InteriorBench","InteriorSofa","InteriorTable","InteriorStudyDesk","InteriorShelf","InteriorNoticeBoard","InteriorWayfinding","InteriorPlant","InteriorCounter","InteriorQueueBarrier"]
static func box(root: Node3D,p: Vector3,size: Vector3,key: String="warm_white",solid: bool=false) -> MeshInstance3D:
	return K.box(root,p,size,key,solid)
static func lettering(root: Node3D,words: String,p: Vector3,size: float=.018) -> Label3D:
	var label:=Label3D.new();label.text=words;label.font=Text.FONT;label.font_size=64;label.pixel_size=size;label.position=p;label.modulate=Color("344d4a");label.outline_size=0;root.add_child(label);return label
static func desk(root: Node3D,p: Vector3,study: bool=true) -> void:
	box(root,p+Vector3(0,1.12,0),Vector3(2.6,.16,1.25),"wood_accent",true)
	for side in [-1,1]:box(root,p+Vector3(side*.95,.54,0),Vector3(.12,1.08,.75),"dark_frame")
	if study:
		box(root,p+Vector3(0,.68,.95),Vector3(.9,.18,.9),"glass_bluegray")
		box(root,p+Vector3(0,1.13,1.32),Vector3(.9,1,.13),"glass_bluegray")
static func sofa(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3(0,.65,0),Vector3(3.5,.6,1.35),"glass_bluegray",true)
	box(root,p+Vector3(0,1.22,-.58),Vector3(3.5,1.2,.23),"glass_bluegray")
	for side in [-1,1]:box(root,p+Vector3(side*1.7,.95,0),Vector3(.22,.8,1.4),"glass_bluegray")
static func shelf(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3(0,1.75,0),Vector3(3.2,3.5,.7),"wood_accent",true)
	for row in 4:
		box(root,p+Vector3(0,.4+row*.78,.4),Vector3(3,.08,.85),"warm_white")
		var transforms: Array[Transform3D]=[]
		for i in 12:transforms.append(Transform3D(Basis.IDENTITY,p+Vector3(-1.35+i*.24,.73+row*.78,.46)))
		K.batch(root,transforms,Vector3(.17,.53,.24),"glass_bluegray" if row%2==0 else "light_stone")
static func plant(root: Node3D,p: Vector3) -> void:
	box(root,p+Vector3.UP*.45,Vector3(.85,.9,.85),"light_stone")
	box(root,p+Vector3.UP*1.4,Vector3(1.3,1.4,1.3),"60826a")
static func board(root: Node3D,p: Vector3,words: String) -> void:
	box(root,p,Vector3(4,2.9,.15),"wood_accent")
	box(root,p+Vector3(0,0,.1),Vector3(3.8,2.7,.05),"warm_white")
	lettering(root,words,p+Vector3(0,0,.15),.011)
static func ramp(root: Node3D,start: Vector3,end: Vector3,width: float) -> void:
	var run: float=Vector2(end.x-start.x,end.z-start.z).length();var rise: float=end.y-start.y
	var shape:=BoxMesh.new();shape.size=Vector3(width,.18,sqrt(run*run+rise*rise))
	var node:=MeshInstance3D.new();node.mesh=shape;node.material_override=K.material("light_stone");node.position=(start+end)/2-Vector3.UP*.09
	node.rotation.x=atan2(rise,run);root.add_child(node)
	var body:=StaticBody3D.new();node.add_child(body);var collision:=CollisionShape3D.new();var volume:=BoxShape3D.new();volume.size=shape.size;collision.shape=volume;body.add_child(collision)
	# A shallow smooth collider supports the unchanged controller. Visible treads sit flush.
	for i in 25:
		var t: float=i/25.0;box(root,start.lerp(end,t)+Vector3.UP*.035,Vector3(width,.07,run/25+.03),"warm_white")
	for side in [-1,1]:
		var rail:=box(root,(start+end)/2+Vector3(side*(width/2+.15),1.55,0),Vector3(.09,.09,sqrt(run*run+rise*rise)),"dark_frame",true);rail.rotation.x=atan2(rise,run)
static func lights(root: Node3D,w: float,d: float,h: float) -> void:
	for x in [-w*.3,0.0,w*.3]:
		for z in [-d*.3,0.0,d*.3]:
			var panel:=box(root,Vector3(x,h-.17,z),Vector3(2.5,.08,1.3),"f3f0d9")
			panel.material_override=preload("res://world/MeshKit.gd").material(Color("efe8cf"),true)
	for x in [-w*.25,0.0,w*.25]:box(root,Vector3(x,h-.05,0),Vector3(.06,.05,d),"concrete_gray")
	# Shared palette/ambient: no dynamic shadow lights.
static func glass(root: Node3D,p: Vector3,size: Vector3) -> void:
	var pane:=box(root,p,size,"glass_bluegray",true)
	var material:=StandardMaterial3D.new();material.albedo_color=Color(.47,.65,.67,.2);material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;material.cull_mode=BaseMaterial3D.CULL_DISABLED;material.roughness=.3;pane.material_override=material
static func finish(root: Node3D) -> void:
	K.bake(root)
