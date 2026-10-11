extends RefCounted
## V54: real terrace/road relationship from official Main Square panorama and aerial.
## 2.4m rise and all horizontal dimensions remain fitted, not survey data.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const RISE:=2.4
const Terrace:=preload("res://world/visual_campus/MainSquareTerrace.gd")

static func fitted_height(x: float,z: float,base: float) -> float:
	return Terrace.fitted_height(x,z,base)

static func build(root: Node3D) -> void:
	var n:=K.holder(root,"StartZoneTerraceV78")
	Terrace.build(n)
	preload("res://world/visual_campus/ZhirenGarden.gd").build(n)
	# V76 separates grey courtyard, dark bands and the ochre street apron.
	preload("res://world/visual_campus/ZhixinCourt.gd").build(n)
	K.box(n,Vector3(-39,G+.085,-774),Vector3(60,.03,4),"a6a79a",false,26)
	# V88 road-side base has a planted strip; retain paving only inside the glass setback.
	K.box(n,Vector3(-38,G+.085,-692.45),Vector3(48,.03,1.5),"a6a79a",false,26)
	K.box(n,Vector3(-64.5,G+.085,-733),Vector3(5,.03,86),"a6a79a",false,26)
	# The anniversary inset-panel garden occupies the adjoining approach, not the road setback.
	for x in [-68,-38]:
		for z in [-635]: # V87 court wall/brick path replaces former roadside shrubs.
			for dx in [-6,0,6]:V.shrub(n,Vector3(x+dx,G+.14,z),Vector3(2.5,1.2,2.4),absi(x+z+dx))
	K.finish(n)
