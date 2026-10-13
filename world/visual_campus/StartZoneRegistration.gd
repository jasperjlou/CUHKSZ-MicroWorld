extends RefCounted
## V82: masterplan043 and May2026 map place DaoYuan behind Zhixin, not at its end.
## Road topology corrected; absolute measurements and grades remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const R:=preload("res://world/visual_campus/LibraryRearRoad.gd")
const S:=preload("res://world/visual_campus/StartZoneLandscape.gd")
const G:=2.24

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"StartZoneRegistrationV82")
	for r:Dictionary in builder.data.routes:
		if r.id=="west_crossroad":
			# V217 OldGateSite owns the supported road surface and its entry grade.
			for side in [-1,1]:
				# End the transverse footway at the main-road kerb. Extending it
				# to X=0 left an isolated ochre tongue over half the asphalt lane.
				var footway:Array=R.offset(r.points,side*6.3)
				for p:Array in footway:p[0]=clampf(float(p[0]),-174,-4.65)
				builder.ribbon(n,footway,3.8,"a99579",34,.13)
				# Leave vehicle and pedestrian junctions open at both ends and the rear aisle.
				for pair:Vector2 in [Vector2(-158,-85),Vector2(-65,-17)]:
					builder.ribbon(n,[[pair.x,G,-790+side*4.2],[pair.y,G,-790+side*4.2]],.25,"b2b6a9",26,.21)
			for x in range(-153,-18,9):
				if abs(x+76)>10:K.box(n,Vector3(x,G+.21,-790),Vector3(3,.018,.12),"cbb356",false,22)
		elif r.id=="old_gate_access":builder.ribbon(n,r.points,4.4,"a8aa9b",26,.13)
	# Hard corner joining the existing square-side walk and the relocated transverse street.
	K.box(n,Vector3(-7,G+.185,-790),Vector3(14,.025,12),"414b4c",false,32)
	for i in range(-4,5):
		K.box(n,Vector3(-8.2,G+.218,-790+i*.82),Vector3(3.2,.016,.43),"d5d8cb",false,22)
	for interval:Vector2 in [Vector2(-739,-783),Vector2(-798,-801)]:
		S.strip(n,Vector2(-4.66,interval.x),Vector2(-4.66,interval.y),.28,.18,"bbbdb1")
	# Complete the return between the two streets; no arbitrary grass apron at a footway junction.
	builder.ribbon(n,[[-71,G,-775],[-76,G,-783.7]],4,"a8aa9b",26,.145)
	for x in [-147,-113,-38]:
		S.street_lamp(n,Vector3(x,G,-797),1)
		S.grate(n,x,-794.0,PI/2)
	# Perimeter-facing DaoYuan staircase feet connect to the old gate and the Shaw-end branch.
	for z in [-755,-711]:
		K.box(n,Vector3(-160.5,G+.115,z),Vector3(7,.035,8.2),"a8aa9b",false,26)
	# The hall approach retains a pedestrian link through the former misplaced building's plot.
	builder.ribbon(n,[[-20,G,-796.3],[-20,G,-839],[-8.1,G,-839]],3.4,"a8aa9b",26,.12)
	# The official aerial shows a planted island across this lane, not another building.
	for iz in 3:
		for ix in 5:
			var x:float=-139+ix*24+sin(ix*2.4+iz)*2
			var z:float=-806-iz*11+cos(ix+iz)*1.5
			K.tree(n,Vector3(x,G,z),8.5+(ix+iz)%4,8260+ix+iz*5,2.0)
			preload("res://world/visual_campus/CampusVegetation.gd").shrub(n,Vector3(x,G,z),Vector3(4.5,1.1,4.5),8300+ix+iz*5)
	K.finish(n)
