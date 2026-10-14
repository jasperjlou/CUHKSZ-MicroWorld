extends RefCounted
## V223:029 ground envelope and official1F panoramas86404084/85.
## Furniture/service positions are fitted; capture date and current operator unknown.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const C=preload("res://world/visual_campus/StudentFrontCore.gd")
const E=preload("res://world/visual_campus/StudentLowerEntrances.gd")

static func front(n:Node3D)->void:
	# First-plan arcade is at u218. Upper first-court wall stays at u425.
	# V233 the1F front stair crosses242..296; the old459..562 opening was a mislevelled3F flight.
	var bays:Array=[[304,333,false],[340,362,true],[371,387,true],[425,451,true],[470,500,false],[510,545,false],[570,597,false]]
	for band in [[300.,603.]]:
		var cursor:float=band[0]
		for bay in bays:
			var a:float=bay[0];var b:float=bay[1]
			if a<band[0] or b>band[1]:continue
			C.rect(n,216,cursor,220,a,.075,4.12,"c4af5f",true,52)
			C.rect(n,216,a,220,b,3.35,4.12,"706455",true,22)
			if bay[2]:
				E.door(n,P.point(218,(a+b)/2,.075),(b-a)/P.PIXELS_PER_METRE-.2,2.85)
				C.rect(n,217.4,a,218.6,b,3.04,3.35,"859c96",true,19)
			else:
				C.rect(n,217.4,a,218.6,b,.18,3.35,"859c96",true,19)
				for v in [a,b,(a+b)/2]:C.rect(n,216.8,v-.4,219.2,v+.4,.18,3.35,"505b59",false,11)
				C.rect(n,216.8,a,219.2,b,.90,.96,"505b59",false,11)
			cursor=b
		if cursor<band[1]:C.rect(n,216,cursor,220,band[1],.075,4.12,"c4af5f",true,52)

static func table(n:Node3D,u:float,v:float,color:String)->void:
	var h:=K.holder(n,"CanteenTable",P.point(u,v,.09))
	K.box(h,Vector3(0,.77,0),Vector3(2.35,.07,.82),"d9dcd1",true,22)
	for x in [-1.02,1.02]:
		for z in [-.30,.30]:K.box(h,Vector3(x,.37,z),Vector3(.055,.74,.055),"444a46",false,11)
	for x in [-.78,0.,.78]:
		for sign in [-1,1]:
			var z:float=sign*.70
			K.box(h,Vector3(x,.44,z),Vector3(.42,.055,.42),color,false,22)
			K.box(h,Vector3(x,.70,z+sign*.19),Vector3(.42,.44,.055),color,false,22)
			for dx in [-.16,.16]:
				for dz in [-.16,.16]:K.box(h,Vector3(x+dx,.21,z+dz),Vector3(.033,.42,.033),color,false,11)
	K.finish(h)

static func service(n:Node3D,v0:float,v1:float)->void:
	# Fitted to the historic service-side boundary; not a measured shop lease plan.
	C.rect(n,708,v0,711,v1,.075,4.12,"d0d6c7",true)
	for v in range(int(v0)+21,int(v1)-10,44):
		C.rect(n,684,v-19,708,v+19,.09,1.04,"b1cec0",true)
		C.rect(n,682,v-20,709,v+20,1.04,1.11,"d7d9ce",true)
		C.rect(n,688,v-19,689,v+19,1.11,2.29,"8da7a0",true,19)
		for end in [v-19,v+19]:C.rect(n,687,end-.35,690,end+.35,1.1,2.4,"b9b8a2",false,11)
		C.rect(n,687,v-20,710,v+20,2.4,2.92,"899d85",true)
		C.rect(n,686,v-7,687,v+7,2.52,2.80,"444f4b",false,11)
		C.rect(n,686.5,v-18,687,v+18,.89,.92,"e5e5d3",false,17)

static func ceiling_islands(n:Node3D)->void:
	# Irregular-sized hexagonal suspended panels are visible in both official1F views.
	# Distribution/height is a visual fit inside the registered structural grid.
	C.rect(n,438,253,598,593,3.76,3.80,"444b47",false)
	for i in range(4):
		for j in range(10):
			var u:float=458+i*37;var v:float=270+j*32+(i%2)*10
			if v>582:continue
			var mesh:=CylinderMesh.new();mesh.radial_segments=6;mesh.height=.065
			mesh.top_radius=.91 if (i+j)%3==0 else .72;mesh.bottom_radius=mesh.top_radius
			var node:=MeshInstance3D.new();node.mesh=mesh;node.position=P.point(u,v,3.54)
			node.material_override=K.material("e0e5d9" if (i+j)%4==0 else "bdc9c1",17 if (i+j)%4==0 else 22)
			n.add_child(node)
			K.box(n,P.point(u,v,3.65),Vector3(.018,.23,.018),"636c64",false,11)
	# Local unshadowed fill represents indoor fixtures; no claim of calibrated illuminance.
	for q in [[395,310],[555,310],[395,490],[555,490]]:
		var light:=OmniLight3D.new();light.position=P.point(q[0],q[1],3.35)
		light.light_color=Color("f5f0db");light.light_energy=.75;light.omni_range=12.
		light.shadow_enabled=false;light.distance_fade_enabled=true;light.distance_fade_begin=55;light.distance_fade_length=15
		n.add_child(light)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentCanteenGroundV223")
	front(n)
	# Finish sheets use existing collision slabs; no extra walkable floating platform.
	for r in [[310,85,704,242],[220,242,704,453],[317,453,704,603],[505,603,704,687]]:
		C.rect(n,r[0],r[1],r[2],r[3],.076,.09,"afb1a4",false,68)
	# Mint panels wrap existing support boxes without changing their footprint.
	for u in [426,508,610]:
		for v in [154,235,338,460,563]:
			C.rect(n,u-5.16,v-5.16,u+5.16,v+5.16,.20,3.87,"b1cbbc",false)
			for edge in [-5.2,5.2]:C.rect(n,u+edge-.12,v-5.2,u+edge+.12,v+5.2,.20,3.87,"aa986a",false,11)
			C.rect(n,u-5.25,v-5.25,u+5.25,v+5.25,.19,.23,"aa986a",false,11)
	service(n,251,423)
	service(n,486,593)
	for u in [350,470,565]:
		for v in [275,315,395,435,550]:
			if u==350 and v==550:continue
			table(n,u,v,"baae37" if u==350 else ("883f42" if u==470 else "416a5c"))
	# White plaster and recessed linear light strips, observed in the1F panorama.
	# Leave current fitted first stair and the front internal stair clear.
	for r in [[315,88,700,240],[325,242,700,300],[222,300,700,453],[320,453,700,599]]:
		C.rect(n,r[0],r[1],r[2],r[3],3.84,3.91,"d6d8cb",false)
	for u in [388,650]:
		C.rect(n,u-.28,250,u+.28,587,3.825,3.84,"e2e6d9",false,17)
	ceiling_islands(n)
	n.set_meta("source","official1F86404084/85 and historic029; date unknown; layout fitted; stair mouth pending")
	K.finish(n)
