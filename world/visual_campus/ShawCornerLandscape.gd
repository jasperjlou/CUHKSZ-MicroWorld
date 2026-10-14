extends RefCounted
## Anniversary street character, fitted to retained anchors; not a surveyed plan.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const S := preload("res://world/visual_campus/StartZoneLandscape.gd")
const G := 2.24

static func offset(points: Array,distance: float) -> Array:
	var result: Array=[]
	for i in points.size():
		var a: Array=points[maxi(0,i-1)];var c: Array=points[mini(i+1,points.size()-1)]
		var tangent:=Vector2(float(c[0])-float(a[0]),float(c[2])-float(a[2])).normalized()
		result.append([float(points[i][0])+tangent.y*distance,G,float(points[i][2])-tangent.x*distance])
	return result

static func markings(b: Node3D,points: Array,builder) -> void:
	# Continuous arc-length phase: dense spline samples must not suppress every dash.
	var travelled:=0.0
	for i in range(points.size()-1):
		var a:=Vector3(points[i][0],G,points[i][2]);var c:=Vector3(points[i+1][0],G,points[i+1][2])
		var direction: Vector3=(c-a).normalized();var length:=a.distance_to(c)
		var cursor:=0.0
		while cursor<length:
			var step:=minf(.5,length-cursor);var p:=a+direction*(cursor+step/2)
			if fmod(travelled+cursor,8.0)<3.0 and p.distance_to(Vector3(56,G,-585))>5:
				p.y=builder.height(p.x,p.z)+.147
				K.box(b,p,Vector3(.13,.015,step+.015),"d5b747",false,22,atan2(direction.x,direction.z))
			cursor+=step
		travelled+=length

static func after_junction(points: Array) -> Array:
	var travelled:=0.0
	for i in range(1,points.size()):
		var a: Array=points[i-1];var c: Array=points[i]
		travelled+=Vector2(c[0]-a[0],c[2]-a[2]).length()
		if travelled>=14:return points.slice(i)
	return points

static func monument(b: Node3D) -> void:
	var n:=K.holder(b,"ShawTitleStone",Vector3(64.5,G,-576.5))
	n.rotation.y=PI
	preload("res://world/visual_campus/ShawStoneGarden.gd").rock(n)
	var bed:=PackedVector3Array()
	for i in 32:
		var a:=TAU*float(i)/32;var c:=TAU*float(i+1)/32
		bed.append_array(K.quad(Vector3.ZERO+Vector3.UP*.14,Vector3(cos(a)*5.5,.14,sin(a)*1.85),Vector3(cos(c)*5.5,.14,sin(c)*1.85),Vector3.ZERO+Vector3.UP*.14))
	K.surface(n,bed,"5a6847",3)
	preload("res://world/visual_campus/ShawStoneGarden.gd").planting(n)
	var label:=K.label(n,"逸 夫 书 院",Vector3(0,1.12,.725),.012)
	label.modulate=Color("d8b33d")
	K.finish(n)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"ShawCornerLandscapeV50")
	var points: Array=[]
	# One east-to-west centreline joins rear road, Shaw corner and old square avenue.
	for route: Dictionary in builder.data.routes:
		if route.id=="shaw_corner_link":
			points=route.points.duplicate(true);points.reverse()
	for route: Dictionary in builder.data.routes:
		if route.id=="main_road":
			for p: Array in route.points:
				if float(p[2])>=-636 and (points.is_empty() or points.back()!=p):points.append(p)
	# Stone sidewalks precede the road surface, so crossing paths cannot tile over asphalt.
	builder.ribbon(b,points,23.0,"939591",26,.098)
	builder.ribbon(b,points,9.0,"414b4c",2,.126)
	var edged_points:=after_junction(points)
	for side in [-1,1]:
		var edge:=offset(edged_points,side*4.27)
		builder.ribbon(b,edge,.15,"e0ded2",22,.147)
		builder.ribbon(b,offset(edged_points,side*4.68),.27,"b9bab2",26,.152)
		builder.ribbon(b,offset(points,side*11.3),.22,"727c70",26,.132)
	markings(b,points,builder)
	# The rear road junction stays open: its asphalt and edge cross the end of our apron.
	var junction: Array=[]
	for route: Dictionary in builder.data.routes:
		if route.id=="library_rear_shaw_avenue":
			var last: Array=route.points.back();var previous: Array=route.points[-2]
			var end:=Vector3(last[0],G,last[2]);var approach:=Vector3(previous[0],G,previous[2])
			var p:=end.move_toward(approach,12)
			junction=[[p.x,G,p.z],last]
	for route: Dictionary in builder.data.routes:
		if route.id=="research_service":
			var a: Array=route.points[0];var c: Array=route.points[1]
			var p:=Vector3(c[0],G,c[2])
			junction.append([p.x,G,p.z])
	builder.ribbon(b,junction,6.0,"414b4c",2,.135)
	# Walk from the student frontage across to Shaw West; flush crossing, no curb barrier.
	var crossing:=K.holder(b,"ShawPedestrianCrossing",Vector3(56,G+.158,-585))
	crossing.rotation.y=PI/2
	for i in range(-4,5):K.box(crossing,Vector3(i*.96,0,0),Vector3(.52,.018,3.5),"e0ded2",false,22)
	K.finish(crossing)
	for z in [-591,-579]:
		K.box(b,Vector3(56,G+.13,z),Vector3(3.6,.03,1.0),"c5ac6d",false,26)
	# Low planted edges are outside both pavements and clear of the existing building shell.
	for p: Vector2 in [Vector2(29,-576),Vector2(9,-603),Vector2(77,-601),Vector2(98,-601)]:
		V.shrub(b,Vector3(p.x,G,p.y),Vector3(4,.65,3),absi(int(p.x*11+p.y)))
	# Anniversary built view: keep lawn, but add its planted tree margins.
	# Fitted sites stay away from the road, transverse path and west podium.
	for p:Vector2 in [Vector2(25,-615),Vector2(40,-621),Vector2(55,-615),Vector2(33,-640),Vector2(55,-641)]:
		var y:float=builder.height(p.x,p.y)
		K.tree(b,Vector3(p.x,y,p.y),10.2+float(absi(int(p.x))%3),18300+absi(int(p.x+p.y)),1.5)
		V.shrub(b,Vector3(p.x,y,p.y),Vector3(3.3,.48,2.8),18300+absi(int(p.x*2+p.y)))
	for p: Vector2 in [Vector2(37,-585),Vector2(13,-610),Vector2(76,-592)]:
		S.grate(b,p.x,p.y,PI/2)
	for p: Vector2 in [Vector2(28,-582),Vector2(2,-611),Vector2(84,-595)]:
		S.street_lamp(b,Vector3(p.x,G,p.y),1)
	monument(b)
	K.finish(b)
