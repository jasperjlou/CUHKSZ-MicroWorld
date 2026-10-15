extends RefCounted
## V51: fitted 1F/3F plan registration. Public shell only, no invented private rooms.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const T := preload("res://world/visual_campus/TeachingBlocks.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const F1:=.45
const F2:=4.95
const F3:=8.85
## V142: normalized 1F/3F drawing outlines, fitted to the retained 68 x 58.6 frame.
## Court edges align with the existing central stair opening; not surveyed metres.
const LARGE_COURT:=Rect2(-20,-15.3,15.3,27.8)
const SMALL_COURT:=Rect2(4.7,6.1,15.3,9.4)

static func floor_with_holes(b: Node3D,y: float,holes: Array) -> void:
	var xs: Array[float]=[-34,34];var zs: Array[float]=[-29.3,29.3]
	for r: Rect2 in holes:
		for x in [r.position.x,r.end.x]:
			if not xs.has(x):xs.append(x)
		for z in [r.position.y,r.end.y]:
			if not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var centre:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2);var skip:=false
			for r: Rect2 in holes:
				if r.has_point(centre):skip=true
			if not skip:
				K.box(b,Vector3(centre.x,y-.14,centre.y),Vector3(xs[i+1]-xs[i],.28,zs[j+1]-zs[j]),"a5aba3",true,22)
				K.box(b,Vector3(centre.x,y+.008,centre.y),Vector3(xs[i+1]-xs[i],.014,zs[j+1]-zs[j]),"9b9e96",false,26)

static func rail(b: Node3D,a: Vector3,c: Vector3,metal:bool=false,horizontal:bool=false) -> void:
	var d:=c-a;var yaw:=atan2(d.x,d.z);var mid: Vector3=(a+c)/2
	if horizontal:
		# V257 DaoYuan reference: open horizontal metal rails; retain the full guard collider.
		for height in [.35,.72]:
			var cross:=K.holder(b,"HorizontalGuardRail",mid+Vector3.UP*height)
			cross.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),yaw,0)
			K.box(cross,Vector3.ZERO,Vector3(.045,.045,d.length()),"a1aaa1",false,11);K.finish(cross)
	elif not metal:K.surface(b,K.quad(a,c,c+Vector3.UP*1.2,a+Vector3.UP*1.2),"67766c",19,false)
	else:
		var bars:=ceili(d.length()/.14)
		for i in bars:
			var p:Vector3=a.lerp(c,(i+.5)/bars)
			K.box(b,p+Vector3.UP*.59,Vector3(.025,1.1,.025),"c1c4b7",false,11)
	# Glass is double-sided visually; a thin solid guard must also stop both directions.
	var guard:=StaticBody3D.new();guard.name="PodiumGuardCollision";b.add_child(guard)
	guard.position=mid+Vector3.UP*.6
	guard.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),yaw,0)
	var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new()
	shape.size=Vector3(.09,1.2,d.length());collision.shape=shape;guard.add_child(collision)
	var top:=K.holder(b,"PodiumHandrail",mid+Vector3.UP*1.17)
	top.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),yaw,0)
	K.box(top,Vector3.ZERO,Vector3(.09,.06,d.length()),"a1aaa1",false,11);K.finish(top)
	for i in range(ceili(d.length()/1.3)+1):
		var p:=a.lerp(c,float(i)/ceili(d.length()/1.3))
		K.box(b,p+Vector3.UP*.59,Vector3(.065,1.18,.065),"9ba59b",false,11)

static func well_rails(b: Node3D,y: float,r: Rect2) -> void:
	var a:=Vector3(r.position.x,y,r.position.y);var c:=Vector3(r.end.x,y,r.end.y)
	rail(b,a,Vector3(c.x,y,a.z));rail(b,Vector3(c.x,y,a.z),c)
	rail(b,c,Vector3(a.x,y,c.z));rail(b,Vector3(a.x,y,c.z),a)

static func stair(b: Node3D,a: Vector3,c: Vector3,w: float,closed_risers: bool=false,metal:bool=false,horizontal:bool=false) -> void:
	var count:=ceili(absf(c.y-a.y)/.17)
	for i in count:
		# Local V141 closed risers: the old 120mm treads left light slits below 160mm rises.
		# Collision ramp/footprint stay unchanged; other buildings keep their existing helper behavior.
		var thickness:float=maxf(.12,absf(c.y-a.y)/count+.02) if closed_risers else .12
		var p:=a.lerp(c,(i+.5)/count);p.y=lerpf(a.y,c.y,float(i+1)/count)-thickness/2
		K.box(b,p,Vector3(w,thickness,absf(c.z-a.z)/count+.015),"b1b3a7",false,26)
	# A small collision clearance avoids the slab's vertical edge catching a capsule at the seam.
	var ramp:=K.surface(b,K.quad(a+Vector3(-w/2,.035,0),a+Vector3(w/2,.035,0),c+Vector3(w/2,.065,0),c+Vector3(-w/2,.065,0)),"a8aca0",26,true);ramp.hide()
	T.stair_soffit(b,a,c,w)
	for side in [-1,1]:rail(b,a+Vector3(side*(w/2+.12),0,0),c+Vector3(side*(w/2+.12),0,0),metal,horizontal)

