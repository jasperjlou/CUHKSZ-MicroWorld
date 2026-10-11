extends RefCounted
## V67: entrance-left two-high/two-low composition, photographer7/9 and architect text.
## Geometry in the retained world frame. All metric dimensions and public stair
## routing are proportional fits; no claim of a surveyed room/core plan.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const Site := preload("res://world/visual_campus/EastGatePortal.gd")
const DECK := 4.4

static func floor_rect(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float=DECK) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.14,(z0+z1)/2),Vector3(x1-x0,.28,z1-z0),"a7aba0",true,22)
	K.box(n,Vector3((x0+x1)/2,y+.008,(z0+z1)/2),Vector3(x1-x0,.015,z1-z0),"929b91",false,31)

static func tower(root: Node3D,centre: Vector3,depth: float,levels: Array,name: String) -> void:
	var n:=K.holder(root,name,centre);var w:=24.0;var top: float=levels[-1]
	# Tall warm podium, narrow openings and a continuous stone/glass street end.
	K.box(n,Vector3(0,5.1,0),Vector3(w,10.2,depth),"8b624b",true,20)
	for x in [-4.0,5.0]:
		for y in [2.3,7.0]:K.window(n,Vector3(x,y,depth/2+.035),.75,2.1)
	for y: float in levels.slice(1):K.box(n,Vector3(0,y,0),Vector3(w,.24,depth),"bfc3b8",true,22)
	for side in [-1,1]:
		var cells:=int(depth/3.8);var pitch:=depth/cells
		for f in range(1,levels.size()-1):
			var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
			for i in cells:
				var z: float=-depth/2+(i+.5)*pitch
				K.box(n,Vector3(side*w/2,low+h/2,z),Vector3(.24,h,pitch),"b1b5a9",true,22)
				for dz in [-.69,.69]:K.window(n,Vector3(side*(w/2+.16),low+h/2,z+dz),1.0,h-.8,side*PI/2)
				for dz in [-pitch/2,0.0]:K.box(n,Vector3(side*(w/2+.3),low+h/2,z+dz),Vector3(.45,h,.23),"c1c6b8",false,22)
			K.box(n,Vector3(side*(w/2+.3),low+.15,0),Vector3(.45,.30,depth),"c1c6b8",false,22)
	# Glazed vertical strip on the right of the arrival face; most of the end is solid.
	var front: float=depth/2+.16
	K.box(n,Vector3(-3.5,(top+10.2)/2,front),Vector3(17,top-10.2,.26),"b6bdaf",true,0)
	K.box(n,Vector3(8.5,(top+10.2)/2,front),Vector3(7,top-10.2,.14),"557b82",true,5)
	for x in [5.0,6.75,8.5,10.25,12.0]:K.box(n,Vector3(x,(top+10.2)/2,front+.10),Vector3(.065,top-10.2,.12),"6e8b89",false,22)
	for f in range(1,levels.size()-1):
		var y: float=levels[f]
		K.box(n,Vector3(8.5,y,front+.1),Vector3(7,.065,.12),"7e9d96",false,22)
		K.box(n,Vector3(3.0,y+1.6,front+.15),Vector3(.23,2.45,.12),"414d44",false,22)
		# Visible unequal transom rhythm, not a facade of uniform paired windows.
		K.box(n,Vector3(7.1,y+2.45,front+.1),Vector3(4.2,.055,.12),"7e9d96",false,22)
	K.box(n,Vector3(0,(top+10.2)/2,-depth/2),Vector3(w,top-10.2,.26),"b8bdae",true,0)
	for y: float in levels.slice(1,-1):
		for x in [-7.0,0.0,7.0]:K.window(n,Vector3(x,y+1.6,-depth/2-.16),1.3,2.3,PI)
	K.box(n,Vector3(0,top+.22,0),Vector3(w,.44,depth),"c2c8b8",false,22)
	K.finish(n)

static func hall(n: Node3D) -> void:
	# Two compact structural cores support a long street-facing projection.
	for x in [-84.0,-70.0]:K.box(n,Vector3(x,6.3,4),Vector3(3.0,3.8,5),"805d4a",true,20)
	K.box(n,Vector3(-77,8.2,11),Vector3(32,.45,24),"929b91",true,22)
	K.box(n,Vector3(-77,18.2,11),Vector3(32,.40,24),"c3c9bd",true,22)
	K.box(n,Vector3(-77,13.2,23),Vector3(32,10,.25),"b7c2bc",true,11)
	for x in [-93.0,-61.0]:K.box(n,Vector3(x,13.2,11),Vector3(.25,10,24),"b7c2bc",true,11)
	K.box(n,Vector3(-77,13.2,-1),Vector3(32,10,.22),"6d8c87",true,5)
	for x in range(-92,-61,2):K.box(n,Vector3(x,13.2,-.85),Vector3(.07,9.8,.16),"bcc9bd",false,22)
	var label:=K.label(n,"The Chinese University of Hong Kong,\nShenzhen",Vector3(-77,16.2,23.17),.016)
	label.modulate=Color("354a46")
	# Thin roof rim, shallow raised skylights and a planted roof border.
	for x in [-87,-77,-67]:K.box(n,Vector3(x,18.72,9),Vector3(5,.65,8),"a8b2a4",false,22)
	K.box(n,Vector3(-77,18.44,-.2),Vector3(30,.10,1.2),"5f7842",false,3)

