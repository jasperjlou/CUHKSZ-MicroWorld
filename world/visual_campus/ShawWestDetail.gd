extends RefCounted
## Official Shaw West scene 116440787. Structural heights retained; unseen rooms remain inferred.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func opening(cell: int,floor: int,count: int) -> int:
	for rect: Array in [[2,2],[4,maxi(2,count-5)],[6,2]]:
		if floor in [rect[0],rect[0]+1] and cell>=rect[1] and cell<rect[1]+2:return int(rect[0])
	return -1

static func elevation(b: Node3D,w: float,d: float,levels: Array,side: int,dark: bool) -> void:
	var count:=maxi(3,roundi(w/3.1));var cell: float=w/count
	var stone: String="696d69" if dark else "c2c3b7"
	for f in range(levels.size()-1):
		var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
		for i in count:
			var x: float=(i+.5)*cell-w/2;var y: float=(low+high)/2;var z: float=side*d/2
			var terrace:=opening(i,f,count)
			if terrace>=0:
				# Deep warm recess, with the double-height void kept genuinely hollow.
				K.box(b,Vector3(x,y,0),Vector3(cell,h,.20),"ae9566",false,22)
				for edge in [-1,1]:
					if opening(i+edge,f,count)!=terrace:
						K.box(b,Vector3(x+edge*(cell/2-.04),y,side*d*.25),Vector3(.10,h,d*.5),"b19b71",false,22)
				if f==terrace:
					K.box(b,Vector3(x,low+.21,side*d*.26),Vector3(cell,.14,d*.48),"aaac9d",false,12)
					for yy in [.3,1.15]:K.box(b,Vector3(x,low+yy,z+.07*side),Vector3(cell,.055,.06),"6c766a",false,11)
					for j in 7:K.box(b,Vector3(x-cell/2+(j+.5)*cell/7,low+.72,z+.07*side),Vector3(.025,.85,.025),"768071",false,11)
					K.planter(b,Vector3(x,low+.2,side*d*.21))
				continue
			var aperture: float=cell-.68
			for edge in [-1,1]:
				K.box(b,Vector3(x+edge*(cell/2-.17),y,z),Vector3(.34,h,.30),stone,true,22)
				K.box(b,Vector3(x,low if edge<0 else high,z),Vector3(cell,.23,.32),stone,false,22)
			# Blue-grey inset glazing and metal lower panel sit behind the projecting white frame.
			K.box(b,Vector3(x,low+h*.61,z-side*.12),Vector3(aperture,h*.57,.08),"718b91",false,5)
			K.box(b,Vector3(x,low+.49,z),Vector3(aperture,.76,.11),"777f7d",false,11)
			for dx in [-aperture/2,0,aperture/2]:K.box(b,Vector3(x+dx,low+h*.59,z+side*.02),Vector3(.055,h*.62,.13),"647470",false,11)
			K.box(b,Vector3(x,low+.97,z+side*.16),Vector3(aperture,.07,.12),"b0b7aa",false,11)
			for edge in [-1,1]:K.box(b,Vector3(x+edge*(cell/2-.08),y,z+side*.29),Vector3(.16,h,.70),"cbccbe",false,22)
			K.box(b,Vector3(x,high-.04,z+side*.30),Vector3(cell,.20,.82),"cbccbe",false,22)
			K.box(b,Vector3(x,low+.14,z+side*.33),Vector3(cell,.18,.84),"c2c5b5",false,22)
			if i%2==0:
				K.box(b,Vector3(x+aperture*.28,low+.60,z+side*.45),Vector3(.53,.55,.40),"adb6aa",false,22)
				for row in 5:K.box(b,Vector3(x+aperture*.28,low+.38+row*.10,z+side*.665),Vector3(.44,.025,.018),"687b6f",false,11)

