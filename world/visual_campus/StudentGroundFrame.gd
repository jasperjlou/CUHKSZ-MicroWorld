extends RefCounted
## V219: missing free-standing symbols traced from historic architect029 1F.
## Stops at current first supporting slab. Intermediate floors/current fitout remain unverified.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")
static func supports()->Array:
	var rows:Array=[[303,338,4.4],[794,338,4.4]]
	for u in [426,508,610]:
		for v in [154,235,338,460,563]:rows.append([u,v,4.4])
	return rows
static func beam(n:Node3D,a:Vector3,b:Vector3)->void:
	var delta:=b-a
	K.box(n,(a+b)/2,Vector3(delta.length(),.32,.48),"c8c9bc",true,22,-atan2(delta.z,delta.x))
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentGroundFrameV219")
	for q in supports():
		# 10px square symbols / historical ruler; dimensions are design-plan fit.
		Core.rect(n,q[0]-5,q[1]-5,q[0]+5,q[1]+5,.075,q[2]-.28,"c8c9bc")
		Core.rect(n,q[0]-5.1,q[1]-5.1,q[0]+5.1,q[1]+5.1,.075,.20,"94998f",false)
	# Conservative beam closures under the existing slabs, not a structural engineering claim.
	for row in [[154,4.4],[235,4.4],[338,4.4],[460,4.4],[563,4.4]]:
		beam(n,P.point(426,row[0],row[1]-.44),P.point(610,row[0],row[1]-.44))
	n.set_meta("traced_support_count",supports().size());n.set_meta("source","architect029 historic1F;metres/heights fitted")
	K.finish(n)
