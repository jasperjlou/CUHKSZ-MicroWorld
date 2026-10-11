extends RefCounted
## V100. Front stair visible in the 2019 1F/2F/3F plans and colonnade elevation,
## corroborated by official panorama70040618. Widths/position fitted to current frame.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func floor_piece(n:Node3D,u0:float,u1:float,v0:float,v1:float,y:float) -> void:
	K.box(n,Vector3((u0+u1)/2,y-.15,(v0+v1)/2),Vector3(u1-u0,.30,v1-v0),"b7b6a8",true,22)

static func build(parent:Node3D) -> void:
	# Runtime loading avoids a cyclic preload with TeachingAArcadeDetail.
	var d=load("res://world/visual_campus/TeachingAArcadeDetail.gd")
	var n:=K.holder(parent,"PromenadeReturnStairV100")
	# Keep a continuous 2m inner walk and the outer column strip; open the flight slot.
	floor_piece(n,-15,37,91,93,8.7)
	floor_piece(n,-15,37,95,96,8.7)
	floor_piece(n,-15,5.8,93,95,8.7)
	floor_piece(n,20.5,37,93,95,8.7)
	# The intermediate landing also connects through a new real 2F door.
	# End at the lower flight's top, otherwise the slab lip blocks the last risers.
	floor_piece(n,5.8,7.5,90.7,94.95,4.2)
	d.stair(n,Vector3(20,0,92),Vector3(7.5,4.2,92),1.6)
	d.stair(n,Vector3(7.5,4.2,94),Vector3(20.5,8.7,94),1.6)
	d.rail(n,Vector3(5.8,4.2,91),Vector3(5.8,4.2,94.95))
	d.rail(n,Vector3(5.8,4.2,94.95),Vector3(8.6,4.2,94.95))
	# Guard the opening from the upper inner promenade, with an open top arrival.
	d.rail(n,Vector3(5.8,8.7,93),Vector3(20.5,8.7,93))
	d.rail(n,Vector3(5.8,8.7,93),Vector3(5.8,8.7,95))
	K.box(n,Vector3(7.15,2.02,91.30),Vector3(.28,4.04,.28),"b7b6a8",true,22)
	K.box(n,Vector3(7.15,2.02,94.65),Vector3(.28,4.04,.28),"b7b6a8",true,22)
	K.box(n,Vector3(7.15,4.0,92.7),Vector3(2.9,.30,.27),"b7b6a8",false,22)
	K.finish(n)
