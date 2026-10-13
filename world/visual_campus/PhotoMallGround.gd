extends RefCounted
## User photos 222215/225/227/241 plus architect central-courtyard views.
## White ground colonnade registered to the retained student transverse interface.
## Exact span, pier spacing and lawn extents remain proportional fits.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const W:=preload("res://world/visual_campus/WesternCampus.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const STONE:="6f7778"

static func paving(n:Node3D,x0:float,x1:float,z0:float,z1:float,long_stone:bool=false) -> void:
	K.box(n,Vector3((x0+x1)/2,G+.151,(z0+z1)/2),Vector3(x1-x0,.025,z1-z0),STONE,false,(63 if x1-x0>z1-z0 else 64) if long_stone else 40)

static func drain(n:Node3D,a:Vector2,b:Vector2) -> void:
	preload("res://world/visual_campus/ColonnadeRainDetail.gd").drain(n,a,b)

static func planter(n:Node3D,p:Vector3,seed:int) -> void:
	K.box(n,p+Vector3.UP*.39,Vector3(.78,.76,.78),"4f4c40",true,4)
	K.box(n,p+Vector3.UP*.79,Vector3(.85,.055,.85),"686553",false,11)
	V.shrub(n,p+Vector3.UP*.78,Vector3(1.05,.48,1.05),seed)

static func build(root:Node3D) -> void:
	var n:=K.holder(root,"PhotoMallGroundV89")
	# Distinct stone walks and tree lawns; no blanket grass/stone over the whole forecourt.
	paving(n,-35,-29,-439,-334,true);paving(n,-4,9,-439,-334,true)
	paving(n,-35.5,44,-401,-392,true);paving(n,-35,9,-440,-435,true);paving(n,-35,9,-340,-334,true)
	for span:Vector2 in [Vector2(-435,-402),Vector2(-391,-340)]:
		K.box(n,Vector3(-16.5,G+.140,(span.x+span.y)/2),Vector3(23,.024,span.y-span.x),"6c7f56",false,3)
		for x in [-28.0,-5.0]:K.box(n,Vector3(x,G+.154,(span.x+span.y)/2),Vector3(.14,.025,span.y-span.x),"a6ada0",false,26)
		for z in [span.x,span.y]:K.box(n,Vector3(-16.5,G+.154,z),Vector3(23,.025,.14),"a6ada0",false,26)
		for x in [-28.65,-4.45]:drain(n,Vector2(x,span.x),Vector2(x,span.y))
	for z in [-391.5,-401.5,-435.5,-339.5]:drain(n,Vector2(-35,z),Vector2(9,z))
	for z in [-425,-409,-380,-364,-348]:
		for x in [-23,-10]:
			K.tree(n,Vector3(x,G+.15,z),10.4+float(absi(z)%3)*.45,8900+absi(x+z),1.65)
			for side in [-1,1]:
				W.beam(n,Vector3(x+side*1.2,G+.16,z+.6),Vector3(x,G+3.15,z),.055,.055,"477564")
			K.box(n,Vector3(x+.65,G+.30,z+.4),Vector3(.15,.25,.16),"5e6b5c",false,11)
		# Paired vertical light strips are seen in the night reference; daylight geometry retained.
		K.box(n,Vector3(-6.2,G+2.25,z),Vector3(.11,4.25,.11),"717b6a",false,11)
		for dx in [-.11,.11]:K.box(n,Vector3(-6.2+dx,G+2.38,z),Vector3(.045,3.6,.07),"e7dfbe",false,17)
	# White lower canopy is distinct from the existing bronze upper gallery at Z=-400.
	var roof:float=6.64
	K.box(n,Vector3(1.5,roof-.09,-396.5),Vector3(85,.18,5.1),"c6c8bc",true,22)
	for z in [-398.55,-394.45]:
		K.box(n,Vector3(1.5,roof-.32,z),Vector3(85,.47,.32),"d0d1c7",false,22)
	for x in [-39,-30,-21,-12,-3,6,15,24,33,42]:
		for z in [-398.55,-394.45]:
			K.box(n,Vector3(x,(G+roof-.55)/2,z),Vector3(.48,roof-G-.55,.48),"c9ccc1",true,22)
			K.box(n,Vector3(x,G+.14,z),Vector3(.53,.28,.53),"d0d3c8",false,22)
		K.box(n,Vector3(x,roof-.32,-396.5),Vector3(.28,.46,5.1),"c9ccc0",false,22)
		K.box(n,Vector3(x+.75,roof-.46,-396.5),Vector3(.20,.08,.20),"dfddc8",false,17)
		# Small grey rainwater pipes follow one pier row, including a visible roof offset.
		if x in [-30,-12,6,24,42]:
			preload("res://world/visual_campus/ColonnadeRainDetail.gd").downpipe(n,x+.29,-394.40,roof)
		if x in [-30,-12,6,24]:planter(n,Vector3(x+.76,G+.17,-394.35),8900+absi(x))
	# Grey apron toward the retained library pool walkway, stopping before the sunken court.
	paving(n,-4,17.6,-334,-326.8,true)
	drain(n,Vector2(-4,-329.0),Vector2(17.6,-329.0))
	K.finish(n)
