extends RefCounted
## V163 local two-storey pond entry fit from official cube; floor/drawing conflict recorded explicitly.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"PondRecessedEntryV163")
	# Yellow side returns and header, with no floor cutting the middle of the tall mouth.
	Core.rect(n,308.5,25,310,80,.075,8.8,"c4af5f",true,52)
	Core.rect(n,425,25,426.5,80,.075,8.8,"c4af5f",true,52)
	# Finish inside the cut edge; no coplanar yellow/brick front faces or exposed intermediate slab stripe.
	Core.rect(n,310.3,25,311.5,79.5,.075,8.54,"c4af5f",false,52)
	Core.rect(n,423.5,25,424.7,79.5,.075,8.54,"c4af5f",false,52)
	Core.rect(n,310,24,425,80,8.54,8.8,"c6c7bb",false,22)
	# Recessed glazed line. Only ground central leaves are open; upper edge stays protected.
	for span in [[310,352],[383,425]]:Core.rect(n,span[0],79.5,span[1],80,.075,8.54,"586d73",true,5)
	Core.rect(n,352,79.5,383,80,3.25,8.54,"586d73",true,5)
	for u in [310,325,339,352,383,397,411,425]:Core.rect(n,u-.45,79.0,u+.45,80.0,.075,8.54,"495955",false,11)
	for y in [3.25,4.4,7.8]:Core.rect(n,310,79,425,80,y,y+.085,"697771",false,11)
	Core.rect(n,350.8,79,352,81,.075,3.25,"c4af5f",false,52)
	Core.rect(n,383,79,384.2,81,.075,3.25,"c4af5f",false,52)
	# Thin stone apron bridges only the retained dry shore to the existing ground slab.
	Core.deck(n,310,-12,425,24,.075)
	for u in [329,407]:K.box(n,P.point(u,76,2.15),Vector3(.12,.18,.19),"d3d4c2",false,22)
	K.finish(n)
