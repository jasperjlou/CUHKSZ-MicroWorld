extends RefCounted
## Dated user image 20261010_222404: high narrow court, overhead canopy, glazed links, raised edge.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const Front:=preload("res://world/visual_campus/ZhangPhotoFront.gd")
const G:=2.24
static func build(root:Node3D) -> void:
	var n:=K.holder(root,"ResearchPhotoCourtV85")
	K.box(n,Vector3(-92,G+.06,-537),Vector3(14,.04,82),"99978c",false,26)
	for x in [-98.5,-85.5]:K.box(n,Vector3(x,G+.088,-537),Vector3(.20,.02,82),"555f56",false,11)
	# Raised arrival edge, with a side stair and a gradual return to the existing court datum.
	var top:=G+.65
	K.box(n,Vector3(-92,top-.15,-493),Vector3(14,.30,6),"b1aea0",true,22)
	K.box(n,Vector3(-92,top+.014,-493),Vector3(14,.024,6),"a19e90",false,26)
	K.box(n,Vector3(-92,G+.25,-490.1),Vector3(14,.5,.22),"aaa797",true,22)
	K.box(n,Vector3(-98.9,G+.25,-493),Vector3(.22,.5,6),"aaa797",true,22)
	Front.rail(n,Vector3(-92,top,-489.99),14)
	var slope:=K.quad(Vector3(-99,top,-496),Vector3(-85,top,-496),Vector3(-85,G+.08,-503),Vector3(-99,G+.08,-503))
	K.surface(n,slope,"99978c",26,true)
	# Side stair lies before the two building ends, avoiding their facade and columns.
	var stair:=K.holder(n,"CourtSideSteps",Vector3(-76,1.115,-493));stair.rotation.y=-PI/2
	var end:=Vector3(0,top-1.115,9)
	for i in 12:
		var height:float=(i+1)*end.y/12
		K.box(stair,Vector3(0,height/2,(i+.5)*.75),Vector3(2.5,height,.75),"a8a699",false,26)
	var ramp:=K.surface(stair,K.quad(Vector3(-1.25,0,0),Vector3(1.25,0,0),end+Vector3(1.25,0,0),end-Vector3(1.25,0,0)),"a8a699",26,true);ramp.hide();K.finish(stair)
	K.box(n,Vector3(-74.3,1.095,-493),Vector3(4,.035,3.5),"99978c",false,26)
	# The photograph shows high transverse members, not a low beam every four metres along the entire lane.
	K.box(n,Vector3(-92,19.1,-496),Vector3(14,.85,.70),"bfbbae",false,22)
	for z in range(-514,-531,-2):K.box(n,Vector3(-92,18.3,z),Vector3(14,.25,.34),"69716a",false,11)
	K.box(n,Vector3(-92,18.48,-522),Vector3(14,.065,17),"8eaaaa",false,19)
	for x in [-98.7,-85.3]:K.box(n,Vector3(x,18.3,-522),Vector3(.25,.42,17.5),"65736c",false,11)
	# Glazed links fitted between existing wings. Their interior access through the buildings remains unverified.
	for item:Vector2 in [Vector2(-543,10.68),Vector2(-560,6.98)]:
		var z:float=item.x;var y:float=item.y
		K.box(n,Vector3(-92,y-.14,z),Vector3(14,.28,3.6),"aeb3a7",true,22)
		K.box(n,Vector3(-92,y+3.25,z),Vector3(14,.22,3.9),"aeb3a7",true,22)
		for side in [-1,1]:
			K.box(n,Vector3(-92,y+1.55,z+side*1.75),Vector3(14,3.1,.075),"566d72",true,5)
			for x in range(-98,-85,2):K.box(n,Vector3(x,y+1.55,z+side*1.81),Vector3(.075,3.1,.13),"48544f",false,11)
	var label:=K.label(n,"涂辉龙楼\nH.L. Tu Building",Vector3(-81,8.3,-495.77),.008);label.modulate=Color("424943")
	K.finish(n)
