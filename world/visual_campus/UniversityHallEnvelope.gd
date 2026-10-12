extends RefCounted
## V62 anniversary aerial: pale panel shell, dark base ribbon and tall glazed end.
## Exact panel grid, glazing extents, roof module count and site grades are visual fits.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")

static func panel_face(b: Node3D,width: float,height: float) -> void:
	K.box(b,Vector3(0,height/2,0),Vector3(width,height,.28),"c2c6c0",true,22)
	for x in range(0,ceili(width/3)):
		K.box(b,Vector3(-width/2+x*3,height/2,.151),Vector3(.022,height,.012),"858e88",false,22)
	for y in range(0,ceili(height/3.8)):
		K.box(b,Vector3(0,y*3.8,.152),Vector3(width,.025,.012),"969f98",false,22)

static func side(b: Node3D,side_value: int) -> void:
	var n:=K.holder(b,"HallSidePanelAndGlazing",Vector3(side_value*45,0,-6))
	n.rotation.y=side_value*PI/2
	var width:float=35 if side_value>0 else 48
	var middle:float=6.5 if side_value>0 else 0
	# Hollow bands replace the solid wall: the dark ribbon is actual glazing.
	K.box(n,Vector3(middle,1.14,0),Vector3(width,.60,.34),"5b6661",true,22)
	C.glazing(n,Vector3(middle,2.75,0),width,2.62)
	var upper:=K.holder(n,"PaleUpperPanels",Vector3(middle,4.06,0));panel_face(upper,width,11.9);K.finish(upper)
	if side_value>0:
		var over:=K.holder(n,"PanelsOverGlazedWaitingWing",Vector3(-17.5,8.5,0));panel_face(over,13,7.46);K.finish(over)
	for u in range(-24,25,6):
		if side_value>0 and u < -11:continue
		K.box(n,Vector3(u,2.75,.20),Vector3(.12,2.62,.35),"4c5c58",false,11)
	K.box(n,Vector3(middle,4.1,.14),Vector3(width,.18,.32),"d3d5cc",false,22)
	K.finish(n)

static func build(b: Node3D) -> void:
	for side_value in [-1,1]:side(b,side_value)
	# Rear end's tall glass strip is visible beside the separate Complex in the aerial.
	var rear:=K.holder(b,"HallRearEnvelope",Vector3(0,0,-30));rear.rotation.y=PI
	for span: Vector2 in [Vector2(-45,-36),Vector2(-25,45)]:
		var n:=K.holder(rear,"PanelBay",Vector3((span.x+span.y)/2,.84,0));panel_face(n,span.y-span.x,15.11);K.finish(n)
	C.glazing(rear,Vector3(-30.5,8.395,0),11,15.11)
	for x in [-35,-33,-31,-29,-27]:K.box(rear,Vector3(x,8.395,.22),Vector3(.12,15.11,.44),"485753",false,11)
	K.box(rear,Vector3(-30.5,5.6,.16),Vector3(11,.20,.22),"4b5c55",false,11)
	K.finish(rear)
	# Shallow roof seams/modules interpreted from the anniversary aerial, not counted as measured skylights.
	for x in range(-44,45,2):K.box(b,Vector3(x,16.39,-6),Vector3(.045,.08,48),"cdd0c5",false,11)
	for x in range(-39,43,6):
		for z in [-24,-17,-10,-3,4,11]:
			var n:=K.holder(b,"FittedRoofDaylightModule",Vector3(x,16.42,z));n.rotation.x=-.10
			K.box(n,Vector3.ZERO,Vector3(2.2,.17,2.5),"aab8b3",false,19)
			for dx in [-1.12,1.12]:K.box(n,Vector3(dx,0,0),Vector3(.09,.24,2.65),"d7dad0",false,11)
			for dz in [-1.29,1.29]:K.box(n,Vector3(0,0,dz),Vector3(2.3,.24,.09),"d7dad0",false,11)
			K.finish(n)
	# Continuous hard perimeter, kerb and drainage: no default grass immediately at the wall.
	for side_value in [-1,1]:
		S.paving(b,Vector3(side_value*47,0,-5),Vector2(3.6,57))
		S.drain(b,Vector3(side_value*45.55,0,-6),47,PI/2)
		# After rotation both ends meet existing public spaces; no invented hedge row across the connections.
	S.paving(b,Vector3(0,0,-35),Vector2(101,9.5))
	S.drain(b,Vector3(0,0,-30.6),88)
	# Along the front side wing, the existing covered walk gets actual stone joints and a low plinth edge.
	S.paving(b,Vector3(33,0,30),Vector2(23,8))
	for x in [23,43]:K.box(b,Vector3(x,.14,35),Vector3(2,.28,1),"aeb6a6",true,26)
	b.set_meta("envelope_v62",{"source":"anniversary aerial and2026-03-06 photographer views","surveyed":false,"rear_glass_position_fitted":true,"unseen_side_symmetry_fitted":true})
