extends RefCounted
## Backdoor panorama 116443793, back face: low steps up to a planted overlook.
## Four steps, 0.60 m rise and its placement on this retained terrace are fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")

static func build(b: Node3D,builder) -> void:
	# The small overlook is distinct from the main three-stage campus ascent.
	builder.stairs(b,Vector3(15,12.4,-36.6),Vector3(15,13.0,-39),9.2,4)
	K.box(b,Vector3(15,12.70,-41.8),Vector3(9.2,.60,5.6),"a8aaa0",true,26)
	for i in 4:
		K.box(b,Vector3(15,12.4+(i+1)*.15+.012,-36.6-i*.6-.06),Vector3(9.2,.018,.10),"b5b9ad",false,26)
	# Glass guards and plinths follow the raised deck, leaving the entire stair mouth open.
	C.glass_rail(b,Vector3(10.4,13.0,-41.8),5.6,PI/2)
	for x in [10.4,19.8]:K.box(b,Vector3(x,12.71,-41.8),Vector3(.18,.58,5.6),"9aa093",false,15)
	K.box(b,Vector3(15,13.012,-43.3),Vector3(8.6,.018,.15),"857a6d",false,26)
	K.box(b,Vector3(15,13.02,-43.55),Vector3(7.5,.02,.20),"59685c",false,13)
	for i in 46:K.box(b,Vector3(11.35+i*.16,13.036,-43.55),Vector3(.028,.012,.16),"a6ad9f",false,13)
	# Sloping handrails join the low terrace guard and raised overlook guard.
	for x in [10.15,19.85]:
		var a:=Vector3(x,13.48,-36.6);var c:=Vector3(x,14.08,-39)
		var rail:=K.holder(b,"LookoutSlopeRail",(a+c)/2)
		# These endpoints are building-local; a global look_at would send the rail off-site.
		rail.rotation.x=-atan2(c.y-a.y,c.z-a.z)
		K.box(rail,Vector3.ZERO,Vector3(.06,.06,a.distance_to(c)),"8e978a",false,13);K.finish(rail)
