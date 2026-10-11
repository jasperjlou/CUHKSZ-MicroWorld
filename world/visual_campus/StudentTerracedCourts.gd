extends RefCounted
## Front-to-hill ascending courts from architect plans 1F/3F/5F and sections.
## Fixed mall edge, fitted metre scale. Ground dining layout remains schematic.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Dining := preload("res://world/visual_campus/StudentPublicSpaces.gd")

static func slab(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.15,(z0+z1)/2),Vector3(x1-x0,.30,z1-z0),"b8bbb1",true,26)

static func rail(n: Node3D,a: Vector3,c: Vector3) -> void:
	var length:=a.distance_to(c);var delta:=c-a;var h:=K.holder(n,"CourtGuard",(a+c)/2)
	h.rotation.y=atan2(delta.x,delta.z);h.rotation.x=-atan2(delta.y,Vector2(delta.x,delta.z).length())
	K.box(h,Vector3(0,1.07,0),Vector3(.075,.075,length),"46534e",true,11)
	for i in int(length/.18)+1:K.box(h,Vector3(0,.53,-length/2+i*length/maxi(1,int(length/.18))),Vector3(.025,1.04,.025),"46534e",false,11)
	K.box(h,Vector3(0,.52,0),Vector3(.10,1.04,length),"46534e",true,19)
	K.finish(h)

static func terrace(n: Node3D,y: float,z0: float,z1: float,stair_x: float,end_z: float) -> void:
	slab(n,-13,stair_x-2.6,z0,z1,y);slab(n,stair_x+2.6,13,z0,z1,y)
	slab(n,stair_x-2.6,stair_x+2.6,z0,end_z,y)
	# Guard front edge except the ascending stair mouth.
	rail(n,Vector3(-13,y,z1),Vector3(stair_x-2.6,y,z1))
	if is_equal_approx(y,4.4):
		rail(n,Vector3(stair_x+2.6,y,z1),Vector3(-3,y,z1))
		rail(n,Vector3(3,y,z1),Vector3(13,y,z1))
	else:rail(n,Vector3(stair_x+2.6,y,z1),Vector3(13,y,z1))
	for sx in [stair_x-2.6,stair_x+2.6]:rail(n,Vector3(sx,y,end_z),Vector3(sx,y,z1))

static func yellow_face(n: Node3D,z: float,low: float,high: float,omit_x: float=99) -> void:
	for i in 6:
		var x: float=-10.5+i*4.2
		if absf(x-omit_x)<3:continue
		K.box(n,Vector3(x,low+(high-low)/2,z),Vector3(1.4,high-low,.35),"c4af5f",true,21)
		K.box(n,Vector3(x+1.5,high-.52,z),Vector3(1.6,1.04,.25),"a6a89c",false,22)
		K.box(n,Vector3(x+1.5,(low+high-.9)/2,z-.13),Vector3(1.6,high-low-1.15,.10),"6c8580",true,19)
		for edge in [-.82,.82]:K.box(n,Vector3(x+1.5+edge,(low+high)/2,z+.08),Vector3(.07,high-low,.14),"58665f",false,11)
	K.box(n,Vector3(0,high-.13,z),Vector3(26,.26,.45),"bdc2b7",false,22)

static func build(b: Node3D,builder) -> void:
	var n:=K.holder(b,"StudentAscendingCourtyards")
	# Lower, middle and upper outdoor platforms, with real stair openings.
	terrace(n,4.4,12,41,-9,18)
	terrace(n,8.8,-13,12,9,-4)
	terrace(n,12.4,-40,-13,-9,-26)
	# Direct public ascent alternates sides. Thin underside avoids solid stair blocks.
	for data: Array in [[-9,0,38,4.4,18],[9,4.4,12,8.8,-4],[-9,8.8,-10,12.4,-26]]:
		var a:=Vector3(data[0],data[1],data[2]);var c:=Vector3(data[0],data[3],data[4])
		builder.stairs(n,a,c,4.8,28)
		for side in [-1,1]:rail(n,a+Vector3(side*2.48,0,0),c+Vector3(side*2.48,0,0))
	# First platform joins the retained library / teaching upper promenade without a gap.
	slab(n,-3,3,41,51,4.4)
	for x in [-3,3]:rail(n,Vector3(x,4.4,41),Vector3(x,4.4,49))
	# A lateral gallery from the library enters the +X wing, then reaches the first court.
	# Existing full side-wing slabs provide its floor; these edges define the public route.
	for side in [-1,1]:
		for y in [4.4,8.8,12.4]:
			for span: Vector2 in [Vector2(-39,-28),Vector2(-21,-16),Vector2(-1,8),Vector2(23,33)]:
				rail(n,Vector3(side*13,y,span.x),Vector3(side*13,y,span.y))
	# Double-height red sides and yellow terrace faces reproduce the sectional sequence.
	yellow_face(n,12,0,8.8,9)
	yellow_face(n,-13,4.4,12.4,-9)
	yellow_face(n,-40,8.8,16,0)
	for side in [-1,1]:
		for span: Vector2 in [Vector2(16,40),Vector2(-39,-16)]:
			var base: float=0 if span.x>0 else 8.8
			for j in int((span.y-span.x)/.8):
				var z: float=span.x+(j+.5)*.8
				if side==1 and z>32 and z<39:
					K.box(n,Vector3(side*13.2,2.1,z),Vector3(.18,4.2,.74),"9c695d",true,15)
					continue
				K.box(n,Vector3(side*13.2,base+4.1,z),Vector3(.18,8.2,.74),"9c695d",true,15)
				K.box(n,Vector3(side*13.05,base+4.1,z+.36),Vector3(.10,8.2,.05),"bd8b76",false,11)
		# Dining frontage is outside the court circulation, with genuine open door bays.
		var room:=K.holder(n,"LowerDiningFront",Vector3(side*21,0,0));room.rotation.y=-side*PI/2
		for u in [-33,-21,-9,3,15,27,39]:
			if u in [-9,27]:continue
			K.box(room,Vector3(u,2.04,0),Vector3(8.5,4.08,.10),"82978c",true,19)
			for edge in [-4.35,4.35]:K.box(room,Vector3(u+edge,2.1,.08),Vector3(.5,4.2,.25),"c6b15d",true,21)
		K.finish(room)
		for z in [-30,-12,8,26]:Dining.table(n,Vector3(side*27,0,z))
		K.box(n,Vector3(side*24,.045,0),Vector3(22,.06,95),"b5b1a4",false,26)
	# Stone court and perimeter paths, not default lawn in the building footprint.
	K.box(n,Vector3(0,.035,0),Vector3(26,.05,95),"9b9e96",false,26)
	K.box(n,Vector3(0,.042,52),Vector3(70,.06,9),"a5a79e",false,26)
	for x in [-37,37]:K.box(n,Vector3(x,.042,0),Vector3(3.6,.06,100),"a5a79e",false,26)
	K.box(n,Vector3(0,.042,-50),Vector3(76,.06,4.5),"a5a79e",false,26)
	for p: Vector3 in [Vector3(1,4.4,27),Vector3(3,8.8,0),Vector3(2,12.4,-32)]:
		Dining.table(n,p);K.planter(n,p+Vector3(4.5,0,2.5))
	K.box(n,Vector3(-3,4.55,34),Vector3(3,.3,4),"969e8b",true,26)
	K.tree(n,Vector3(-3,4.7,34),4.3,4913)
	K.label(n,"学生中心  STUDENT CENTRE",Vector3(0,4.05,50.1),.008)
	K.finish(n)
