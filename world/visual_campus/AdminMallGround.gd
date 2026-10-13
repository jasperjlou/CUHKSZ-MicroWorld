extends RefCounted
## Official 116440794 lower tiles: clear forecourt,meander bands,drains and nine visible poles.
## Snapshot date unknown; positions/spans/step rise fitted to the retained East Gate frame.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const M:=preload("res://world/visual_campus/PhotoMallGround.gd")
const G:=2.24

static func meander(n:Node3D,a:Vector2,b:Vector2) -> void:
	var delta:=b-a;var length:=delta.length()
	var strip:=K.holder(n,"GraniteInlayReturnV200",Vector3((a.x+b.x)/2,G,(a.y+b.y)/2))
	strip.rotation.y=-atan2(delta.y,delta.x)
	for side in [-1,1]:K.box(strip,Vector3(0,.180,side*1.03),Vector3(length,.016,.13),"424c4d",false,22)
	var count:=maxi(1,roundi(length/4.0));var pitch:=length/count
	for i in count:
		var x:float=-length/2+i*pitch
		# Source-visible angular inlay. Full perimeter and unit dimensions remain fitted.
		for bar:Array in [[1.8,-.88,3.6,.13],[3.53,-.1,.13,1.56],[2.43,.62,2.2,.13],[1.4,.12,.13,1.0],[2.02,-.32,1.25,.13]]:
			K.box(strip,Vector3(x+bar[0]*pitch/4,.181,bar[1]),Vector3(bar[2]*pitch/4,.015,bar[3]),"424c4d",false,22)
	K.finish(strip)

static func build(root:Node3D) -> void:
	var n:=K.holder(root,"AdminMallGroundV91")
	M.paving(n,-37,55,-202,-163)
	# Framing follows the same two axes as the retained administrative stair-side bands.
	meander(n,Vector2(-26,-197),Vector2(51,-197))
	meander(n,Vector2(-26,-165),Vector2(51,-165))
	# Close the return bands seen meeting at right angles; clear the flag-platform steps.
	for x:float in [-24.8,49.8]:meander(n,Vector2(x,-195.9),Vector2(x,-166.1))
	M.drain(n,Vector2(-26,-201),Vector2(54,-201))
	M.drain(n,Vector2(-26,-162),Vector2(54,-162))
	M.drain(n,Vector2(52,-202),Vector2(52,-163))
	# Low,grey flag plinth opposite administration,with a three-step frontal landing.
	K.box(n,Vector3(-30.9,G+.21,-180),Vector3(6.4,.42,33),"59635f",true,26)
	for i in 3:
		var x:float=-25.9-i*.60;var h:float=(i+1)*.14
		K.box(n,Vector3(x,G+h/2,-180),Vector3(.62,h,6.4),"656e67",false,26)
	var ramp:=K.surface(n,K.quad(Vector3(-25.6,G,-183.2),Vector3(-25.6,G,-176.8),Vector3(-27.7,G+.42,-176.8),Vector3(-27.7,G+.42,-183.2)),"656e67",26,true);ramp.visible=false
	for i in 9:
		var z:float=-194+i*3.5
		K.box(n,Vector3(-30.7,G+.52,z),Vector3(.30,.2,.30),"b7bfbb",false,11)
		K.box(n,Vector3(-30.7,G+7.62,z),Vector3(.12,14.4,.12),"adb8b3",true,11)
		K.box(n,Vector3(-30.59,G+1.2,z),Vector3(.06,.65,.08),"7c8c83",false,11)
		K.box(n,Vector3(-30.60,G+7.75,z+.055),Vector3(.016,13.9,.016),"767f79",false,11)
	# Poles are visible; changing flags and temporary flower displays are not invented.
	K.finish(n)
