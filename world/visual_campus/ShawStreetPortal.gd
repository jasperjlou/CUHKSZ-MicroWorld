extends RefCounted
## V249: 1F plan left-side recess between room and front service core;
## official70040608 front cube confirms yellow two-storey portal beside solid grey wall.
## Local coordinates in retained plan fit, not measured geographic coordinates.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/ShawEastPodium.gd")
static func build(b:Node3D)->void:
	var n:=K.holder(b,"ShawStreetPortalV249")
	# Restore the omitted front-left service-core envelope. Interior use remains unknown.
	K.box(n,Vector3(-34,4.65,17.10),Vector3(.24,8.4,9.2),"777d7d",true,22)
	K.box(n,Vector3(-28.6,4.65,12.5),Vector3(10.8,8.4,.24),"777d7d",true,22)
	K.box(n,Vector3(-28.6,4.65,21.7),Vector3(10.8,8.4,.24),"777d7d",true,22)
	K.box(n,Vector3(-23.2,4.65,17.10),Vector3(.24,8.4,9.2),"777d7d",true,22)
	# Recess side liners face into the entry; the old front-terrace yellow gateway is removed.
	for z:float in [3.13,12.37]:
		K.box(n,Vector3(-32.5,4.65,z),Vector3(3,8.30,.045),"b7a126",false,22)
	K.box(n,Vector3(-32.5,8.64,7.75),Vector3(3,.22,9.24),"b6a137",false,22)
	# Retain the visible mid-height edge beam while opening the wrong intervening slab.
	K.box(n,Vector3(-33.85,4.86,7.75),Vector3(.26,.22,9.24),"a8aea5",false,22)
	for z:float in [3.05,12.45]:
		K.box(n,Vector3(-34.17,4.65,z),Vector3(.25,8.4,.28),"bdc0b6",false,22)
	# Two vertically slatted panels immediately beside the recess, seen in official street view.
	for y:float in [2.1,6.65]:
		K.box(n,Vector3(-34.14,y,13.62),Vector3(.03,2.75,1.60),"4d5351",false,22)
		for j in 11:
			K.box(n,Vector3(-34.20,y,12.89+j*.145),Vector3(.09,2.75,.065),"ae9272",false,4)
	# The published side recess has shallow approach steps; retain F1=.45 until surveyed.
	var approach:=K.holder(n,"StreetPortalApproach",Vector3(0,0,7.75));approach.rotation.y=-PI/2
	P.stair(approach,Vector3(0,0,38),Vector3(0,.45,34.3),8.4,true)
	K.box(approach,Vector3(0,.31,34.12),Vector3(8.4,.28,.42),"a5aba3",true,26)
	K.finish(approach);K.finish(n)
