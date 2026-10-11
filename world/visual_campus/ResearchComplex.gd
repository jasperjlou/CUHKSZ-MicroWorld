extends RefCounted
## V56: architect standard-floor plan/section and anniversary photograph.
## Two parallel wings, a connecting return, open garden and stepped podium; all metric values fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const BASE:=11.5

static func elevation(b: Node3D,width: float,base: float,count: int,ochre: bool) -> void:
	for floor in count:
		var y: float=base+floor*4.0
		K.box(b,Vector3(0,y+.48,-.15),Vector3(width,.96,.30),"c4bca9" if ochre else "d3d5ca",true,22)
		K.box(b,Vector3(0,y+3.69,-.15),Vector3(width,.62,.30),"c4bca9" if ochre else "d3d5ca",true,22)
		var cells:=maxi(2,roundi(width/3));var pitch:=width/cells
		for i in cells:
			var x: float=-width/2+(i+.5)*pitch
			var blank: bool=ochre and absf(x)>width*.34
			K.box(b,Vector3(x,y+2.15,-.14),Vector3(pitch-.02,2.42,.20),"c4baa3" if blank else "49636a",true,22 if blank else 5)
			if blank and i in [2,cells-3]:K.box(b,Vector3(x,y+2.15,.005),Vector3(pitch*.82,.62,.08),"4e676d",false,5)
			if not blank:
				K.box(b,Vector3(x-pitch/2,y+2.15,.02),Vector3(.09,2.46,.18),"5c716b",false,11)
				K.box(b,Vector3(x,y+1.90,.015),Vector3(pitch,.065,.14),"5c716b",false,11)
		if ochre:
			for x in [-23,-17,-11,-5,1,7,13,19]:
				K.box(b,Vector3(x+.8,y+2.15,.64),Vector3(3.8,2.58,.18),"b58a45",false,11,.22)
				K.box(b,Vector3(x-1.08,y+2.15,.28),Vector3(.16,2.58,.94),"ab8040",false,11)

static func wing(parent: Node3D,name: String,centre: Vector2,size: Vector2,count: int,front: bool) -> void:
	var b:=K.holder(parent,name,Vector3(centre.x,0,centre.y))
	for i in count+1:K.box(b,Vector3(0,BASE+i*4-.14,0),Vector3(size.x,.28,size.y),"bac0b7",true,18 if i==count else 15)
	for side in [-1,1]:
		var face:=K.holder(b,"LongElevation",Vector3(0,0,side*size.y/2));face.rotation.y=0.0 if side==1 else PI
		# The lowest storey of the front wing opens to the outside and garden on the stair axis.
		if front:
			var door: float=-centre.x*side
			# Upper levels preserve continuous ribbon/ochre shading rhythms.
			elevation(face,size.x,BASE+4,count-1,side==1)
			for span: Vector2 in [Vector2(-size.x/2,door-3.5),Vector2(door+3.5,size.x/2)]:
				var width:=span.y-span.x
				K.box(face,Vector3((span.x+span.y)/2,BASE+2,-.12),Vector3(width,3.8,.18),"71928e",true,19)
			K.box(face,Vector3(0,BASE+3.85,-.1),Vector3(size.x,.30,.25),"c9c7bb",false,22)
			for x in [door-3.5,door+3.5]:K.box(face,Vector3(x,BASE+1.9,0),Vector3(.12,3.8,.2),"687c70",true,11)
		else:elevation(face,size.x,BASE,count,false)
		K.finish(face)
	for side in [-1,1]:
		var end:=K.holder(b,"StoneEnd",Vector3(side*size.x/2,0,0));end.rotation.y=side*PI/2
		K.box(end,Vector3(0,BASE+count*2,-.17),Vector3(size.y,count*4,.34),"c4bca9",true,26)
		# A tall recessed glass slit gives the photographed end wall its distinct vertical emphasis.
		K.box(end,Vector3(-size.y*.17,BASE+count*2,.025),Vector3(3.1,count*4-2,.12),"48636b",false,5)
		for y in range(int(BASE+1),int(BASE+count*4),2):K.box(end,Vector3(-size.y*.17,y,.10),Vector3(3.15,.075,.12),"5e746f",false,11)
		K.finish(end)
	for side in [-1,1]:K.box(b,Vector3(0,BASE+count*4+.65,side*size.y/2),Vector3(size.x,1.3,.25),"d0d1c5",true,22)
	K.finish(b)