static func rear_bar(n: Node3D) -> void:
	floor_rect(n,-91,-20,-55,-41)
	K.box(n,Vector3(-55.5,14.2,-48),Vector3(71,.3,14),"b9c0b2",true,22)
	for z in [-55.0,-41.0]:
		for span: Vector2 in [Vector2(-91,-57),Vector2(-51,-20)]:
			K.box(n,Vector3((span.x+span.y)/2,6.7,z),Vector3(span.y-span.x,4.6,.15),"6b8981",true,19)
			K.box(n,Vector3((span.x+span.y)/2,11.6,z),Vector3(span.y-span.x,5,.22),"b3bbad",true,22)
		K.box(n,Vector3(-54,11.5,z),Vector3(6,5.4,.22),"b3bbad",true,22)
		for x in range(-89,-20,3):
			K.window(n,Vector3(x,11.5,z+(.17 if z>-50 else -.17)),1.1,2.6,0 if z>-50 else PI)
			if x<-57 or x>-51:K.box(n,Vector3(x,6.7,z),Vector3(.065,4.6,.22),"b6c1b0",false,22)
	for x in [-91.0,-20.0]:K.box(n,Vector3(x,9.3,-48),Vector3(.22,9.8,14),"b7bcae",true,22)
	K.box(n,Vector3(-55.5,14.41,-48),Vector3(67,.10,10),"607a43",false,3)

static func build(b: Node3D,r: Dictionary,builder) -> void:
	# Cancel only this record's transform; all below positions use the documented world frame.
	var n:=K.holder(b,"LeftEntranceCourtyard");n.transform=b.transform.affine_inverse()
	tower(n,Vector3(-32,0,-16),45,r.floor_levels,"InnerTower")
	tower(n,Vector3(-79,0,-24),40,[0,10.2,14,17.8,21.6,25.4,29.2,33,36.8,40.6],"OuterTower")
	hall(n);rear_bar(n)
	# Public raised courtyard with a real open light well and a continuous perimeter.
	floor_rect(n,-67,-61,-41,-4);floor_rect(n,-50,-44,-41,-4)
	floor_rect(n,-61,-50,-41,-22);floor_rect(n,-61,-50,-6,-4)
	floor_rect(n,-94,-44,-4,22)
	for pair: Array in [[Vector3(-61,DECK,-22),Vector3(-50,DECK,-22)],[Vector3(-50,DECK,-22),Vector3(-50,DECK,-6)],[Vector3(-50,DECK,-6),Vector3(-61,DECK,-6)],[Vector3(-61,DECK,-6),Vector3(-61,DECK,-22)]]:P.rail(n,pair[0],pair[1])
	Site.field(n,builder,-61,-50,-22,-6,"878f85")
	K.box(n,Vector3(-55.5,.17,-14),Vector3(6,.20,9),"617449",false,3)
	K.tree(n,Vector3(-55.5,.30,-14),7.8,6701)
	# Street approach: two wide flights, intermediate landing and sheltered upper apron.
	Site.field(n,builder,-98,-20,36,44,"899185")
	Site.field(n,builder,-98,-20,22,36,"899185")
	Site.field(n,builder,-44,-20,6.6,22,"899185")
	Site.field(n,builder,-88,-72,35,38,"969e90")
	P.stair(n,Vector3(-80,0,36),Vector3(-80,2.2,30),10)
	floor_rect(n,-85,-75,28,30,2.2)
	P.stair(n,Vector3(-80,2.2,28),Vector3(-80,DECK,22),10)
	for span: Vector2 in [Vector2(-94,-85.2),Vector2(-74.8,-44)]:P.rail(n,Vector3(span.x,DECK,22),Vector3(span.y,DECK,22))
	P.rail(n,Vector3(-94,DECK,-4),Vector3(-94,DECK,22))
	P.rail(n,Vector3(-44,DECK,6.7),Vector3(-44,DECK,22))
	# Front plinth reads as warm solid support, with the approach opening left clear.
	for span: Vector2 in [Vector2(-94,-85.2),Vector2(-74.8,-44)]:K.box(n,Vector3((span.x+span.y)/2,2.08,21.88),Vector3(span.y-span.x,4.16,.24),"8b624b",true,20)
	# Public rear connection to the teaching-side walk. Grade/door offsets remain fitted.
	floor_rect(n,-57,-51,-56.5,-55)
	P.stair(n,Vector3(-54,2.24,-70),Vector3(-54,DECK,-56),4)
	Site.field(n,builder,-57,-17,-74,-69,"929b8e")
	Site.field(n,builder,-22,-18,-72,-54,"929b8e")
	Site.field(n,builder,-20,0,-59,-55,"929b8e")
	Site.field(n,builder,-98,-94,-56,44,"8b9388")
	# Source frontages have bounded planting beds and trees, not an unbounded grass apron.
	for bed: Rect2 in [Rect2(-73,27,26,6),Rect2(-42,14,14,7)]:
		K.box(n,Vector3(bed.get_center().x,.18,bed.get_center().y),Vector3(bed.size.x,.18,bed.size.y),"536c40",false,3)
		for side in [-1,1]:
			K.box(n,Vector3(bed.get_center().x,.21,bed.get_center().y+side*bed.size.y/2),Vector3(bed.size.x,.22,.20),"a2ac9b",false,26)
			K.box(n,Vector3(bed.get_center().x+side*bed.size.x/2,.21,bed.get_center().y),Vector3(.20,.22,bed.size.y),"a2ac9b",false,26)
	for p: Vector2 in [Vector2(-69,30),Vector2(-60,30),Vector2(-51,30),Vector2(-38,17.5),Vector2(-31,17.5)]:K.tree(n,Vector3(p.x,.30,p.y),7.3,6710+absi(int(p.x)))
	for x in [-89,-69]:K.bench(n,Vector3(x,DECK,18),PI)
	K.finish(n)
