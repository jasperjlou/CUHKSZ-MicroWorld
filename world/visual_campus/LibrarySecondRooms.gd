extends RefCounted
## V226: university Level2 public map. Staff-office internals remain unregistered.
## Room envelope follows the map; intermediate210-212 splits and door widths are fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const FLOOR=4.4
const TOP=8.50
static func plan_rect(u0:float,v0:float,u1:float,v1:float)->PackedVector2Array:
	var poly:=PackedVector2Array()
	for q in [[u0,v0],[u1,v0],[u1,v1],[u0,v1]]:
		var p:=P.point2(q[0],q[1]);poly.append(Vector2(p.x,p.z))
	return poly
static func in_room(p:Vector3)->bool:
	for poly in [plan_rect(326,250,463,420),plan_rect(463,365,747,420)]:
		if Geometry2D.is_point_in_polygon(Vector2(p.x,p.z),poly):return true
	return false
static func retained_rail(n:Node3D,p:Vector3,length:float,yaw:float=0)->void:
	var direction:=Basis(Vector3.UP,yaw)*Vector3.RIGHT
	var a:=p-direction*length/2;var b:=p+direction*length/2
	var parts:Array[PackedVector2Array]=[PackedVector2Array([Vector2(a.x,a.z),Vector2(b.x,b.z)])]
	# Retire decorative rails through mapped rooms or same-level public approaches only.
	for poly in [plan_rect(326,250,463,420),plan_rect(463,365,747,420),plan_rect(260,420,800,470),plan_rect(260,250,326,420),preload("res://world/visual_campus/LibrarySecondServices.gd").frontage_polygon()]:
		var next:Array[PackedVector2Array]=[]
		for part in parts:next.append_array(Geometry2D.clip_polyline_with_polygon(part,poly))
		parts=next
	for part in parts:
		var centre:Vector2=(part[0]+part[-1])/2
		preload("res://world/visual_campus/LandmarkBuildings.gd").guardrail(n,Vector3(centre.x,p.y,centre.y),part[0].distance_to(part[-1]),yaw)
static func wall(n:Node3D,a:Vector2,b:Vector2,low:float=FLOOR,top:float=TOP)->void:
	var p:=P.point2(a.x,a.y);var q:=P.point2(b.x,b.y);var delta:=q-p
	K.box(n,(p+q)/2+Vector3.UP*((low+top)/2),Vector3(delta.length(),top-low,.16),"c6c8bd",true,22,-atan2(delta.z,delta.x))
	if low==FLOOR:K.box(n,(p+q)/2+Vector3.UP*(FLOOR+.06),Vector3(delta.length(),.12,.18),"909990",false,22,-atan2(delta.z,delta.x))
static func frontage(n:Node3D,left:float,right:float,door:float,number:String)->void:
	wall(n,Vector2(left,420),Vector2(door-12,420));wall(n,Vector2(door+12,420),Vector2(right,420))
	wall(n,Vector2(door-12,420),Vector2(door+12,420),FLOOR+2.65)
	var p:=P.point2(door,420,FLOOR);var along:Vector3=(P.point2(door+1,420)-P.point2(door,420)).normalized()
	var h:=K.holder(n,"SecondFloorDoor"+number,p);h.rotation.y=-atan2(along.z,along.x)
	var width:float=P.point2(door-12,420).distance_to(P.point2(door+12,420))
	for side in [-1,1]:K.box(h,Vector3(side*(width/2-.03),1.30,0),Vector3(.06,2.60,.22),"89948c",true,11)
	K.box(h,Vector3(0,2.64,0),Vector3(width,.07,.22),"89948c",false,11)
	# Park a plain leaf on the room side; no claim about current door material.
	if number=="209":
		# Fully parked against the inside wall: the former90-degree leaf crossed
		# the side aisle. Opening angle remains fitted, not a surveyed door state.
		K.box(h,Vector3(-width/2-.47,1.28,-.16),Vector3(.94,2.56,.055),"b5b5a6",true,22)
		K.box(h,Vector3(-width/2-.82,1.10,-.22),Vector3(.14,.025,.10),"727e77",false,11)
	else:
		K.box(h,Vector3(-width/2+.09,1.28,-.49),Vector3(.055,2.56,.94),"b5b5a6",true,22)
		K.box(h,Vector3(-width/2+.14,1.10,-.85),Vector3(.10,.025,.14),"727e77",false,11)
	K.label(h,number,Vector3(width/2+.30,2.08,.16),.0038)
	K.finish(h)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibrarySecondPublicRoomsV226")
	#209 is taller in plan than the shallow row210-213; retain public west-side core access.
	wall(n,Vector2(326,250),Vector2(326,420))
	wall(n,Vector2(326,250),Vector2(463,250))
	wall(n,Vector2(463,250),Vector2(463,420))
	frontage(n,326,463,435,"209")
	wall(n,Vector2(463,365),Vector2(747,365))
	for u in [538,609,680,747]:wall(n,Vector2(u,365),Vector2(u,420))
	var bounds:Array=[463,538,609,680,747]
	for i in 4:frontage(n,bounds[i],bounds[i+1],(bounds[i]+bounds[i+1])/2,str(210+i))
	# Neutral fill makes the untextured public envelopes legible; furniture and exact finish await evidence.
	for q in [[395,335],[503,392],[574,392],[645,392],[714,392]]:
		var light:=OmniLight3D.new();light.position=P.point2(q[0],q[1],7.25);light.light_color=Color("f0eee1");light.light_energy=.28;light.omni_range=5;light.shadow_enabled=false;n.add_child(light)
	n.set_meta("source","official2F map;209-213 identity and envelopes; intermediate partitions fitted")
	K.finish(n)
	preload("res://world/visual_campus/LibraryTraining209.gd").build(parent)
