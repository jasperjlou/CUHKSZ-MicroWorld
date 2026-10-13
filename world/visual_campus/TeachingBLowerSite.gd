extends RefCounted
## V139 teaching-B two-level site. Source dates/metres unverified; front retained.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const Site:=preload("res://world/visual_campus/LowerCampusLandscape.gd")
const LOW:float=-4.8
const ROAD:float=-4.565
const CUTS:Array[Rect2]=[Rect2(-41,-54,82,92)]
static func cutout(x:float,z:float)->bool:
	var p:=Vector2(-220-z,x+86.62)
	for rect:Rect2 in CUTS:
		if rect.has_point(p):return true
	return false
static func terrain_breaks()->Dictionary:
	var xs:Array[float]=[];var zs:Array[float]=[]
	for rect:Rect2 in CUTS:
		xs.append(-86.62+rect.position.y);xs.append(-86.62+rect.end.y)
		zs.append(-220-rect.position.x);zs.append(-220-rect.end.x)
	return {"x":xs,"z":zs}
static func build(b:Node3D,r:Dictionary)->void:
	# Runtime load avoids the building-factory/site/core preload cycle.
	var S:Script=load("res://world/visual_campus/ZhangCourtGround.gd")
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	var n:=K.holder(b,"TeachingBLowerSiteV139")
	S.floor_rect(n,-41,41,-54,38,LOW,26)
	S.floor_rect(n,-40.6,40.6,-51.25,-45.75,ROAD)
	# The old substrate is235mm below the road; extend its level to the open
	# outside edge so the removed wall does not leave an unwalkable curb.
	S.floor_rect(n,-41,41,-54,-51.25,ROAD)
	Site.drain(n,Vector3(0,ROAD+.015,-49.7),74)
	# C/D share one lower road: no staircase remains between their rear endpoints.
	S.slope(n,Vector3(-13,ROAD,-47.5),Vector3(-13,LOW,-41.5),5.4)
	var xs:Array[float]=[-35.5,-9.8,-6.2,35.5]
	var zs:Array[float]=[-44,7.5,27,38]
	for i in 3:
		for j in 3:
			if i==1 and j==1:continue
			S.floor_rect(n,xs[i],xs[i+1],zs[j],zs[j+1],.08)
	S.floor_rect(n,-9.8,-6.2,26,27,.08)
	# Actual floor hole and a fitted descending flight into the lower public shell.
	S.flight(n,Vector3(-8,LOW,9),Vector3(-8,.08,26),3.0)
	for x in [-9.8,-6.2]:C.rail(n,Vector3(x,.08,7.5),Vector3(x,.08,26))
	C.rail(n,Vector3(-9.8,.08,7.5),Vector3(-6.2,.08,7.5))
	for span:Vector2 in [Vector2(-35.5,-16),Vector2(-10,35.5)]:S.retaining(n,Vector3(span.x,LOW,-43.9),Vector3(span.y,LOW,-43.9),-.12)
	for side in [-1,1]:
		S.retaining(n,Vector3(side*35.5,LOW,-44),Vector3(side*35.5,LOW,38),-.12)
		C.rail(n,Vector3(side*35.5,.08,-44),Vector3(side*35.5,.08,38))
	S.retaining(n,Vector3(-35.5,LOW,38),Vector3(35.5,LOW,38),-.12)
	C.rail(n,Vector3(-35.5,.08,-44),Vector3(35.5,.08,-44))
	for x in [-10,8,26]:
		for z in [-36,-20,-4,12,26]:
			if x==-10 and z==12:continue
			K.column(n,Vector3(x,LOW,z),4.68,.50)
	for z in [-38,-20,-2,24]:
		K.box(n,Vector3(0,-.30,z),Vector3(66,.3,.3),"babcb1",false,22)
		var light:=OmniLight3D.new();light.position=Vector3(-3,-1,z);light.omni_range=13;light.light_energy=.32;n.add_child(light)
	# Perimeter steps and boundaries; exact side-stair footprint remains fitted.
	for side in [-1,1]:
		S.floor_rect(n,side*38.5-2,side*38.5+2,-49.5,-32,ROAD)
		S.flight(n,Vector3(side*38.5,ROAD,-32),Vector3(side*38.5,.08,-8),3.8)
		S.floor_rect(n,side*38.5-2,side*38.5+2,-8,50.5,.08)
		for span:Vector2 in [Vector2(-54,-51.4),Vector2(-45.6,38)]:S.retaining(n,Vector3(side*41,LOW,span.x),Vector3(side*41,LOW,span.y),.02)
	# V140 A rear road now reaches this opening; the temporary end wall is retired.
	# V197: the outside is the same low apron, not an upper terrain face.
	# The former full-height rear retaining wall incorrectly sealed this edge.
	# 175mm old-gallery lip is joined by a short slope, not an unwalkable riser.
	S.slope(n,Vector3(-25.3,4.75,25.0),Vector3(-25.3,4.925,26.90),8.4)
	# Front paving/material evidence retained from V121/V135.
	K.box(n,Vector3(0,.063,40.62),Vector3(71,.03,5.24),"a4aaa0",false,26) # Existing photo lobby-to-promenade paving; no grass band.
	var front:float=float(r.depth)*.46
	K.box(n,Vector3(0,.081,front+4),Vector3(77,.028,8),"aaa89e",false,42)
	for row in 2:
		for i in 7:
			var p:=Vector3(-33+i*11+(2 if row==1 else 0),0,-64-row*8)
			var w:Vector3=b.to_global(p)
			p.y=preload("res://world/visual_campus/TeachingOuterGrade.gd").fitted_height(w.x,w.z,2.24)-2.24
			K.tree(n,p,8.5+float((i+row)%3),4400+row*10+i)
	K.finish(n)
	preload("res://world/visual_campus/TeachingBCEntryDetail.gd").build(b,r)
