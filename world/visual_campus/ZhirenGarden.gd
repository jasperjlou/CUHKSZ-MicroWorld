extends RefCounted
## V79: named official Zhiren garden panorama 116846254 / resource 70358014.
## Timber, lawn, low rocks and folded green parasols are observed; dimensions are fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const A:=preload("res://world/visual_campus/AdministrationGarden.gd")
const G:=4.64

static func seating(root:Node3D,p:Vector3) -> void:
	var n:=K.holder(root,"GreenGardenSeating",p)
	for z in [-.88,.88]:
		for j in 3:K.box(n,Vector3(0,.48,z+(j-1)*.12),Vector3(2.1,.075,.10),"345b49",true,22)
		for x in [-.72,.72]:K.box(n,Vector3(x,.26,z),Vector3(.08,.45,.33),"344b41",true,22)
	for j in 6:K.box(n,Vector3(0,.79,(j-2.5)*.12),Vector3(2.15,.07,.10),"3e6854",true,22)
	for x in [-.7,.7]:K.box(n,Vector3(x,.43,0),Vector3(.10,.73,.10),"46564a",true,22)
	A.cylinder(n,Vector3(0,.1,0),.36,.12,"adaf9f")
	A.cylinder(n,Vector3(0,1.6,0),.032,3.2,"b2b3a1")
	# Folded, vertically tapered fabric rather than an invented open canopy.
	var cloth:=CylinderMesh.new();cloth.top_radius=.07;cloth.bottom_radius=.23;cloth.height=1.85;cloth.radial_segments=10
	var m:=MeshInstance3D.new();m.mesh=cloth;m.position=Vector3(0,2.28,0);m.material_override=K.material("406c59",22);n.add_child(m)
	for j in 10:
		var angle:float=j*TAU/10
		A.bar(n,Vector3(cos(angle)*.235,1.36,sin(angle)*.235),Vector3(cos(angle)*.073,3.20,sin(angle)*.073),.013,.013,"668070")
	K.finish(n)

static func build(root:Node3D) -> void:
	var n:=K.holder(root,"ZhirenOuterGardenV79")
	# Keep the flower-box/car apron and both photographed colonnade exits unobstructed.
	K.box(n,Vector3(76,G+.105,-751),Vector3(62,.045,4),"a98974",false,35)
	K.box(n,Vector3(86,G+.105,-759.5),Vector3(38,.045,13),"a98974",false,35)
	K.box(n,Vector3(56,G+.115,-759.5),Vector3(20,.055,13),"799260",false,3)
	for z in [-753.05,-766.1]:K.box(n,Vector3(56,G+.14,z),Vector3(20,.07,.15),"939a81",false,26)
	# Loose staggered stone slabs continue into lawn, not another full paved rectangle.
	for j in 7:
		K.box(n,Vector3(61.5+sin(j*.95)*.55,G+.15,-754.3-j*1.55),Vector3(1.15,.055,.78),"b1b3a0",false,26,.1*sin(j))
	for row:Array in [[50.5,-756.0,1.3,.55,.82],[55.0,-762.4,1.7,.75,1.0],[49.0,-764.0,.85,.40,.7]]:
		A.rock(n,Vector3(row[0],G+row[3]*.62,row[1]),Vector3(row[2],row[3],row[4]),int(row[0]))
	# Dense canopy is behind the occupied deck; never planted through a walking line.
	for p:Vector2 in [Vector2(49,-760),Vector2(69,-764.7),Vector2(85,-765.2),Vector2(103,-765)]:
		K.tree(n,Vector3(p.x,G+.1,p.y),8.4,7900+int(p.x),1.15)
	for x in range(48,106,3):V.shrub(n,Vector3(x,G+.12,-766.0),Vector3(2.8,.70,1.3),7900+x)
	for p:Vector2 in [Vector2(48,-755),Vector2(53,-765),Vector2(58,-755.5)]:
		V.shrub(n,Vector3(p.x,G+.14,p.y),Vector3(2.3,1.0,1.9),int(p.x)*79)
	seating(n,Vector3(77,G+.13,-760));seating(n,Vector3(93,G+.13,-760))
	# Slatted noticeboard seen at the planted edge; no invented readable campus notice.
	for x in [65.8,68.2]:K.box(n,Vector3(x,G+1.15,-764),Vector3(.10,2.1,.10),"d0d2c4",true,22)
	for j in 7:K.box(n,Vector3(67,G+.65+j*.16,-764),Vector3(2.4,.11,.12),"8f8c76",false,4)
	K.box(n,Vector3(67,G+1.93,-764),Vector3(2.6,.20,.14),"c1c9be",false,22)
	for x in [48,64,85,104]:
		K.box(n,Vector3(x,G+.43,-753),Vector3(.14,.64,.18),"394b40",true,22)
		K.box(n,Vector3(x,G+.70,-752.9),Vector3(.10,.08,.02),"d4d8bd",false,17)
	# The side/rear path wraps the existing LeTian shell; it never cuts through its rear wall.
	K.box(n,Vector3(116.5,G+.098,-751),Vector3(23,.032,3.2),"a6a795",false,26)
	K.box(n,Vector3(128,G+.098,-715.5),Vector3(3.2,.032,71),"a6a795",false,26)
	K.box(n,Vector3(112.5,G+.098,-680),Vector3(34,.032,3.2),"a6a795",false,26)
	K.box(n,Vector3(97,G+.098,-696.5),Vector3(3.2,.032,33),"a6a795",false,26)
	for z in range(-743,-683,8):
		V.shrub(n,Vector3(131.1,G+.1,z),Vector3(2,.6,2.8),7900-z)
	K.box(n,Vector3(130,G+.12,-715.5),Vector3(.18,.04,71),"59655b",false,22)
	K.finish(n)
