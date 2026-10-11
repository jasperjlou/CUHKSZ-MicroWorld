extends RefCounted
## V125: rear-return stair indicated in ROCCO plans; metric fit, not an as-built survey.
## Joins the deep court and the two photographed bronze-screen galleries.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const T:=preload("res://world/visual_campus/TeachingBlocks.gd")
const D:=preload("res://world/visual_campus/LowerCampusLandscape.gd")
const LEVELS:Array[float]=[0,4.925,8.625,12.325,16.025,19.725]

static func slab(n:Node3D,x0:float,x1:float,z0:float,z1:float,y:float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.125,(z0+z1)/2),Vector3(x1-x0,.25,z1-z0),"b4b6ac",true,42)

static func rail(n:Node3D,a:Vector3,c:Vector3) -> void:
	# Same guard collision as the accepted podium rail; dark pickets match user photos.
	var d:=c-a;var yaw:=atan2(d.x,d.z);var mid:Vector3=(a+c)/2
	var guard:=StaticBody3D.new();n.add_child(guard);guard.position=mid+Vector3.UP*.6
	guard.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),yaw,0)
	var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new()
	shape.size=Vector3(.09,1.2,d.length());collision.shape=shape;guard.add_child(collision)
	var top:=K.holder(n,"DarkCourtHandrail",mid+Vector3.UP*1.17);top.rotation=guard.rotation
	K.box(top,Vector3.ZERO,Vector3(.065,.06,d.length()),"484f49",false,11);K.finish(top)
	var count:=ceili(d.length()/.28)
	for i in count+1:
		var p:=a.lerp(c,float(i)/count)
		K.box(n,p+Vector3.UP*.57,Vector3(.028,1.14,.028),"484f49",false,11)

static func flight(n:Node3D,a:Vector3,c:Vector3) -> void:
	var count:=ceili((c.y-a.y)/.165)
	for i in count:
		var p:=a.lerp(c,(i+.5)/count);p.y=lerpf(a.y,c.y,float(i+1)/count)-.07
		K.box(n,p,Vector3(1.9,.14,absf(c.z-a.z)/count+.01),"b4b6ac",false,42)
	var ramp:=K.surface(n,K.quad(a+Vector3(-.95,.04,0),a+Vector3(.95,.04,0),c+Vector3(.95,.12,0),c+Vector3(-.95,.12,0)),"b4b6ac",42,true);ramp.hide()
	# Blend the collision clearance back into the landing; no raised lip on descent.
	var end:=c+Vector3(0,.015,signf(c.z-a.z)*.8)
	var join:=K.surface(n,K.quad(c+Vector3(-.95,.12,0),c+Vector3(.95,.12,0),end+Vector3(.95,0,0),end+Vector3(-.95,0,0)),"b4b6ac",42,true);join.hide()
	T.stair_soffit(n,a,c,1.9)
	for side in [-1,1]:rail(n,a+Vector3(side*1.02,0,0),c+Vector3(side*1.02,0,0))

