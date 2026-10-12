extends RefCounted
## WWJ's multi-level courtyard: geometry inferred within the existing East Gate anchors.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")
const LOW := -1.76
const GROUND := 2.24

static func cutout(x: float,z: float) -> bool:
	return x>12 and x<48 and z>-380 and z<-338

static func flight(b: Node3D,x: float,width: float,z0: float,z1: float) -> void:
	var steps:=26
	for i in steps:
		var y: float=GROUND-(GROUND-LOW)*(i+1)/steps
		var zz: float=lerpf(z0,z1,(i+.5)/steps);var h:=maxf(.10,y-LOW)
		K.box(b,Vector3(x,LOW+h/2,zz),Vector3(width,h,absf(z1-z0)/steps+.01),"b8bab1",false,6)
	var points:=K.quad(Vector3(x-width/2,GROUND,z0),Vector3(x+width/2,GROUND,z0),Vector3(x+width/2,LOW,z1),Vector3(x-width/2,LOW,z1))
	var collider:=K.surface(b,points,"b8bab1",6,true);collider.visible=false
	for side in [-1,1]:
		for i in 8:
			var p:=Vector3(x+side*(width/2+.1),lerpf(GROUND,LOW,i/7.0),lerpf(z0,z1,i/7.0))
			K.box(b,p+Vector3.UP*.54,Vector3(.05,1.08,.05),"68716b",false,11)
		var a:=Vector3(x+side*(width/2+.1),GROUND+1.08,z0);var c:=Vector3(a.x,LOW+1.08,z1)
		var rail:=K.holder(b,"SunkenStairContinuousRail",(a+c)/2);rail.rotation.x=-atan2(c.y-a.y,c.z-a.z)
		K.box(rail,Vector3.ZERO,Vector3(.065,.065,a.distance_to(c)),"657269",false,11);K.finish(rail)

static func covered_walk(b: Node3D,a: Vector3,c: Vector3) -> void:
	var length:=Vector2(c.x-a.x,c.z-a.z).length();var n:=K.holder(b,"UpperCoveredWalk",(a+c)/2)
	n.rotation.y=atan2(c.x-a.x,c.z-a.z)
	K.box(n,Vector3(0,-.16,0),Vector3(4.4,.32,length),"b3b5aa",true,6)
	K.box(n,Vector3(0,3.05,0),Vector3(4.7,.28,length+.2),"b1b3a5",false,18)
	K.box(n,Vector3(0,-.36,0),Vector3(4.1,.12,length),"b6b9ab",false,22)
	for side in [-1,1]:
		K.box(n,Vector3(side*2.05,1.05,0),Vector3(.07,.07,maxf(1,length-5)),"79786a",false,11)
		for i in int(length/.5):
			var zz: float=-length/2+(i+.5)*.5
			if absf(zz)>length/2-2.5:continue
			K.box(n,Vector3(side*2.15,1.65,zz),Vector3(.55,3,.10),"b2a17d",false,11)
	for i in int(length/9):
		for side in [-1,1]:
			var p:=Vector3(side*1.7,-4.4,-length/2+4+i*9)
			var site_p: Vector3=(a+c)/2+Basis(Vector3.UP,n.rotation.y)*p
			if site_p.x>28 and site_p.x<36 and site_p.z>-336 and site_p.z<-326:continue
			K.box(n,p+Vector3.UP*3.65,Vector3(.48,7.3,.48),"a7b3a6",true,22)
			var photo_white:bool=(is_equal_approx(a.z,-400.0) and is_equal_approx(c.z,-400.0)) or (is_equal_approx(a.x,56.0) and is_equal_approx(c.x,56.0))
			K.box(n,p+Vector3.UP*1.95,Vector3(.50,3.9,.50),"c9ccc1" if photo_white else "657d6e",false,22 if photo_white else 7)
		K.box(n,Vector3(0,-.44,-length/2+4+i*9),Vector3(4.4,.30,.27),"aeb6a7",false,22)
	for i in int(length/5):K.box(n,Vector3(0,2.88,-length/2+2.5+i*5),Vector3(.16,.055,1.6),"e2dfce",false,17)
	K.finish(n)

