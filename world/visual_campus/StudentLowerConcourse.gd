extends RefCounted
## Gift-shop entrance panorama 25308214 + ITSO location; metric placement remains fitted.
## Independent lower service level beneath the D / Student Centre mall, not library G.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/TeachingPublicSpaces.gd")
const F:=preload("res://world/visual_campus/ZhangPhotoFront.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const LOW:=-1.76

static func cutout(x:float,z:float) -> bool:
	return (x>11 and x<25 and z>-438 and z<-415) or (x>-20 and x<-14 and z>-467 and z<-451) or (x>25 and x<40 and z>-493 and z<-451) or (x>25 and x<50 and z>-504 and z<-493)

static func terrain_breaks() -> Dictionary:
	return {"x":[-26.0,-20.0,-14.0,11.0,25.0,34.0,40.0,50.0],"z":[-504.0,-493.0,-467.0,-451.0,-438.0,-415.0,-407.0]}

static func lane_height(z:float) -> float:
	return lerpf(LOW,G,clampf((-z-467)/26,0,1))

static func open_lane(b:Node3D) -> void:
	# Entrance 25308214 and reverse Shaw road 70040609 show an open paved continuation.
	# Rise/run and registration are fitted; this does not assert a surveyed road gradient.
	for i in 42:
		var z0:float=-451-i;var z1:float=z0-1
		var y0:=lane_height(z0);var y1:=lane_height(z1)
		K.surface(b,K.quad(Vector3(25,y0,z0),Vector3(34,y0,z0),Vector3(34,y1,z1),Vector3(25,y1,z1)),"8b8982" if i<16 else "746c69",49 if i<16 else 33,true)
		K.surface(b,K.quad(Vector3(34,y0,z0),Vector3(40,G,z0),Vector3(40,G,z1),Vector3(34,y1,z1)),"758857",3,true)
		var bottom:=minf(y0,y1)-.10;var h:=G-bottom
		if i>=16:
			K.box(b,Vector3(24.90,(G+bottom)/2,(z0+z1)/2),Vector3(.20,h,1.01),"656e69",true,7)
		K.box(b,Vector3(24.90,G+.045,(z0+z1)/2),Vector3(.36,.09,1.01),"8a9186",false,26)
		K.surface(b,K.quad(Vector3(33.55,y0+.008,z0),Vector3(33.75,y0+.008,z0),Vector3(33.75,y1+.008,z1),Vector3(33.55,y1+.008,z1)),"505a56",11)
	# The final broad stone apron meets the existing Shaw paver route at its actual fitted level.
	slab(b,25,50,-504,-493,G,33,"746c69")
	F.rail(b,Vector3(24.75,G,-472),42,PI/2)
	# Discrete low planting stays on the upper lip instead of floating inside the lower route.
	for z in [-455,-465,-475,-485]:
		V.shrub(b,Vector3(39,G+.04,z),Vector3(1.35,.45,2.2),1270+absi(z))
		K.box(b,Vector3(39.7,G+.40,z+3),Vector3(.15,.80,.15),"666e63",false,11)
		K.box(b,Vector3(39.7,G+.70,z+3),Vector3(.17,.16,.17),"d6ddc5",false,17)
	service_lane_front(b)

static func service_lane_front(b:Node3D) -> void:
	# Entrance cube 25308214/r: grey brick above a slim dark canopy, recessed bays and square piers.
	# Four fitted bays on the flat lane only; do not stretch full-height windows up the guessed slope.
	var n:=K.holder(b,"LowerLaneRecessedFrontV128")
	K.box(n,Vector3(24.86,LOW+3.46,-459),Vector3(.28,1.08,16),"8a8e89",true,7)
	K.box(n,Vector3(24.05,LOW+2.91,-459),Vector3(1.95,.14,16),"bac0ba",true,22)
	# Thin overhang and folded metal fascia; lower recess remains physically walkable.
	K.box(n,Vector3(25.07,LOW+2.80,-459),Vector3(2.26,.12,16.24),"3f4946",true,11)
	K.box(n,Vector3(26.18,LOW+2.78,-459),Vector3(.055,.19,16.24),"3b4542",false,11)
	for z in [-451,-455,-459,-463,-467]:
		K.box(n,Vector3(25.02,LOW+1.35,z),Vector3(.25,2.70,.26),"404b46",true,11)
		K.box(n,Vector3(25.02,LOW+.07,z),Vector3(.48,.14,.49),"797f74",true,26)
		K.box(n,Vector3(24.66,LOW+2.66,z),Vector3(2.9,.13,.15),"4e5750",false,11)
	# Closed service envelope: no unsupported shop identities or invented occupiable rooms.
	for z in [-451,-467]:
		K.box(n,Vector3(23.94,LOW+1.42,z),Vector3(2.2,2.84,.18),"a7ada5",true,22)
	for i in 4:
		var z:float=-453-i*4
		K.box(n,Vector3(23.05,LOW+1.42,z),Vector3(.16,2.84,3.88),"8a918a",true,22)
		K.box(n,Vector3(23.78,LOW+.08,z),Vector3(.20,.16,3.74),"8f9488",true,26)
		if i==0:
			# Pale utility panel and visible louvre are observed; exact bay allocation is fitted.
			K.box(n,Vector3(23.74,LOW+1.40,z),Vector3(.16,2.80,3.74),"cbd0c7",true,22)
			K.box(n,Vector3(23.85,LOW+1.07,z+.55),Vector3(.065,2.10,1.20),"d8dcd3",true,22)
			for dz in [-.08,1.18]:K.box(n,Vector3(23.90,LOW+1.10,z+dz),Vector3(.08,2.2,.042),"737e76",false,11)
			K.box(n,Vector3(23.90,LOW+2.19,z+.55),Vector3(.08,.042,1.30),"737e76",false,11)
			K.box(n,Vector3(23.97,LOW+1.03,z+.13),Vector3(.08,.16,.055),"65716a",false,11)
			K.box(n,Vector3(23.86,LOW+2.47,z),Vector3(.045,.42,2.9),"394440",false,11)
			for j in 9:K.box(n,Vector3(23.90,LOW+2.29+j*.045,z),Vector3(.055,.016,2.88),"7a827a",false,11)
		else:
			K.box(n,Vector3(23.76,LOW+1.43,z),Vector3(.075,2.56,3.74),"8c9b96",true,48)
			for dz in [-1.86,0,1.86]:K.box(n,Vector3(23.83,LOW+1.44,z+dz),Vector3(.12,2.62,.055),"4c5851",false,11)
			for y in [.17,2.37,2.75]:K.box(n,Vector3(23.83,LOW+y,z),Vector3(.12,.055,3.78),"4c5851",false,11)
			K.box(n,Vector3(23.82,LOW+.89,z),Vector3(.018,.22,3.70),"a3afa5",false,19)
		K.box(n,Vector3(25.24,LOW+2.72,z),Vector3(.28,.035,.62),"c9cfc0",false,17)
	# Narrow drainage at the back of the covered recess, not a raised trip edge.
	K.box(n,Vector3(23.96,LOW+.009,-459),Vector3(.12,.014,15.8),"454f47",false,11)
	for i in 63:K.box(n,Vector3(23.96,LOW+.018,-451.15-i*.25),Vector3(.105,.008,.024),"939a90",false,11)
	K.finish(n)

static func slab(b:Node3D,x0:float,x1:float,z0:float,z1:float,top:float,kind:int=49,color:String="929798") -> void:
	K.box(b,Vector3((x0+x1)/2,top-.12,(z0+z1)/2),Vector3(x1-x0,.24,z1-z0),color,true,kind)

static func beam_grid(b:Node3D,x0:float,x1:float,z0:float,z1:float) -> void:
	for x in range(int(x0),int(x1)+1,6):
		K.box(b,Vector3(x,G-.43,(z0+z1)/2),Vector3(.28,.40,z1-z0),"c8cdca",false,22)
	for z in range(int(z0),int(z1)+1,6):
		K.box(b,Vector3((x0+x1)/2,G-.43,z),Vector3(x1-x0,.40,.28),"c8cdca",false,22)
		for x in range(int(x0)+3,int(x1),6):
			K.box(b,Vector3(x,G-.263,z+2.8),Vector3(.24,.045,.24),"eeeee2",false,17)

static func north_connection(b:Node3D) -> void:
	# Entrance left cube shows continued lower circulation beyond the card frontage.
	# Link to the retained north court beneath the upper mall, preserving its ground datum.
	# Alignment/27m length are fitted; no additional unsupported daylight hole is cut.
	var n:=K.holder(b,"LowerServiceNorthConnectionV129")
	slab(n,22,34,-407,-380,LOW,49,"929798")
	slab(n,22,34,-407,-380,G,22,"c7cdc9")
	for x in [21.9,34.1]:
		K.box(n,Vector3(x,.12,-393.5),Vector3(.20,3.76,27),"c1c8c2",true,22)
		K.box(n,Vector3(x+(.12 if x<25 else -.12),LOW+.13,-393.5),Vector3(.035,.26,27),"8e9890",false,26)
	beam_grid(n,22,34,-407,-380)
	for z in [-402,-394,-386]:
		for x in [22.35,33.65]:K.box(n,Vector3(x,.08,z),Vector3(.48,3.68,.48),"cad0c8",true,22)
		var light:=OmniLight3D.new();light.position=Vector3(28,1.1,z);light.omni_range=10;light.light_energy=.60;light.light_color=Color("e5ebe2");n.add_child(light)
	for x in [22.7,33.3]:
		K.box(n,Vector3(x,LOW+.012,-393.5),Vector3(.16,.018,26.8),"515e56",false,11)
		for i in 88:K.box(n,Vector3(x,LOW+.025,-406.85+i*.30),Vector3(.14,.012,.028),"97a096",false,11)
	K.finish(n)

static func facade(b:Node3D,z:float,width:float,gift:bool) -> void:
	var n:=K.holder(b,"GiftShopFront" if gift else "CampusCardFront",Vector3(-21,LOW,z));n.rotation.y=PI/2
	# A real central doorway, glazed side lights and transom. The room beyond is shallow/public only.
	for side in [-1,1]:
		var w:float=(width-2.4)/2
		K.box(n,Vector3(side*(1.2+w/2),1.36,0),Vector3(w,2.72,.09),"577171",true,19)
		for i in 3:
			var x:float=side*(1.2+i*w/2)
			K.box(n,Vector3(x,1.44,.07),Vector3(.07,2.88,.14),"485453",false,11)
		K.box(n,Vector3(side*(1.2+w/2),.77,.06),Vector3(w,.07,.12),"485453",false,11)
		var door:=K.holder(n,"OpenEntryLeaf",Vector3(side*1.22,0,-.55));door.rotation.y=side*PI*.40
		K.box(door,Vector3(0,1.36,0),Vector3(1.1,2.72,.075),"647b78",true,19)
		K.box(door,Vector3(side*.40,1.2,.08),Vector3(.035,.65,.045),"a1aaa2",false,11);K.finish(door)
	K.box(n,Vector3(0,2.91,0),Vector3(width,.39,.09),"6b8382",true,19)
	for y in [2.71,3.13]:K.box(n,Vector3(0,y,.06),Vector3(width,.07,.14),"485453",false,11)
	K.box(n,Vector3(0,3.43,-.02),Vector3(width,.59,.18),"d5c785" if gift else "dddeda",true,22)
	if gift:
		for i in 14:K.box(n,Vector3(0,3.16+i*.042,.105),Vector3(width,.022,.055),"cfbd75",false,11)
		for side in [-1,1]:
			K.box(n,Vector3(side*(width/2+.30),1.87,-.035),Vector3(.60,3.74,.20),"c6bc95",true,22)
			for i in 84:K.box(n,Vector3(side*(width/2+.30),.05+i*.044,.095),Vector3(.59,.024,.065),"d8c782",false,11)
	else:K.box(n,Vector3(0,3.15,.12),Vector3(width,.10,.045),"82345d",false,11)
	var title:=K.label(n,"纪念品商店  UNIVERSITY GIFT SHOP" if gift else "校园卡服务中心  Campus Card Services",Vector3(0,3.27,.17),.0034);title.modulate=Color("303a36")
	var depth:float=4.7 if gift else 9.7
	K.box(n,Vector3(0,1.8,-depth),Vector3(width if gift else width+.86,3.6,.20),"d6d3c5",true,22)
	for side in [-1,1]:K.box(n,Vector3(side*(width/2+.34),1.8,-depth/2),Vector3(.18,3.6,depth+.1),"c8ccc4",true,22)
	if gift:
		# The visible pale display table; private stock rooms are not invented.
		K.box(n,Vector3(0,.92,-3.6),Vector3(2,.12,.75),"c8b089",true,43)
		for x in [-.8,.8]:K.box(n,Vector3(x,.43,-3.6),Vector3(.09,.86,.60),"ab9471",false,43)
		for x in [-4.2,-2.5,2.5,4.2]:
			K.box(n,Vector3(x,.20,.55),Vector3(.32,.40,.32),"e1e3da",true,22)
			V.shrub(n,Vector3(x,.51,.55),Vector3(.52,.58,.49),1260+int(x*10))
	else:preload("res://world/visual_campus/CampusCardBankInterior.gd").build(n)
	K.finish(n)

static func build(root:Node3D) -> void:
	var b:=K.holder(root,"StudentLowerServiceConcourseV126")
	slab(b,-26,34,-467,-407,LOW)
	# Existing lawn and mall stay on the structural roof; only evidenced down-stair/lightwell topology is open.
	var xs:Array[float]=[-26,-20,-14,11,25,34]
	var zs:Array[float]=[-467,-451,-438,-415,-407]
	for xi in xs.size()-1:
		for zi in zs.size()-1:
			if cutout((xs[xi]+xs[xi+1])/2,(zs[zi]+zs[zi+1])/2):continue
			slab(b,xs[xi],xs[xi+1],zs[zi],zs[zi+1],G,22,"c7cdc9")
	# Retaining enclosure follows the underground public corridor, with no surface walls blocking the mall.
	# Card/bank public room extends west of the former shallow shell; no hidden wall through furniture.
	for span:Vector2 in [Vector2(-467,-433.45),Vector2(-416.55,-407)]:
		K.box(b,Vector3(-26,.24,(span.x+span.y)/2),Vector3(.25,4,span.y-span.x),"bfc6c1",true,22)
	slab(b,-31,-26,-433.5,-416.5,LOW)
	slab(b,-31,-26,-433.5,-416.5,G,22,"c7cdc9")
	K.box(b,Vector3(34,.24,-429),Vector3(.25,4,44),"bfc6c1",true,22)
	K.box(b,Vector3(-.5,.24,-467),Vector3(51,4,.25),"bfc6c1",true,22)
	# North wall terminates at the real lower through-passage instead of sealing both districts.
	K.box(b,Vector3(-2,.24,-407),Vector3(48,4,.25),"bfc6c1",true,22)
	K.box(b,Vector3(28,G-.38,-407),Vector3(12,.76,.30),"bfc6c1",true,22)
	beam_grid(b,-20,10,-450,-408)
	beam_grid(b,10,34,-450,-438)
	for x in [-15,-3,9,24]:
		for z in [-412,-438,-450]:
			K.box(b,Vector3(x,.08,z),Vector3(.58,3.68,.58),"c6cdca",true,22)
	# Shop lies on the D side, bank/card frontage adjoins it toward the library side; facing remains site-fitted.
	facade(b,-443,10,true);facade(b,-425,16,false)
	# Broad outdoor descent next to the beam hall, with real slab and terrain apertures.
	P.flight(b,Vector3(18,LOW,-430),Vector3(18,G,-415),10,"93968b",49)
	for x in [11,25]:F.rail(b,Vector3(x,G,-426.5),23,PI/2)
	F.rail(b,Vector3(18,G,-438),14)
	for x in [12,24]:F.rail(b,Vector3(x,G,-415),2)
	# Open lawn at the foot of the stair; dark low stone edging matches the entrance panorama.
	K.box(b,Vector3(18,LOW+.14,-435.5),Vector3(11,.28,3),"646f69",true,15)
	K.box(b,Vector3(18,LOW+.29,-435.5),Vector3(10.6,.045,2.6),"718553",false,3)
	# Secondary access keeps the southern side reachable without a hidden teleport or sealed pit.
	P.flight(b,Vector3(-17,LOW,-452),Vector3(-17,G,-466),4.5,"93968b",49)
	slab(b,-20,-14,-467,-466,G,49)
	for x in [-20,-14]:F.rail(b,Vector3(x,G,-459),16,PI/2)
	F.rail(b,Vector3(-17,G,-451),6)
	for x in [-19.62,-14.38]:F.rail(b,Vector3(x,G,-467),.7)
	# A lower lane and shop threshold use one quiet rectangular stone finish, with perimeter drainage.
	for z in [-437,-449]:
		K.box(b,Vector3(5,LOW+.012,z),Vector3(53,.018,.18),"4d5754",false,11)
		for i in 166:K.box(b,Vector3(-21.3+i*.32,LOW+.025,z),Vector3(.034,.012,.16),"8d9690",false,11)
	for p:Vector3 in [Vector3(7,LOW,-440),Vector3(22,LOW,-440)]:K.bench(b,p)
	for p:Vector3 in [Vector3(-9,.96,-444),Vector3(-9,.96,-423),Vector3(21,.96,-444)]:
		var light:=OmniLight3D.new();light.position=p;light.omni_range=13;light.light_energy=.60;light.light_color=Color("e7ece4");b.add_child(light)
	var direction:=K.label(b,"纪念品商店  ↓\n校园卡服务",Vector3(26.1,G+1.1,-415.3),.005);direction.rotation.y=PI/2
	open_lane(b)
	north_connection(b)
	K.finish(b)
