extends RefCounted
## Each teaching site owns its real grade cutouts; no flat decorative slab over stair holes.
static func build(b:Node3D,r:Dictionary)->void:
	if r.id=="teaching_c":preload("res://world/visual_campus/TeachingCLowerSite.gd").build(b,r)
	elif r.id=="teaching_b":preload("res://world/visual_campus/TeachingBLowerSite.gd").build(b,r)
