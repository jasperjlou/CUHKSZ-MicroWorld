extends RefCounted
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryIndependentLowerFrontV115");var front:=P.front3()
	for i in range(front.size()-1):
		var a:=front[i];var b:=front[i+1];var delta:=b-a;var yaw:float=-atan2(delta.y,delta.x);var basis:=Basis(Vector3.UP,yaw)
		var count:=maxi(1,int(ceil(delta.length()/.72)))
		var full_height:bool=i>=4 and i<=9
		# Public3F footprint owns this glazing;1F door sits further back independently.
		Pods.strip(n,a,b,10.69,3.72,.12,"7c9492",19,true)
		for y in [8.86,12.52]:Pods.strip(n,a,b,y,.22,.32,"a7b0a5",22,true)
		for j in count:
			var q:=a.lerp(b,(j+.5)/count)
			var low:float=.20 if full_height else 8.94
			# Curved water-facing bay continues to the white pier beside the entrance.
			# Side return i3 stays open below3F for the mapped G outdoor corridor.
			K.box(n,Vector3(q.x,(low+12.52)/2,q.y)+basis*Vector3(0,0,.32),Vector3(.095,12.52-low,.58),"b8b4a2",false,11,yaw)
			if j%2==0:K.box(n,Vector3(q.x,10.69,q.y)-basis*Vector3(0,0,.09),Vector3(.045,3.78,.09),"78877f",false,11,yaw)
	var second:=P.front2()
	for i in range(second.size()-1):
		var a:=second[i];var b:=second[i+1];var count:=maxi(1,int(ceil(a.distance_to(b)/1.5)))
		Pods.strip(n,a,b,6.45,3.94,.1,"90a39b",19,true)
		for y in [4.48,8.42]:Pods.strip(n,a,b,y,.16,.18,"94a297",22)
		for j in range(count+1):
			var q:=a.lerp(b,float(j)/count);K.box(n,Vector3(q.x,6.45,q.y),Vector3(.065,4.02,.065),"788d81",false,11)
	# Recessed G glazing follows the1F map; the two adjoining entrance segments are open.
	var ground:=P.ground_front()
	for i in range(ground.size()-1):
		var a:=ground[i];var b:=ground[i+1];var length:=a.distance_to(b)
		Pods.strip(n,a,b,4.08,.20,.22,"9da99e",22)
		if i in [4,5]:continue
		Pods.strip(n,a,b,2.05,3.94,.10,"97aaa1",19,true)
		var count:=maxi(1,int(ceil(length/1.5)))
		for j in range(count+1):
			var q:=a.lerp(b,float(j)/count)
			K.box(n,Vector3(q.x,2.05,q.y),Vector3(.07,4.05,.07),"788d81",false,11)
	for q in [ground[4],ground[6]]:K.box(n,Vector3(q.x,2.04,q.y),Vector3(.11,4.08,.11),"5e7267",true,11)
	var entry:=P.entrance();var sign:=K.label(n,"G · 公共门厅",entry+Vector3(0,3.7,.10),.005);sign.rotation.y=-.44
	K.box(n,entry+Vector3(0,.09,-.4),Vector3(4.8,.018,2.4),"767e73",false,25,-.44)
	# Neutral stone replaces the old lobby carpet outside the newly traced glass line.
	var apron:=ground.duplicate();apron.append(Vector2(ground[-1].x,30));apron.append(Vector2(ground[0].x,30))
	for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(apron):K.surface(n,UpperVertices(dry,.12),"a7ada2",26)
	K.finish(n)
	preload("res://world/visual_campus/LibraryPoolArcade.gd").build(parent)
static func UpperVertices(poly:PackedVector2Array,y:float)->PackedVector3Array:
	return preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd").floor_vertices([poly],y)