static func room(b: Node3D,rect: Rect2,y: float,h: float) -> void:
	var n:=K.holder(b,"PublicPodiumRoom",Vector3(rect.get_center().x,y,rect.get_center().y))
	var w:=rect.size.x;var d:=rect.size.y
	K.box(n,Vector3(0,h/2,-d/2),Vector3(w,h,.23),"777d7d",true,22)
	for side in [-1,1]:
		K.box(n,Vector3(side*w/2,h/2,0),Vector3(.23,h,d),"777d7d",true,22)
		var sw: float=w/2-1.5
		K.box(n,Vector3(side*(1.5+sw/2),h/2,d/2),Vector3(sw,h-.25,.08),"677d78",true,19)
		K.box(n,Vector3(side*1.52,h/2,d/2),Vector3(.09,h,.14),"afb6aa",true,11)
	K.box(n,Vector3(0,h-.18,d/2),Vector3(w,.36,.26),"818982",false,22)
	K.finish(n)

static func plan_wall(n:Node3D,a:Vector2,c:Vector2,y:float,h:float,door:float=-1) -> void:
	var delta:=c-a;var length:=delta.length();var along:=delta.normalized()
	var yaw:=atan2(-delta.y,delta.x)
	var spans:Array[Vector2]=[Vector2(0,length)]
	if door>=0:spans=[Vector2(0,door-1.2),Vector2(door+1.2,length)]
	for span:Vector2 in spans:
		if span.y-span.x<.01:continue
		var p:=a+along*(span.x+span.y)/2
		K.box(n,Vector3(p.x,y+h/2,p.y),Vector3(span.y-span.x,h,.22),"777d7d",true,22,yaw)
	if door>=0:
		var p:=a+along*door
		K.box(n,Vector3(p.x,y+3+(h-3)/2,p.y),Vector3(2.4,h-3,.22),"777d7d",true,22,yaw)
		for side in [-1,1]:
			var jamb:Vector2=p+along*side*1.23
			K.box(n,Vector3(jamb.x,y+1.5,jamb.y),Vector3(.07,3,.30),"b8c0ba",false,11,yaw)
		K.box(n,Vector3(p.x,y+3.02,p.y),Vector3(2.52,.07,.30),"b8c0ba",false,11,yaw)

static func ground_rooms(b:Node3D) -> void:
	var n:=K.holder(b,"PublicPlan1FV142")
	# Left public room: the 1F entrance arrow is on its outer side, not the court-front wall.
	plan_wall(n,Vector2(-34,-15.3),Vector2(-20,-15.3),F1,4.5)
	plan_wall(n,Vector2(-20,-15.3),Vector2(-20,3),F1,4.5)
	plan_wall(n,Vector2(-20,3),Vector2(-34,3),F1,4.5)
	plan_wall(n,Vector2(-34,3),Vector2(-34,-15.3),F1,4.5,3)
	# Small rear service/stair enclosure visible in the plan; no invented finished room.
	plan_wall(n,Vector2(-34,-9.2),Vector2(-28,-9.2),F1,4.5,3)
	plan_wall(n,Vector2(-28,-9.2),Vector2(-28,-15.3),F1,4.5)
	K.box(n,Vector3(-27,F1+.015,-6.15),Vector3(13.7,.025,17.95),"a3a69e",false,26)
	# Front public room has a real return around the service core instead of a 29m box.
	var poly:Array[Vector2]=[Vector2(4.7,18.6),Vector2(26,18.6),Vector2(26,23.2),Vector2(16.8,23.2),Vector2(16.8,29.3),Vector2(4.7,29.3)]
	for i in poly.size():plan_wall(n,poly[i],poly[(i+1)%poly.size()],F1,4.5,18.7 if i==0 else -1)
	# Two surface rectangles cover only the L room; its service-core notch stays distinct.
	K.box(n,Vector3(15.35,F1+.015,20.9),Vector3(21.05,.025,4.35),"a3a69e",false,26)
	K.box(n,Vector3(10.75,F1+.015,26.25),Vector3(11.85,.025,6.05),"a3a69e",false,26)
	# The plan shows a separate front-right core. Shared L walls are generated only once.
	plan_wall(n,Vector2(26,18.6),Vector2(34,18.6),F1,4.5)
	plan_wall(n,Vector2(34,18.6),Vector2(34,29.3),F1,4.5)
	plan_wall(n,Vector2(34,29.3),Vector2(16.8,29.3),F1,4.5)
	# Closed service door: its inaccessible interior is not claimed reconstructed.
	K.box(n,Vector3(29.8,F1+1.15,18.47),Vector3(1.35,2.3,.035),"5e6967",false,11)
	K.box(n,Vector3(30.32,F1+1.1,18.43),Vector3(.035,.32,.035),"b5bbb4",false,11)
	K.finish(n)
	# Side threshold and shallow stair own the actual 450mm approach, with a clear landing.
	var entry:=K.holder(b,"SidePublicEntryV142");entry.rotation.y=-PI/2
	stair(entry,Vector3(0,0,38),Vector3(0,F1,35.5),3.8,true)
	K.box(entry,Vector3(0,F1-.14,34.6),Vector3(3.8,.28,1.8),"a5aba3",true,26)
	K.box(entry,Vector3(0,.04,38.8),Vector3(4,.08,1.6),"9b9e96",false,26)
	K.finish(entry)

