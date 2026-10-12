extends RefCounted
## V177: anniversary aerial exposes a guarded terrace and lower plinth at the white end.
## Local dimensions/2.4m relief are photo fits; hidden service rooms and stairs are not invented.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/ShawEastPodium.gd")

static func drop_at(x:float,z:float)->float:
	return 2.4*smoothstep(-104,-86,x)*(1-smoothstep(-66,-62,x))*smoothstep(-35,-24,z)*(1-smoothstep(25,42,z))

static func fitted_height(x:float,z:float,base:float)->float:
	if x< -114 or x> -72 or z< -982 or z> -905:return base
	return base-drop_at(x+10,z+947)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"SportsWhiteEndPlinthV177")
	# Side terrace shares field level, over a visible stone/concrete retaining base.
	K.box(n,Vector3(-66.8,-1.30,0),Vector3(8.4,2.8,44),"a8ada5",true,26)
	# Existing forecourt paving was visual-only. Support both returns at the terrace datum
	# so the lowered terrain cannot drop the player into the vertical plinth edge.
	K.box(n,Vector3(-56.8,-.05,-21.4),Vector3(28.4,.3,11.4),"a4aaa1",true,26)
	K.box(n,Vector3(-56.8,-.05,21.7),Vector3(28.4,.3,12.4),"a4aaa1",true,26)
	K.box(n,Vector3(-66.8,-1.35,-24.5),Vector3(8.4,2.7,5),"a8ada5",true,26)
	K.box(n,Vector3(-66.8,-1.35,24.9),Vector3(8.4,2.7,5.8),"a8ada5",true,26)
	K.box(n,Vector3(-66.8,-.25,0),Vector3(8.6,.5,44.2),"c5c9c0",false,22)
	K.box(n,Vector3(-66.8,.092,0),Vector3(8.4,.025,44),"909f9f",false,26)
	# Continuous slender perimeter railing; access stays around both ends of the white wall.
	P.rail(n,Vector3(-70.8,.105,-21.8),Vector3(-70.8,.105,21.8),true)
	P.rail(n,Vector3(-70.8,.105,-21.8),Vector3(-64,.105,-21.8),true)
	P.rail(n,Vector3(-70.8,.105,21.8),Vector3(-64,.105,21.8),true)
	for z in range(-21,22,3):
		K.box(n,Vector3(-71.012,-1.52,z),Vector3(.016,2.12,.022),"7f8b83",false,22)
	K.box(n,Vector3(-71.02,-.57,0),Vector3(.02,.05,44),"6a7972",false,22)
	# Lower paved strip follows the fitted terrain, not a second floating platform.
	var vertices:=PackedVector3Array()
	for x in range(-83,-71):
		for z in range(-22,26):
			var a:=Vector3(x,-drop_at(x,z)+.045,z);var b:=Vector3(x+1,-drop_at(x+1,z)+.045,z)
			var c:=Vector3(x+1,-drop_at(x+1,z+1)+.045,z+1);var d:=Vector3(x,-drop_at(x,z+1)+.045,z+1)
			vertices.append_array(K.quad(a,b,c,d))
	K.surface(n,vertices,"a0a69d",26,true)
	for z in range(-21,25):
		var y:float=-drop_at(-71.4,z)+.06
		K.box(n,Vector3(-71.4,y,z+.5),Vector3(.18,.018,1),"52615b",false,22)
	for z in [-16,0,16]:K.tree(n,Vector3(-89,-drop_at(-89,z),z),6.5,1770+z)
	# End wall has small closed service panels in the aerial, rather than public door openings.
	for z:float in [-9,2,10]:
		K.box(n,Vector3(-62.825,1.0,z),Vector3(.045,1.45,.72),"bec8bf",false,22)
		K.box(n,Vector3(-62.856,1.0,z+.25),Vector3(.05,.035,.12),"65796e",false,11)
	K.finish(n)
