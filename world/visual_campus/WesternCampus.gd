extends RefCounted
## Four official panoramas support these silhouettes; metric dimensions remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const H := preload("res://world/visual_campus/UniversityHallEnvelope.gd")

static func beam(b: Node3D,a: Vector3,c: Vector3,width: float,depth: float,color: String) -> void:
	var n:=K.holder(b,"Member",(a+c)/2)
	n.quaternion=Quaternion(Vector3.UP,(c-a).normalized())
	K.box(n,Vector3.ZERO,Vector3(width,a.distance_to(c),depth),color,false,11);K.finish(n)

static func stair(b: Node3D,a: Vector3,c: Vector3,width: float,count: int) -> void:
	var run: float=a.z-c.z
	for i in count:
		var top: float=lerpf(a.y,c.y,float(i+1)/count)
		K.box(b,Vector3(a.x,(a.y+top)/2,a.z-run*(i+.5)/count),Vector3(width,top-a.y,absf(run)/count+.01),"b7b8ac",false,6)
	var ramp:=K.surface(b,K.quad(a+Vector3(-width/2,0,0),a+Vector3(width/2,0,0),c+Vector3(width/2,0,0),c+Vector3(-width/2,0,0)),"b7b8ac",6,true);ramp.visible=false
	for side in [-1,1]:
		var offset:=Vector3(side*(width/2+.15),0,0)
		beam(b,a+offset+Vector3.UP*1.05,c+offset+Vector3.UP*1.05,.065,.065,"8e958d")
		for i in 5:K.box(b,a.lerp(c,i/4.0)+offset+Vector3.UP*.5,Vector3(.06,1,.06),"90988f",false,11)

static func sports(b: Node3D,_r: Dictionary) -> void:
	# Hollow perimeter replaces the previous solid glass block. Only the observed public zones are open.
	K.box(b,Vector3(0,.42,-6),Vector3(90,.84,48),"b7b8ab",true,12)
	K.box(b,Vector3(0,6.5,5),Vector3(89,11.4,.35),"b9beb4",true,15)
	# V57: this is University Sports Hall. Its flat roof must not inherit the adjacent complex.
	K.box(b,Vector3(0,16.15,-6),Vector3(91,.40,49),"b5bbb0",true,18)
	for z in [-30.4,18.4]:K.box(b,Vector3(0,16.65,z),Vector3(91,.65,.22),"c2c7bc",false,22)
	for x in [-45.4,45.4]:K.box(b,Vector3(x,16.65,-6),Vector3(.22,.65,49),"c2c7bc",false,22)
	H.build(b)
	# Monumental front recess: left dark fins, deep side walls, slender overhead blades.
	for x in [0,20]:K.box(b,Vector3(x,8.4,27),Vector3(1.4,16.8,17),"bac1b6",true,15)
	K.box(b,Vector3(10,16.5,35.4),Vector3(21.4,1.25,.8),"c1c6b9",true,15)
	for z in range(19,35,2):K.box(b,Vector3(10,15.75,z),Vector3(18.6,.46,.22),"a7b1a6",false,11)
	var sign:=K.label(b,"UNIVERSITY SPORTS HALL",Vector3(10,16.5,35.84),.008);sign.modulate=Color("3c4840")
	K.box(b,Vector3(-23,4.2,20),Vector3(44,6.8,4),"afb5aa",true,15)
	for x in range(-44,0,2):K.window(b,Vector3(x,2.55,22.08),1.72,3.2)
	for i in 68:K.box(b,Vector3(-44+i*.65,10.25,23.0),Vector3(.15,11.3,.90),"46504c",false,11)
	# Entry plinth and short stair are visible in the front panorama.
	stair(b,Vector3(10,0,37),Vector3(10,.84,34),17,5)
	K.box(b,Vector3(10,.42,26),Vector3(18,.84,16),"b7b8ab",true,6)
	S.paving(b,Vector3(10,0,40),Vector2(44,9));S.drain(b,Vector3(10,0,43),40)
	S.hedge(b,Vector3(-24,0,24.7),Vector2(34,2))
	for x in [-40,-28,-16]:K.tree(b,Vector3(x,0,26),7.0,1300+x) # V64 keeps the covered public aisle outside this tree row.
	# Front doorway: real opening, flanking glass and transom, no wall across the player path.
	C.glazing(b,Vector3(10,10.3,18),18.6,9.4)
	for span: Vector2 in [Vector2(.7,7),Vector2(13,19.3)]:C.glazing(b,Vector3((span.x+span.y)/2,3.12,18),span.y-span.x,4.56)
	for x in [7,13]:
		K.box(b,Vector3(x,3.12,18),Vector3(.13,4.56,.18),"6a7771",true,11)
		C.glazing(b,Vector3(x,3.1,16.7),2.6,4.5,PI/2)
	K.box(b,Vector3(10,5.5,18),Vector3(18.6,.3,.45),"9ca9a0",false,11)
	# Service centre and reception: pale counter, ribbed ceiling, red seating by the glass.
	K.box(b,Vector3(10,7.25,11.5),Vector3(19,.2,13),"bfc1b6",true,16)
	K.box(b,Vector3(10,4.0,5.23),Vector3(18.4,6.3,.08),"c6c5b9",false,18)
	for x in range(1,20):K.box(b,Vector3(x,7.06,11.5),Vector3(.08,.22,12.7),"909b90",false,11)
	for x in [3,10,17]:K.box(b,Vector3(x,6.99,12),Vector3(.30,.05,1.2),"fff1d0",false,17)
	var light:=OmniLight3D.new();light.position=Vector3(10,5.6,12);light.light_color=Color("f6efd7");light.light_energy=1.5;light.omni_range=18;b.add_child(light)
	K.box(b,Vector3(14,1.46,8.1),Vector3(7,1.24,1.6),"d0cbbd",true,12)
	K.box(b,Vector3(14,2.13,8.1),Vector3(7.2,.12,1.8),"e1daca",false,12)
	var service:=K.label(b,"体育馆服务中心\nSports Hall Service Center",Vector3(14,4.0,5.31),.008);service.modulate=Color("26352c")
	for x in [12,14,16]:
		K.box(b,Vector3(x,2.29,8.0),Vector3(.45,.25,.16),"50677c",false,11)
	K.box(b,Vector3(18,2.36,8.2),Vector3(.18,.42,.18),"d2d8ca",false,11)
	for z in [11,15]:
		K.box(b,Vector3(3,1.65,z),Vector3(1.35,.08,1.35),"e0ddd0",false,12)
		K.box(b,Vector3(3,1.25,z),Vector3(.16,.8,.16),"777d73",false,11)
		for x in [1.8,4.2]:
			K.box(b,Vector3(x,1.28,z),Vector3(.7,.14,.7),"9c3c53",false,11)
			K.box(b,Vector3(x,1.58,z+.3),Vector3(.7,.55,.10),"9c3c53",false,11)
			for dx in [-.25,.25]:K.box(b,Vector3(x+dx,1.03,z),Vector3(.07,.38,.5),"987949",false,4)
	for p in [Vector3(2,.84,7),Vector3(18,.84,16),Vector3(-4,0,37),Vector3(24,0,37)]:K.planter(b,p)
	# Lower side volume belongs to the original hall; no folded roof or field gallery here.
	preload("res://world/visual_campus/HallGlazedWing.gd").build(b)
	K.gallery(b,Vector3(33,0,30),23,8,4.2)
	S.paving(b,Vector3(0,0,-35),Vector2(100,10))
	# V62 rotated end gaps meet the Complex and DaoYuan terrace; retain their existing planting.

