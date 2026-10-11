extends RefCounted
## Fitted mountain-foot bench behind Shaw West. Retained anchors, no surveyed contour claim.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24

static func along(z: float) -> float:
	return smoothstep(-700,-683,z)*(1.0-smoothstep(-598,-580,z))

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<=145 or x>=225 or z<=-700 or z>=-580:return base
	var target: float=G
	if x>183.6:
		var wall: float=smoothstep(183.6,183.8,x)*1.8
		target=G+wall+maxf(0,base-G-1.8)*smoothstep(183.8,225,x)
	return lerpf(base,target,along(z))

static func excludes_grove(x: float,z: float) -> bool:
	return x>116 and x<210 and z>-686 and z<-594

static func build(root: Node3D,builder: RefCounted) -> void:
	var n:=K.holder(root,"ShawWestMountainFoot")
	# Rear walk and two flat returns stay outside the residential footprints.
	K.box(n,Vector3(178.5,G+.045,-640),Vector3(6,.055,80),"999d90",false,12)
	K.box(n,Vector3(176.5,G+.05,-629.5),Vector3(6,.06,45),"a4a394",false,12)
	for z in [-680,-600]:K.box(n,Vector3(158.3,G+.046,z),Vector3(46.4,.055,5.5),"999d90",false,12)
	for x in [175.55,181.45]:K.box(n,Vector3(x,G+.095,-640),Vector3(.17,.11,75),"a5ad9e",false,15)
	# Narrow drain between walk and retaining edge. The terrain break lies within this wall thickness.
	for z in range(-681,-598,2):
		K.box(n,Vector3(182.25,G+.074,z),Vector3(.32,.035,1.90),"526257",false,11)
		for j in 9:K.box(n,Vector3(182.25,G+.097,z-.8+j*.2),Vector3(.37,.012,.035),"99a493",false,11)
	for z in range(-698,-580,2):
		var h: float=1.8*along(z)
		if h<.03:continue
		K.box(n,Vector3(183.7,G+h/2,z),Vector3(.34,h,2.04),"8b9283",true,15)
		K.box(n,Vector3(183.7,G+h+.06,z),Vector3(.48,.12,2.02),"a9b29e",false,15)
		if z>=-682 and z<=-600:
			K.box(n,Vector3(183.7,G+h+.64,z),Vector3(.065,1.10,.065),"8c9d8b",false,11)
			K.box(n,Vector3(183.7,G+h+1.15,z),Vector3(.065,.065,2.02),"a0ae97",false,11)
			for j in 5:K.box(n,Vector3(183.7,G+h+.61,z-.8+j*.4),Vector3(.025,1.05,.025),"8d9f8b",false,11)
	# Planting follows the fitted soil, leaving the service path and building bases clear.
	var rng:=RandomNumberGenerator.new();rng.seed=116440787
	for z in range(-680,-599,8):
		for x in [187.2,192.5,200.0,211.0]:
			if absf(z+665)<6 and x<209:continue
			var p:=Vector3(x+rng.randf_range(-.8,.8),0,z+rng.randf_range(-1.6,1.6));p.y=builder.height(p.x,p.z)
			V.shrub(n,p,Vector3(rng.randf_range(2.6,4.2),rng.randf_range(.7,1.3),rng.randf_range(2.8,4.3)),abs(z)+int(x))
			if x>184 and z%16==-8:K.tree(n,p,rng.randf_range(7.5,11),abs(z)+int(x)*3)
	# Compact rest points are outside the clear walking strip.
	for z in [-670,-617]:
		K.box(n,Vector3(173.5,G+.047,z),Vector3(3.6,.06,4.0),"999d90",false,12)
		K.bench(n,Vector3(173.3,G,z),-PI/2)
		K.lamp(n,Vector3(174.9,G,z-2.0))
	# V143 fourth-floor roof exit faces the mountain; bridge crosses the retained lower walk.
	var rail:=preload("res://world/visual_campus/ShawEastPodium.gd")
	var end_y: float=builder.height(205,-665)+.055
	var points: Array[Vector3]=[Vector3(154,G+12.1,-665),Vector3(198,G+12.1,-665),Vector3(205,end_y,-665)]
	for i in range(points.size()-1):
		var a: Vector3=points[i];var c: Vector3=points[i+1]
		K.surface(n,K.quad(a+Vector3(0,0,-3),a+Vector3(0,0,3),c+Vector3(0,0,3),c+Vector3(0,0,-3)),"a2a291",26,true)
		for side in [-1,1]:
			K.surface(n,K.quad(a+Vector3(0,0,side*3),c+Vector3(0,0,side*3),c+Vector3(0,-.28,side*3),a+Vector3(0,-.28,side*3)),"a6ad9f",22,false)
		for side in [-1,1]:rail.rail(n,a+Vector3(0,0,side*3),c+Vector3(0,0,side*3))
	for x in [164,180,190]:
		var bottom: float=builder.height(x,-665)
		for z in [-667.4,-662.6]:K.column(n,Vector3(x,bottom,z),G+12.1-bottom,.4)
	K.finish(n)
