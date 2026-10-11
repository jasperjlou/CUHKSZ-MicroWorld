extends RefCounted
## V120: public1F outdoor strip under the3F fin bay, joined from the open side.
## Public plans +2023built frontage +2024entrance-corridor photos. Heights/columns fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const U=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Pool=preload("res://world/visual_campus/LibraryPoolFrontage.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")

static func outer_strip()->PackedVector2Array:
	var poly:=P.ground_front().duplicate();var front:=P.front3()
	for i in range(10,3,-1):poly.append(front[i])
	poly.append_array(PackedVector2Array([Vector2(-36,21.4),Vector2(-36,12),Vector2(-40.5,12),Vector2(-40.5,5)]))
	return poly

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryPoolArcadeV120")
	for polygon in [outer_strip(),PackedVector2Array([Vector2(-43,12),Vector2(-32.2,12),Vector2(-32.2,24),Vector2(-43,24)])]:
		for dry:PackedVector2Array in Pool.dry_parts(polygon):
			# Match the surrounding G physical datum; .12 is the existing decorative finish.
			# Giving that finish collision made an unsupported12cm lip at the side entrance.
			K.surface(n,U.floor_vertices([dry],0),"a7ada2",26,true).visible=false
			K.surface(n,U.floor_vertices([dry],.12),"a7ada2",26)
	var front:=P.front3()
	# White end pier beside the entry void, visible in2023 and architect photos.
	var a:Vector2=front[9];var end:Vector2=front[10];var axis:Vector2=(end-a).normalized()
	var inside:=Vector2(axis.y,-axis.x);var c:Vector2=end-axis*.55+inside*.65
	var yaw:float=-atan2(axis.y,axis.x)
	K.box(n,Vector3(c.x,6.33,c.y),Vector3(1.15,12.66,1.3),"ced0c4",true,22,yaw)
	# Shallow beam and sparse supports follow the same curved edge; no solid G infill.
	for i in range(4,10):
		var p:Vector2=front[i];var q:Vector2=front[i+1];var dir:Vector2=(q-p).normalized()
		var inset:=Vector2(dir.y,-dir.x)*.75
		Pods.strip(n,p+inset,q+inset,8.54,.28,.40,"c5cbbf",22)
		if i==9:continue
		var at:Vector2=p+inset+dir*.35
		K.box(n,Vector3(at.x,4.34,at.y),Vector3(.42,8.44,.42),"c5cbbf",true,22)
	# Low edge on the water side; route is behind it, not across the basin.
	for i in range(4,10):
		Pods.strip(n,front[i],front[i+1],.13,.18,.26,"9aa699",26)
	K.finish(n)
