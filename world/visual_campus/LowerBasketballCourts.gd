extends RefCounted
## Two outdoor courts: current PE directory; red/green surfacing and green fence in official aerial.
## Site footprint and standard-like court dimensions are model fits, not surveyed measurements.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const W:=preload("res://world/visual_campus/WesternCampus.gd")
const G:=2.24

static func line(n:Node3D,a:Vector2,c:Vector2,width:float=.055,color:String="dcded4",y:float=.165) -> void:
	var d:=c-a
	K.box(n,Vector3((a.x+c.x)/2,y,(a.y+c.y)/2),Vector3(width,.012,d.length()),color,false,22,atan2(d.x,d.y))

static func arc(n:Node3D,p:Vector2,r:float,a:float,c:float,y:float=.165,color:String="dcded4",width:float=.055) -> void:
	var count:=maxi(12,ceili(absf(c-a)*r*5))
	for i in count:
		var s:=lerpf(a,c,float(i)/count);var e:=lerpf(a,c,float(i+1)/count)
		line(n,p+Vector2(cos(s),sin(s))*r,p+Vector2(cos(e),sin(e))*r,width,color,y)

static func fence(n:Node3D,a:Vector2,c:Vector2) -> void:
	var d:=c-a;var length:=d.length();var centre:Vector2=(a+c)/2
	var mesh:=MeshInstance3D.new();var plane:=QuadMesh.new();plane.size=Vector2(length,4.2);mesh.mesh=plane
	mesh.position=Vector3(centre.x,2.2,centre.y);mesh.rotation.y=atan2(-d.y,d.x)
	# Subpixel alpha wires alias in the shadow map; solid posts/rails/walls still cast.
	mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material:=ShaderMaterial.new();material.shader=preload("res://world/visual_campus/CourtFence.gdshader")
	material.set_shader_parameter("dimensions",Vector2(length,4.2));mesh.material_override=material;n.add_child(mesh)
	var collision:=StaticBody3D.new();collision.position=mesh.position;collision.rotation=mesh.rotation;n.add_child(collision)
	var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(length,4.2,.07);shape.shape=box;collision.add_child(shape)
	for y in [.12,2.2,4.32]:W.beam(n,Vector3(a.x,y,a.y),Vector3(c.x,y,c.y),.045,.045,"406958")
	var count:=ceili(length/3)
	for i in count+1:
		var p:=a.lerp(c,float(i)/count)
		K.box(n,Vector3(p.x,2.2,p.y),Vector3(.08,4.4,.08),"365f4c",true,11)

static func hoop(n:Node3D,x:float,side:int) -> void:
	var z:float=side*16
	K.box(n,Vector3(x,.36,z),Vector3(1.05,.7,1.4),"426451",true,22)
	W.beam(n,Vector3(x,.7,z),Vector3(x,3.5,side*15),.16,.18,"e0e4d8")
	W.beam(n,Vector3(x,3.5,side*15),Vector3(x,3.45,side*12.8),.13,.14,"e0e4d8")
	W.beam(n,Vector3(x,.9,side*16.4),Vector3(x,3.45,side*12.8),.09,.10,"e0e4d8")
	W.beam(n,Vector3(x,3.5,side*15),Vector3(x,4.2,side*12.8),.075,.075,"e0e4d8")
	K.box(n,Vector3(x,1.55,side*15.6),Vector3(.6,2.1,.25),"334849",true,22)
	K.box(n,Vector3(x,3.68,side*12.8),Vector3(1.8,1.05,.065),"a9c8c0",false,19)
	for dx in [-.91,.91]:K.box(n,Vector3(x+dx,3.68,side*12.8),Vector3(.045,1.1,.07),"e0e4d8",false,22)
	for y in [3.135,4.225]:K.box(n,Vector3(x,y,side*12.8),Vector3(1.85,.045,.07),"e0e4d8",false,22)
	for dx in [-.295,.295]:K.box(n,Vector3(x+dx,3.36,side*12.75),Vector3(.04,.45,.03),"e0e4d8",false,22)
	for y in [3.15,3.58]:K.box(n,Vector3(x,y,side*12.75),Vector3(.63,.04,.03),"e0e4d8",false,22)
	arc(n,Vector2(x,side*12.45),.225,0,TAU,3.05,"be6650",.035)
	for i in 12:
		var a:float=i*TAU/12
		W.beam(n,Vector3(x+cos(a)*.225,3.04,side*12.45+sin(a)*.225),Vector3(x+cos(a+.25)*.13,2.64,side*12.45+sin(a+.25)*.13),.012,.012,"d1d7c9")

