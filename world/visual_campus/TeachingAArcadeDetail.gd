extends RefCounted
## V97. Official panoramas 70040620 / 70037173, capture dates unknown.
## Features fitted to the V96 historic CAD axes; stair runs and screen spacing are inferred.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")

static func rail(n:Node3D,a:Vector3,c:Vector3) -> void:
	var d:=c-a;var length:=Vector2(d.x,d.z).length();var yaw:=atan2(d.x,d.z)
	var h:=K.holder(n,"MetalBalustrade",(a+c)/2+Vector3.UP*1.10);h.rotation=Vector3(-atan2(d.y,length),yaw,0)
	K.box(h,Vector3.ZERO,Vector3(.065,.065,d.length()),"656b62",false,11)
	# Invisible guard follows the posts; no transparent glass sheet in the reference.
	var body:=StaticBody3D.new();n.add_child(body);body.position=(a+c)/2+Vector3.UP*.56;body.rotation=h.rotation
	var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(.075,1.16,d.length())
	collision.shape=shape;body.add_child(collision)
	for i in ceili(length/.15)+1:
		var p:=a.lerp(c,float(i)/ceili(length/.15))
		K.box(n,p+Vector3.UP*.55,Vector3(.028,1.10,.028),"697063",false,11)
	K.finish(h)

static func stair(n:Node3D,a:Vector3,c:Vector3,width:float) -> void:
	var delta:=c-a;var length:=Vector2(delta.x,delta.z).length()
	var h:=K.holder(n,"ConcreteReturnStair",a);h.rotation.y=atan2(delta.x,delta.z)
	var end:=Vector3(0,delta.y,length);var steps:=ceili(absf(delta.y)/.17)
	for i in steps:
		var p:=end*(i+.5)/steps;p.y=delta.y*(i+1)/steps-.065
		K.box(h,p,Vector3(width,.13,length/steps+.015),"a6a89e",false,26)
		K.box(h,Vector3(0,delta.y*(i+1)/steps+.005,length*(i+1)/steps-.04),Vector3(width-.04,.012,.06),"70786e",false,11)
	var ramp:=K.surface(h,K.quad(Vector3(-width/2,.035,0),Vector3(width/2,.035,0),end+Vector3(width/2,.065,0),end+Vector3(-width/2,.065,0)),"a6a89e",26,true);ramp.hide()
	load("res://world/visual_campus/TeachingBlocks.gd").stair_soffit(h,Vector3.ZERO,end,width)
	for side in [-1,1]:rail(h,Vector3(side*(width/2+.12),0,0),end+Vector3(side*(width/2+.12),0,0))
	K.finish(h)

static func floor_piece(n:Node3D,u0:float,u1:float,v0:float,v1:float,y:float) -> void:
	K.box(n,Vector3((u0+u1)/2,y-.13,(v0+v1)/2),Vector3(u1-u0,.26,v1-v0),"8f968e",true,41)

static func potted_yucca(n:Node3D,p:Vector3) -> void:
	var h:=K.holder(n,"PottedYucca",p)
	K.box(h,Vector3(0,.3,0),Vector3(.45,.60,.45),"b7bab0",false,22)
	K.box(h,Vector3(0,1.2,0),Vector3(.055,1.3,.055),"807c59",false,4)
	for j in 2:
		var center:=Vector3(0,1.65-j*.50,0)
		for i in 13:
			var angle:=i*TAU/13+j*.3;var dir:=Vector3(cos(angle),0,sin(angle));var tangent:=Vector3(-dir.z,0,dir.x)*.07
			K.surface(h,PackedVector3Array([center-tangent,center+dir*.8+Vector3.UP*(.22 if i%2 else .60),center+tangent,center+tangent,center+dir*.8+Vector3.UP*(.22 if i%2 else .60),center-tangent]),"617347",22)
	K.finish(h)

