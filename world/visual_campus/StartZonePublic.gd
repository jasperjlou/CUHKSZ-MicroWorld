extends RefCounted
## Ground-floor details from the named Le Tian, Zhiren and Main Square panoramas.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func glazing(b: Node3D,w: float,z: float,awning: bool,clip_min:float=-INF,clip_max:float=INF) -> void:
	var count:=maxi(2,roundi(w/3.0));var pitch:=w/count
	for i in count:
		var left:float=maxf(-w/2+i*pitch,clip_min);var right:float=minf(-w/2+(i+1)*pitch,clip_max)
		if right-left<.1:continue
		var x:float=(left+right)/2;var pane:float=right-left
		if absf(x)<4.5:continue
		K.box(b,Vector3(x,2.07,z-.12),Vector3(pane-.10,4,.10),"91b0ad",true,19)
		for side in [-1,1]:K.box(b,Vector3(x+side*(pane/2-.035),2.1,z),Vector3(.07,4.2,.16),"4d625d",false,11)
		K.box(b,Vector3(x,4.15,z),Vector3(pane,.14,.20),"4d625d",false,11)
		K.box(b,Vector3(x,.12,z+.02),Vector3(pane,.20,.26),"697c70",false,11)
	for x in [-4.5,4.5]:K.box(b,Vector3(x,2.1,z),Vector3(.12,4.2,.18),"435b51",true,11)
	K.box(b,Vector3(0,4.18,z),Vector3(9.1,.14,.20),"435b51",false,11)
	for side in [-1,1]:
		var door:=K.holder(b,"OpenEntryDoor",Vector3(side*4.1,0,z-.5));door.rotation.y=side*.35
		K.box(door,Vector3(0,1.94,0),Vector3(.11,3.88,1.05),"8eaba5",false,19)
		K.box(door,Vector3(.075,1.2,.1),Vector3(.04,.65,.04),"50685c",false,11);K.finish(door)
	if awning:
		# One coherent entrance awning replaces a rooflet over every window bay.
		K.box(b,Vector3(0,4.32,z+1.05),Vector3(11,.065,2.35),"8fa9a9",false,19)
		for x in [-5.4,-2.7,0,2.7,5.4]:K.box(b,Vector3(x,4.25,z+1.05),Vector3(.09,.16,2.6),"65786c",false,11)
		for zz in [z-.2,z+2.25]:K.box(b,Vector3(0,4.27,zz),Vector3(11,.12,.10),"65786c",false,11)

static func flowering_pot(b: Node3D,p: Vector3,seed: int) -> void:
	K.planter(b,p)
	var petals:=PackedVector3Array()
	for i in 21:
		var a: float=i*2.399+seed;var q:=p+Vector3(cos(a)*(.22+float(i%4)*.05),1.15+float(i%6)*.12,sin(a)*(.22+float(i%4)*.05))
		for side in [-1,1]:
			petals.append_array(PackedVector3Array([q,q+Vector3(.12,.05,side*.06),q+Vector3(.01,.14,side*.01),q,q+Vector3(.01,.14,side*.01),q+Vector3(.12,.05,side*.06)]))
	K.surface(b,petals,"a96f8a",22)

static func room(b: Node3D,center: Vector3,w: float,d: float,front_z: float,ceiling:bool=true,floor_kind:int=12) -> void:
	K.box(b,center+Vector3.UP*.065,Vector3(w,.08,d),"888c76" if floor_kind==55 else "b4b3a2",false,floor_kind)
	if ceiling:K.box(b,center+Vector3.UP*4.44,Vector3(w,.04,d),"b8bfb2",false,15)
	K.box(b,Vector3(center.x,2.1,center.z-d/2+.25),Vector3(w,4.2,.24),"b6b6a6",true,22)
	K.box(b,Vector3(center.x-w*.23,1,front_z-4),Vector3(5.2,1.9,1.3),"9a8d72",true,4)
	K.box(b,Vector3(center.x-w*.23,2,front_z-4),Vector3(5.5,.13,1.5),"c1bfaa",false,12)
	for x in [-w*.27,w*.27]:
		K.bench(b,Vector3(center.x+x,0,center.z-1))
		K.box(b,Vector3(center.x+x,4.34,center.z),Vector3(5,.04,.2),"e0d9bc",false,17)
		var light:=OmniLight3D.new();light.position=Vector3(center.x+x,3.1,center.z);light.light_energy=.55;light.light_color=Color("eee6cb");light.omni_range=12;b.add_child(light)

