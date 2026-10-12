extends RefCounted
## V159 photo012 upper enclosed cross-court wing; height/depth inferred,not independent6F plan.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Sheet=preload("res://world/visual_campus/LibraryUpperLevels.gd")
static func point(u:float,v:float,y:float=0)->Vector3:
	var q:=P.fifth_to_first(u,v);return P.point(q.x,q.y,y)
static func poly(raw:Array)->PackedVector2Array:
	var out:=PackedVector2Array()
	for q in raw:
		var p:=point(q[0],q[1]);out.append(Vector2(p.x,p.z))
	return out
static func facade(n:Node3D,u:float,back:bool)->void:
	var wall:=K.holder(n,"YellowUpperCrossFacade",point(u,334));wall.rotation.y=PI if back else 0
	var width:float=point(u,228).distance_to(point(u,440));var pitch:float=width/7
	for i in 7:
		var x:float=-width/2+(i+.5)*pitch;var opening:float=.95
		for side in [-1,1]:K.box(wall,Vector3(x+side*(opening/2+(pitch-opening)/4),21.4,0),Vector3((pitch-opening)/2,3.6,.24),"c4af5f",true,52)
		K.box(wall,Vector3(x,22.83,.0),Vector3(opening,.74,.24),"969e93",true,22)
		K.box(wall,Vector3(x,19.76,.0),Vector3(opening,.32,.24),"969e93",true,22)
		K.box(wall,Vector3(x,21.19,-.04),Vector3(opening,2.54,.10),"627b80",true,5)
		for side in [-1,1]:K.box(wall,Vector3(x+side*(opening/2+.025),21.19,.09),Vector3(.055,2.64,.14),"53646b",false,11)
		for y in [19.92,20.6,21.96,22.46]:K.box(wall,Vector3(x,y,.09),Vector3(opening,.06,.15),"53646b",false,11)
	K.box(wall,Vector3(0,19.4,0),Vector3(width,.40,.38),"bdc2b7",false,22)
	K.finish(wall)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"UpperCrossCourtWingV159")
	# Existing gallery already covers228..240; avoid two coplanar floor surfaces there.
	var outline:=poly([[410,240],[592,240],[592,440],[410,440]])
	for y in [19.6,23.2]:
		Sheet.sheet(n,outline,y,"858d8a" if y>23 else "b5b5a7",18 if y>23 else 26,true)
		Sheet.sheet(n,outline,y-.28,"c6c7bb",22,false,false,86,58,true)
		if y>23:Sheet.sheet(n,outline,y+.025,"858d8a",18,false)
	facade(n,410,false);facade(n,592,true)
	# Deep spanning edge beams seen in the courtyard photograph; noncolliding visual structure.
	for u in [410.,592.]:
		K.box(n,point(u,334,19.25),Vector3(point(u,228).distance_to(point(u,440)),.7,.34),"c6c7bb",false,22)
	K.finish(n)
