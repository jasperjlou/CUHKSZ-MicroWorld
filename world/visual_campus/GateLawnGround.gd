extends RefCounted
## Official panorama 70040618: uninterrupted lawn, flanking tree beds and stone walks.
## Capture date unknown; metre extents and tree spacing are fitted to existing anchors.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const W:=preload("res://world/visual_campus/WesternCampus.gd")
const M:=preload("res://world/visual_campus/PhotoMallGround.gd")
const G:=2.24
const AREA:=Rect2(-38,-163,77,99)
const LAWN:=Rect2(-22,-98,44,30)

static func planting_rects() -> Array[Rect2]:
	return [Rect2(-34,-126,4,35),Rect2(-34,-147,4,9),Rect2(-31,-85,4,17),
		Rect2(29,-99,5,10),Rect2(29,-80,5,12),Rect2(30,-151,4,28)]

static func inset_surface(n:Node3D,area:Rect2,color:String,kind:int,y:float) -> void:
	K.surface(n,K.quad(Vector3(area.position.x,y,area.position.y),Vector3(area.end.x,y,area.position.y),
		Vector3(area.end.x,y,area.end.y),Vector3(area.position.x,y,area.end.y)),color,kind)

static func edging(n:Node3D,r:Rect2,y:float) -> void:
	for x:float in [r.position.x,r.end.x]:K.box(n,Vector3(x,y,r.get_center().y),Vector3(.15,.035,r.size.y+.15),"aeb4a8",false,26)
	for z:float in [r.position.y,r.end.y]:K.box(n,Vector3(r.get_center().x,y,z),Vector3(r.size.x,.035,.15),"aeb4a8",false,26)

static func tree(n:Node3D,p:Vector3,seed_value:int) -> void:
	K.tree(n,p,9.6+float(seed_value%3)*.4,seed_value,1.8)
	# Three green braces visible in both sides of the panorama.
	for i in 3:
		var a:float=TAU*i/3.0
		W.beam(n,p+Vector3(cos(a)*1.15,.04,sin(a)*1.15),p+Vector3(0,2.7,0),.052,.052,"487565")
	K.box(n,p+Vector3(.32,.12,.27),Vector3(.14,.20,.10),"777d6e",false,11)

static func build(root:Node3D) -> void:
	var n:=K.holder(root,"GateLawnGroundV98")
	var cuts:Array[Rect2]=planting_rects();cuts.append(LAWN)
	# Partition the stone around the lawn and soil: no hidden crossing slab or z-fighting.
	var xs:Array[float]=[AREA.position.x,AREA.end.x];var zs:Array[float]=[AREA.position.y,AREA.end.y]
	for r:Rect2 in cuts:
		for x:float in [r.position.x,r.end.x]:
			if not xs.has(x):xs.append(x)
		for z:float in [r.position.y,r.end.y]:
			if not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	for ix in xs.size()-1:
		for iz in zs.size()-1:
			var tile:=Rect2(xs[ix],zs[iz],xs[ix+1]-xs[ix],zs[iz+1]-zs[iz]);var skip:=false
			for r:Rect2 in cuts:
				if r.has_point(tile.get_center()):skip=true;break
			if not skip:inset_surface(n,tile,"8e9392",42,G+.113)
	inset_surface(n,LAWN,"667e50",3,G+.113);edging(n,LAWN,G+.128)
	for r:Rect2 in planting_rects():
		inset_surface(n,r,"554f3f",8,G+.115);edging(n,r,G+.135)
		V.shrub(n,Vector3(r.get_center().x,G+.13,r.get_center().y),Vector3(r.size.x-.3,.44,r.size.y-.3),9800+absi(int(r.position.y)))
	for p:Vector2 in [Vector2(-32,-98),Vector2(-32,-111),Vector2(-32,-121),Vector2(-32,-143),
		Vector2(-29,-76),Vector2(31.5,-94),Vector2(31.5,-72),Vector2(32,-132),Vector2(32,-145)]:
		tree(n,Vector3(p.x,G+.13,p.y),9800+absi(int(p.x+p.y)))
	# Stone seats touch the planting edge; leave the TA portal at Z=-132.75 unobstructed.
	for p:Vector2 in [Vector2(-29.55,-106),Vector2(-29.55,-143),Vector2(28.55,-95),Vector2(28.55,-73),Vector2(29.55,-140)]:
		K.box(n,Vector3(p.x,G+.30,p.y),Vector3(.85,.35,3.4),"a5aaa0",true,15)
		K.box(n,Vector3(p.x,G+.50,p.y),Vector3(.98,.07,3.55),"b2b5ac",false,26)
	# Flush square maintenance hatch observed within the lawn.
	K.box(n,Vector3(7,G+.123,-102),Vector3(1.15,.016,1.15),"a5aaa0",false,26)
	for x in [6.46,7.54]:K.box(n,Vector3(x,G+.133,-102),Vector3(.018,.005,1.10),"63715f",false,11)
	for z in [-102.54,-101.46]:K.box(n,Vector3(7,G+.133,z),Vector3(1.10,.005,.018),"63715f",false,11)
	for z in [-113.4,-145.5,-161.5]:K.box(n,Vector3(0,G+.119,z),Vector3(57,.012,.28),"626e64",false,26)
	M.drain(n,Vector2(-28.5,-126),Vector2(-28.5,-90))
	M.drain(n,Vector2(-28.5,-137),Vector2(-28.5,-160))
	M.drain(n,Vector2(27.6,-151),Vector2(27.6,-112))
	for p:Vector2 in [Vector2(-26,-72),Vector2(-26,-118),Vector2(26,-83),Vector2(26,-154)]:
		K.box(n,Vector3(p.x,G+2.7,p.y),Vector3(.13,5.4,.13),"495a4f",false,11)
		K.box(n,Vector3(p.x,G+4.87,p.y+.085),Vector3(.075,.84,.045),"d5dfbc",false,17)
	K.finish(n)
