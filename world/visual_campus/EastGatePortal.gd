extends RefCounted
## V66: same bridge in official origin and square scenes. The vehicle camera is
## offset from the ceremonial axis; do not equate panorama centre with world origin.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")

static func fitted_height(x: float,z: float,base: float) -> float:
	if z>21.5 and z<50 and absf(x)<24:
		var weight: float=(1.0-smoothstep(20,24,absf(x)))*(1.0-smoothstep(45,50,z))
		base=lerpf(base,-.36*clampf((z-21.5)/1.5,0,1),weight)
	# Long side grade is independent of the ceremonial broad stair.
	if x>23.5 and x<35 and z< -20 and z> -60:
		var weight: float=smoothstep(23.5,25,x)*(1.0-smoothstep(33.5,35,x))
		base=lerpf(base,2.24*clampf((-20-z)/35,0,1),weight)
	return base

static func field(b: Node3D,builder,x0: float,x1: float,z0: float,z1: float,color: String,kind: int=31) -> void:
	var mesh:=PackedVector3Array();var nx:=ceili(x1-x0);var nz:=ceili(z1-z0)
	for i in nx:
		for j in nz:
			var a:=Vector3(lerpf(x0,x1,float(i)/nx),0,lerpf(z0,z1,float(j)/nz))
			var c:=Vector3(lerpf(x0,x1,float(i+1)/nx),0,lerpf(z0,z1,float(j+1)/nz))
			var points: Array[Vector3]=[a,Vector3(c.x,0,a.z),c,Vector3(a.x,0,c.z)]
			for k in 4:points[k].y=builder.height(points[k].x,points[k].z)+.112
			mesh.append_array(K.quad(points[0],points[1],points[2],points[3]))
	K.surface(b,mesh,color,kind)

static func bridge(b: Node3D) -> void:
	var z:=-38.0
	K.box(b,Vector3(0,10.7,z),Vector3(45,.55,6.2),"a8afa8",true,22)
	K.box(b,Vector3(0,14.3,z),Vector3(45,.45,6.2),"949d98",true,22)
	for face in [-1,1]:
		K.box(b,Vector3(0,12.6,z+face*3.2),Vector3(45,3.3,.12),"89905b",false,5)
		for x in range(-22,23):K.box(b,Vector3(x,12.6,z+face*3.28),Vector3(.075,3.5,.14),"596555",false,22)
		for i in 21:K.box(b,Vector3(-22+i*2.2,12.6,z+face*3.4),Vector3(.13,3.15,1.08),"9fa79f",false,13,face*.50)
	for i in 125:K.box(b,Vector3(-21.7+i*.35,10.36,z),Vector3(.07,.12,6.0),"c2c7bb",false,13)
	for x in range(-20,21,5):K.box(b,Vector3(x,10.28,z),Vector3(.25,.48,6.3),"a0aaa1",false,22)
	# A single broad rounded pier is visible on the square's right side.
	var n:=MeshInstance3D.new();var cylinder:=CylinderMesh.new();cylinder.top_radius=1.15;cylinder.bottom_radius=1.15;cylinder.height=10.45;cylinder.radial_segments=24;n.mesh=cylinder;n.material_override=K.material("b5baaf",22);n.position=Vector3(19.5,5.225,z);b.add_child(n)
	var body:=StaticBody3D.new();b.add_child(body);body.position=n.position
	var c:=CollisionShape3D.new();var shape:=CylinderShape3D.new();shape.radius=1.15;shape.height=10.45;c.shape=shape;body.add_child(c)
	# Recent photographer image has purple freestanding lettering over the link.
	var label:=K.label(b,"The Chinese University of Hong Kong, Shenzhen",Vector3(0,14.95,z+3.25),.012)
	label.modulate=Color("634374")

