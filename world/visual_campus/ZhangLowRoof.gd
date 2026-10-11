extends RefCounted
## V133: low return roof, distinct from the taller oblique teaching bars.
## Rocco roof plan supports planted low roof; dimensions and planting fit remain provisional.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
static func build(b:Node3D,r:Dictionary)->void:
	var n:=K.holder(b,"ZhangLowRoofTerraceV133")
	var x0:float=-float(r.width)*.49;var x1:float=-float(r.width)*.33
	var z1:float=float(r.depth)*.44;var y:=12.325
	# Roof slab already belongs to StraightCourtReturn. Finish adds no raised collision lip.
	K.box(n,Vector3((x0+x1)/2,y+.007,8),Vector3(x1-x0-.16,.012,62),"a8aca1",false,42)
	# Low planted roof in the architect roof plan, set back for perimeter access.
	K.box(n,Vector3((x0+x1)/2,y+.12,6),Vector3(6.5,.24,39),"858a7d",true,15)
	K.box(n,Vector3((x0+x1)/2,y+.251,6),Vector3(6.16,.025,38.65),"72845a",false,2)
	# Back edge meets the retained tall return. Exposed side/front get solid parapets.
	for x in [x0+.12]:
		K.box(n,Vector3(x,y+.51,8.4),Vector3(.24,1.02,65.7),"b7ad9e",true,15)
		K.box(n,Vector3(x,y+1.04,8.4),Vector3(.31,.07,65.7),"bfc0b4",false,15)
	K.box(n,Vector3((x0+x1)/2,y+.51,z1-.12),Vector3(x1-x0,1.02,.24),"b7ad9e",true,15)
	# Inward edge joins the existing third-level gallery up to z30; guard the last roof bay.
	K.box(n,Vector3(x1-.12,y+.51,(30+z1)/2),Vector3(.24,1.02,z1-30),"b7ad9e",true,15)
	K.finish(n)
