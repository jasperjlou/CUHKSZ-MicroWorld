extends RefCounted
## V171: built views009/010/011 and axo073, published2025-12-24, capture date unknown.
## Local stairs/apron fitted to retained podium datums; rear hill-road registration remains open.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const T=preload("res://world/visual_campus/TeachingBlocks.gd")
const P=preload("res://world/visual_campus/ShawEastPodium.gd")

static func guard(n:Node3D,a:Vector3,b:Vector3)->void:
	var c:=b+Vector3.UP*1.12;var d:=a+Vector3.UP*1.12
	K.surface(n,PackedVector3Array([a,b,c,a,c,d,c,b,a,d,c,a]),"c8ccc3",26,true)
	var delta:=b-a;var top:=K.holder(n,"StoneCoping",(a+b)/2+Vector3.UP*1.14)
	top.rotation=Vector3(-atan2(delta.y,Vector2(delta.x,delta.z).length()),atan2(delta.x,delta.z),0)
	K.box(top,Vector3.ZERO,Vector3(.23,.065,delta.length()),"d0d3c9",false,22);K.finish(top)

static func stair(n:Node3D,a:Vector3,b:Vector3)->void:
	var count:=ceili((b.y-a.y)/.17);var thickness:float=(b.y-a.y)/count+.02
	for i in count:
		var p:=a.lerp(b,(i+.5)/count);p.y=lerpf(a.y,b.y,(i+1.)/count)-thickness/2
		K.box(n,p,Vector3(4,thickness,absf(b.z-a.z)/count+.01),"c4c7bc",false,26)
	var ramp:=K.surface(n,K.quad(a+Vector3(-2,.035,0),a+Vector3(2,.035,0),b+Vector3(2,.065,0),b+Vector3(-2,.065,0)),"c4c7bc",26,true);ramp.visible=false
	T.stair_soffit(n,a,b,4)
	for x:float in [-2.12,2.12]:guard(n,a+Vector3(x,0,0),b+Vector3(x,0,0))

static func deck(n:Node3D,x0:float,x1:float,z0:float,z1:float,y:float)->void:
	K.box(n,Vector3((x0+x1)/2,y-.14,(z0+z1)/2),Vector3(x1-x0,.28,z1-z0),"bfc4ba",true,22)
	K.box(n,Vector3((x0+x1)/2,y+.01,(z0+z1)/2),Vector3(x1-x0,.02,z1-z0),"b5b9af",false,26)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"ResearchSideAccessV171")
	# Ground arrival is hard paving, with a covered portal distinct from the axial stair.
	deck(n,18,53,38,53,0)
	for x:float in [20,43]:
		K.box(n,Vector3(x,2.5,38),Vector3(4,5,.28),"c0c5b8",true,26)
	for span:Vector2 in [Vector2(22,30),Vector2(34,41)]:
		K.box(n,Vector3((span.x+span.y)/2,2.15,38),Vector3(span.y-span.x,4.3,.10),"5c797c",true,19)
		for x in range(int(span.x),int(span.y)+1,2):K.box(n,Vector3(x,2.15,38.10),Vector3(.07,4.3,.14),"6c7c73",false,11)
	for x:float in [29.95,34.05]:K.box(n,Vector3(x,2.15,38),Vector3(.10,4.3,.18),"697970",true,11)
	K.box(n,Vector3(31.5,4.7,38),Vector3(19,.6,.28),"c5c8bd",true,26)
	# Projecting upper stone terrace; retain the interior floor at exactly5.5.
	deck(n,18,45,38,44,5.5)
	guard(n,Vector3(18,5.5,44),Vector3(45,5.5,44))
	guard(n,Vector3(18,5.5,38),Vector3(18,5.5,44))
	guard(n,Vector3(45,5.5,30),Vector3(45,5.5,44))
	# Lower ochre fascia and a slender white covered walk beneath, as distinct layers.
	K.box(n,Vector3(31.5,4.55,43.9),Vector3(27,1.5,.22),"c8b49a",false,22)
	for y in range(0,6):K.box(n,Vector3(31.5,3.86+y*.25,44.03),Vector3(27,.016,.018),"9f9584",false,11)
	K.box(n,Vector3(31.5,3.78,42.6),Vector3(27,.12,2.6),"bdbcae",false,22)
	# Keep the low canopy on the building-side pavement, clear of the existing road at z46.
	K.box(n,Vector3(31,3.50,41.5),Vector3(26,.11,3),"d2d8cc",false,22)
	for x in [19,28,37,43]:K.box(n,Vector3(x,1.72,42.65),Vector3(.20,3.44,.20),"d1d7ce",true,22)
	for x in range(19,44,3):K.box(n,Vector3(x,3.43,41.5),Vector3(.075,.12,3),"c9d0c4",false,22)
	# Two flights on the end side rise behind the canopy, not through its roof.
	stair(n,Vector3(48,0,44),Vector3(48,5.5,30))
	deck(n,45,50.2,26,30,5.5)
	guard(n,Vector3(50.12,5.5,26),Vector3(50.12,5.5,30))
	stair(n,Vector3(48,5.5,26),Vector3(48,11.5,6))
	deck(n,41,50.2,2,6,11.5)
	guard(n,Vector3(45,11.5,2),Vector3(50.12,11.5,2))
	guard(n,Vector3(50.12,11.5,2),Vector3(50.12,11.5,6))
	# Middle landing enters the podium through a real opening in the former solid sidewall.
	deck(n,41,45,26,30,5.5)
	# Side and rear existing roof aisles get explicit hardscape, not a floating lawn overlay.
	K.box(n,Vector3(42.3,11.525,-15),Vector3(4.6,.025,36),"b1b6aa",false,26)
	K.box(n,Vector3(18,11.525,-35.5),Vector3(53,.025,3),"b1b6aa",false,26)
	for z in [47,52]:
		K.box(n,Vector3(32,.026,z),Vector3(24,.026,.15),"586257",false,11)
		for x in range(21,44):K.box(n,Vector3(x,.045,z),Vector3(.06,.012,.16),"899589",false,11)
	K.finish(n)