static func build(b:Node3D,_r:Dictionary) -> void:
	var n:=K.holder(b,"ZhangRearCoreAndCourtGalleryV125")
	# Open ground vestibule has real side access; no invented private room fit-out.
	for span:Vector2 in [Vector2(-22.8,-22.0),Vector2(-18.5,-18.0)]:
		K.box(n,Vector3((span.x+span.y)/2,2.2,-24.44),Vector3(span.y-span.x,4.4,.20),"bbb7aa",true,22)
	K.box(n,Vector3(-20.4,4.38,-24.44),Vector3(4.8,.22,.28),"aaa99f",false,22)
	for x in [-22.05,-18.45]:K.box(n,Vector3(x,1.98,-24.28),Vector3(.08,3.96,.13),"4d5652",false,11)
	for side in [-1,1]:
		K.box(n,Vector3(-20.25+side*1.82,1.9,-25.5),Vector3(.07,3.8,2.2),"91a7a2",false,19)
	# Switchback well is cut from all occupied upper slabs; roof is retained.
	for f in LEVELS.size()-1:
		var y:float=LEVELS[f];var upper:float=LEVELS[f+1];var half:float=(y+upper)/2
		flight(n,Vector3(-21.65,y,-28.2),Vector3(-21.65,half,-38))
		slab(n,-22.8,-18.0,-40.65,-38,half)
		flight(n,Vector3(-19.15,half,-38),Vector3(-19.15,upper,-28.2))
		rail(n,Vector3(-22.7,half,-40.55),Vector3(-18.1,half,-40.55))
		for x in [-22.7,-18.1]:rail(n,Vector3(x,upper,-40.55),Vector3(x,upper,-28.2))
		rail(n,Vector3(-22.7,upper,-40.55),Vector3(-18.1,upper,-40.55))
		# The floor beside the well leads through actual openings in the return wall.
		slab(n,-19.9,-18.0,-24.44,-21.7,upper)
		rail(n,Vector3(-19.8,upper,-21.72),Vector3(-18.1,upper,-21.72))
		rail(n,Vector3(-18.1,upper,-24.2),Vector3(-18.1,upper,-21.72))
		# The side return stops at the third-level roof. Higher floors retain only
		# their rear-core landing; no unsupported upper corridor over the low roof.
		# V134 low wing supplies the interior floors/roof itself. Keep only the
		# external front bridges and rear landings, without slabs through its notch.
		if f in [1,2]:
			# Body datum moved down4.8; preserve independently photographed galleries.
			# Fitted gentle1.1m transitions join body level3.825/7.525 to4.925/8.625.
			var start:=Vector3(-21.5,upper,16.26)
			var end:=Vector3(-21.5,upper+1.1,39.64)
			K.surface(n,K.quad(start+Vector3(-1.6,0,0),start+Vector3(1.6,0,0),end+Vector3(1.6,0,0),end+Vector3(-1.6,0,0)),"b4b6ac",42,true)
			# quad normalizes every ribbon upward; reverse its output for the soffit.
			var underside:=K.quad(start+Vector3(-1.6,-.20,0),end+Vector3(-1.6,-.20,0),end+Vector3(1.6,-.20,0),start+Vector3(1.6,-.20,0))
			underside.reverse();K.surface(n,underside,"bdc0b4",22)
			for side in [-1,1]:
				var fascia:=K.holder(n,"BridgeSlabEdge",(start+end)/2+Vector3(side*1.6,-.10,0));fascia.rotation.x=-atan2(1.1,23.38)
				K.box(fascia,Vector3.ZERO,Vector3(.12,.20,start.distance_to(end)),"bdc0b4",false,22);K.finish(fascia)
			for x in [-23.05,-19.82]:rail(n,Vector3(x,upper,16.5),Vector3(x,upper+1.1,39.59))
		elif f>=3:
			slab(n,-23.1,-19.9,-24.44,-21.7,upper)
			rail(n,Vector3(-23.05,upper,-21.75),Vector3(-19.82,upper,-21.75))
			rail(n,Vector3(-23.05,upper,-24.3),Vector3(-23.05,upper,-21.75))

		K.box(n,Vector3(-20.4,upper+2.9,-26.6),Vector3(2.4,.055,.22),"e4e4d4",false,17)
	# Slender support line leaves the ground court permeable.
	for z in [-17,-5,7,19,31]:K.column(n,Vector3(-20.25,0,z),4.8,.44)
	K.column(n,Vector3(-18.3,0,-22.2),4.8,.44)
	D.drain(n,Vector3(-20.25,.072,-23.65),3.5)
	# Paved branch from the existing rear undercroft route into the stair vestibule.
	K.box(n,Vector3(-10,.072,-20),Vector3(24,.02,3.1),"a3a79e",false,42)
	# V133: discard the four unbacked ground-glass placeholders. Their isolated
	# panels were not an evidenced room boundary and became exposed in the open court.
	K.finish(n)
