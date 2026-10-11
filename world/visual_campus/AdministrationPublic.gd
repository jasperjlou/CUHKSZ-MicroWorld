extends RefCounted
## Ground recesses and forecourt from 116440794; rear planting from 116443793.
## Public-room depth and furnishing are inferred, not an administrative-office floor plan.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const Site := preload("res://world/visual_campus/LowerCampusLandscape.gd")

static func glazing(b: Node3D,center: Vector3,width: float,height: float,door: bool=false) -> void:
	var count:=maxi(2,int(width/1.65));var pitch:=width/count
	for i in count:
		var x: float=-width/2+(i+.5)*pitch
		if door and absf(x)<2.25:continue
		var left: float=x-pitch/2;var right: float=x+pitch/2
		if door:
			if x>0:left=maxf(left,2.25)
			else:right=minf(right,-2.25)
		var middle: float=(left+right)/2
		K.box(b,center+Vector3(middle,height/2,0),Vector3(right-left-.075,height,.09),"547670",true,19)
		for edge in [left,right]:K.box(b,center+Vector3(edge,height/2,.055),Vector3(.055,height,.15),"394d43",false,11)
		K.box(b,center+Vector3(middle,3.05,.08),Vector3(right-left,.07,.15),"435549",false,11)
	for y in [.10,height]:K.box(b,center+Vector3(0,y,.055),Vector3(width,.10,.17),"435549",false,11)
	if door:
		for side in [-1,1]:
			K.box(b,center+Vector3(side*2.25,height/2,0),Vector3(.10,height,.20),"364a3e",true,11)
			var leaf:=K.holder(b,"OpenAdministrationDoor",center+Vector3(side*2.16,0,-.7));leaf.rotation.y=side*.20
			K.box(leaf,Vector3(0,1.76,0),Vector3(.085,3.5,1.5),"77978c",false,19)
			K.box(leaf,Vector3(.06,1.1,.3),Vector3(.045,.85,.055),"9aa89b",false,11);K.finish(leaf)

static func low_flower_bed(b: Node3D,p: Vector3,seed: int) -> void:
	K.box(b,p+Vector3.UP*.27,Vector3(3.4,.54,1.4),"8b665e",true,7)
	K.box(b,p+Vector3.UP*.55,Vector3(3.1,.05,1.15),"62533d",false,4)
	V.shrub(b,p+Vector3.UP*.57,Vector3(3,.4,1.05),seed)
	var petals:=PackedVector3Array()
	for i in 45:
		var q:=p+Vector3(-1.4+float(i%15)*.2,.92+float(i%4)*.035,-.4+float(i/15)*.4)
		petals.append_array(PackedVector3Array([q,q+Vector3(.09,.07,.04),q+Vector3(.02,.02,.12),q,q+Vector3(.02,.02,.12),q+Vector3(.09,.07,.04)]))
	K.surface(b,petals,"b5869a",22)

static func ground_wing(parent: Node3D,x: float,wing_w: float,side: int) -> void:
	var n:=K.holder(parent,"RecessedAdministrationLobby",Vector3(x,0,0));var inner_w: float=wing_w-4.4
	K.box(n,Vector3(0,.066,13.7),Vector3(inner_w,.04,18.5),"a9ac9d",false,12)
	K.box(n,Vector3(0,4.04,13.7),Vector3(inner_w,.09,18.5),"434d43",false,16)
	glazing(n,Vector3(0,.04,23),inner_w,3.9,true)
	# Recessed side glazing and a back wall enclose a modest lobby, leaving the outer arcade open.
	for edge in [-1,1]:
		var return_wall:=K.holder(n,"GroundGlassReturn",Vector3(edge*inner_w/2,0,13.7));return_wall.rotation.y=PI/2
		glazing(return_wall,Vector3.ZERO,18.5,3.94);K.finish(return_wall)
	K.box(n,Vector3(0,1.97,4.45),Vector3(inner_w,3.94,.20),"8b9584",true,22)
	K.box(n,Vector3(side*inner_w*.30,.90,10.2),Vector3(4.5,1.8,1.15),"a39f8b",true,12)
	K.box(n,Vector3(side*inner_w*.30,1.84,10.2),Vector3(4.7,.12,1.3),"c1bca5",false,12)
	for xx in [-inner_w*.30,inner_w*.30]:
		K.bench(n,Vector3(xx,0,17.4),side*PI/2)
		K.box(n,Vector3(xx,3.96,13.5),Vector3(.16,.04,6),"dfddc6",false,17)
	K.box(n,Vector3(0,3.1,4.59),Vector3(6,.75,.06),"607461",false,22)
	K.label(n,"行政楼 · 公共门厅",Vector3(0,3.1,4.65),.004)
	var light:=OmniLight3D.new();light.position=Vector3(0,3.1,13.8);light.light_energy=.5;light.omni_range=12;light.light_color=Color("ede8d1");n.add_child(light)
	# The deep fascia and separate ceiling keep the entry shaded in the front panorama.
	K.box(n,Vector3(0,3.94,25),Vector3(wing_w-.8,.08,3.6),"535b51",false,22)
	K.box(n,Vector3(0,4.15,27.12),Vector3(wing_w,.30,.16),"424e43",false,11)
	for xx in [-6,0,6]:
		K.box(n,Vector3(xx,3.87,25),Vector3(.20,.08,.20),"dcdac5",false,17)
	K.finish(n)

