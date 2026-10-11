extends RefCounted
## V138 teaching-C two-level site. Source dates/metres unverified; front retained.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const Site:=preload("res://world/visual_campus/LowerCampusLandscape.gd")
const LOW:float=-4.8
const ROAD:float=-4.565
const CUTS:Array[Rect2]=[Rect2(-41,-54,82,84),Rect2(-66.5,-51.5,26,6)]
static func cutout(x:float,z:float)->bool:
	var p:=Vector2(-325-z,x+86.62)
	for rect:Rect2 in CUTS:
		if rect.has_point(p):return true
	return false
static func terrain_breaks()->Dictionary:
	var xs:Array[float]=[];var zs:Array[float]=[]
	for rect:Rect2 in CUTS:
		xs.append(-86.62+rect.position.y);xs.append(-86.62+rect.end.y)
		zs.append(-325-rect.position.x);zs.append(-325-rect.end.x)
	return {"x":xs,"z":zs}
static func build(b:Node3D,r:Dictionary)->void:
	# Runtime load avoids the building-factory/site/core preload cycle.
	var S:Script=load("res://world/visual_campus/ZhangCourtGround.gd")
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	var n:=K.holder(b,"TeachingCLowerSiteV138")
	S.floor_rect(n,-41,41,-54,30,LOW,26)
	S.floor_rect(n,-40.6,40.6,-51.25,-45.75,ROAD)
	Site.drain(n,Vector3(0,ROAD+.015,-49.7),74)
	# C/D share one lower road: no staircase remains between their rear endpoints.
	S.slope(n,Vector3(-13,ROAD,-47.5),Vector3(-13,LOW,-41.5),5.4)
	var xs:Array[float]=[-35.5,-9.8,-6.2,35.5]
	var zs:Array[float]=[-44,7.5,29,34.1]
	for i in 3:
		for j in 3:
			if i==1 and j==1:continue
			S.floor_rect(n,xs[i],xs[i+1],zs[j],zs[j+1],.08)
	S.floor_rect(n,-9.8,-6.2,28,29,.08)
	# Actual floor hole and a fitted descending flight into the lower public shell.
	S.flight(n,Vector3(-8,LOW,9),Vector3(-8,.08,28),3.0)
	for x in [-9.8,-6.2]:C.rail(n,Vector3(x,.08,7.5),Vector3(x,.08,28))
	C.rail(n,Vector3(-9.8,.08,7.5),Vector3(-6.2,.08,7.5))
	for span:Vector2 in [Vector2(-35.5,-16),Vector2(-10,35.5)]:S.retaining(n,Vector3(span.x,LOW,-43.9),Vector3(span.y,LOW,-43.9),-.12)
	for side in [-1,1]:
		S.retaining(n,Vector3(side*35.5,LOW,-44),Vector3(side*35.5,LOW,30),-.12)
		C.rail(n,Vector3(side*35.5,.08,-44),Vector3(side*35.5,.08,30))
	S.retaining(n,Vector3(-35.5,LOW,30),Vector3(35.5,LOW,30),-.12)
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
		for span:Vector2 in [Vector2(-54,-51.4),Vector2(-45.6,30)]:S.retaining(n,Vector3(side*41,LOW,span.x),Vector3(side*41,LOW,span.y),.02)
	S.retaining(n,Vector3(-41,LOW,-54),Vector3(41,LOW,-54),.02)
	# V139 B now shares the lower road. Its former temporary stair is removed.
	S.floor_rect(n,-66.5,-40.5,-51.5,-45.5,LOW)
	S.floor_rect(n,-66.5,-40.5,-51.25,-45.75,ROAD)
	for z in [-51.5,-45.5]:S.retaining(n,Vector3(-64.5,LOW,z),Vector3(-43,LOW,z),.02)
	# Low-wing upper room to retained first gallery, separate from the old stair.
	var a:=Vector3(-23,3.825,16.26);var e:=Vector3(-23,4.925,30.62)
	S.slope(n,a,e,2.6)
	var underside:=K.quad(a+Vector3(-1.3,-.2,0),a+Vector3(1.3,-.2,0),e+Vector3(1.3,-.2,0),e+Vector3(-1.3,-.2,0));underside.reverse();K.surface(n,underside,"bdc0b4",22)
	for x in [-24.35,-21.65]:C.rail(n,Vector3(x,3.825,16.3),Vector3(x,4.925,30.55))
	# Front paving/material evidence retained from V121/V135.
	var front:float=float(r.depth)*.46
	K.box(n,Vector3(0,.081,(front+3.33+front+8)/2),Vector3(77,.028,4.67),"aaa89e",false,42)
	for row in 2:
		for i in 7:K.tree(n,Vector3(-33+i*11+(2 if row==1 else 0),0,-64-row*8),8.5+float((i+row)%3),4400+row*10+i)
	K.finish(n)
	preload("res://world/visual_campus/TeachingBCEntryDetail.gd").build(b,r)
