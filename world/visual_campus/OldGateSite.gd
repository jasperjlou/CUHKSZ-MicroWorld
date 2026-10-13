extends RefCounted
## V217 official70013462 f/r/b/l: entrance beside blades, stone DaoYuan forecourt,
## and transverse city street outside the boundary. Metres and end transitions fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const S=preload("res://world/visual_campus/StartZoneLandscape.gd")
const G:=2.24

static func street(n:Node3D,builder,route:Dictionary)->void:
	var points:Array=route.points;var widths:Array=route.surface_widths;var sides:Array[Vector3]=[]
	for i in points.size():
		var a:Vector3=builder.point(points[maxi(0,i-1)]);var p:Vector3=builder.point(points[i]);var b:Vector3=builder.point(points[mini(i+1,points.size()-1)])
		var incoming:Vector3=(p-a).normalized() if i>0 else (b-p).normalized()
		var outgoing:Vector3=(b-p).normalized() if i<points.size()-1 else incoming
		var n1:=Vector3(incoming.z,0,-incoming.x);var n2:=Vector3(outgoing.z,0,-outgoing.x)
		var m:Vector3=(n1+n2).normalized();sides.append(m*float(widths[i])*.5/maxf(.62,m.dot(n2)))
	var verts:=PackedVector3Array()
	for i in points.size()-1:
		var a:Vector3=builder.point(points[i]);var b:Vector3=builder.point(points[i+1]);var count:=maxi(1,ceili(a.distance_to(b)/2))
		for j in count:
			var p:=a.lerp(b,float(j)/count);var q:=a.lerp(b,float(j+1)/count)
			var u:=sides[i].lerp(sides[i+1],float(j)/count);var v:=sides[i].lerp(sides[i+1],float(j+1)/count)
			var corners:Array[Vector3]=[p-u,p+u,q+v,q-v]
			for c in 4:corners[c].y=builder.height(corners[c].x,corners[c].z)+.035
			verts.append_array(K.quad(corners[0],corners[1],corners[2],corners[3]))
		for j in range(3,int(a.distance_to(b))-2,9):
			var p:=a.lerp(b,float(j)/a.distance_to(b))
			if absf(p.z+790)<19:continue
			K.box(n,Vector3(p.x,builder.height(p.x,p.z)+.052,p.z),Vector3(.12,.012,3),"c3ad58",false,22,atan2(b.x-a.x,b.z-a.z))
	K.surface(n,verts,"505652",32)

static func hatch(n:Node3D)->void:
	# Yellow box is visible on the road-facing panorama. Extents remain fitted.
	for x:float in [-207.6,-194.4]:K.box(n,Vector3(x,G+.057,-790),Vector3(.10,.015,29),"c4aa57",false,22)
	for z:float in [-804.5,-775.5]:K.box(n,Vector3(-201,G+.057,z),Vector3(13.2,.015,.10),"c4aa57",false,22)
	for direction:float in [-1,1]:
		for station in range(-22,23,4):
			# Clip diagonal endpoints to the rectangle, rather than paint over its pavement.
			var lo:=maxf(-6.6,(-14.5-station)*direction if direction>0 else (14.5-station)*direction)
			var hi:=minf(6.6,(14.5-station)*direction if direction>0 else (-14.5-station)*direction)
			if hi<=lo:continue
			var a:=Vector2(-201+lo,-790+station+direction*lo);var b:=Vector2(-201+hi,-790+station+direction*hi);var delta:=b-a
			K.box(n,Vector3((a.x+b.x)/2,G+.057,(a.y+b.y)/2),Vector3(.09,.015,delta.length()),"c4aa57",false,22,atan2(delta.x,delta.y))

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"OldGateSiteV217")
	for route:Dictionary in builder.data.routes:
		if route.id=="south_perimeter":street(n,builder,route)
	# The retired inboard asphalt strip is stone forecourt, not a road through the booth.
	for span:Vector2 in [Vector2(-840,-794),Vector2(-786,-624)]:
		K.box(n,Vector3(-174,G+.04,(span.x+span.y)/2),Vector3(7.2,.12,span.y-span.x),"969b90",true,26)
	# Photo r-face has a joined stone forecourt up to the existing stair-foot pavement.
	# Fill only the seam between the two authored walks, not the planted raised bank.
	K.box(n,Vector3(-168.7,G+.065,-733),Vector3(3.4,.03,58),"a8aa9b",false,26)
	# Extend the existing clock-end lane to the outside street and support its visible top.
	K.box(n,Vector3(-87,G+.088,-790),Vector3(174,.184,8),"414b4c",true,32)
	K.box(n,Vector3(-187,G+.015,-790),Vector3(14,.04,8),"414b4c",true,32)
	# Grade inside the gate; the city street remains level across its yellow box.
	K.surface(n,K.quad(Vector3(-180,G+.035,-794),Vector3(-174,G+.18,-794),Vector3(-174,G+.18,-786),Vector3(-180,G+.035,-786)),"414b4c",32,true)
	# Public sidewalk stays outside the boundary planting and meets the gate mouth.
	for span:Vector2 in [Vector2(-840,-796),Vector2(-784,-640)]:
		K.box(n,Vector3(-191.7,G+.0325,(span.x+span.y)/2),Vector3(4.0,.075,span.y-span.x),"a3a698",true,26)
		K.box(n,Vector3(-193.83,G+.07,(span.x+span.y)/2),Vector3(.22,.14,span.y-span.x),"b4b8aa",true,15)
	for ends:Vector4 in [Vector4(-796,.07,-794,.035),Vector4(-786,.035,-784,.07)]:
		K.surface(n,K.quad(Vector3(-193.7,G+ends.y,ends.x),Vector3(-189.7,G+ends.y,ends.x),Vector3(-189.7,G+ends.w,ends.z),Vector3(-193.7,G+ends.w,ends.z)),"a3a698",26,true)
	# Fill the open gate's side forecourt without extending stone across its driveway.
	for span:Vector2 in [Vector2(-820,-796),Vector2(-784,-766)]:
		K.box(n,Vector3(-186.5,G+.055,(span.x+span.y)/2),Vector3(6.5,.03,span.y-span.x),"a3a698",false,26)
	for z:float in [-795,-785]:
		K.box(n,Vector3(-186.5,G+.02,z),Vector3(6.5,.02,2),"a3a698",false,26)
	# Opposite sidewalk seen in the outward panorama; beyond it remains unregistered.
	builder.ribbon(n,[[-211.4,G,-840],[-211.4,G,-640]],4.2,"9ba193",26,.065)
	K.box(n,Vector3(-208.6,G+.022,-740),Vector3(1.4,.016,200),"8e9788",false,15)
	for z in [-825,-747,-689,-652]:S.street_lamp(n,Vector3(-213.5,G,z),-1)
	hatch(n);K.finish(n)
