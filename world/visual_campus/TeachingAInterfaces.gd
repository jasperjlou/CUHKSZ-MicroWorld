extends RefCounted
## Connect the existing TA arcade to the anniversary stone field; geometry is fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func build(root: Node3D) -> void:
	var b:=K.holder(root,"TeachingAStoneInterfaces")
	# Region fill lives in the JSON ledger. Only flush drains/inlays are added here.
	K.box(b,Vector3(-40.9,2.36,-109),Vector3(.22,.015,62),"65716a",false,26)
	for z in range(-138,-78,6):
		K.box(b,Vector3(-40.9,2.369,z),Vector3(.22,.016,1.0),"4e5d54",false,13)
		for i in 8:K.box(b,Vector3(-40.9,2.38,z-.42+i*.12),Vector3(.18,.012,.025),"a3ac9e",false,13)
	for z in [-145.0,-78.0]:
		K.box(b,Vector3(-44.5,2.359,z),Vector3(15,.012,.20),"738079",false,26)
	K.finish(b)