static func end_wall(b: Node3D,w: float,d: float,levels: Array,side: int) -> void:
	# Mostly plain rendered end walls, rather than the teaching-block stone-and-sill template.
	var n:=K.holder(b,"WestPlainEndWall",Vector3(side*w/2,0,0));n.rotation.y=PI/2
	var cells:=maxi(2,int(d/3.8));var pitch: float=d/cells
	for f in range(levels.size()-1):
		var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
		for i in cells:
			var x: float=-d/2+(i+.5)*pitch
			for edge in [-1,1]:K.box(n,Vector3(x+edge*(pitch+.74)/4,(low+high)/2,0),Vector3((pitch-.74)/2,h,.24),"bfc0b3",true,22)
			K.box(n,Vector3(x,low+.38,0),Vector3(.74,.76,.24),"bfc0b3",true,22)
			K.box(n,Vector3(x,high-.38,0),Vector3(.74,.76,.24),"bfc0b3",true,22)
			K.box(n,Vector3(x,(low+high)/2,.07),Vector3(.68,h-.78,.08),"6c8285",false,5)
			K.box(n,Vector3(x,(low+high)/2,.13),Vector3(.70,.055,.13),"747f74",false,11)
	K.finish(n)

static func public_base(parent: Node3D) -> void:
	var b:=K.holder(parent,"WestPublicForecourt")
	# Continuous stone court with a central passage and separately roofed entrance edge.
	K.box(b,Vector3(-6,.050,5),Vector3(53,.06,35),"a4a394",false,12)
	K.box(b,Vector3(0,.085,8.5),Vector3(6.6,.03,29),"515954",false,2)
	for side in [-1,1]:K.box(b,Vector3(side*3.35,.109,8.5),Vector3(.10,.016,29),"c7c5ac",false,22)
	for x in [-25,-18,-11,-4]:
		K.box(b,Vector3(x,2.12,22.7),Vector3(.25,4.24,.25),"b1b7ad",true,22)
		K.box(b,Vector3(x,4.27,20.8),Vector3(.16,.22,4.1),"a4b0a5",false,11)
	K.box(b,Vector3(-14.5,4.4,20.8),Vector3(27,.09,4.1),"789c93",false,19)
	for z in [18.8,22.8]:K.box(b,Vector3(-14.5,4.25,z),Vector3(27,.20,.17),"acb7aa",false,11)
	# Recessed shared lounge within the flat part of the cross wing. Private dorms are not modelled.
	K.box(b,Vector3(22.6,.055,0),Vector3(14.5,.055,15.4),"b0ab98",false,12)
	K.box(b,Vector3(29.85,2.2,0),Vector3(.24,4.4,15.4),"737971",true,22)
	for z in [-7.7,7.7]:K.box(b,Vector3(22.6,2.2,z),Vector3(14.5,4.4,.24),"85877a",true,22)
	for z in [-6,-3,3,6]:
		K.box(b,Vector3(15.32,2.12,z),Vector3(.085,4.0,2.92),"729087",true,19)
		for edge in [-1,1]:K.box(b,Vector3(15.23,2.12,z+edge*1.5),Vector3(.16,4.15,.08),"495b50",false,11)
	K.box(b,Vector3(22.6,4.49,0),Vector3(14.5,.12,15.4),"727b71",false,22)
	for x in [18,23,28]:
		for z in [-5,0,5]:K.box(b,Vector3(x,4.38,z),Vector3(1.5,.06,.18),"e5decb",false,17)
	for z in [-5,5]:K.bench(b,Vector3(25,0,z),PI/2);K.planter(b,Vector3(28,0,z))
	K.box(b,Vector3(15.13,4.00,0),Vector3(.19,.70,5.7),"929888",false,22)
	var label:=K.label(b,"逸夫书院 · 公共空间",Vector3(15.01,4.0,0),.005);label.rotation.y=-PI/2
	var light:=OmniLight3D.new();light.position=Vector3(22.6,3.4,0);light.light_energy=.65;light.omni_range=11;light.light_color=Color("f0e9d5");b.add_child(light)
	for z in [-8.5,8.5]:
		K.box(b,Vector3(14,.25,z),Vector3(2,.5,3),"8f9787",false,15)
		K.box(b,Vector3(14,.52,z),Vector3(1.7,.08,2.7),"657b4e",false,3)
	K.finish(b)
