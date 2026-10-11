extends RefCounted
## User photos 20261010_222250/257/313: open galleries behind continuous bronze fins.
## Retained building anchor; dimensions and unseen upper/court geometry remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const T:=preload("res://world/visual_campus/TeachingBlocks.gd")

static func rail(b:Node3D,p:Vector3,length:float,yaw:float=0.0) -> void:
	var body:=StaticBody3D.new();var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new()
	shape.size=Vector3(length,1.14,.065);collision.shape=shape;collision.position=p+Vector3.UP*.57;collision.rotation.y=yaw;body.add_child(collision);b.add_child(body)
	K.box(b,p+Vector3.UP*1.15,Vector3(length,.065,.075),"454a46",false,11,yaw)
	var basis:=Basis(Vector3.UP,yaw)
	for i in int(length/.24):K.box(b,p+basis*Vector3(-length/2+(i+.5)*.24,.56,0),Vector3(.027,1.12,.035),"454a46",false,11)

static func build(b:Node3D,r:Dictionary) -> void:
	var n:=K.holder(b,"ZhangPhotoFrontV85")
	# Two galleries sit in front of the retained oblique court. Separate bands leave the outer stair open.
	for y in [4.8,8.5]:
		K.box(n,Vector3(0,y,23.6),Vector3(60,.25,3.2),"bab9af",true,22)
		if y==4.8:
			for span:Vector2 in [Vector2(-30,-4),Vector2(12,30)]:K.box(n,Vector3((span.x+span.y)/2,y,27),Vector3(span.y-span.x,.25,3.6),"bab9af",true,22)
		else:K.box(n,Vector3(0,y,27),Vector3(60,.25,3.6),"bab9af",true,22)
		K.box(n,Vector3(0,y-.31,23.6),Vector3(60,.36,.36),"c3c0b6",false,22)
		if y==4.8:
			rail(n,Vector3(-4.1,y+.125,28.75),51.8)
			rail(n,Vector3(28.1,y+.125,28.75),3.8)
		else:rail(n,Vector3(0,y+.125,28.75),60)
		# Inner gallery edge meets existing wings only where their current shells reach it.
		for span:Vector2 in [Vector2(-30,-23.4),Vector2(-19.6,10)]:rail(n,Vector3((span.x+span.y)/2,y+.125,22.02),span.y-span.x)
	for x in [-28,-20,-12,4,20,28]:
		K.box(n,Vector3(x,2.34,23.1),Vector3(.65,4.68,.65),"c6c1b3",true,22)
		K.box(n,Vector3(x,4.47,25.4),Vector3(.36,.40,7.3),"c9c5b9",false,22)
		K.box(n,Vector3(x,4.22,26),Vector3(1.2,.05,.20),"e9e1cc",false,17)
	K.box(n,Vector3(0,12.25,25.5),Vector3(60,.24,7.4),"c3bfb2",true,22)
	# The photographed screen is one tall veil, not small screens in individual windows.
	for i in 150:
		var x:float=-30+(i+.5)*.4
		if x>21.8 and x<26.2:K.box(n,Vector3(x,10.43,29.02),Vector3(.105,3.87,.42),"a87b4c",false,11)
		else:K.box(n,Vector3(x,8.29,29.02),Vector3(.105,8.15,.42),"a87b4c",false,11)
	for y in [4.48,8.48,12.1]:K.box(n,Vector3(0,y,28.8),Vector3(60,.08,.11),"5c6257",false,11)
	# Concrete external stair runs along the front elevation; the first gallery has a real opening.
	var stair:=K.holder(n,"LongitudinalExteriorStair",Vector3(12,0,26.85));stair.rotation.y=-PI/2
	var a:=Vector3.ZERO;var c:=Vector3(0,4.925,16)
	preload("res://world/visual_campus/TeachingPublicSpaces.gd").flight(stair,a,c,3.0)
	T.stair_soffit(stair,a,c,3.0)
	K.finish(stair)
	# First-floor landing merges with the gallery at the head of the flight.
	K.box(n,Vector3(-5,4.8,26.85),Vector3(2,.25,3.1),"bab9af",true,22)
	rail(n,Vector3(4,4.925,25.21),16)
	preload("res://world/visual_campus/ZhangEntranceArcade.gd").build(n)
	K.box(n,Vector3(0,.067,31),Vector3(64,.04,3),"858b85",false,26)
	# Slotted drain follows the actual arcade edge, separate from the narrow grass strip.
	K.box(n,Vector3(0,.093,32.65),Vector3(64,.018,.32),"48554e",false,11)
	for i in 256:K.box(n,Vector3(-32+(i+.5)*.25,.106,32.65),Vector3(.052,.012,.27),"989c8f",false,11)
	K.box(n,Vector3(-4,.035,33.8),Vector3(56,.04,1.8),"667956",false,3)
	K.box(n,Vector3(-4,.072,37),Vector3(56,.035,4.4),"959a90",false,26)
	for x in [-23,-8,8,23]:
		K.tree(n,Vector3(x,0,42),7.8,8500+int(x))
	# Join both frontage ends and leave the strip open at the transverse bridge.
	for x in [-32,24]:K.box(n,Vector3(x,.072,34.75),Vector3(2,.035,10.5),"959a90",false,26)
	K.finish(n)

static func transverse(root:Node3D) -> void:
	var n:=K.holder(root,"ZhangTransverseLinkV85")
	var top:=6.89
	K.box(n,Vector3(10,top-.14,-444),Vector3(124,.28,4.4),"b1b0a3",true,26)
	# Small fitted level transition joins the existing transverse deck to Zhang's first gallery.
	K.surface(n,K.quad(Vector3(-33,top,-446.1),Vector3(-33,top,-441.9),Vector3(-36.3,7.165,-441.9),Vector3(-36.3,7.165,-446.1)),"b1b0a3",26,true)
	for x in [-42,-24,24,48,67]:
		K.box(n,Vector3(x,(top+2.24)/2-.1,-444),Vector3(.65,top-2.24-.2,.65),"c5c2b5",true,22)
		K.box(n,Vector3(x,top-.40,-444),Vector3(.42,.52,4.8),"c5c2b5",false,22)
	for z in [-446.35,-441.65]:
		for i in 310:
			var x:float=-52+(i+.5)*.4
			if x<-36.5:continue # Inside the adjoining gallery, not an exterior bridge edge.
			if z>-444 and absf(x-38)<1.85:continue
			K.box(n,Vector3(x,8.52,z),Vector3(.09,4.0,.36),"a78a65",false,11)
		# Leave the existing access stair mouth free.
		if z>-444:
			rail(n,Vector3(0,top,-441.83),72)
			rail(n,Vector3(56,top,-441.83),32)
		else:rail(n,Vector3(18,top,-446.17),108)
		K.box(n,Vector3(10,10.63,z),Vector3(124,.16,.20),"8f8c7b",false,11)
	# Slim open overhead beams remain visible between the two fin screens.
	for x in range(-52,73,4):K.box(n,Vector3(x,10.45,-444),Vector3(.13,.16,4.7),"828777",false,11)
	K.finish(n)
