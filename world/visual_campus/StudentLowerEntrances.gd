extends RefCounted
## V151: rear doors traced from architect 1F, fitted to the retained V49 envelope.
## This is not a surveyed datum or evidence that the rear street is at actual 1F.
const K = preload("res://world/visual_campus/VisualCampusKit.gd")
const REAR_MAIN_X: float = -9.6
const REAR_SIDE_X: float = -24.0

static func door(n: Node3D, p: Vector3, width: float, height: float=3.25, yaw: float=0) -> void:
	var h:=K.holder(n,"RecessedOpenDoor",p);h.rotation.y=yaw
	for side in [-1,1]:
		K.box(h,Vector3(side*(width/2+.06),height/2,0),Vector3(.12,height,.34),"545e5c",true,11)
		# Open leaves sit against the inner reveals, outside the clear route.
		K.box(h,Vector3(side*(width/2+.12),height/2,-.55),Vector3(.08,height-.12,1.04),"82948b",true,19)
		for z in [-.08,-1.04]:K.box(h,Vector3(side*(width/2+.12),height/2,z),Vector3(.10,height,.06),"65706b",false,11)
		K.box(h,Vector3(side*(width/2+.04),1.2,-.75),Vector3(.035,.38,.035),"b1b8b0",false,11)
	K.box(h,Vector3(0,height+.06,0),Vector3(width+.24,.12,.34),"59625e",true,11)
	K.box(h,Vector3(0,.036,-.08),Vector3(width,.072,.8),"aaa99d",true,26)
	K.finish(h)

static func rear(n: Node3D) -> void:
	var h:=K.holder(n,"StudentRearGroundEntries")
	for spec in [[REAR_MAIN_X,2.8],[REAR_SIDE_X,2.6]]:
		var x:float=spec[0];var w:float=spec[1]
		door(h,Vector3(x,0,-46.6),w,3.25,PI)
		# Deep masonry opening, not a full-storey missing facade bay.
		for side in [-1,1]:K.box(h,Vector3(x+side*(w/2+.12),1.8,-47.05),Vector3(.24,3.6,1.4),"a4aaa4",true,7)
		K.box(h,Vector3(x,4.02,-47.05),Vector3(w+.48,.76,1.4),"a4aaa4",true,7)
		K.box(h,Vector3(x,3.48,-46.64),Vector3(w,.42,.12),"74877f",true,19)
		K.box(h,Vector3(x,.036,-48.25),Vector3(w+.6,.072,3.7),"a9aca2",true,26)
		K.box(h,Vector3(x,3.37,-47.87),Vector3(.35,.09,.16),"dedbd0",false,22)
	# Plan029 rear stair-lobby passage: right image edge to the inner hall.
	# Closed side rooms are kept neutral; their programme and full stairs remain pending.
	for x in [-11.23,-7.97]:K.box(h,Vector3(x,2.1,-40.2),Vector3(.26,4.2,12.8),"b9bbae",true,22)
	K.box(h,Vector3(REAR_MAIN_X,.036,-40.2),Vector3(3.0,.072,12.8),"b5b3a7",true,26)
	K.box(h,Vector3(REAR_MAIN_X,4.12,-40.2),Vector3(3.26,.16,12.8),"c5c6ba",true,22)
	for z in [-44.8,-40.4,-36]:K.box(h,Vector3(REAR_MAIN_X,4.01,z),Vector3(.22,.05,1.2),"f1ede0",false,22)
	# Narrow closed service leaf on the core side of the lobby.
	K.box(h,Vector3(-11.075,1.38,-42.5),Vector3(.04,2.7,1.2),"8a9390",false,11)
	for z in [-43.13,-41.87]:K.box(h,Vector3(-11.035,1.38,z),Vector3(.07,2.82,.07),"5e6661",false,11)
	for y in [2.38,2.49,2.60]:K.box(h,Vector3(-11.04,y,-42.5),Vector3(.045,.035,1.02),"59635e",false,11)
	K.finish(h)

static func court_door(n: Node3D,x: float,z: float,low: float,high: float) -> void:
	door(n,Vector3(x,low,z-.1),1.6,2.75)
	var h:float=high-low-3.15
	K.box(n,Vector3(x,low+2.9+h/2,z-.13),Vector3(1.6,h,.10),"6c8580",true,19)
	K.box(n,Vector3(x,low+2.84,z),Vector3(1.7,.12,.2),"58665f",true,11)
	for y in [low+1.15,low+2.85,low+4.4,high-1.1]:
		if y>low+2.8:K.box(n,Vector3(x,y,z+.03),Vector3(1.64,.06,.16),"58665f",false,11)

static func lower_hall(n: Node3D) -> void:
	var h:=K.holder(n,"StudentLowerCourtVestibule")
	# Stone threshold strip in the open 1F hall. Do not invent a low ceiling or rooms:
	# the section places this volume beneath the higher, next courtyard slab.
	K.box(h,Vector3(0,.044,8.1),Vector3(24,.088,7.6),"b1aea1",true,26)
	for x in [-6.3,2.1]:
		K.box(h,Vector3(x,2.72,12.23),Vector3(.24,.20,.23),"b5bcb3",false,11)
		K.box(h,Vector3(x,2.68,12.36),Vector3(.24,.07,.05),"ede8d6",false,22)
	K.finish(h)
