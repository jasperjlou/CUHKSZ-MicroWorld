extends RefCounted
## V55: raised brick forecourt and planted bank visible in the anniversary/official panorama.
## Heights, footprint and two flanking access flights are fitted, not a surveyed site plan.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const H:=2.4
const STAIRS: Array[float]=[-783,-827]

## V82 registration: the building stands behind Zhixin, facing the perimeter.
## A rigid half-turn preserves the already-authored local stair and facade geometry.
static func registered(p: Vector3) -> Vector3:
	return Vector3(-177-p.x,p.y,-1538-p.z)

static func fitted_height(x: float,z: float,base: float) -> float:
	return local_height(-177-x,-1538-z,base)

static func local_height(x: float,z: float,base: float) -> float:
	if x < -102 or x > -18 or z < -836 or z > -775:return base
	var front:=smoothstep(36.0,36.4,-x)
	if absf(z+805)<=13.0:front=clampf((-x-18)/18.5,0,1)
	for s in STAIRS:
		if absf(z-s)<=4.0:front=clampf((-x-18)/18.5,0,1)
	# V62 keep the Hall-side passage flat; the raised ground starts inside the existing retaining wall.
	return base+H*front*smoothstep(-102,-98,x)*smoothstep(-832.2,-831.8,z)*(1.0-smoothstep(-778,-775,z))

static func build(root: Node3D) -> void:
	var n:=K.holder(root,"DaoYuanRaisedForecourtV55")
	n.position=Vector3(-177,0,-1538);n.rotation.y=PI
	K.box(n,Vector3(-67.25,G+H+.049,-805),Vector3(61.5,.06,54),"a37b6b",false,89)
	# Full lower pavement follows the retained street; a flower slope replaces the old central shortcut.
	K.box(n,Vector3(-14.5,G+.082,-805),Vector3(9,.03,58),"b2a48a",false,1)
	for z in STAIRS:
		var s:=K.holder(n,"DaoYuanSideFlight",Vector3(-18,G,z));s.rotation.y=PI/2
		P.stair(s,Vector3.ZERO,Vector3(0,H,-18.5),8,true,false,true)
		K.box(s,Vector3(0,H-.14,-20),Vector3(8.5,.28,3),"b1b3a7",true,26)
		K.finish(s)
		K.box(n,Vector3(-14,G+.105,z),Vector3(8,.025,8),"b4b3a4",false,26)
	# Blockwork is kept separate from brick paving and the planted slope.
	for z in range(-831,-778,2):
		var gap:=false
		for s in STAIRS:
			if absf(z-s)<5.1:gap=true
		if gap:continue
		K.box(n,Vector3(-36.2,G+H/2,z),Vector3(.45,H,2.02),"a8a696",true,26)
		K.box(n,Vector3(-36.2,G+H+.08,z),Vector3(.66,.16,2.05),"bbb9a8",false,26)
	# Close the old unguarded gaps at both stair-head corners; same guard height/thickness.
	P.rail(n,Vector3(-36.65,G+H,-822.88),Vector3(-36.65,G+H,-787.12),false,true)
	for z in [-822.88,-787.12]:
		P.rail(n,Vector3(-36.65,G+H,z),Vector3(-36.5,G+H,z),false,true)
	for z in [-832,-778]:
		K.box(n,Vector3(-67.5,G+H/2,z),Vector3(61,H,.4),"a6a493",true,26)
		P.rail(n,Vector3(-98,G+H,z),Vector3(-40,G+H,z),false,true)
	# V257 official left/front view: pale paving border and a slotted channel at the stone edge.
	# Runs stop before the stair mouths. Exact dimensions and routing remain fitted.
	for span in [Vector2(-821.8,-788.2)]:
		var length:float=span.y-span.x;var centre:float=(span.x+span.y)/2
		K.box(n,Vector3(-37.3,G+H+.086,centre),Vector3(.65,.025,length),"b5b3a5",false,26)
		K.box(n,Vector3(-37.3,G+H+.105,centre),Vector3(.28,.016,length),"646d69",false,11)
		for i in ceili(length/.14):
			K.box(n,Vector3(-37.3,G+H+.116,span.x+(i+.5)*.14),Vector3(.24,.012,.023),"343e3a",false,22)
	for z in range(-831,-778):
		var at_stair:bool=false
		for s in STAIRS:
			if absf(z-s)<5.1:at_stair=true
		if not at_stair:K.box(n,Vector3(-36.2,G+H+.163,z),Vector3(.65,.006,.012),"898a7e",false,22)
	# Curved burgundy/lime bands are living foliage, with soil beneath rather than grass rectangles.
	V.setup()
	for iz in 51:
		var dz: float=-12.5+iz*.5
		var bow: float=3.8*pow(absf(dz)/12.5,2)
		for ix in 30:
			var x: float=-18.4-bow-ix*.47
			if x < -36.1:continue
			var y:=local_height(x,-805+dz,G)
			var band:=int(ix/6)%2
			var tint:=Color(1.30,.43,.92) if band==0 else Color(1.20,1.25,.50)
			V.queue_instance(n,"leaf",Transform3D(Basis(Vector3.UP,ix*2.399+iz)*Basis.from_scale(Vector3(.78,.53,.76)),Vector3(x,y+.32,-805+dz)),tint)
	for x in range(-35,-18):
		var a:=Vector3(x,local_height(x,-817.8,G)+.035,-817.8)
		var c:=Vector3(x+1,local_height(x+1,-792.2,G)+.035,-792.2)
		K.surface(n,K.quad(a,Vector3(c.x,c.y,a.z),c,Vector3(a.x,a.y,c.z)),"665645",3,false)
	# Leave a clear upper route behind the bank and along both building sides.
	for z in [-787.5,-822.5]:
		K.box(n,Vector3(-41,G+H+.09,z),Vector3(7,.025,.25),"b8b6a7",false,26)
	for z in [-796,-814]:
		K.box(n,Vector3(-39.5,G+H+.095,z),Vector3(.35,.03,3),"606d61",false,11)
	K.finish(n)
