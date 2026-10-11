extends RefCounted
## Road-facing grey plaster and projecting white louver boxes: official scene 116443797.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func elevation(b: Node3D,w: float,d: float,levels: Array,side: int,parapet: bool=true) -> void:
	var count:=maxi(2,roundi(w/3.5));var pitch: float=w/count
	for f in range(levels.size()-1):
		var low: float=levels[f];var h: float=levels[f+1]-low
		for i in count:
			var x: float=(i+.5)*pitch-w/2;var z: float=side*d/2
			var aperture: float=pitch-1.05;var top: float=low+h
			for edge in [-1,1]:
				K.box(b,Vector3(x+edge*(pitch/2-.2625),low+h/2,z),Vector3(.525,h,.28),"777d7d",true,22)
			K.box(b,Vector3(x,low+.32,z),Vector3(aperture,.64,.28),"777d7d",true,22)
			K.box(b,Vector3(x,top-.24,z),Vector3(aperture,.48,.28),"777d7d",true,22)
			K.box(b,Vector3(x,low+h*.53,z-side*.08),Vector3(aperture-.09,h-1.12,.07),"556d7b",false,5)
			for dx in [-aperture/2,0,aperture/2]:K.box(b,Vector3(x+dx,low+h*.53,z+side*.05),Vector3(.055,h-1.08,.1),"b8c0ba",false,11)
			# A narrow projecting service/louver bay sits alongside the glazing, not an open balcony.
			var bx: float=x+aperture*.26;var bw: float=aperture*.48;var bh: float=h-.42
			for edge in [-1,1]:
				K.box(b,Vector3(bx+edge*bw/2,low+h/2,z+side*.35),Vector3(.095,bh,.68),"c8cbc1",false,22)
				K.box(b,Vector3(bx,low+h/2+edge*bh/2,z+side*.35),Vector3(bw+.10,.10,.68),"c8cbc1",false,22)
			for row in range(1,16):
				K.box(b,Vector3(bx,low+.24+row*(bh-.16)/16,z+side*.62),Vector3(bw-.06,.042,.13),"495a60",false,11)
			K.box(b,Vector3(x-aperture*.27,low+.70,z+side*.14),Vector3(aperture*.43,.06,.14),"bdc4bb",false,11)
	if parapet:K.box(b,Vector3(0,levels[-1]+.38,side*d/2),Vector3(w,.66,.24),"828982",false,22)

static func end_wall(b: Node3D,w: float,d: float,levels: Array,side: int,road_end: bool=false) -> void:
	var n:=K.holder(b,"EastGreyEnd",Vector3(side*w/2,0,0));n.rotation.y=PI/2
	if road_end:
		# The street-corner gable is a broad grey wall, not another repeated window grid.
		var bottom: float=levels[0];var top: float=levels[-1]
		K.box(n,Vector3(0,(bottom+top)/2,0),Vector3(d,top-bottom,.3),"777d7d",true,22)
		for y: float in levels.slice(1,-1):
			K.box(n,Vector3(-d*.36,y+1.1,side*.17),Vector3(1.1,1.6,.08),"435b62",false,5)
		for x in [-d*.47,d*.47]:K.box(n,Vector3(x,(top+bottom)/2,side*.17),Vector3(.13,top-bottom,.12),"a5aaa0",false,22)
		var sign:=K.label(n,"逸\n夫\n书\n院",Vector3(d*.13,top-5.3,side*.23),.018)
		if side<0:sign.rotation.y=PI
		K.box(n,Vector3(0,top+.38,0),Vector3(d,.66,.3),"828982",false,22)
	else:elevation(n,d,0,levels,side)
	K.finish(n)

static func public_base(b: Node3D,w: float) -> void:
	# The earlier opaque podium boxes become recessed open-door rooms, while the centre stays open.
	K.box(b,Vector3(0,.048,0),Vector3(65,.05,44),"a29f95",false,12)
	K.box(b,Vector3(0,.080,25.5),Vector3(65,.04,7),"96958e",false,12)
	for x in [-32,32]:K.box(b,Vector3(x,.105,6),Vector3(.16,.025,46),"677269",false,11)
	# Align the public roof walk with the existing courtyard stair (4.925 m local).
	K.box(b,Vector3(0,4.8,18),Vector3(w*.92,.25,8),"afb4a9",true,22)
	K.box(b,Vector3(0,4.934,18),Vector3(w*.92,.014,8),"8d9186",false,12)
	for x in [-28,-17,17,28]:
		for z in [14.65,21.35]:K.box(b,Vector3(x,2.34,z),Vector3(.6,4.68,.6),"929a91",true,22)
	for x in range(-28,29,7):
		K.box(b,Vector3(x,4.48,18),Vector3(.28,.4,8),"aab2a6",false,22)
		K.box(b,Vector3(x,4.22,20.3),Vector3(1.1,.045,.17),"e1dfc7",false,17)
	for side in [-1,1]:
		var cx: float=side*w*.32;var width: float=w*.23
		var room:=K.holder(b,"EastPublicRoom",Vector3(cx,0,16))
		K.box(room,Vector3(0,.065,0),Vector3(width,.06,7),"b1aa98",false,12)
		K.box(room,Vector3(0,2.24,-3.5),Vector3(width,4.48,.20),"847e6b",true,22)
		for edge in [-1,1]:
			K.box(room,Vector3(edge*width/2,2.24,0),Vector3(.20,4.48,7),"7f8981",true,22)
			var glass_width: float=width/2-1.5
			K.box(room,Vector3(edge*(1.5+glass_width/2),2.12,3.48),Vector3(glass_width,4.12,.08),"738d86",true,19)
			K.box(room,Vector3(edge*1.5,2.13,3.55),Vector3(.12,4.2,.18),"42574b",true,11)
			K.box(room,Vector3(edge*1.56,2.06,2.82),Vector3(.075,3.95,1.3),"779c91",false,19)
			K.bench(room,Vector3(edge*3.0,0,.3),PI);K.planter(room,Vector3(edge*6.2,0,1.8))
		K.box(room,Vector3(0,4.47,0),Vector3(width,.12,7),"9a9b8a",false,22)
		K.box(room,Vector3(0,4.22,3.55),Vector3(width,.38,.20),"566655",false,22)
		K.label(room,"公共休憩",Vector3(0,4.20,3.67),.006)
		for x in [-5,0,5]:K.box(room,Vector3(x,4.37,0),Vector3(1.7,.05,.18),"e6dfc9",false,17)
		K.finish(room)
	# Separate approach paving, drain and planted pots match the pedestrian character of the panorama.
	for x in [-27,-18,18,27]:K.planter(b,Vector3(x,0,26.6))
	for x in range(-30,31,2):K.box(b,Vector3(x,.11,28.2),Vector3(1.85,.025,.17),"4e6157",false,11)
	K.box(b,Vector3(0,4.28,22.12),Vector3(16,.82,.12),"6b7669",false,22)
	K.label(b,"逸夫书院 · 东座",Vector3(0,4.28,22.21),.01)
