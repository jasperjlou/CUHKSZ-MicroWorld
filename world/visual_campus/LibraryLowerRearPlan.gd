extends RefCounted
## Five-anchor legacy1F/map registration; ground rear differs from the upper shell.
## Ground plan only. Historical source/date and metric/world registration remain partial.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
static func rear()->PackedVector2Array:
	return PackedVector2Array([Vector2(-28,-16.9),Vector2(-.37,-16.45),Vector2(2.79,-13.15),Vector2(4.37,-13.12),Vector2(11.28,-18.04),Vector2(14.699643,-14.494975)])
static func public_polygon()->PackedVector2Array:
	var p=rear();p.append(Vector2(14.699643,12));p.append(Vector2(-28,12));return p
static func contains(x:float,z:float)->bool:
	return Geometry2D.is_point_in_polygon(Vector2(x,z),public_polygon())
static func build(parent:Node3D)->void:
	var n=K.holder(parent,"LibraryGroundRegisteredRear")
	var back=rear()
	for i in back.size()-1:
		var a=back[i];var c=back[i+1]
		Pods.strip(n,a,c,2.05,4.1,.20,"c1b99f",22,true)
		# Warm short-strand panels are observed inG; wall courses/spacing remain fitted.
		if i>0 or a.x>=-15:
			Pods.strip(n,a+Vector2(0,.115),c+Vector2(0,.115),2.0,3.85,.035,"b69a65",24)
	# First long edge changes from study-wing plaster to the shared area's timber.
	Pods.strip(n,Vector2(-15,-16.573),Vector2(-.37,-16.335),2,3.85,.035,"b69a65",24)
	var floor=PackedVector2Array([Vector2(-28,-8),Vector2(14.699643,-8)])
	for i in range(back.size()-1,-1,-1):floor.append(back[i])
	P.sheet(n,floor,.014,"b9b4a4",12,true)
	P.sheet(n,floor,.106,"c4c5c1",46)
	# V208 retains the G toilet aisle, closes the former speculative exterior corridor.
	K.box(n,Vector3(-31.05,2.05,-26),Vector3(6.1,4.1,.20),"bdbdac",true,22)
	K.box(n,Vector3(-28,2.05,-21.45),Vector3(.20,4.1,9.1),"bdbdac",true,22)
	K.box(n,Vector3(-31.05,4.08,-21.45),Vector3(6.1,.08,9.1),"c4c4b8",false,22)
	K.box(n,Vector3(-31.05,.10,-21.45),Vector3(6.1,.04,9.1),"b4b6a9",false,12)
	K.finish(n)