static func build(b: Node3D) -> void:
	# Reproduce the two light wells instead of filling the podium with an unbroken slab.
	var court:=LARGE_COURT;var small:=SMALL_COURT
	floor_with_holes(b,F1,[])
	preload("res://world/visual_campus/ShawGroundEdges.gd").podium(b)
	floor_with_holes(b,F2,[court,small,Rect2(-7.8,15.1,6.4,6.8),Rect2(-34,3,14,9.5)])
	floor_with_holes(b,F3,[court,small,Rect2(-4.7,5.5,9.4,8.0)])
	for y in [F2,F3]:
		well_rails(b,y,court);well_rails(b,y,small)
	# Lower-floor public rooms follow the asymmetrical plan rather than two generic boxes.
	ground_rooms(b)
	room(b,Rect2(20,-15.3,14,21),F1,4.5)
	room(b,Rect2(-34,-15.3,14,18),F2,3.9)
	room(b,Rect2(20,-15.3,14,21),F2,3.9)
	room(b,Rect2(5.0,19.6,29,9.7),F2,3.9)
	preload("res://world/visual_campus/ShawStreetPortal.gd").build(b)
	for x in range(-11,5):K.box(b,Vector3(x+.3,6.8,29.4),Vector3(.12,3.6,.3),"b49b63",false,4)
	stair(b,Vector3(-20,0,35),Vector3(-20,F1,29.5),22,true)
	K.box(b,Vector3(-20,F1-.14,29.4),Vector3(24,.28,.5),"a5aba3",true,26)
	# Lower stair core: two flights with a shared half landing, registered to 1F plan.
	stair(b,Vector3(-6.1,F1,21.8),Vector3(-6.1,2.70,16.8),2.4,true)
	K.box(b,Vector3(-4.65,2.56,16),Vector3(5.4,.28,1.6),"a5aba3",true,26)
	stair(b,Vector3(-3.2,2.70,16.8),Vector3(-3.2,F2,21.8),2.4,true)
	# 3F public terrace stair, placed at the central opening in the published plan.
	stair(b,Vector3(0,F2,13.5),Vector3(0,F3,5.5),8.8,true)
	stair(b,Vector3(6.8,4.5,-35),Vector3(6.8,F2,-29.3),6,true)
	for x in [-7.8,-1.4]:rail(b,Vector3(x,F2,15.1),Vector3(x,F2,21.4))
	for x in [-4.7,4.7]:rail(b,Vector3(x,F3,5.5),Vector3(x,F3,13.5))
	rail(b,Vector3(-4.7,F3,13.5),Vector3(4.7,F3,13.5))
	# 3F terraces between the three residential bars.
	rail(b,Vector3(-34,F3,29.3),Vector3(7.8,F3,29.3))
	rail(b,Vector3(-34,F3,21.7),Vector3(-34,F3,29.3))
	rail(b,Vector3(34,F3,-11),Vector3(34,F3,-3))
	rail(b,Vector3(-34,F3,-29.3),Vector3(-13.5,F3,-29.3))
	rail(b,Vector3(-34,F3,-29.3),Vector3(-34,F3,-15.3))
	# V249 restored front2F floor requires its actual outer guard, separate from street portal.
	rail(b,Vector3(-34,F2,29.3),Vector3(5,F2,29.3))
	# Rear entrance remains open between guards.
	rail(b,Vector3(-34,F2,-29.3),Vector3(3.6,F2,-29.3))
	rail(b,Vector3(10,F2,-29.3),Vector3(34,F2,-29.3))
	for x in [-34,34]:rail(b,Vector3(x,F2,-29.3),Vector3(x,F2,-15.3))
	# Plant beds remain in the light wells; public paths and the stair landings stay clear.
	for r: Rect2 in [court,small]:
		var p:=r.get_center()
		K.box(b,Vector3(p.x,F1+.12,p.y),Vector3(r.size.x-.8,.24,r.size.y-.8),"575b42",false,8)
		V.shrub(b,Vector3(p.x,F1+.24,p.y),Vector3(r.size.x-1.2,.45,r.size.y-1.2),5101+int(p.x))
		K.tree(b,Vector3(p.x,F1+.23,p.y),8.4,5102+int(p.x))
	for p: Vector3 in [Vector3(-28,F3,25.5),Vector3(12,F3,16.5),Vector3(-27,F3,-22)]:
		K.planter(b,p);K.bench(b,p+Vector3(2,0,0))
