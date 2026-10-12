extends RefCounted
## V180 official rear-road panorama: close-set metal rails and stone porch over asphalt.
## Retained fitted porch/ramp geometry; not a verified G/2F site datum.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")

static func rail(n:Node3D,a:Vector3,b:Vector3)->void:
	var delta:=b-a
	for y:float in [.12,1.02]:
		var beam:=K.holder(n,"RearEntryRailBeam",(a+b)/2+Vector3.UP*y)
		beam.quaternion=Quaternion(Vector3.UP,delta.normalized())
		K.box(beam,Vector3.ZERO,Vector3(.035,delta.length(),.045),"8a9996",false,11);K.finish(beam)
	var count:=maxi(1,ceili(delta.length()/.18))
	for i in range(count+1):
		var p:=a.lerp(b,float(i)/count)
		K.box(n,p+Vector3.UP*.55,Vector3(.025,.94,.025),"8a9996",false,11)
	var p:=a+Vector3.UP*.10;var q:=b+Vector3.UP*.10;var r:=b+Vector3.UP*1.04;var s:=a+Vector3.UP*1.04
	var collision:=K.surface(n,PackedVector3Array([p,q,r,p,r,s,r,q,p,s,r,p]),"8a9996",22,true);collision.hide()

static func build(h:Node3D)->void:
	var n:=K.holder(h,"RearAccessDetailV180")
	for z:float in [-3.35,-1.45]:
		var a:=Vector3(4,.48,z);var b:=Vector3(12,0,z)
		rail(n,a,b)
		# Close the triangular slab edge at the shallow ramp instead of leaving a paper surface.
		var c:=Vector3(4,0,z)
		K.surface(n,PackedVector3Array([a,b,c,c,b,a]),"929d93",26)
		rail(n,Vector3(12,0,z),Vector3(12.25,0,z))
	rail(n,Vector3(-2.5,.48,-3.3),Vector3(-2.5,.48,-.5))
	for ends in [Vector2(-2.5,-1.7),Vector2(1.7,4.0)]:rail(n,Vector3(ends.x,.48,-3.3),Vector3(ends.y,.48,-3.3))
	for i in 3:
		K.box(n,Vector3(0,.16*(i+1)+.008,-5.4+i*.7+.035),Vector3(3.18,.015,.055),"697770",false,22)
	# Drain now follows the registered stair toe, rather than obsolete world coordinates.
	K.box(n,Vector3(0,.10,-5.57),Vector3(3.6,.018,.18),"4f5d58",false,11)
	for i in 24:K.box(n,Vector3(-1.725+i*.15,.112,-5.57),Vector3(.025,.012,.18),"a2aaa2",false,11)
	K.finish(n)
