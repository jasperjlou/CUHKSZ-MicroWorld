extends RefCounted
## V41: three upper window rows ABOVE the separate 4F terrace/undercroft.
## Official panorama 116443793, f/r faces. Heights and corner position remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const TERRACE := 12.4
const UPPER_BASE := 16.1

static func elevation(b: Node3D,w: float,z: float) -> void:
	for floor in 3:
		var base: float=UPPER_BASE+floor*3.7
		for cell in range(1,9):
			var x: float=-w/2+(cell+.5)*w/10;var width: float=w/10
			var opening: float=1.2 if cell in [2,7] else width-2.32
			K.box(b,Vector3(x,base+.56,z),Vector3(width,1.12,.28),"bcc2c0",true,20)
			K.box(b,Vector3(x,base+3.34,z),Vector3(width,.72,.28),"bcc2c0",true,20)
			var pier: float=(width-opening)/2
			for side in [-1,1]:K.box(b,Vector3(x+side*(width/2-pier/2),base+2.06,z),Vector3(pier,1.88,.28),"b9c0bd",true,20)
			K.window(b,Vector3(x,base+2.06,z+.075),opening,1.88,PI)
			if opening>2:
				for split in [-1,1]:K.box(b,Vector3(x+split*opening/6,base+2.06,z-.1),Vector3(.055,1.88,.09),"9aa8a8",false,11)
		K.box(b,Vector3(0,base+3.65,z-.19),Vector3(w,.12,.43),"9ba7a2",false,11)
	# Full-height glazed end returns, visible beside the opaque rear window bands.
	for side in [-1,1]:
		var x: float=side*(w/2-w/20)
		C.glazing(b,Vector3(x,21.65,z),w/10,11.1,PI)
		# Opaque reflection backing prevents the office volume reading as an empty glass cage.
		K.box(b,Vector3(x,21.65,z+.09),Vector3(w/10,11.1,.06),"516d79",false,5)
	# The shared upper slab supplies the soffit; a second coplanar slab caused flicker.
	K.box(b,Vector3(0,16.08,z-.18),Vector3(w,.22,.40),"66736e",false,11)
	for x in range(-36,40,6):
		for zz in [z+2.5,z+7.5,z+12.5]:K.box(b,Vector3(x,15.847,zz),Vector3(.17,.018,.17),"d1d8c1",false,17)

static func corner_lobby(b: Node3D,z: float) -> void:
	# Photographed corner entrance: dark core beside a recessed glazed lobby under the cantilever.
	# Only this visible public threshold is modelled; internal offices/core circulation are unknown.
	var n:=K.holder(b,"Administration4FCornerLobby")
	K.box(n,Vector3(21.5,14.2,z+5.8),Vector3(9,3.6,11.6),"505952",true,22)
	C.closed_door(n,Vector3(21.5,TERRACE,z-.12),1.45,"354441",11)
	K.box(n,Vector3(21.5,15.45,z-.65),Vector3(2.2,.09,1.4),"748785",false,19)
	K.box(n,Vector3(32,12.24,z+5.8),Vector3(12,.32,11.6),"a4a99e",true,26)
	K.box(n,Vector3(32,14.2,z+11.6),Vector3(12,3.6,.20),"798578",true,22)
	# Split glazing leaves a real walkable portal; the two open leaves sit inside, clear of the aisle.
	for span: Vector2 in [Vector2(26,30.2),Vector2(33.8,38)]:
		C.glazing(n,Vector3((span.x+span.y)/2,14.18,z),span.y-span.x,3.56,PI)
	C.glazing(n,Vector3(32,15.65,z),3.6,.58,PI)
	C.glazing(n,Vector3(38,14.18,z+5.8),11.6,3.56,PI/2)
	for side in [-1,1]:
		K.box(n,Vector3(32+side*1.8,13.86,z),Vector3(.09,2.92,.18),"7d8b85",true,11)
		C.glazing(n,Vector3(32+side*1.8,13.85,z+.85),1.7,2.86,PI/2)
	K.box(n,Vector3(32,15.48,z-.85),Vector3(5.2,.11,1.9),"748986",false,19)
	for x in [30,34]:K.box(n,Vector3(x,15.46,z-.8),Vector3(.06,.13,1.8),"a9b2a8",false,11)
	K.box(n,Vector3(30,15.8,z+5),Vector3(.18,.04,4),"e2e1ca",false,17)
	K.label(n,"4F",Vector3(34.5,14.4,z-.12),.005).rotation.y=PI
	K.finish(n)

static func terrace_returns(b: Node3D,w: float) -> void:
	# Connect the retained central platform to each low-wing roof, with solid retaining edges.
	for side in [-1,1]:
		var width: float=w/2-20;var x: float=side*(20+width/2)
		K.box(b,Vector3(x,12.24,-29),Vector3(width,.32,8),"aaa99c",true,26)
		K.box(b,Vector3(x,6.2,-33),Vector3(width,12.4,.36),"939b8c",true,15)
		C.glass_rail(b,Vector3(x,TERRACE,-33),width)
		C.glass_rail(b,Vector3(side*w/2,TERRACE,-29),8,PI/2)
	# Red-brown entrance strip and drain follow the relocated corner doorway.
	K.box(b,Vector3(32,12.415,-24.3),Vector3(12,.02,2.8),"a18472",false,7)
	K.box(b,Vector3(32,12.417,-25.8),Vector3(12,.024,.17),"67746b",false,13)

static func stair_guards(b: Node3D) -> void:
	# Existing glass rails had no physical guard. Keep their meshes and add only collision here.
	var guard:=StaticBody3D.new();guard.name="AdministrationUpperStairGuards";b.add_child(guard)
	for x in [-10.0,10.0]:
		var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new()
		shape.size=Vector3(.09,1.1,11.4);collider.shape=shape
		collider.position=Vector3(x,12.95,-31.8);guard.add_child(collider)
	var overlook:=CollisionShape3D.new();var barrier:=BoxShape3D.new()
	barrier.size=Vector3(.09,1.1,5.6);overlook.shape=barrier
	overlook.position=Vector3(10.4,13.55,-41.8);guard.add_child(overlook)