static func old_gate(b: Node3D) -> void:
	# Two freestanding granite blades, not the former invented beam spanning the road.
	# V217: blades stand on a side island; the driveway remains asphalt beside it.
	K.box(b,Vector3(-15,.06,0),Vector3(22,.12,12),"aaa69a",true,26)
	for x in [-13,-6]:
		K.box(b,Vector3(x,6.5,0),Vector3(1.05,13,1.45),"a2a39b",true,6)
		K.box(b,Vector3(x,10.8,1.1),Vector3(1.2,.92,4.3),"969b94",false,6)
		K.box(b,Vector3(x,9.7,-1.4),Vector3(1.18,.7,2.5),"939991",false,6)
		for y in [2.2,4.4,6.6,8.8,11]:K.box(b,Vector3(x,y,.735),Vector3(1.05,.025,.015),"787f76",false,11)
	K.box(b,Vector3(-25,1.65,-1.4),Vector3(15,3.3,.75),"acaea2",true,6)
	var title:=K.label(b,"香港中文大学（深圳）",Vector3(-25,2.02,-.99),.008);title.modulate=Color("414b43")
	var sub:=K.label(b,"The Chinese University of Hong Kong, Shenzhen",Vector3(-25,1.27,-.98),.0027);sub.modulate=Color("414b43")
	S.hedge(b,Vector3(-25,0,.5),Vector2(16,1.5))
	for x in [-19,-15,-5,5,13]:
		var bollard:=MeshInstance3D.new();var mesh:=CylinderMesh.new()
		mesh.top_radius=.24;mesh.bottom_radius=.26;mesh.height=.57;mesh.radial_segments=16
		bollard.mesh=mesh;bollard.material_override=K.material("a9aea3",15);bollard.position=Vector3(x,.385,5.7);b.add_child(bollard)
		var body:=StaticBody3D.new();var shape:=CollisionShape3D.new();var cylinder:=CylinderShape3D.new()
		cylinder.radius=.26;cylinder.height=.57;shape.shape=cylinder;body.add_child(shape);body.position=bollard.position;b.add_child(body)
	# Zebra crossing and a compact side booth, kept clear of the old-gate pedestrian route.
	# Cross only the entry mouth, not the stone walking area beside the booth.
	for x in range(-3,4):K.box(b,Vector3(x,.048,8.8),Vector3(.56,.012,3.6),"d6d9c9",false,22)
	K.box(b,Vector3(17,1.6,-1),Vector3(4,3.2,4),"a5b1a3",true,15)
	K.window(b,Vector3(17,1.8,1.06),3.3,1.65)
	K.box(b,Vector3(17,3.34,-1),Vector3(5,.25,5),"728273",false,18)
	for x in [-38,-30,-22,22,30]:K.tree(b,Vector3(x,0,-8),8.5,901+x)
	for x in [-35,-25,25]:S.hedge(b,Vector3(x,0,-5),Vector2(8,2.3))

static func west_waypoint(b: Node3D) -> void:
	# Official tour supplies a direction here but no verified gate facade.
	S.paving(b,Vector3.ZERO,Vector2(12,8))
	for x in [-7,7]:K.lamp(b,Vector3(x,0,0))

static func track(b: Node3D) -> void:
	preload("res://world/visual_campus/AthleticsGround.gd").build(b)
