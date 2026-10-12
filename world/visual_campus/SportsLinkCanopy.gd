extends RefCounted
## V179: built photographer61 and official Hall approach panorama support the white link.
## Retained alignment; spans, height and pavement joint positions are fitted, not surveyed.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")

static func member(n:Node3D,a:Vector3,b:Vector3,width:float,depth:float)->void:
	var h:=K.holder(n,"WhiteCanopyMember",(a+b)/2)
	h.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
	K.box(h,Vector3.ZERO,Vector3(width,a.distance_to(b),depth),"d6dcd3",false,11);K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"BetweenHallsCanopy",Vector3(37,0,39));n.rotation.y=PI/2
	# Shared shallow physical paving spans both aisles. Keep the column row clear of walking lanes.
	K.box(n,Vector3(0,.015,0),Vector3(44,.15,7),"aaaFA4",true,26)
	K.box(n,Vector3(0,.099,0),Vector3(44,.018,6.7),"b6b8ac",false,6)
	# Built inter-hall photo shows stone court beyond the canopy, not the old default grass strip.
	K.box(n,Vector3(0,.015,9.5),Vector3(44,.15,12),"b6b8ac",true,6)
	K.box(n,Vector3(0,.103,15.43),Vector3(44,.025,.14),"9aa69a",false,22)
	for z:float in [-3.28,3.28]:
		K.box(n,Vector3(0,.11,z),Vector3(44,.016,.12),"6b7770",false,22)
		for x in range(-21,22):K.box(n,Vector3(x,.119,z),Vector3(.034,.009,.12),"a4afa3",false,11)
	# Rectangular steel columns, local base plates and paired longitudinal spine beams.
	for x in [-20,-10,0,10,20]:
		K.box(n,Vector3(x,1.90,0),Vector3(.28,3.62,.32),"d8ddd5",true,22)
		K.box(n,Vector3(x,.12,0),Vector3(.44,.055,.48),"afb9af",false,11)
		for dx:float in [-.16,.16]:
			for dz:float in [-.18,.18]:K.box(n,Vector3(x+dx,.156,dz),Vector3(.045,.04,.045),"697970",false,11)
		# Slender cantilever arms and diagonal haunches read below the transparent roof.
		member(n,Vector3(x,3.68,-2.68),Vector3(x,3.68,2.68),.15,.19)
		for side in [-1,1]:member(n,Vector3(x,2.98,side*.17),Vector3(x,3.62,side*2.18),.10,.12)
	for z:float in [-.24,.24]:K.box(n,Vector3(0,3.67,z),Vector3(41,.20,.13),"d6dcd3",false,11)
	# Individual clear panes with a white pressure-cap grid; no opaque continuous roof sheet.
	for i in 16:
		var x:float=-20.5+(i+.5)*41.0/16
		for z:float in [-1.36,1.36]:K.box(n,Vector3(x,3.82,z),Vector3(41.0/16-.065,.035,2.64),"d1ded9",false,19)
	for i in 17:
		var x:float=-20.5+i*41.0/16
		K.box(n,Vector3(x,3.80,0),Vector3(.065,.085,5.5),"d6dcd3",false,11)
	K.box(n,Vector3(0,3.80,0),Vector3(41,.085,.065),"d6dcd3",false,11)
	# Open-topped gutters and discreet downpipes finish the canopy edges without obstructing an aisle.
	for z:float in [-2.75,2.75]:
		K.box(n,Vector3(0,3.70,z),Vector3(41.15,.045,.18),"b8c5bb",false,11)
		for dz:float in [-.10,.10]:K.box(n,Vector3(0,3.77,z+dz),Vector3(41.15,.18,.035),"d6dcd3",false,11)
	for x in [-20,20]:
		member(n,Vector3(x,3.63,2.65),Vector3(x,3.54,.26),.075,.075)
		K.box(n,Vector3(x,1.88,.24),Vector3(.075,3.32,.075),"a8b8ad",false,11)
	K.finish(n)
