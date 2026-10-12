extends RefCounted
## Official panorama116440795 + Jan2024 bookfair photo: actual apertures, grey stone, black rail.
## Dimensions/site coordinates remain fitted; publication date is not a capture timestamp.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G=2.24
static func wall_piece(n:Node3D,z0:float,z1:float,y0:float,y1:float)->void:
	K.box(n,Vector3(119,(y0+y1)/2,(z0+z1)/2),Vector3(.42,y1-y0,z1-z0),"d4d4c7",true,15)
static func moon_panel(n:Node3D)->void:
	# Ring-to-rectangle mesh leaves an actual circular sight opening through both faces.
	var center:=Vector2(-340.0,G+.93);var radius:=.56;var half:=Vector2(.83,.93)
	var mesh:=PackedVector3Array()
	var angles:Array[float]=[]
	for i in 65:angles.append(i*TAU/64)
	var corner:=atan2(half.y,half.x)
	for angle in [corner,PI-corner,PI+corner,TAU-corner]:angles.append(angle)
	angles.sort()
	for i in range(angles.size()-1):
		var a:float=angles[i];var b:float=angles[i+1]
		var va:=Vector2(cos(a),sin(a));var vb:=Vector2(cos(b),sin(b))
		var oa:Vector2=center+va*minf(half.x/maxf(absf(va.x),.00001),half.y/maxf(absf(va.y),.00001))
		var ob:Vector2=center+vb*minf(half.x/maxf(absf(vb.x),.00001),half.y/maxf(absf(vb.y),.00001))
		var ia:Vector2=center+va*radius;var ib:Vector2=center+vb*radius
		for x in [118.79,119.21]:
			var p:=Vector3(x,ia.y,ia.x);var q:=Vector3(x,ib.y,ib.x);var r:=Vector3(x,ob.y,ob.x);var s:=Vector3(x,oa.y,oa.x)
			mesh.append_array(PackedVector3Array([p,q,r,p,r,s,s,r,q,s,q,p]))
		var pa:=Vector3(118.79,ia.y,ia.x);var pb:=Vector3(119.21,ia.y,ia.x)
		var pc:=Vector3(119.21,ib.y,ib.x);var pd:=Vector3(118.79,ib.y,ib.x)
		mesh.append_array(PackedVector3Array([pa,pb,pc,pa,pc,pd,pd,pc,pb,pd,pb,pa]))
	K.surface(n,mesh,"d4d4c7",15,true)
static func screen(n:Node3D)->void:
	# Extend the old eleven-metre blank placeholder across the retained twenty-six-metre pond end.
	for span in [[-363.,-358.],[-350.,-340.83],[-339.17,-337.]]:wall_piece(n,span[0],span[1],G,G+1.86)
	wall_piece(n,-358,-350,G,G+.26);wall_piece(n,-358,-350,G+1.46,G+1.86)
	for i in 41:
		K.box(n,Vector3(119,G+.86,-358+i*.20),Vector3(.22,1.20,.04),"b9bcae",true,15)
	for i in 7:
		K.box(n,Vector3(119,G+.26+i*.20,-354),Vector3(.22,.04,8),"b9bcae",true,15)
	moon_panel(n)
	K.box(n,Vector3(119,G+1.885,-350),Vector3(.47,.05,26),"d8d8cd",false,26)
	# Damp lower stone/plinth is visible beneath the pale wall in the recent photo.
	K.box(n,Vector3(119,G-.19,-350),Vector3(.50,.38,26),"7c8177",true,7)
static func mall_rail(n:Node3D)->void:
	var x:=64.40;var low:=-363.;var high:=-337.
	for y in [.13,1.08]:K.box(n,Vector3(x,G+y,(low+high)/2),Vector3(.065,.065,high-low),"35433e",false,11)
	for i in 131:K.box(n,Vector3(x,G+.59,low+i*.2),Vector3(.033,.98,.033),"35433e",false,11)
	for i in 14:K.box(n,Vector3(x,G+.55,low+i*2),Vector3(.075,1.10,.075),"35433e",false,11)
	var body:=StaticBody3D.new();body.name="MallPondRailCollision";n.add_child(body)
	var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(.075,1.10,high-low)
	shape.shape=box;shape.position=Vector3(x,G+.55,(low+high)/2);body.add_child(shape)
static func paving(n:Node3D,p:Vector3,size:Vector2)->void:
	K.box(n,p+Vector3.UP*.028,Vector3(size.x,.045,size.y),"747c78",false,53)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"PhotoRegisteredPondEdgesV161")
	screen(n);mall_rail(n)
	# The official colonnade view shows continuous stone beneath the columns, not a lawn strip.
	paving(n,Vector3(55.95,G,-350),Vector2(4.3,29))
	K.finish(n)
