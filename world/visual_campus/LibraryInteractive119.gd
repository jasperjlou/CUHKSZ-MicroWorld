extends RefCounted
## 119: registered legacy footprint + official 2026-09-23 event photographs.
## Two internal glass faces, two solid returns. Dimensions and column offsets remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
const Detail=preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const ORIGIN=Vector3(21.7,0,-14)
const YAW=PI/4
const HX=4.6
const HZ=5.3

static func point(v:Vector3)->Vector3:
	return ORIGIN+Basis(Vector3.UP,YAW)*v

static func outline()->PackedVector2Array:
	var result=PackedVector2Array()
	for v in [Vector3(-HX,0,-HZ),Vector3(HX,0,-HZ),Vector3(HX,0,HZ),Vector3(-HX,0,HZ)]:
		var p=point(v);result.append(Vector2(p.x,p.z))
	return result

static func glass(b:Node3D,a:Vector2,c:Vector2)->void:
	var count=maxi(1,int(ceil(a.distance_to(c)/1.5)))
	for i in count:
		var p=a.lerp(c,float(i)/count);var q=a.lerp(c,float(i+1)/count)
		Pods.strip(b,p,q,2.0,3.95,.065,"c3c9c3",19,true)
		K.box(b,Vector3(p.x,2.03,p.y),Vector3(.048,4.06,.048),"c2c6bb",false,11)
	for y in [.12,3.85]:Pods.strip(b,a,c,y,.055,.08,"bac1b8",11)

static func chair(b:Node3D,p:Vector3,index:int)->void:
	var n=K.holder(b,"SeminarChair",p)
	K.box(n,Vector3(0,.47,0),Vector3(.48,.07,.46),"428ba4" if index%4!=0 else "916784",true,22)
	K.box(n,Vector3(0,.78,.20),Vector3(.48,.54,.045),"a5aea5",false,44)
	for side in [-1,1]:
		K.box(n,Vector3(side*.255,.70,.015),Vector3(.055,.045,.39),"454e49",false,22)
		for z in [-.18,.18]:K.box(n,Vector3(side*.19,.23,z),Vector3(.028,.46,.028),"aab5aa",false,11)
	K.finish(n)

static func mobile_display(b:Node3D,p:Vector3)->void:
	var n=K.holder(b,"MobileTeachingDisplay",p)
	K.box(n,Vector3(0,1.05,0),Vector3(.09,1.75,.08),"65716a",false,11)
	K.box(n,Vector3(0,1.9,0),Vector3(1.32,.83,.09),"303937",true,22)
	K.box(n,Vector3(0,1.9,-.053),Vector3(1.22,.72,.014),"617980",false,22)
	for x in [-.44,.44]:
		K.box(n,Vector3(x,.13,0),Vector3(.045,.065,.70),"848e85",false,11)
		for z in [-.30,.30]:Detail.cylinder(n,Vector3(x,.075,z),.055,.11,"424c46")
	K.finish(n)

static func build(parent:Node3D)->void:
	var b=K.holder(parent,"InteractiveClassroom119",ORIGIN);b.rotation.y=YAW
	K.box(b,Vector3(0,.12,0),Vector3(HX*2,.04,HZ*2),"b7b9ae",false,25)
	# The two outside walls meet at the projecting back corner; the public faces stay glazed.
	K.box(b,Vector3(0,2.05,-HZ),Vector3(HX*2,4.1,.18),"d0d0c6",true,22)
	K.box(b,Vector3(HX,2.05,0),Vector3(.18,4.1,HZ*2),"d0d0c6",true,22)
	glass(b,Vector2(-HX,-HZ),Vector2(-HX,-4.25))
	glass(b,Vector2(-HX,-2.35),Vector2(-HX,HZ))
	glass(b,Vector2(-HX,HZ),Vector2(1.95,HZ))
	glass(b,Vector2(3.85,HZ),Vector2(HX,HZ))
	# Open paired doors at the two map-indicated accesses, not one generic centre opening.
	for spec in [[Vector3(-HX,3.55,-3.3),PI/2],[Vector3(2.9,3.55,HZ),0.0]]:
		var n=K.holder(b,"119DoorHeader",spec[0]);n.rotation.y=spec[1]
		K.box(n,Vector3.ZERO,Vector3(1.9,.8,.10),"c6cac1",false,22)
		K.box(n,Vector3(0,-.02,.07),Vector3(1.5,.28,.02),"746087",false,22)
		K.label(n,"119 · 互动教室",Vector3(0,-.02,.09),.0032)
		K.finish(n)
	# Thin pastel graphics are visible on the glass in the dated official photos.
	for i in 5:
		K.box(b,Vector3(-3.6+i*1.1,1.52,HZ-.05),Vector3(.9,.20,.012),"b9a4b8" if i%2==0 else "c7bb8d",false,22)
	# Yellow/white square acoustic panels, with the projection screen offset to the right.
	for row in 3:
		for col in 8:
			K.box(b,Vector3(-3.95+col*1.12,1.15+row*.91,-HZ+.12),Vector3(1.10,.89,.035),"d5a51c" if (col+row*2)%4==0 else "d7d8cc",false,22)
	K.box(b,Vector3(1.15,2.30,-HZ+.18),Vector3(4.5,2.75,.05),"414a43",false,22)
	K.box(b,Vector3(1.15,2.30,-HZ+.215),Vector3(4.28,2.52,.025),"d7dad1",false,22)
	K.box(b,Vector3(1.15,3.73,-HZ+.18),Vector3(4.62,.13,.18),"c6cbbf",false,11)
	# Photos prove round columns, not square stand-ins; their metric offsets are fitted.
	Detail.cylinder(b,Vector3(-2.9,2.05,-4.7),.43,4.1,"c7c8bc",true)
	Detail.cylinder(b,Vector3(-3.94,2.05,3.0),.43,4.1,"c7c8bc",true)
	K.box(b,Vector3(-.6,.55,-3.95),Vector3(1.4,1.10,.6),"b7c0aa",true,22)
	K.box(b,Vector3(-.6,1.14,-3.95),Vector3(1.48,.09,.65),"b29a72",false,43)
	K.box(b,Vector3(-2.5,1.8,-3.8),Vector3(1.5,1.3,.07),"d4dad0",false,22)
	for x in [-3.15,-1.85]:K.box(b,Vector3(x,.73,-3.8),Vector3(.035,1.4,.035),"a9b7aa",false,11)
	# Representative seminar arrangement: not an assertion of permanent furniture or capacity.
	for row in 4:
		for col in 6:
			var x:float=-2.3+col*.90+(.25 if col>=3 else 0.0)
			chair(b,Vector3(x,0,-1.9+row*1.22),row*6+col)
	for x in [-2.0,-.4,1.2]:mobile_display(b,Vector3(x,0,4.5))
	K.box(b,Vector3(0,4.06,0),Vector3(HX*2,.075,HZ*2),"c7cdc1",false,44)
	for x in [-3.0,0.0,3.0]:
		for z in [-3.4,0.0,3.4]:
			K.box(b,Vector3(x,3.992,z),Vector3(1.3,.035,1.0),"e6ecdb",false,17)
	K.box(b,Vector3(.7,3.65,-.6),Vector3(.50,.22,.43),"646f68",false,11)
	K.box(b,Vector3(.7,3.89,-.6),Vector3(.035,.40,.035),"9aaba0",false,11)
	var light=OmniLight3D.new();light.position=Vector3(0,3.1,0);light.omni_range=10;light.light_energy=.65;light.light_color=Color("f1f5e8");b.add_child(light)
	K.finish(b)