static func seat_group(n:Node3D,p:Vector3) -> void:
	K.box(n,p+Vector3.UP*.76,Vector3(1.4,.07,.78),"726848",true,4)
	for a in [-.52,.52]:
		for z in [-.27,.27]:K.box(n,p+Vector3(a,.37,z),Vector3(.04,.74,.04),"515950",false,11)
		K.box(n,p+Vector3(a,.12,0),Vector3(.04,.04,.60),"515950",false,11)
	for side in [-1,1]:
		for u in [-.38,.38]:
			var c:=p+Vector3(u,0,side*.75)
			K.box(n,c+Vector3.UP*.43,Vector3(.43,.06,.43),"93815b",true,4)
			K.box(n,c+Vector3(0,.72,side*.18),Vector3(.43,.51,.045),"93815b",false,4)
			for x in [-.17,.17]:
				for z in [-.17,.17]:K.box(n,c+Vector3(x,.21,z),Vector3(.035,.42,.035),"515950",false,11)

static func build(parent:Node3D) -> void:
	var n:=K.holder(parent,"ObservedArcadeV97")
	# Rear open gallery and four flights: the courtyard photograph shows a tall return stair.
	floor_piece(n,-2,17,26,37.5,4.2)
	K.box(n,Vector3(7.5,6.40,26),Vector3(19,4.4,.23),"b6ae9b",true,15)
	for u in [-2.0,14.5,27.0,37.0]:K.box(n,Vector3(u,6.4,37.5),Vector3(.4,4.4,.42),"b6ae9b",true,15)
	K.box(n,Vector3(17.5,8.42,37.5),Vector3(39,.38,.45),"b6ae9b",false,15)
	K.box(n,Vector3(17.5,8.425,31.8),Vector3(39,.035,10.9),"4d5650",false,22)
	for u in [-.5,5.0,11.0,17.0,24.0,31.0,35.0]:
		for v in [29.0,34.5]:K.box(n,Vector3(u,8.394,v),Vector3(1.1,.027,.13),"e3e5d6",false,17)
	for span:Vector2 in [Vector2(-2,20.5),Vector2(23.5,37)]:rail(n,Vector3(span.x,4.2,37.6),Vector3(span.y,4.2,37.6))
	rail(n,Vector3(-2,4.2,26),Vector3(-2,4.2,37.5))
	for level:float in [0.0,4.2]:
		var mid:float=2.1 if level==0 else 6.45;var top:float=4.2 if level==0 else 8.7
		stair(n,Vector3(22,level,43.3),Vector3(30,mid,43.3),2.2)
		floor_piece(n,30,32.1,37.7,44.6,mid)
		stair(n,Vector3(30,mid,39.1),Vector3(22,top,39.1),2.2)
		floor_piece(n,20.5,22.1,37.35,44.6 if top<8 else 40.3,top)
		for v in [37.7,44.6]:rail(n,Vector3(30.2,mid,v),Vector3(32.1,mid,v))
		rail(n,Vector3(32.1,mid,37.7),Vector3(32.1,mid,44.6))
		rail(n,Vector3(20.5,top,37.6),Vector3(20.5,top,44.6 if top<8 else 40.3))
	rail(n,Vector3(20,8.7,37.5),Vector3(20,8.7,45))
	rail(n,Vector3(20,8.7,45),Vector3(32.5,8.7,45))
	rail(n,Vector3(32.5,8.7,45),Vector3(32.5,8.7,37.5))
	# Warm suspended fins at the outer side of the tall arcade, clear above the walking level.
	for i in 45:K.box(n,Vector3(37.1,6.25,38.0+i*.75),Vector3(.48,4.1,.085),"9a7356",false,4)
	for y in [4.2,8.3]:K.box(n,Vector3(37.05,y,54.8),Vector3(.13,.10,34.3),"586251",false,11)
	for v in range(46,72,7):
		K.box(n,Vector3(25.6,8.10,v),Vector3(22,.40,.38),"aeb0a2",false,22)
		for u in [20.0,30.0]:K.box(n,Vector3(u,7.86,v),Vector3(.16,.025,.16),"dedcc9",false,17)
	for v in [54.0,63.0]:
		seat_group(n,Vector3(29,.07,v));seat_group(n,Vector3(33,.07,v))
	for v in [40.0,46.0,50.5]:potted_yucca(n,Vector3(15.4,.06,v))
	# Entry: narrow central glazing in a warm wall with dark fins, not a full-width glass curtain.
	for span:Vector2 in [Vector2(14.5,26),Vector2(31,37)]:
		var center:float=(span.x+span.y)/2;var width:float=span.y-span.x
		K.box(n,Vector3(center,3.1,91),Vector3(width,6.2,.28),"baab8e",true,15)
		K.box(n,Vector3(center,7.92,91),Vector3(width,1.56,.28),"baab8e",true,15)
		K.box(n,Vector3(center,6.72,90.95),Vector3(width-.4,1.03,.06),"485d5e",true,5)
		for u in range(ceili(span.x),floori(span.y),2):K.box(n,Vector3(u,6.72,91.01),Vector3(.07,1.04,.15),"4b554c",false,11)
		for i in floori(width/.42):K.box(n,Vector3(span.x+.20+i*.42,2.17,91.23),Vector3(.075,4.34,.47),"454f45",false,11)
	for u in [26.0,31.0]:K.box(n,Vector3(u,4.29,91.04),Vector3(.11,8.58,.24),"364238",true,11)
	for y in [4.1,8.55]:K.box(n,Vector3(28.5,y,91.04),Vector3(5,.11,.24),"364238",false,11)
	K.box(n,Vector3(28.5,6.32,91.01),Vector3(4.85,4.29,.075),"819b91",true,19)
	for u in [26.12,30.88]:
		K.box(n,Vector3(u,2.02,90.4),Vector3(.06,4,1.18),"819b91",false,19)
		K.box(n,Vector3(u+.07,1.56,90.35),Vector3(.045,1.15,.07),"aeb3a4",false,11)
	# Exterior covered arcade and photographed upper screens; entrance path remains clear.
	floor_piece(n,-15,37,91,96,.06)
	# V100 external return stair must pass through the 8.7m front gallery floor.
	preload("res://world/visual_campus/TeachingAPromenadeStair.gd").build(n)
	for u in [-13.0,-5.0,3.0,11.0,19.0,27.0,35.0]:
		K.box(n,Vector3(u,4.3,95.3),Vector3(.52,8.6,.52),"b5b7a9",true,22)
		if u>5.8 and u<20.5:
			# No rendered cross-beam through the new upper flight opening.
			K.box(n,Vector3(u,8.10,92),Vector3(.40,.65,2),"b5b7a9",false,22)
			K.box(n,Vector3(u,8.10,95.5),Vector3(.40,.65,1),"b5b7a9",false,22)
		else:K.box(n,Vector3(u,8.10,93.5),Vector3(.40,.65,5),"b5b7a9",false,22)
		K.box(n,Vector3(u+.34,3.95,95.3),Vector3(.09,7.9,.09),"bdbbad",false,22)
	for i in 68:K.box(n,Vector3(-14.5+i*.75,6.18,96),Vector3(.085,4.25,.45),"9c765a",false,4)
	for y in [4.08,8.28]:K.box(n,Vector3(11,y,95.94),Vector3(52,.11,.12),"59624e",false,11)
	# Tree/hedge beds and stone seats are registered in GateLawnGround V98.
	for u in [-8.0,8.0,23.0]:K.box(n,Vector3(u,.071,93.5),Vector3(.12,.015,4.8),"737c70",false,15)
	K.label(n,"教学楼 A",Vector3(28.5,4.5,91.21),.009)
	K.finish(n)
