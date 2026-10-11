extends RefCounted
## Official TA arcade 116440778 and TA square 116443786. Heights fitted to existing upper datum.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func build(parent: Node3D,r: Dictionary) -> void:
	var b:=K.holder(parent,"TeachingAObservedEntry")
	var z: float=float(r.depth)*.27
	# Warm wall, actual clerestory openings, and dark fins stop below the upper plain wall.
	for span: Vector2 in [Vector2(-27,-3),Vector2(3,20)]:
		var mid: float=(span.x+span.y)/2;var width: float=span.y-span.x
		K.box(b,Vector3(mid,3.10,z),Vector3(width,6.20,.26),"bbaa8d",true,15)
		K.box(b,Vector3(mid,7.84,z),Vector3(width,1.07,.26),"bbaa8d",true,15)
		var count:=maxi(1,int(width/5.0));var cell: float=width/count
		for i in count:
			var xx: float=span.x+(i+.5)*cell;var aperture: float=cell*.66;var pier: float=(cell-aperture)/2
			K.box(b,Vector3(xx,6.75,z-.045),Vector3(aperture,1.1,.08),"4b6267",true,19)
			for edge in [-1,1]:
				K.box(b,Vector3(xx+edge*(aperture+pier)/2,6.75,z),Vector3(pier,1.1,.26),"bbaa8d",true,15)
				K.box(b,Vector3(xx,6.75+edge*.56,z+.025),Vector3(aperture,.09,.30),"4b524a",false,11)
			for dx in [-aperture/2,0,aperture/2]:K.box(b,Vector3(xx+dx,6.75,z+.02),Vector3(.07,1.1,.19),"46534b",false,11)
		for i in int(width/.46):K.box(b,Vector3(span.x+.2+i*.46,2.13,z+.26),Vector3(.075,4.26,.50),"454d47",false,11)
		K.box(b,Vector3(mid,.09,z+.10),Vector3(width,.18,.38),"777b70",false,15)
	# Ceiling beams express the tall concrete structure, rather than a low timber pergola.
	K.box(b,Vector3(-7.4,8.30,18.6),Vector3(59.2,.12,10),"b7b8ab",false,22)
	for x in [-35,-29,-23,-17,-11,-5,1,7,13,19]:
		K.box(b,Vector3(x,7.97,18.0),Vector3(.42,.60,10.8),"b5b7ab",false,22)
		K.box(b,Vector3(x+2.6,8.14,17.2),Vector3(.17,.09,.17),"687164",false,11)
		K.box(b,Vector3(x+2.6,8.085,17.2),Vector3(.12,.018,.12),"e1dece",false,17)
	for zz in [14.05,21.48]:K.box(b,Vector3(-7.4,7.94,zz),Vector3(59.2,.66,.4),"b5b7ab",false,22)
	K.box(b,Vector3(-7.4,7.70,20.4),Vector3(59,.10,.10),"bdbbad",false,22)
	for x in [-29,-11,7]:
		K.box(b,Vector3(x+.39,3.85,21.48),Vector3(.10,7.70,.10),"bdbbad",false,22)
		for yy in [1.2,3.8,6.4]:K.box(b,Vector3(x+.39,yy,21.48),Vector3(.16,.07,.16),"899382",false,11)
	# High suspended outside screen and cross ties are visible from the arcade looking to the lawn.
	for i in 74:K.box(b,Vector3(-36.6+i*.79,6.05,23.52),Vector3(.095,4.25,.50),"9c7b5b",false,11)
	for yy in [4.12,8.14]:K.box(b,Vector3(-7.4,yy,23.32),Vector3(59.2,.12,.14),"535e52",false,11)
	for x in [-32,-20,-8,4,16]:
		var brace:=K.holder(b,"OutsideShadeTie",Vector3(x,3.0,23.40));brace.rotation.z=.42
		K.box(brace,Vector3.ZERO,Vector3(.045,2.5,.045),"606b5e",false,11);K.finish(brace)
	# Large grey stone slabs and narrow dark inlays follow the full arcade.
	K.box(b,Vector3(-7.4,.062,18.5),Vector3(59.2,.035,11),"aaa99f",false,12)
	for xx in [-29,-17,-5,7,19]:K.box(b,Vector3(xx,.086,18.5),Vector3(.14,.012,10.6),"686f65",false,15)
	# Tall glazed entrance with an open central pair of leaves, and a lower inner corridor.
	for side in [-1,1]:
		K.box(b,Vector3(side*3,4.13,z+.07),Vector3(.12,8.26,.23),"35433d",true,11)
		K.box(b,Vector3(side*2.22,4.13,z),Vector3(1.43,8.1,.09),"78958d",true,19)
		K.box(b,Vector3(side*1.48,4.13,z+.07),Vector3(.09,8.26,.18),"35433d",true,11)
		var door:=K.holder(b,"OpenTeachingADoor",Vector3(side*1.5,0,z-.7))
		K.box(door,Vector3(0,1.96,0),Vector3(.085,3.92,1.42),"78958d",false,19)
		K.box(door,Vector3(side*.07,1.30,.40),Vector3(.07,1.3,.06),"b3b8aa",false,11);K.finish(door)
	K.box(b,Vector3(0,4.07,z+.06),Vector3(6,.12,.20),"35433d",false,11)
	K.box(b,Vector3(0,6.20,z),Vector3(2.90,4.14,.09),"78958d",true,19)
	K.box(b,Vector3(0,8.31,z+.06),Vector3(6,.14,.20),"35433d",false,11)
	K.box(b,Vector3(0,4.59,7.7),Vector3(5.9,.12,9.9),"3f4843",false,16)
	K.box(b,Vector3(0,.064,7.7),Vector3(5.9,.04,9.9),"aaa99b",false,12)
	for side in [-1,1]:K.box(b,Vector3(side*3,2.25,7.7),Vector3(.17,4.5,9.9),"b9b49f",true,22)
	for zz in [4.5,8,11.5]:K.box(b,Vector3(0,4.47,zz),Vector3(1.6,.06,.18),"e5e0cd",false,17)
	K.box(b,Vector3(0,3.75,9.1),Vector3(5.8,.8,.09),"765474",false,22)
	K.label(b,"经管学院\nSchool of Management and Economics",Vector3(0,3.75,9.17),.0037)
	var light:=OmniLight3D.new();light.position=Vector3(0,3.1,7.5);light.light_energy=.55;light.omni_range=9;light.light_color=Color("eee9d5");b.add_child(light)
	# Plain information panels replace photo-specific posters; attached outside the walking lane.
	for i in 4:
		var xx: float=-8-i*1.7
		K.box(b,Vector3(xx,1.8,z+.55),Vector3(1.05,1.42,.06),["6f8791","8b926d","8b8196","7d968e"][i],false,22)
		for row in 4:K.box(b,Vector3(xx,2.2-row*.22,z+.59),Vector3(.76,.025,.015),"cecfbd",false,22)
	K.finish(b)
