extends RefCounted
## V143: uniform manual fit of the architect's 1F/3F/4F drawings.
## Drawing coordinates refer to the 1888px review image, not surveyed metres.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const S:=60.0/1214.0
const F2:=4.4
const F3:=8.8
const F4:=12.1

static func point(x:float,z:float)->Vector2:return Vector2((x-474)*S-33,(z-64)*S-30)
static func rect(x:float,z:float,w:float,d:float)->Rect2:return Rect2(point(x,z),Vector2(w,d)*S)
static func ground_parts()->Array:
	return [rect(474,64,866,773),rect(1217,737,224,541),Rect2(-4,25,7.8,5),Rect2(-6.1,30,23,4.55)]
static func cutout(x:float,z:float)->bool:
	return occupied(Vector2(x-145,z+640),ground_parts(),[])
static func terrain_breaks()->Dictionary:
	var xs:Array=[];var zs:Array=[]
	for r:Rect2 in ground_parts():
		for v:float in [r.position.y,r.end.y]:zs.append(v-640)
		for v:float in [r.position.x,r.end.x]:xs.append(v+145)
	return {"x":xs,"z":zs}
static func occupied(p:Vector2,parts:Array,holes:Array)->bool:
	for r:Rect2 in holes:
		if r.has_point(p):return false
	for r:Rect2 in parts:
		if r.has_point(p):return true
	return false

static func window_covers_edge(a:Vector2,c:Vector2,y:float)->bool:
	if y not in [F2,F3]:return false
	var f:=rect(1217,837,224,441);var m:=rect(474,615,541,222)
	var edges:Array=[
		[Vector2(m.position.x,m.end.y),m.end],
		[f.position,Vector2(f.position.x,24)],
		[Vector2(f.end.x,f.position.y),f.end],
		[Vector2(f.position.x,f.end.y),f.end]]
	if y==F3:
		var h:=rect(1045,64,295,475)
		edges.append([h.position,Vector2(h.end.x,h.position.y)])
		edges.append([Vector2(h.end.x,h.position.y),h.end])
		edges.append([Vector2(h.position.x,h.end.y),h.position])
	for edge:Array in edges:
		if Geometry2D.get_closest_point_to_segment(a,edge[0],edge[1]).distance_to(a)<.02 and Geometry2D.get_closest_point_to_segment(c,edge[0],edge[1]).distance_to(c)<.02:return true
	return false

static func deck(b:Node3D,y:float,parts:Array,holes:Array,guards:bool=true)->void:
	var xs:Array[float]=[point(1015,0).x];var zs:Array[float]=[-28.0,-22.0,24.0,27.2,29.7]
	for r:Rect2 in parts+holes:
		for x:float in [r.position.x,r.end.x]:
			if not xs.has(x):xs.append(x)
		for z:float in [r.position.y,r.end.y]:
			if not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var mid:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2)
			if not occupied(mid,parts,holes):continue
			K.box(b,Vector3(mid.x,y-.14,mid.y),Vector3(xs[i+1]-xs[i],.28,zs[j+1]-zs[j]),"a4a89f",true,26)
			if not guards:continue
			for side in [-1,1]:
				var x:float=xs[i] if side<0 else xs[i+1]
				var z:float=zs[j] if side<0 else zs[j+1]
				if not occupied(Vector2(mid.x,z+side*.01),parts,holes):
					# The roof stair head remains open.
					if y==F4 and absf(z+12)<.01 and mid.x>6.6 and mid.x<9.4:continue
					if not window_covers_edge(Vector2(xs[i],z),Vector2(xs[i+1],z),y):P.rail(b,Vector3(xs[i],y,z),Vector3(xs[i+1],y,z),true)
				if not occupied(Vector2(x+side*.01,mid.y),parts,holes):
					# Main switchback landing meets the forward wing at this edge.
					if absf(x-point(1217,0).x)<.01 and mid.y>24:continue
					if y==F4 and absf(x-point(1340,0).x)<.01 and mid.y>-28 and mid.y<-22:continue
					if not window_covers_edge(Vector2(x,zs[j]),Vector2(x,zs[j+1]),y):P.rail(b,Vector3(x,y,zs[j]),Vector3(x,y,zs[j+1]),true)

static func wall(b:Node3D,a:Vector2,c:Vector2,y:float,h:float,door:float=-1)->void:
	P.plan_wall(b,a,c,y,h,door)