static func forecourt(b: Node3D,w: float) -> void:
	K.box(b,Vector3(0,.052,32.5),Vector3(w+3,.045,20),"a7ab9e",false,6)
	K.box(b,Vector3(0,.051,20.5),Vector3(30,.045,13),"a7ab9e",false,6)
	for z in [26.5,37.5]:
		K.box(b,Vector3(0,.084,z),Vector3(w+3,.018,.25),"6d7b6a",false,6)
	# V91 AdminMallGround owns the continuous world-aligned meander inlay.
	for x in [-11,-5,5,11]:low_flower_bed(b,Vector3(x,0,17),absi(x)+107)
	for side in [-1,1]:
		for x in [side*23,side*37]:
			Site.hedge(b,Vector3(x,0,34.7),Vector2(6,2.8))
			if absf(x)>30:
				K.tree(b,Vector3(x,.48,34.7),8.3,absi(x)*21)
				for stake in [-1,1]:K.box(b,Vector3(x+stake*.75,1.35,34.7),Vector3(.075,2.7,.075),"617953",false,11)
				K.box(b,Vector3(x,1.7,34.7),Vector3(1.65,.075,.075),"617953",false,11)
		K.bench(b,Vector3(side*30,0,39),PI)
		Site.drain(b,Vector3(side*29,.034,28.2),18)

static func rear_garden(b: Node3D) -> void:
	# Planting and horizontal equipment screen visible behind the official backdoor viewpoint.
	for side in [-1,1]:
		var terrace_y: float=13.0 if side>0 else 12.4
		Site.hedge(b,Vector3(side*15.8,terrace_y,-44 if side>0 else -43),Vector2(6.5,1.0 if side>0 else 2.4))
		var p:=Vector3(side*17.8,terrace_y,-44 if side>0 else -42.5)
		K.tree(b,p+Vector3.UP*.5,5.2,168+side)
		for i in 13:K.box(b,Vector3(side*15.6,terrace_y+.7+i*.085,-44.6),Vector3(7.2,.045,.12),"9a9e8c",false,11)
		for x in [side*12.1,side*19.1]:K.box(b,Vector3(x,terrace_y+1.25,-44.6),Vector3(.08,1.55,.12),"828c78",false,11)
		K.box(b,Vector3(side*15.6,terrace_y+.33,-44.6),Vector3(7.3,.62,.22),"929985",false,6)
	# Warm threshold strip and a fine perimeter band echo the photographed terrace paving.
	for side in [-1,1]:K.box(b,Vector3(side*12.6,12.414,-32),Vector3(.16,.02,15),"867967",false,6)

static func build(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"AdministrationPublicDetail")
	var w: float=r.width;var wing_w:=w*.27;var wing_x: float=w/2-wing_w/2
	for side in [-1,1]:ground_wing(n,side*wing_x,wing_w,side)
	forecourt(n,w);rear_garden(n);K.finish(n)
