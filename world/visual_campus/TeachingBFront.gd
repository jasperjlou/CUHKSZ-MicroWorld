extends RefCounted
## V42: anniversary / official aerial hierarchy: low screened promenade, set-back glazing,
## and projecting metal-and-glass end cap. Dimensions use fitted existing floor datums.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func window_wall(b: Node3D,p: Vector3,width: float,height: float,yaw: float=0) -> void:
	K.box(b,p,Vector3(width,height,.12),"546f79",true,5,yaw)
	var basis:=Basis(Vector3.UP,yaw)
	for i in ceili(width/1.7)+1:
		var x: float=-width/2+minf(width,i*1.7)
		K.box(b,p+basis*Vector3(x,0,.10),Vector3(.065,height,.19),"818e88",false,11,yaw)
	for y in [-height/2,0,height/2]:K.box(b,p+Vector3.UP*y,Vector3(width,.12,.22),"89958c",false,11,yaw)

static func end_block(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"TeachingBGlazedEnd",Vector3(float(r.width)*.24,0,float(r.depth)*.36))
	var w: float=float(r.width)*.33;var d: float=float(r.depth)*.20
	# Open ground arcade below the recessed upper glazing.
	for x in [-w/2+1,w/2-1]:
		for z in [-d/2+1,d/2-1]:K.column(n,Vector3(x,0,z),8.38,.65)
	for y in [8.5,12.2,15.9]:K.box(n,Vector3(0,y,0),Vector3(w,.25,d),"aeb2a8",true,15)
	for side in [-1,1]:
		window_wall(n,Vector3(0,12.2,side*d/2),w,7.15,0 if side>0 else PI)
		window_wall(n,Vector3(side*w/2,12.2,0),d,7.15,side*PI/2)
	# Metal upper cap projects beyond the recessed glass; the front is a tall glazed strip.
	var cw: float=w+4;var cd: float=d+3
	K.box(n,Vector3(0,15.83,0),Vector3(cw,.22,cd),"64716d",true,20)
	K.box(n,Vector3(0,19.61,0),Vector3(cw,.24,cd),"959e98",true,20)
	for z in [-cd/2,cd/2]:
		window_wall(n,Vector3(0,17.72,z),cw,3.52,0 if z>0 else PI)
		for i in ceili(cw/.9):K.box(n,Vector3(-cw/2+(i+.5)*cw/ceili(cw/.9),17.72,z+signf(z)*.21),Vector3(.075,3.7,.33),"7c8a86",false,11)
	for side in [-1,1]:
		K.box(n,Vector3(side*cw/2,18.95,0),Vector3(.24,1.16,cd),"a2aba6",true,20)
		K.box(n,Vector3(side*cw/2,16.59,0),Vector3(.24,1.30,cd),"a2aba6",true,20)
		window_wall(n,Vector3(side*cw/2,17.73,0),cd,1.0,side*PI/2)
	K.finish(n)

static func promenade(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"TeachingBScreenedPromenade")
	var front: float=float(r.depth)*.46;var w: float=float(r.width)*.94
	# The first-floor inner gallery stays separate from this higher long roof.
	K.box(n,Vector3(-1,8.5,front-5.0),Vector3(w,.26,11.6),"a6aea4",true,15)
	K.box(n,Vector3(-1,8.32,front-5.0),Vector3(w,.08,11.6),"b8bcb0",false,22)
	for x in [-32,-24,-6,2,30]:
		K.box(n,Vector3(x,4.18,front-.9),Vector3(.48,8.36,.48),"b9bcb6",true,22)
		K.box(n,Vector3(x,8.04,front-5),Vector3(.38,.48,11.4),"a9b3a4",false,22)
	for i in ceili(w/.40):
		var x: float=-1-w/2+(i+.5)*w/ceili(w/.40)
		var low: float=3.90 if absf(x+13.0)<3.2 else 2.68
		K.box(n,Vector3(x,(low+8.28)/2,front+.38),Vector3(.075,8.28-low,.56),"98784f",false,11)
	K.box(n,Vector3(-1,8.25,front+.03),Vector3(w,.1,.15),"66705d",false,11)
	for span: Vector2 in [Vector2(-1-w/2,-16.2),Vector2(-9.8,-1+w/2)]:
		K.box(n,Vector3((span.x+span.y)/2,2.69,front+.03),Vector3(span.y-span.x,.1,.15),"66705d",false,11)
	# Recessed deck edge stays behind the screen; a guard closes its exposed edge.
	K.box(n,Vector3(0,5.47,front-.60),Vector3(float(r.width)*.75,1.08,.07),"708881",true,19)
	K.box(n,Vector3(0,6.02,front-.60),Vector3(float(r.width)*.75,.055,.08),"67716b",false,11)
	# The stair's inner landing connects to the recessed outer deck. This fitted
	# connector repairs the formerly isolated deck; exact plan placement is pending.
	var stair_x: float=-float(r.width)*.27
	K.box(n,Vector3(stair_x,4.8,front-7.2),Vector3(2.8,.25,10.2),"b3b6ad",true,15)
	for span: Vector2 in [Vector2(-float(r.width)*.375,stair_x-1.48),Vector2(stair_x+1.48,float(r.width)*.375)]:
		K.box(n,Vector3((span.x+span.y)/2,5.47,front-4.9),Vector3(span.y-span.x,1.08,.07),"708881",true,19)
		K.box(n,Vector3((span.x+span.y)/2,6.02,front-4.9),Vector3(span.y-span.x,.055,.08),"67716b",false,11)
	for side in [-1,1]:
		K.box(n,Vector3(stair_x+side*1.42,5.47,front-7.4),Vector3(.07,1.08,4.6),"708881",true,19)
		K.box(n,Vector3(stair_x+side*1.42,6.02,front-7.4),Vector3(.08,.055,4.6),"67716b",false,11)
		K.box(n,Vector3(side*float(r.width)*.375,5.47,front-2.8),Vector3(.07,1.08,4.2),"708881",true,19)
	# Roof vegetation is split around the projecting end block, not laid through its walls.
	var roof_min: float=-1-w/2+.6;var roof_max: float=float(r.width)*.24-(float(r.width)*.33+4)/2-.6
	for i in 5:
		var rw: float=(roof_max-roof_min)/5
		var x: float=roof_min+(i+.5)*rw
		K.box(n,Vector3(x,8.647,front-5),Vector3(rw-.20,.024,10.4),"6f7950",false,3)
		K.box(n,Vector3(x,8.67,front-5),Vector3(.16,.025,10.6),"b1b29f",false,6)
	for z in [front-10.6,front+.6]:K.box(n,Vector3(-1,8.7,z),Vector3(w,.18,.24),"a2a99d",false,15)
	for x in [-27,-10]:
		K.box(n,Vector3(x,9.02,front-5),Vector3(1.9,.62,1.7),"8e998a",false,18)
		for z in [-.5,0,.5]:K.box(n,Vector3(x,9.36,front-5+z),Vector3(1.6,.035,.13),"616e64",false,11)
	# The pedestrian band stays below the suspended fins, with a paved flush threshold.
	K.box(n,Vector3(-1,.09,front+.8),Vector3(w,.028,4),"a6a89e",false,42)
	K.finish(n)
