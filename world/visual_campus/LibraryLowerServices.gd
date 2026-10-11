extends RefCounted
## Public lower-level service identities from the official 2024-01-labelled 1F map.
## These fitted inserts do not establish surveyed placement or hidden-room furnishings.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func plaque(b: Node3D,text: String,p: Vector3,width: float=2.2) -> void:
	K.box(b,p,Vector3(width,.40,.055),"655479",false,22)
	K.label(b,text,p+Vector3(0,0,.04),.0038)

static func studio(b: Node3D,p: Vector3,title: String,yaw: float) -> void:
	var n:=preload("res://world/visual_campus/LibraryStudyPods.gd").single(b,p,title,2.5,3.2,yaw)
	K.box(n,Vector3(0,.75,-.6),Vector3(2.1,.09,.7),"baa885",true,4)
	K.box(n,Vector3(0,1.15,-.8),Vector3(.85,.52,.08),"343e3f",false,22)
	K.box(n,Vector3(0,1.15,-.75),Vector3(.77,.43,.015),"617778",false,5)
	# Rounded shell already carries the room number; keep the glazing unobstructed.
	K.finish(n)

static func silence_cell(b: Node3D,p: Vector3,title: String,yaw:float=-PI/2) -> void:
	var n:=K.holder(b,"SilenceCell"+title,p);n.rotation.y=yaw
	for side in [-1,1]:K.box(n,Vector3(side*.65,1.25,0),Vector3(.09,2.5,1.3),"adada2",true,22)
	K.box(n,Vector3(0,1.25,-.65),Vector3(1.3,2.5,.09),"b2b3a4",true,22)
	K.box(n,Vector3(0,2.48,0),Vector3(1.4,.10,1.4),"adb5a8",false,22)
	K.box(n,Vector3(.48,1.25,.65),Vector3(.26,2.5,.06),"9bb1a6",true,19)
	K.box(n,Vector3(0,.85,-.36),Vector3(1.1,.07,.45),"b6a17f",true,4)
	plaque(n,title,Vector3(0,2.23,.72),1.0);K.finish(n)

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"LowerLibraryServices")
	# V104 one shared capsule in LibraryLowerRightWing owns117/118.
	# Silence cells face inward from the non-pond outer aisle.
	silence_cell(b,Vector3(43.75,0,3.3),"S101",-PI*.75)
	silence_cell(b,Vector3(41.05,0,6.0),"S102",-PI*.75)
	# V72 arrival module owns the separately registered security and ITSO counters.
	# V107 service devices sit beside, not in front of, the registered diagonal lift/WC lobby.
	var core=preload("res://world/visual_campus/LibraryDiagonalCore.gd")
	var services=K.holder(b,"DiagonalLobbyPrinterWater",core.point(Vector3(5.5,0,-1.5)));services.rotation.y=PI/4
	K.box(services,Vector3(0,.5,0),Vector3(1.25,1,.8),"c6c7b8",true,22)
	K.box(services,Vector3(0,.94,.12),Vector3(1.2,.1,.6),"6f7970",false,11)
	K.box(services,Vector3(0,.78,.42),Vector3(.72,.11,.055),"444f49",false,22)
	K.box(services,Vector3(0,.55,2.5),Vector3(.8,1.1,.65),"a6b2ab",true,11)
	K.box(services,Vector3(0,1.2,2.5),Vector3(.8,.10,.65),"657d74",false,11)
	K.finish(services)
	K.finish(b)