static func ceremonial_ground(b: Node3D,builder) -> void:
	field(b,builder,-20,20,-5,21.5,"8b9089")
	field(b,builder,-20,20,23,42,"969b94")
	P.stair(b,Vector3(0,-.36,23),Vector3(0,0,21.5),34)
	# Small edges beside the three shallow arrival treads; side slope remains clear.
	for side in [-1,1]:
		field(b,builder,side*18-1,side*18+1,20,25,"a8ada2")
		K.box(b,Vector3(side*18.9,.125,8.1),Vector3(.35,.018,25.9),"b3b6ad",false,26)
	# Four modern stone huabiao, not three flagpoles. Fitted cross arms and split caps.
	for x in [-14.0,-6.0,6.0,14.0]:
		K.box(b,Vector3(x,5.1,0),Vector3(.82,10.2,.68),"aeb4ac",true,15)
		K.box(b,Vector3(x,8.6,0),Vector3(2.5,.70,.80),"c0c6bc",false,22)
		K.box(b,Vector3(x+.22,10.35,0),Vector3(.30,.30,.68),"aeb4ac",false,22)
	# School name stone and low rectangular planted island leave paths on both sides.
	K.box(b,Vector3(0,.22,7),Vector3(18,.23,4.2),"566938",true,3)
	for side in [-1,1]:
		K.box(b,Vector3(0,.43,7+side*2.0),Vector3(18,.35,.4),"587a31",false,3)
		K.box(b,Vector3(side*8.8,.43,7),Vector3(.4,.35,3.7),"587a31",false,3)
	K.box(b,Vector3(0,.85,7.55),Vector3(12.2,1.05,.75),"a0a493",true,22)
	var label:=K.label(b,"香港中文大學（深圳）",Vector3(0,.92,7.94),.015);label.modulate=Color("655e42")
	# Retractable fence remains opened at the two pedestrian approaches.
	for side in [-1,1]:
		for i in 7:K.box(b,Vector3(side*(16+i*.34),.68,13),Vector3(.035,1.15,.035),"69746b",false,22)
	# Cross street behind the huabiao; no longitudinal asphalt on the stone axis.
	field(b,builder,-18,29,-13,-5,"414b4c",2)
	for x in [-11.0,11.0]:
		for i in 8:K.box(b,Vector3(x,.128,-12.5+i),Vector3(3.5,.015,.45),"cbd0c0",false,22)
	for z in [-13.2,-4.8]:K.box(b,Vector3(0,.124,z),Vector3(36,.018,.22),"b5bbae",false,26)

static func right_tower(b: Node3D,r: Dictionary) -> void:
	# Retained anchor; corrected six paired-window storeys above the tall undercroft.
	var levels: Array=r.floor_levels
	for y: float in levels.slice(1):
		# The rear third of the inward facade has a three-storey recessed loggia.
		if y>18.0 and y<29.1:
			K.box(b,Vector3(7.5,y,0),Vector3(30,.28,24),"bfc2b6",true,22)
			K.box(b,Vector3(-15,y,-8),Vector3(15,.28,8),"bfc2b6",true,22)
		else:K.box(b,Vector3(0,y,0),Vector3(45,.28,24),"bfc2b6",true,22)
	# Deep warm undercroft wall and only four corner piers; road stays open along Z.
	K.box(b,Vector3(0,5.1,-11.8),Vector3(45,10.2,.40),"98684d",true,20)
	for x in [-21.7,21.7]:
		for z in [-11.1,11.1]:K.box(b,Vector3(x,5.1,z),Vector3(1.6,10.2,1.6),"bbbcad",true,15)
	K.box(b,Vector3(0,10.02,0),Vector3(41.8,.10,22),"9b7255",false,20)
	for side in [-1,1]:
		for f in range(1,levels.size()-1):
			var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
			for i in 12:
				var x: float=-22.5+(i+.5)*3.75
				if side>0 and x< -7.5 and low>=17.7 and high<=29.3:continue
				K.box(b,Vector3(x,low+h/2,side*12),Vector3(3.75,h,.30),"b8b9aa",true,22)
				for dx in [-.70,.70]:K.window(b,Vector3(x+dx,low+h/2,side*12.18),1.02,h-.75,PI if side<0 else 0.0)
				for dx in [-1.875,0.0]:K.box(b,Vector3(x+dx,low+h/2,side*12.36),Vector3(.25,h,.55),"c6c8bb",false,22)
				K.box(b,Vector3(x,low+.14,side*12.36),Vector3(3.75,.28,.55),"c6c8bb",false,22)
	# Recess returns and back wall: the opening has real depth rather than painted brown glass.
	K.box(b,Vector3(-15,23.5,-4),Vector3(15,11.4,.30),"956445",true,20)
	K.box(b,Vector3(-7.6,23.5,4),Vector3(.25,11.4,16),"9a6e4e",true,20)
	K.box(b,Vector3(-15,29.2,4),Vector3(15,.30,16),"ac8864",true,20)
	K.box(b,Vector3(-22.28,23.5,4),Vector3(.08,11.4,16),"9a6e4e",false,20)
	P.rail(b,Vector3(-21.9,17.98,12.1),Vector3(-7.9,17.98,12.1))
	# Street end is primarily stone with a narrow glass reveal, not another repeated facade.
	for end in [-1,1]:
		K.box(b,Vector3(end*22.5,21.6,0),Vector3(.30,22.8,24),"bdc0b3",true,15)
		for z in [-10.8,10.8]:K.box(b,Vector3(end*22.7,22,z),Vector3(.10,19.4,.62),"425955",false,5)
	K.box(b,Vector3(0,33.35,0),Vector3(45,.7,24),"c3c6b9",false,22)
	# End identity/crest and neighbouring low wings await official name registration.