static func podium(b: Node3D) -> void:
	# Public terraces are real horizontal slabs; the centre stays open to the sky.
	for y in [0.0,5.5,BASE]:
		K.box(b,Vector3(0,y-.14,0),Vector3(90,.28,76),"bec3b8",true,15)
		K.box(b,Vector3(0,y+.01,0),Vector3(90,.02,76),"adac9e",false,26)
	for x in [-40,-26,26,40]:
		for z in [-30,-6,30]:K.column(b,Vector3(x,0,z),BASE,.75)
	# White stone plinth with slender windows and ground door gaps toward street and service lane.
	for side in [-1,1]:
		for x in range(-42,43,3):
			if abs(x)<6:continue
			K.box(b,Vector3(x,2.55,side*38),Vector3(2.92,5.1,.28),"bfc1b5",true,26)
			K.box(b,Vector3(x,2.9,side*38+side*.18),Vector3(1.15,3.4,.10),"577078",false,5)
		for x in [-6,6]:K.box(b,Vector3(x,2.55,side*38),Vector3(.18,5.1,.5),"9fa99c",true,11)
		# Intermediate level opens only through fitted public doorways, leaving the upper apron continuous.
		for x in range(-42,43,3):
			if abs(x)<6:continue
			K.box(b,Vector3(x,8.5,side*38),Vector3(2.92,5.7,.25),"bdc1b5",true,26)
	for x in [-45,45]:
		K.box(b,Vector3(x,5.6,0),Vector3(.30,11.2,76),"c1c3b7",true,26)
	# Main outdoor stair follows the stepped base; lower and upper doorways remain separate.
	P.stair(b,Vector3(0,0,63),Vector3(0,5.5,51),14)
	K.box(b,Vector3(0,5.36,49),Vector3(14.4,.28,4),"b4b7ab",true,26)
	for x in [-7.2,7.2]:P.rail(b,Vector3(x,5.5,51),Vector3(x,5.5,47))
	P.stair(b,Vector3(0,5.5,47),Vector3(0,BASE,38),14)
	# The roof garden sits between the two parallel wings instead of a solid centre tower.
	K.box(b,Vector3(-7,BASE+.023,1.5),Vector3(49,.04,19),"768862",false,3)
	K.box(b,Vector3(0,BASE+.055,1.5),Vector3(5,.025,27),"aaa99c",false,26)
	for x in [-25,-7,11]:
		K.tree(b,Vector3(x,BASE+.04,2),6.5,5600+x)
		K.bench(b,Vector3(x,BASE,-9),PI)
	for span: Vector2 in [Vector2(-45,-7.2),Vector2(7.2,45)]:P.rail(b,Vector3(span.x,BASE,38),Vector3(span.y,BASE,38))
	P.rail(b,Vector3(-45,BASE,-38),Vector3(-45,BASE,38));P.rail(b,Vector3(45,BASE,-38),Vector3(45,BASE,38))
	P.rail(b,Vector3(-45,BASE,-38),Vector3(45,BASE,-38))

static func build(b: Node3D,_r: Dictionary) -> void:
	podium(b)
	wing(b,"ResearchRearHighWing",Vector2(-5,-22),Vector2(78,22),11,false)
	wing(b,"ResearchFrontLowWing",Vector2(0,24),Vector2(76,18),8,true)
	wing(b,"ResearchConnectingReturn",Vector2(34,1),Vector2(12,28),8,false)
	# Two low bridges articulate the opening at the return, visible in the architect's section.
	for y in [19.5,27.5]:
		K.box(b,Vector3(24,y-.14,2),Vector3(7,.28,27),"c3c7bc",true,15)
		P.rail(b,Vector3(20.5,y,-11.5),Vector3(20.5,y,15.5))
	K.label(b,"科研楼",Vector3(0,BASE+4.8,33.25),.014)
	# Ground-level hardscape and the step foot join the street without covering the sports hall.
	K.box(b,Vector3(0,.055,41),Vector3(92,.06,6),"b0b0a0",false,26)
	K.box(b,Vector3(0,.075,65),Vector3(18,.04,5),"b0b0a0",false,26)
	K.box(b,Vector3(0,.078,71.5),Vector3(18,.035,17),"b0b0a0",false,26)
