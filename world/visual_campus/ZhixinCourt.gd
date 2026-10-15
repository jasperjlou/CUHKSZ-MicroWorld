extends RefCounted
## V76 official Main Square front faces and aerial D01_01.
## Visual relationships are observed; dimensions and tree positions remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const G:=2.24

static func build(root: Node3D) -> void:
	var n:=K.holder(root,"ZhiXinGreyCourtAndOchreApronV76")
	K.box(n,Vector3(-31.45,G+.112,-733),Vector3(31.3,.022,43.6),"a5a7a2",false,88)
	# V254 pale flush margins seen at the glazed bases; widths remain fitted.
	# Retain the V76 grade and collision: these are finishes, not invented steps.
	for z in [-711.53,-754.47]:
		K.box(n,Vector3(-31.45,G+.127,z),Vector3(31.3,.016,.66),"c0c1b7",false,88)
	K.box(n,Vector3(-46.77,G+.127,-733),Vector3(.66,.016,42.28),"c0c1b7",false,88)
	# The 9m central opening meets the existing hall carpet at local z=-9.88.
	K.box(n,Vector3(-47.02,G+.128,-733),Vector3(.16,.014,8.8),"727b77",false,11)
	# Extend narrow pavers to the existing road curb, keeping the public sidewalk clear.
	K.box(n,Vector3(-10.25,G+.125,-733),Vector3(11.1,.025,86),"a99579",false,34)
	# The photographed black lines are paving bands; no unsupported raised stairs.
	for x in [-16.05,-17.05]:
		K.box(n,Vector3(x,G+.129,-733),Vector3(.20,.018,43.6),"616b68",false,26)
	for z in [-711.5,-754.5]:
		K.box(n,Vector3(-31.45,G+.129,z),Vector3(31.3,.018,.22),"69716a",false,26)
	# Low square tree surrounds visible inside the U-shaped courtyard.
	for z in [-719,-747]:
		var q:=Vector3(-40.5,G,z)
		K.box(n,q+Vector3.UP*.18,Vector3(2.6,.36,2.6),"969b91",true,26)
		K.box(n,q+Vector3.UP*.375,Vector3(2.2,.035,2.2),"585640",false,8)
		K.tree(n,q+Vector3.UP*.4,6.2,7600+absi(z),1.0)
	# Flush slot drain at the stone/brick boundary, interrupted at the court opening.
	for bounds:Vector2 in [Vector2(-754.4,-739),Vector2(-728,-711.6)]:
		K.box(n,Vector3(-15.8,G+.14,(bounds.x+bounds.y)/2),Vector3(.08,.014,bounds.y-bounds.x),"505951",false,11)
	K.finish(n)