static func glazed_wall(b:Node3D,a:Vector2,c:Vector2,y:float,h:float,door:float=-1,yellow:bool=false)->void:
	# V144: plan window runs and photographed public-layer glazing, no painted-on windows.
	var delta:=c-a;var length:=delta.length();var along:=delta.normalized()
	var yaw:=atan2(-delta.y,delta.x)
	var spans:Array[Vector2]=[Vector2(0,length)]
	if door>=0:spans=[Vector2(0,door-1.2),Vector2(door+1.2,length)]
	for span:Vector2 in spans:
		var width:=span.y-span.x
		if width<.01:continue
		var p:=a+along*(span.x+span.y)/2
		K.box(b,Vector3(p.x,y+.38,p.y),Vector3(width,.76,.22),"727c7c",true,22,yaw)
		K.box(b,Vector3(p.x,y+h-.12,p.y),Vector3(width,.24,.24),"c4c4b4",true,0,yaw)
		K.box(b,Vector3(p.x,y+(h+.52)/2,p.y),Vector3(width,h-1,.055),"7e9caa",true,48,yaw)
		var count:=maxi(1,roundi(width/1.45))
		for i in range(count+1):
			var q:=a+along*lerpf(span.x,span.y,float(i)/count)
			K.box(b,Vector3(q.x,y+h/2,q.y),Vector3(.075,h,.16),"5c696b",false,11,yaw)
			if yellow and i<count and i%2==0:
				K.box(b,Vector3(q.x,y+h/2,q.y),Vector3(.33,h-.26,.38),"cbb54d",true,22,yaw)
		K.box(b,Vector3(p.x,y+h-.85,p.y),Vector3(width,.055,.12),"5c696b",false,11,yaw)
	if door>=0:
		var p:=a+along*door
		K.box(b,Vector3(p.x,y+h-.12,p.y),Vector3(2.4,.24,.24),"c4c4b4",true,0,yaw)
		for side in [-1,1]:
			var q:Vector2=p+along*side*1.23
			K.box(b,Vector3(q.x,y+(h-.24)/2,q.y),Vector3(.08,h-.24,.18),"5c696b",false,11,yaw)

static func main_stair(b:Node3D)->void:
	# Paired return flights alongside the forward tower, not two broad straight ramps.
	# Endpoint levels remain fitted pending a dimensioned section.
	var n:=K.holder(b,"WestSwitchbackV143");n.rotation.y=PI/2
	for bounds:Vector2 in [Vector2(.05,F2),Vector2(F2,F3)]:
		var half:float=(bounds.x+bounds.y)/2
		# n(local x,z) -> b(z,-x); width2.0, 5.7m run,1.6m half landing.
		P.stair(n,Vector3(-28.7,bounds.x,3.6),Vector3(-28.7,half,-2.1),2.0,true,true)
		K.box(n,Vector3(-27.35,half-.14,-2.9),Vector3(4.7,.28,1.6),"a4a89f",true,26)
		P.rail(n,Vector3(-29.7,half,-3.7),Vector3(-25,half,-3.7),true)
		P.stair(n,Vector3(-26,half,-2.1),Vector3(-26,bounds.y,3.6),2.0,true,true)
	K.finish(n)

