extends RefCounted
## V53: topology from architect axonometric; dimensions, levels and doors are fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const F2:=4.4
const F3:=8.8

static func occupied(p: Vector2,parts: Array,holes: Array) -> bool:
	for h: Rect2 in holes:
		if h.has_point(p):return false
	for r: Rect2 in parts:
		if r.has_point(p):return true
	return false

static func deck(b: Node3D,y: float,parts: Array,holes: Array) -> void:
	var xs: Array[float]=[-21,-15,19.5,28.5];var zs: Array[float]=[19,23]
	for r: Rect2 in parts+holes:
		for x in [r.position.x,r.end.x]:
			if not xs.has(x):xs.append(x)
		for z in [r.position.y,r.end.y]:
			if not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var p:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2)
			if not occupied(p,parts,holes):continue
			K.box(b,Vector3(p.x,y-.14,p.y),Vector3(xs[i+1]-xs[i],.28,zs[j+1]-zs[j]),"c0c1b3",true,22)
			K.box(b,Vector3(p.x,y+.008,p.y),Vector3(xs[i+1]-xs[i],.016,zs[j+1]-zs[j]),"a5a595",false,26)
			for side in [-1,1]:
				var z: float=zs[j] if side<0 else zs[j+1]
				if not occupied(Vector2(p.x,z+side*.01),parts,holes):
					var opening: bool=(y==F3 and z==-30 and p.x>-21 and p.x<-15) or (z==7 and p.x>19.5 and p.x<28.5)
					if not opening:P.rail(b,Vector3(xs[i],y,z),Vector3(xs[i+1],y,z))
				var x: float=xs[i] if side<0 else xs[i+1]
				if not occupied(Vector2(x+side*.01,p.y),parts,holes):
					if y==F2 and x==10 and p.y>19 and p.y<23:continue
					P.rail(b,Vector3(x,y,zs[j]),Vector3(x,y,zs[j+1]))

static func build(b: Node3D) -> void:
	var front:=Rect2(-33,14,43,16);var rear:=Rect2(-4,-30,37,16)
	var middle:=Rect2(-4,-14,14,28);var hill_court:=Rect2(-33,-30,29,44)
	var lightwell:=Rect2(-27,-20,17,27)
	var parts: Array=[front,rear,middle,hill_court,Rect2(10,3,19,4)]
	# Real hardscape covers the two opposing courts and the columned ground floor.
	K.box(b,Vector3(0,.025,0),Vector3(66,.05,60),"a8a497",true,26)
	K.box(b,Vector3(0,.033,31.4),Vector3(76,.055,2.8),"a8a497",false,26)
	for side in [-1,1]:K.box(b,Vector3(side*35.5,.032,0),Vector3(5,.055,66),"a8a497",false,26)
	for x in [-33,33]:K.box(b,Vector3(x,.06,0),Vector3(.28,.06,60),"606965",false,11)
	deck(b,F2,[front,rear,middle,hill_court],[lightwell])
	deck(b,F3,parts,[lightwell])
	# A two-flight outdoor approach reaches the third-floor public platform.
	P.stair(b,Vector3(24,.05,32),Vector3(24,F2,23),8)
	K.box(b,Vector3(24,F2-.14,21),Vector3(9,.28,4),"b2b2a5",true,26)
	P.rail(b,Vector3(28.5,F2,19),Vector3(28.5,F2,23))
	P.stair(b,Vector3(24,F2,19),Vector3(24,F3,7),8)
	# 2F landing joins the public floor under the front dorm without a dead-end stair.
	K.box(b,Vector3(14.75,F2-.14,21),Vector3(9.5,.28,4),"b2b2a5",true,26)
	for z in [19,23]:P.rail(b,Vector3(10,F2,z),Vector3(19.5,F2,z))
	# Recessed ground public rooms, with wide entrances onto the paved arcade.
	P.room(b,Rect2(-30,18,36,9),.05,F2-.05)
	P.room(b,Rect2(-1,-27,31,10),.05,F2-.05)
	# Additional columns carry the hill-side podium, preserving the open lower court.
	for x in [-31,-7]:
		for z in [-27,-12,11]:K.column(b,Vector3(x,.05,z),F3-.05,.65)
	for x in [13,28]:K.column(b,Vector3(x,.05,4.5),F3-.05,.55)
	# Lightwell planting stays inside its real opening, not on the circulation strips.
	K.box(b,Vector3(-18.5,.12,-6.5),Vector3(15,.18,25),"565c44",false,8)
	V.shrub(b,Vector3(-18.5,.25,-6.5),Vector3(13,.55,23),5301)
	for z in [-13,1]:K.tree(b,Vector3(-18.5,.24,z),7.7,5302+int(z))
	for p: Vector3 in [Vector3(-30,F3,-7),Vector3(15,F3,-28),Vector3(16,.05,28)]:
		K.planter(b,p);K.bench(b,p+Vector3(2,0,0))
	# Front glass canopy follows the observed plain end/arcade vocabulary.
	K.box(b,Vector3(-12,4.28,31.7),Vector3(39,.12,3.2),"78958c",false,19)
	for x in [-30,-18,-6,6]:
		K.column(b,Vector3(x,0,32.8),4.4,.22)
		K.box(b,Vector3(x,4.17,31.7),Vector3(.16,.22,3.2),"959d92",false,11)
	K.label(b,"逸夫书院 · 西座",Vector3(-12,4.03,30.15),.012)
