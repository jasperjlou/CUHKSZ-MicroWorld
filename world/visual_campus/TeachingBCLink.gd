extends RefCounted
## Local link between the now deeper B/C rear walks. Absolute spacing remains fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Site := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const G := 2.24
const M:=preload("res://world/visual_campus/PhotoMallGround.gd")

static func build(root: Node3D) -> void:
	var n:=K.holder(root,"TeachingBCRearConnection")
	# Transverse upper walk crosses above the newly lowered rear road.
	var S:Script=load("res://world/visual_campus/ZhangCourtGround.gd")
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	S.floor_rect(n,-140,-130,-275.5,-269.5,G+.08)
	for z in [-275.55,-269.45]:C.rail(n,Vector3(-140,G+.08,z),Vector3(-130,G+.08,z))
	# One transverse hard-paved route links the rear walk to the existing mall between B and C.
	M.paving(n,-137.87,-34.25,-275.5,-269.5)
	M.drain(n,Vector2(-137.3,-269.85),Vector2(-34.25,-269.85))
	for z in [-275.42,-269.55]:K.box(n,Vector3(-86.06,G+.170,z),Vector3(103.62,.018,.14),"a3aaa2",false,26)
	K.finish(n)
