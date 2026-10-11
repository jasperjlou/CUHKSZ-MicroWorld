extends RefCounted
## Official entrance and lobby panoramas. Hall clear height has a separate historic source.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")
const STONE := "c2baaa"

static func glazing(b: Node3D,p: Vector3,width: float,height: float,yaw: float=0) -> void:
	var basis:=Basis(Vector3.UP,yaw)
	K.box(b,p,Vector3(width,height,.08),"6e929f",true,48,yaw)
	var count:=maxi(1,roundi(width/1.8))
	for i in count+1:K.box(b,p+basis*Vector3(-width/2+i*width/count,0,.05),Vector3(.09,height+.15,.17),"87918f",false,11,yaw)
	for i in maxi(1,ceili(height/3.2))+1:
		var h: float=-height/2+minf(height,i*3.2)
		K.box(b,p+basis*Vector3(0,h,.07),Vector3(width,.08,.18),"939b95",false,11,yaw)

static func glass_rail(b: Node3D,p: Vector3,width: float,yaw: float=0) -> void:
	var basis:=Basis(Vector3.UP,yaw)
	K.box(b,p+Vector3.UP*.58,Vector3(width,1.02,.05),"a9c2bf",false,19,yaw)
	K.box(b,p+Vector3.UP*1.13,Vector3(width,.065,.07),"8f978e",false,11,yaw)
	for i in maxi(1,ceili(width/1.5))+1:
		var x: float=-width/2+minf(width,i*1.5)
		K.box(b,p+basis*Vector3(x,.56,0),Vector3(.045,1.12,.06),"8b938b",false,11,yaw)

static func closed_door(b: Node3D,p: Vector3,width: float=3.4,color: String="65543c",finish: int=4) -> void:
	K.box(b,p+Vector3.UP*1.9,Vector3(width,3.8,.14),color,true,finish)
	K.box(b,p+Vector3(0,1.9,.078),Vector3(.024,3.8,.012),"504b3c",false,13)
	for x in [-.08,.08]:K.box(b,p+Vector3(x,1.5,.14),Vector3(.035,1,.055),"b9bdb2",false,11)
	K.box(b,p+Vector3.UP*3.9,Vector3(width+.2,.18,.25),"555c55",false,11)

static func build(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	preload("res://world/visual_campus/ConferenceCadPlan.gd").build(b,builder,load("res://world/visual_campus/ConferenceCentre.gd"))