static func public_shell(b:Node3D)->void:
	# Main3F hall shown in the drawing, kept unfurnished until current fitout is located.
	var hall:=rect(1045,64,295,475)
	glazed_wall(b,hall.position,Vector2(hall.end.x,hall.position.y),F3,3.3)
	glazed_wall(b,Vector2(hall.end.x,hall.position.y),hall.end,F3,3.3)
	glazed_wall(b,Vector2(6.65,hall.end.y),Vector2(hall.position.x,hall.end.y),F3,3.3,3.85)
	glazed_wall(b,Vector2(hall.position.x,hall.end.y),hall.position,F3,3.3)
	#3F forward wing: open corridor leading to the external stair, no invented dorm furniture.
	var f:=rect(1217,837,224,441)
	for y:float in [F2,F3]:
		var h:float=F3-F2 if y==F2 else F4-F3
		glazed_wall(b,f.position,Vector2(f.position.x,24.0),y,h,-1,true)
		glazed_wall(b,Vector2(f.end.x,f.position.y),f.end,y,h,-1,true)
		wall(b,Vector2(f.position.x,f.end.y),f.end,y,h)
	# The two yellow-window public layers under the middle bar are visible in both
	# the historical elevation and official panorama. Keep a clear rear corridor entry.
	var m:=rect(474,615,541,222)
	for y:float in [F2,F3]:
		var h:float=F3-F2 if y==F2 else F4-F3
		glazed_wall(b,Vector2(m.position.x,m.end.y),m.end,y,h,-1,true)
		glazed_wall(b,m.position,Vector2(m.end.x,m.position.y),y,h,15)
		wall(b,m.position,Vector2(m.position.x,m.end.y),y,h)
		wall(b,Vector2(m.end.x,m.position.y),m.end,y,h)
	# Recessed1F foyer at the forward tip; actual room subdivisions remain unresolved.
	var g:=rect(1217,1030,224,248)
	wall(b,Vector2(g.end.x,g.position.y),g.end,.05,4.35)
	wall(b,Vector2(g.position.x,g.end.y),g.end,.05,4.35,5.5)
	wall(b,g.position,Vector2(g.end.x,g.position.y),.05,4.35)
	# Back-side portico is open; do not build a wall across the switchback foot.

static func build(b:Node3D)->void:
	var body:=rect(474,64,866,773);var forward:=rect(1217,737,224,541)
	var large:=rect(699,247,346,292);var small:=rect(1045,624,139,182)
	var parts:Array=[body,forward]
	# Ground hardscape follows the actual polygon; exterior yard and rear path remain separate.
	deck(b,.05,ground_parts(),[],false)
	for y:float in [F2,F3]:deck(b,y,parts,[large,small])
	# Flat roof above3F service spaces; four-storey plan provides the terrace footprint.
	# Dorm slabs supply their own floors. Roof terrace access/core is the next precision batch.
	deck(b,F4,[rect(699,64,641,183),rect(1045,247,295,292),rect(474,539,866,85),rect(1015,624,202,213)],[small,Rect2(6.65,-12,2.7,7)],true)
	#4F drawing shows the public roof stair beside the hall; run/height fitted.
	P.stair(b,Vector3(8,F3,-5),Vector3(8,F4,-12),2.5,true,true)
	for y:float in [F2,F3]:
		K.box(b,Vector3(4.8,y-.14,26),Vector3(2.6,.28,2.4),"a4a89f",true,26)
	main_stair(b);public_shell(b)
	# Two distinct lightwells, with restrained planting below rather than filled upper slabs.
	for r:Rect2 in [large,small]:
		var c:=r.get_center()
		K.box(b,Vector3(c.x,.12,c.y),Vector3(r.size.x-.5,.18,r.size.y-.5),"595b46",false,8)
		K.tree(b,Vector3(c.x,.23,c.y),7 if r==small else 9,14300+int(c.x))
	# Column lines registered to plan edges, leaving courtyard and front stair circulation clear.
	for p:Vector2 in [point(1045,64),point(1340,64),point(1045,247),point(1340,247),point(1340,390),point(1045,539),point(1340,539),point(474,539),point(699,539),point(867,539),point(1217,837),point(1441,837),point(1217,1020),point(1441,1020)]:
		K.column(b,Vector3(p.x,.05,p.y),F4-.05,.45)
	# Brown rectangular entrance paving and slim segmented glazed canopy from official panorama.
	K.box(b,Vector3(5.4,.038,32.3),Vector3(23,.025,4.5),"746c69",false,33)
	for z in [30.15,34.45]:K.box(b,Vector3(5.4,.065,z),Vector3(23,.025,.16),"818783",false,26)
	for x in [-4.0,1.0,6.0,11.0,16.0]:
		K.box(b,Vector3(x,2.2,33.5),Vector3(.18,4.4,.22),"586360",true,11)
		K.box(b,Vector3(x,4.32,31.75),Vector3(.13,.24,3.7),"65706c",false,11)
	for z in [30,33.5]:K.box(b,Vector3(6,4.33,z),Vector3(20.2,.20,.14),"65706c",false,11)
	for i in 8:K.box(b,Vector3(-2.75+i*2.5,4.48,31.75),Vector3(2.43,.055,3.5),"849b98",false,19)
	K.label(b,"逸夫书院 · 西座",Vector3(6,3.95,33.6),.009)
	K.finish(b)