static func build(root: Node3D) -> void:
	var b:=K.holder(root,"StudentSunkenCourtyard")
	K.box(b,Vector3(30,LOW-.13,-359),Vector3(36,.26,42),"929798",true,49)
	# Continuous retaining walls and coping terminate the terrain, not floating decals.
	for x in [11.8]:
		K.box(b,Vector3(x,.24,-359),Vector3(.4,4,42.4),"9a9e96",true,7)
		K.box(b,Vector3(x,2.28,-359),Vector3(.65,.16,42.7),"b9bdb1")
	# V129 lower service passage opens through the southern retaining edge; upper rim remains.
	for interval:Vector2 in [Vector2(11.8,22),Vector2(34,48.2)]:
		K.box(b,Vector3((interval.x+interval.y)/2,.24,-380.2),Vector3(interval.y-interval.x,4,.4),"a1a497",true,7)
	K.box(b,Vector3(28,GROUND-.38,-380.2),Vector3(12,.76,.4),"c1c8c2",true,22)
	# North edge leaves the real walking stair open; seating terraces flank it.
	for interval: Vector2 in [Vector2(12,28),Vector2(36,48)]:
		K.box(b,Vector3((interval.x+interval.y)/2,.24,-337.8),Vector3(interval.y-interval.x,4,.4),"9c9e92",true,7)
	flight(b,32,8,-338,-351)
	for i in 8:
		var h: float=4.0-(i+1)*.5
		K.box(b,Vector3(23,LOW+maxf(.12,h)/2,-338-(i+.5)*1.625),Vector3(9,maxf(.12,h),1.64),"a8ab9f")
		K.box(b,Vector3(23,LOW+h+.045,-338-(i+.65)*1.625),Vector3(8.3,.08,.52),"aa8861",false,4)
	# Long western ramp links the upper lawn to the bottom, retaining the main-axis path.
	var ramp:=K.quad(Vector3(12.3,GROUND,-380),Vector3(17.7,GROUND,-380),Vector3(17.7,LOW,-350),Vector3(12.3,LOW,-350))
	K.surface(b,ramp,"aaa99c",6,true)
	# V164: complete the retained ramp edge; post-only geometry left a fall-through gap.
	# Dimensions stay fitted. Neither this edge nor the arcade is evidence of a student basement.
	var ra:=Vector3(17.9,GROUND,-380);var rb:=Vector3(17.9,LOW,-350)
	for i in 201:
		var t:=float(i)/200;var p:=ra.lerp(rb,t)
		K.box(b,p+Vector3.UP*.52,Vector3(.025,1.04,.025),"586961",false,11)
	for h in [.12,1.07]:
		var rail:=K.holder(b,"LowerCourtRampRail",(ra+rb)/2+Vector3.UP*h)
		rail.rotation.x=-atan2(rb.y-ra.y,rb.z-ra.z)
		K.box(rail,Vector3.ZERO,Vector3(.065,.065,ra.distance_to(rb)),"586961",false,11);K.finish(rail)
	# One double-sided collision strip follows the slope and stops at both landings.
	var rc:=rb+Vector3.UP*1.07;var rd:=ra+Vector3.UP*1.07
	var collision:=K.surface(b,PackedVector3Array([ra,rb,rc,ra,rc,rd,rc,rb,ra,rd,rc,ra]),"586961",11,true)
	collision.visible=false
	# Concrete side face closes the formerly paper-thin ramp above the lower courtyard.
	K.surface(b,PackedVector3Array([Vector3(17.7,LOW,-380),Vector3(17.7,GROUND,-380),Vector3(17.7,LOW,-350),Vector3(17.7,LOW,-350),Vector3(17.7,GROUND,-380),Vector3(17.7,LOW,-380)]),"a5aaa5",15,false)
	preload("res://world/visual_campus/CourtyardPublicDetail.gd").build(b)
	# Guardrails terminate at the stair and ramp access rather than crossing them.
	L.guardrail(b,Vector3(12,GROUND,-359),42,PI/2)
	L.guardrail(b,Vector3(48,GROUND,-359),42,PI/2)
	L.guardrail(b,Vector3(21,GROUND,-338),14)
	L.guardrail(b,Vector3(42,GROUND,-338),12)
	L.guardrail(b,Vector3(33,GROUND,-380),30)
	# Upper-level connection between the two existing building envelopes.
	covered_walk(b,Vector3(56,6.64,-331),Vector3(56,6.64,-382))
	covered_walk(b,Vector3(10,6.64,-331),Vector3(56,6.64,-331))
	covered_walk(b,Vector3(10,6.64,-400),Vector3(44,6.64,-400)) # V49: canopy stops at facade; open court continues inside.
	# End guards close the open promenade ends, while the far corners remain traversable.
	for z in [-331,-400]:L.guardrail(b,Vector3(10,6.64,z),4.3,PI/2)
	K.finish(b)
