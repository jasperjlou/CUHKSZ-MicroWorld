extends RefCounted
## V216: May2026 map, architect043 and read-only legacy GTA agree on the outer edge.
## Topology only: dimensions, fence finish and planting are fitted; true north unresolved.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const WALK_X:=-181.0
const FENCE_X:=-184.5

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"StartZonePerimeterV216")
	# Continuous outer walk, with no new duplicate over DaoYuan's inner pavement.
	# Solid top sits 8 cm above ground and gives the visible paving a matching support.
	# V217: split at the old-gate driveway and grade the walking edges to its top.
	for span:Vector2 in [Vector2(-840,-796),Vector2(-784,-624)]:
		K.box(n,Vector3(WALK_X,G+.0375,(span.x+span.y)/2),Vector3(4.6,.085,span.y-span.x),"929789",true,26)
	for ends:Vector4 in [Vector4(-796,.08,-794,.035),Vector4(-786,.035,-784,.08)]:
		K.surface(n,K.quad(Vector3(WALK_X-2.3,G+ends.y,ends.x),Vector3(WALK_X+2.3,G+ends.y,ends.x),Vector3(WALK_X+2.3,G+ends.w,ends.z),Vector3(WALK_X-2.3,G+ends.w,ends.z)),"929789",26,true)
	# The narrow margin is a paved gutter, not grass between roadway and kerb.
	K.box(n,Vector3(-178.08,G+.015,-732),Vector3(1.18,.016,216),"92998b",false,15)
	# Road-side edge and shallow drainage, interrupted at the branch and old gate.
	for span:Vector2 in [Vector2(-840,-820),Vector2(-766,-679),Vector2(-673.8,-624)]:
		var length:=span.y-span.x;var z:float=(span.x+span.y)/2
		K.box(n,Vector3(-178.57,G+.10,z),Vector3(.22,.12,length),"b3b7aa",true,15)
		K.box(n,Vector3(-178.18,G+.031,z),Vector3(.42,.015,length),"6b7569",false,15)
		for station in range(ceili(span.x)+2,int(span.y)-1,12):
			K.box(n,Vector3(-178.18,G+.045,station),Vector3(.38,.018,.72),"3d4c43",false,22)
			for i in 6:K.box(n,Vector3(-178.18,G+.058,station-.30+i*.12),Vector3(.37,.016,.022),"8a9486",false,11)
	# A grey landing joins the existing branch footway, ending at the asphalt edge.
	# No decorative stone ribbon extends across the perimeter carriageway.
	K.box(n,Vector3(-169.9,G+.097,-676.4),Vector3(1.3,.034,3.2),"918c7c",false,65)
	# Legacy fence shows a low base, spaced stone piers and slender metal infill.
	# Keep a wide open gate interval; fence does not obstruct either access route.
	for span:Vector2 in [Vector2(-840,-820),Vector2(-766,-624)]:
		var count:=ceili((span.y-span.x)/4.0)
		for i in count:
			var a:=lerpf(span.x,span.y,float(i)/count)
			var b:=lerpf(span.x,span.y,float(i+1)/count)
			var z:float=(a+b)/2
			K.box(n,Vector3(FENCE_X,G+.16,z),Vector3(.40,.32,b-a),"939a89",true,15)
			for h:float in [.46,1.52]:K.box(n,Vector3(FENCE_X,G+h,z),Vector3(.07,.065,b-a),"606f61",false,11)
			var bars:=ceili((b-a)/.23)
			for j in bars:K.box(n,Vector3(FENCE_X,G+.98,lerpf(a,b,(j+.5)/bars)),Vector3(.035,1.13,.035),"647464",false,11)
			# One invisible panel per bay owns collision instead of hundreds of tiny bars.
			var body:=StaticBody3D.new();var shape:=CollisionShape3D.new();var box:=BoxShape3D.new()
			box.size=Vector3(.14,1.45,b-a);shape.shape=box;body.add_child(shape);body.position=Vector3(FENCE_X,G+.89,z);n.add_child(body)
		for i in count+1:
			var z:=lerpf(span.x,span.y,float(i)/count)
			K.box(n,Vector3(FENCE_X,G+.90,z),Vector3(.39,1.8,.39),"a6ad9c",true,15)
			K.box(n,Vector3(FENCE_X,G+1.82,z),Vector3(.49,.10,.49),"b3b9a8",false,15)
	# Narrow planted edge follows the reference boundary; no invented mound or hill.
	for span:Vector2 in [Vector2(-840,-822),Vector2(-764,-624)]:
		builder.ribbon(n,[[-189,G,span.x],[-189,G,span.y]],7.4,"657252",3,.025)
		for z in range(ceili(span.x)+3,int(span.y)-2,5):
			V.shrub(n,Vector3(-187.9,G,z),Vector3(4.3,1.05,4.6),216000+absi(z))
		for z in range(ceili(span.x)+6,int(span.y)-4,13):
			K.tree(n,Vector3(-189.3,G,z),8.6+absi(z)%3,216100+absi(z),1.3)
	K.finish(n)
	n.set_meta("evidence", "start_zone_perimeter_v216.json; fitted boundary, no metric survey")
