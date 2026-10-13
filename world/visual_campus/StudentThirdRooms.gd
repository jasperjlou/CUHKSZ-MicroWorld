extends RefCounted
## V220 historic030 3F partitions. Independent2F/current room uses are not inferred.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const LOW=8.8
const TOP=12.12
static func point(u:float,v:float,y:float=LOW)->Vector3:
	var q:=P.third_to_first(u,v);return P.point(q.x,q.y,y)
static func world(u:float,v:float,y:float=LOW)->Vector3:
	var q:=P.third_to_first(u,v);return P.world(q.x,q.y,y)
static func wall(n:Node3D,a:Vector2,b:Vector2,low:float=LOW,top:float=TOP)->void:
	var p:=point(a.x,a.y);var q:=point(b.x,b.y);var delta:=q-p
	K.box(n,(p+q)/2+Vector3.UP*((low+top)/2-LOW),Vector3(delta.length(),top-low,.16),"c4c5bb",true,22,-atan2(delta.z,delta.x))
	if low==LOW:K.box(n,(p+q)/2+Vector3.UP*.07,Vector3(delta.length(),.14,.18),"8e958e",false,22,-atan2(delta.z,delta.x))
static func door(n:Node3D,a:Vector2,b:Vector2)->void:
	var p:=point(a.x,a.y);var q:=point(b.x,b.y);var delta:=q-p;var width:=delta.length()
	var h:=K.holder(n,"ThirdFloorOpenDoor",(p+q)/2);h.rotation.y=-atan2(delta.z,delta.x)
	K.box(h,Vector3(0,(2.85+TOP-LOW)/2,0),Vector3(width,TOP-LOW-2.85,.16),"c4c5bb",true,22)
	for side in [-1,1]:K.box(h,Vector3(side*(width/2-.035),1.40,0),Vector3(.07,2.8,.22),"626e6b",true,11)
	K.box(h,Vector3(0,2.83,0),Vector3(width,.075,.22),"626e6b",false,11)
	# Park a neutral leaf within the room; no invented room-name signs.
	K.box(h,Vector3(-width/2+.09,1.34,.46),Vector3(.055,2.68,.90),"85908b",true,11)
	K.box(h,Vector3(-width/2+.13,1.13,.81),Vector3(.09,.025,.12),"c7cdca",false,11)
	K.finish(h)
static func horizontal(n:Node3D,u0:float,u1:float,v:float,gaps:Array)->void:
	var cursor:float=u0
	for g in gaps:
		wall(n,Vector2(cursor,v),Vector2(g[0],v));door(n,Vector2(g[0],v),Vector2(g[1],v));cursor=g[1]
	wall(n,Vector2(cursor,v),Vector2(u1,v))
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentThirdRoomsV220")
	wall(n,Vector2(425,34),Vector2(425,200))
	wall(n,Vector2(710,80),Vector2(710,200))
	horizontal(n,425,710,200,[[458,480],[552,576],[650,674]])
	var bounds:Array=[425,466,508,548,590,630,672,710]
	var gaps:Array=[]
	for i in range(bounds.size()-1):gaps.append([bounds[i]+7,bounds[i]+27])
	horizontal(n,425,710,104,gaps)
	for u in [466,508,548,590,630,672]:wall(n,Vector2(u,34),Vector2(u,104))
	# Rear-side pair of rooms, keeping the public strip and lower rear core separate.
	for span in [[240,274],[300,393],[417,464]]:wall(n,Vector2(794,span[0]),Vector2(794,span[1]))
	for span in [[274,300],[393,417]]:door(n,Vector2(794,span[0]),Vector2(794,span[1]))
	for v in [240,343]:wall(n,Vector2(794,v),Vector2(920,v))
	# Lower edge belongs to the existing rear stair envelope; close its short return only.
	wall(n,Vector2(794,464),Vector2(830,464))
	# Four3F symbols; only v160 aligns with0291F columns. Do not extend the other pair into unknown2F.
	for q in [[510,59],[611,59],[510,160],[611,160]]:
		var bottom:float=4.4 if q[1]==160 else LOW
		var at:=point(q[0],q[1],(bottom+TOP)/2)
		K.box(n,at,Vector3(.725,TOP-bottom,.725),"c8c9bc",true,22)
	n.set_meta("door_count",12);n.set_meta("source","historic030; no current usage claim")
	K.finish(n)