static func court(n:Node3D,x:float) -> void:
	K.box(n,Vector3(x,.139,0),Vector3(15,.022,28),"376b51",false,22)
	var centre:=PackedVector3Array()
	for i in 48:
		var a:float=i*TAU/48;var c:float=(i+1)*TAU/48
		centre.append_array(K.quad(Vector3(x,.154,0),Vector3(x+cos(a)*1.8,.154,sin(a)*1.8),Vector3(x+cos(c)*1.8,.154,sin(c)*1.8),Vector3(x,.154,0)))
	K.surface(n,centre,"82483f",22)
	for side in [-1,1]:
		K.box(n,Vector3(x,.154,side*11.1),Vector3(4.9,.012,5.8),"82483f",false,22)
		line(n,Vector2(x-7.5,side*14),Vector2(x+7.5,side*14))
		line(n,Vector2(x+side*7.5,-14),Vector2(x+side*7.5,14))
		line(n,Vector2(x-2.45,side*8.2),Vector2(x+2.45,side*8.2))
		for dx in [-2.45,2.45]:line(n,Vector2(x+dx,side*8.2),Vector2(x+dx,side*14))
		arc(n,Vector2(x,side*8.2),1.8,0,TAU)
		# Semicircle faces the centre, with short corner legs.
		arc(n,Vector2(x,side*12.425),6.75,PI if side==1 else 0,TAU if side==1 else PI)
		for dx in [-6.75,6.75]:line(n,Vector2(x+dx,side*12.425),Vector2(x+dx,side*14))
		hoop(n,x,side)
	line(n,Vector2(x-7.5,0),Vector2(x+7.5,0));arc(n,Vector2(x,0),1.8,0,TAU)

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"LowerBasketballCourtsV87",Vector3(-44,G,-656))
	K.box(n,Vector3(0,.11,0),Vector3(44,.04,38),"80473e",false,22)
	for x in [-10,10]:court(n,x)
	# Two open gates: central aisle from the Zhixin-side footpath, and parking-side gate.
	fence(n,Vector2(-22,-19),Vector2(-1.6,-19));fence(n,Vector2(1.6,-19),Vector2(22,-19))
	fence(n,Vector2(-22,-19),Vector2(-22,-1.6));fence(n,Vector2(-22,1.6),Vector2(-22,19))
	fence(n,Vector2(-22,19),Vector2(-1.6,19));fence(n,Vector2(1.6,19),Vector2(22,19))
	fence(n,Vector2(22,-19),Vector2(22,-1.6));fence(n,Vector2(22,1.6),Vector2(22,19))
	for x in [-21,21]:
		for z in [-16,16]:
			K.box(n,Vector3(x,4.75,z),Vector3(.13,9.5,.13),"50685d",true,11)
			K.box(n,Vector3(x,9.4,z),Vector3(1.5,.20,.35),"6b786d",false,11)
	for x in [-19,19]:
		for z in [-6,6]:
			K.box(n,Vector3(x,.52,z),Vector3(.55,.09,2.6),"365e4d",true,22)
			for dz in [-1.05,1.05]:K.box(n,Vector3(x,.25,z+dz),Vector3(.5,.5,.07),"344e43",false,11)
	var p:=K.holder(root,"CourtParkingAndApproachesV82")
	for r:Dictionary in builder.data.routes:
		if r.id=="lower_basketball_access":builder.ribbon(p,r.points,6,"414b4c",32,.18)
	# Parking stays beside the courts; the narrow DaoYuan/Zhixin gap is kept clear.
	K.box(p,Vector3(-82.8,G+.11,-648),Vector3(6.6,.04,47),"a99579",false,34)
	for z in range(-626,-670,-5):
		K.box(p,Vector3(-82.8,G+.17,z),Vector3(6.2,.015,.10),"dddccc",false,22)
		K.box(p,Vector3(-85.0,G+.1,z-2.4),Vector3(.24,.16,1.55),"7f8579",true,22)
	builder.ribbon(p,[[-44,G,-637],[-44,G,-631],[-18,G,-631],[-18,G,-656],[-22,G,-656]],3.2,"a8aa9b",26,.14)
	builder.ribbon(p,[[-18,G,-656],[-18,G,-676.4],[-44,G,-676.4],[-44,G,-675]],2.4,"a99579",34,.14)
	builder.ribbon(p,[[-82.8,G,-656],[-66,G,-656]],3.2,"a8aa9b",26,.14)
	# South gate is approached along the inside central aisle (there is no mid-court fence).
	builder.ribbon(p,[[-44,G,-675],[-44,G,-637]],3.0,"a8aa9b",26,.07)
	for x in [-60,-30]:K.tree(p,Vector3(x,G,-630),7.8,8200+absi(x),1.8)
	# Low painted retaining wall seen below the roadside mesh; mural artwork still untraced.
	for x in [-11.8,11.8]:K.box(n,Vector3(x,.66,-18.95),Vector3(20.4,1.25,.20),"baaa70",true,22)
	K.finish(n)
	K.finish(p)
