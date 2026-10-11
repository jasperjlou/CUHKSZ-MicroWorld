extends RefCounted
## Official aerial92544949: weathered service roof, large gridded blue-green top cover,
## two cooling towers, grouped condensers and exposed pipes. Dimensions remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const W:=preload("res://world/visual_campus/WesternCampus.gd")

static func cylinder(n:Node3D,p:Vector3,r:float,h:float,color:String) -> void:
	var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.radial_segments=24
	var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=K.material(color,11);node.position=p;n.add_child(node)

static func tower(n:Node3D,x:float,z:float) -> void:
	for dx in [-.85,.85]:K.box(n,Vector3(x+dx,.4,z),Vector3(.20,.6,2),"a1a89e",false,11)
	cylinder(n,Vector3(x,1.65,z),1.25,2.25,"a5ada6")
	cylinder(n,Vector3(x,2.81,z),1.13,.08,"303b36")
	for i in 28:
		var a:float=i*TAU/28
		K.box(n,Vector3(x+cos(a)*1.26,1.65,z+sin(a)*1.26),Vector3(.045,2.05,.045),"6f7b72",false,11)
	for a in [0.0,PI/2]:K.box(n,Vector3(x,2.88,z),Vector3(2.1,.04,.075),"8e9b91",false,11,a)
	for i in 5:K.box(n,Vector3(x,2.85,z),Vector3(1.8,.025,.15),"526159",false,11,i*TAU/5)
	cylinder(n,Vector3(x,2.90,z),.18,.08,"a1aaa0")
	W.beam(n,Vector3(x,.7,z+1.2),Vector3(x,.7,z+3.4),.15,.15,"a0aa9e")

static func build(parent:Node3D,w:float,d:float) -> void:
	var n:=K.holder(parent,"ZhixinRoofPlantV83",Vector3(0,15.84,-d*.33))
	var half:float=d*.14
	K.box(n,Vector3(0,.015,0),Vector3(w-.5,.025,d*.28-.5),"68695f",false,36)
	# Raised blue-green panelled cover. Photo does not establish glazing or an interior opening.
	var cx:float=-6;var length:float=36;var width:float=7.8
	K.box(n,Vector3(cx,.52,0),Vector3(length,1.0,width),"607276",true,22)
	for side in [-1,1]:
		var a:=Vector3(cx-length/2,1.01,side*width/2);var b:=Vector3(cx+length/2,1.01,side*width/2)
		var c:=Vector3(cx+length/2,1.65,0);var e:=Vector3(cx-length/2,1.65,0)
		K.surface(n,K.quad(a,b,c,e),"647f83",22)
		for i in 19:
			var x:float=cx-length/2+i*2.0
			W.beam(n,Vector3(x,1.035,side*width/2),Vector3(x,1.675,0),.055,.055,"a5b3ab")
		for j in 3:
			var t:float=j/2.0
			W.beam(n,a.lerp(e,t)+Vector3.UP*.025,b.lerp(c,t)+Vector3.UP*.025,.055,.055,"a5b3ab")
	# The taller teaching return starts at local X=21.84; stay on the exposed low roof.
	for x in [15,20]:tower(n,x,-1.7)
	# Condensers at the opposite end, outside the rooflight footprint.
	for x in [-36,-32,-28]:
		for z in [-3,0,3]:
			K.box(n,Vector3(x,.7,z),Vector3(1.05,1.30,.72),"b9c0b3",false,11)
			cylinder(n,Vector3(x,1.36,z),.32,.025,"5a665e")
	for z in [-half+.75,half-.75]:
		for dy in [.20,.37]:W.beam(n,Vector3(-w/2+1,dy,z),Vector3(w/2-1,dy,z),.08,.08,"b5b9a8")
		for x in range(-38,39,6):K.box(n,Vector3(x,.14,z),Vector3(.32,.28,.65),"8b9284",false,22)
	W.beam(n,Vector3(15,.65,1.7),Vector3(20,.65,1.7),.13,.13,"a0aa9e")
	W.beam(n,Vector3(20,.65,1.7),Vector3(20,.65,half-.75),.13,.13,"a0aa9e")
	K.finish(n)