static func build(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth;var n:=K.holder(b,"StartZonePublicDetail")
	if r.id=="le_tian":
		var z: float=d*.055
		room(n,Vector3(0,0,-6.2),w*.87,15.5,z)
		K.box(n,Vector3(0,.033,z+2.1),Vector3(w,.045,4.2),"b3b5a7",false,6)
		for x in [-23,-17,-10,10,17,23]:flowering_pot(n,Vector3(x,0,z+1.1),absi(x))
		K.box(n,Vector3(0,.07,z+4.15),Vector3(w,.04,.16),"657b6d",false,11)
	elif r.id=="zhi_ren":
		var z: float=-d*.12
		room(n,Vector3(-5,0,-10.5),w*.64,11,z)
		# Painted columns, exposed beams and rear doors remain visible through the ground arcade.
		for x in range(-24,25,6):
			K.box(n,Vector3(x,4.31,-8),Vector3(.24,.38,12),"b7bfb0",false,15)
			K.box(n,Vector3(x,3.98,z-1),Vector3(.20,.12,.42),"ddd5b8",false,17)
		for x in [-22,-13,13]:flowering_pot(n,Vector3(x,0,3),absi(x))
		K.box(n,Vector3(-4,.029,7),Vector3(36,.04,20),"a48877",false,7)
	elif r.id=="zhi_xin":
		var z: float=-d*.19
		room(n,Vector3(0,0,-17.1),w*.94,14.2,z,false,55)
		# Close the22cm non-structural back-wall head gap seen from the new atrium.
		K.box(n,Vector3(0,4.34,-23.95),Vector3(w*.94,.28,.24),"b6b6a6",false,22)
		# The long return has ribbon glazing above and teal glazing toward the court below.
		var side:=K.holder(n,"LibraryReturnGroundGlazing",Vector3(-w*.26,0,3));side.rotation.y=PI/2
		glazing(side,d*.70,0,false,-INF,12.88);K.finish(side)
		var end:=K.holder(n,"LibraryEndGroundGlazing",Vector3(-w*.38,0,d*.485))
		glazing(end,w*.24,0,false)
		K.box(end,Vector3(0,2.07,-.12),Vector3(8.9,4.0,.10),"91b0ad",true,19)
		for x in [-3,0,3]:K.box(end,Vector3(x,2.1,0),Vector3(.075,4.2,.16),"4d625d",false,11)
		K.finish(end)
		# Previously absent opposing wing: glazed public base, accessible court door,
		# plain outer wall and floor beneath the five-row teaching elevation.
		var opposite:=K.holder(n,"ZhiXinAddedTeachingGround",Vector3(w*.38,0,d*.485))
		glazing(opposite,w*.24,0,false);K.finish(opposite)
		var inner:=K.holder(n,"ZhiXinAddedCourtGlazing",Vector3(w*.26,0,3));inner.rotation.y=-PI/2
		glazing(inner,d*.70,0,false,-12.88,INF);K.finish(inner)
		K.box(n,Vector3(w*.38,.06,4),Vector3(w*.235,.08,d*.78),"b4b3a2",false,12)
		K.box(n,Vector3(w*.497,2.1,4),Vector3(.22,4.2,d*.79),"b4b6a7",true,22)
		K.box(n,Vector3(w*.497,4.34,4),Vector3(.22,.28,d*.79),"b4b6a7",false,22)
		K.box(n,Vector3(w*.38,4.44,7.2),Vector3(w*.235,.04,34.16),"b8bfb2",false,15)
		K.box(n,Vector3(-w*.38,.06,4),Vector3(w*.235,.08,d*.78),"b4b3a2",false,12)
		# V87: photographed court-side base is recessed glazing, not a blank wall.
		preload("res://world/visual_campus/OldLibraryStreet.gd").library_base(n,w,d)
		K.box(n,Vector3(-w*.38,4.44,7.2),Vector3(w*.235,.04,34.16),"b8bfb2",false,15)
		for zz in [0,10,18]:
			K.box(n,Vector3(-w*.44,.76,zz),Vector3(3,.13,1.3),"a99b7e",true,4)
			for xx in [-w*.44-1.2,-w*.44+1.2]:K.box(n,Vector3(xx,.35,zz),Vector3(.1,.7,1),"708177",false,11)
			K.bench(n,Vector3(-w*.44,0,zz+1.25))
			K.box(n,Vector3(-w*.38,4.32,zz),Vector3(5,.05,.18),"ddd4b7",false,17)
		K.box(n,Vector3(0,.028,7),Vector3(w*.56,.045,34),"b49877",false,7)
		# V76: flags stand on the street-side ochre apron, ahead of the grey court.
		K.box(n,Vector3(10,.23,23),Vector3(10,.46,2.8),"92988f",true,26)
		for x in [7,10,13]:
			K.box(n,Vector3(x,6.2,23),Vector3(.085,12,.085),"a9bab3",false,11)
			K.box(n,Vector3(x+.60,11.6,23),Vector3(1.15,.7,.025),"93616a",false,15)
		for x in [-17,17]:
			for zz in [-4,8,21]:flowering_pot(n,Vector3(x,0,zz),absi(x+zz))
		var title:=K.label(n,"PHILIP WONG YU-HONG &\nANITA LEUNG FUNG-YEE\nLIBRARY",Vector3(-w*.38,6.2,d*.485+.10),.010);title.modulate=Color("334f46")
	else:
		var z: float=d*.36
		K.box(n,Vector3(0,.035,z),Vector3(w*.85,.05,10),"aa8c7a",false,7)
		for x in [-w*.32,w*.32]:flowering_pot(n,Vector3(x,0,z+2),absi(int(x)))
	K.finish(n)
