extends RefCounted
## V70: architect section070/elevation038/aerial067 (published 2025-12-24).
## Fitted public section, not surveyed levels or a certified seating plan.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")

static func roof_y(x: float) -> float:
	var t:=clampf((x-44)/53.4,0,1)
	return 23.6-3.4*t+.35*sin(PI*t)

static func two_sided(vertices: PackedVector3Array) -> PackedVector3Array:
	var out:=vertices.duplicate()
	for i in range(vertices.size()-1,-1,-1):out.append(vertices[i])
	return out

static func panel(n: Node3D,a: Vector3,b: Vector3,c: Vector3,d: Vector3,color: String,kind: int,solid: bool=false) -> void:
	K.surface(n,two_sided(K.quad(a,b,c,d)),color,kind,solid)

static func floor_rect(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float,kind: int=26) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.13,(z0+z1)/2),Vector3(x1-x0,.26,z1-z0),"a4a89e",true,22)
	K.box(n,Vector3((x0+x1)/2,y+.008,(z0+z1)/2),Vector3(x1-x0,.016,z1-z0),"929a8f",false,kind)

static func beam(n: Node3D,a: Vector3,c: Vector3,w: float,h: float,color: String="bec4b7") -> void:
	var holder:=K.holder(n,"SectionMember",(a+c)/2)
	var d:=c-a;holder.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),atan2(d.x,d.z),0)
	K.box(holder,Vector3.ZERO,Vector3(w,h,d.length()),color,false,22);K.finish(holder)

static func glass(n: Node3D,a: Vector3,c: Vector3,h: float,door: bool=false) -> void:
	var count:=ceili(a.distance_to(c)/1.5)
	for i in count:
		var u:float=(i+.5)/count
		if door and absf(u-.5)<.11:continue
		var p:=a.lerp(c,float(i)/count);var q:=a.lerp(c,float(i+1)/count)
		panel(n,p,q,q+Vector3.UP*h,p+Vector3.UP*h,"6c8883",19,true)
		beam(n,p,p+Vector3.UP*h,.09,.09)
	beam(n,a+Vector3.UP*(h-.1),c+Vector3.UP*(h-.1),.16,.2)

static func roof(n: Node3D) -> void:
	# Real skylight openings through both green surface and roof underside.
	var xs:Array[float]=[44,97.4];var zs:Array[float]=[-15,13];var holes:Array[Rect2]=[]
	for x in range(50,92,7):
		for z in range(-10,11,5):holes.append(Rect2(x-2.3,z-1.4,4.6,2.8))
	for r in holes:
		for x in [r.position.x,r.end.x]:
			if not xs.has(x):xs.append(x)
		for z in [r.position.y,r.end.y]:
			if not zs.has(z):zs.append(z)
	xs.sort();zs.sort();var verts:=PackedVector3Array();var soffit:=PackedVector3Array()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var centre:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2);var skip:=false
			for r in holes:
				if r.has_point(centre):skip=true;break
			if skip:continue
			var q:=K.quad(Vector3(xs[i],roof_y(xs[i]),zs[j]),Vector3(xs[i+1],roof_y(xs[i+1]),zs[j]),Vector3(xs[i+1],roof_y(xs[i+1]),zs[j+1]),Vector3(xs[i],roof_y(xs[i]),zs[j+1]))
			verts.append_array(q)
			for k in range(q.size()-1,-1,-1):soffit.append(q[k]+Vector3.DOWN*.38)
	K.surface(n,verts,"67804a",3,true);K.surface(n,soffit,"c9ccbf",22)
	for r in holes:
		var x0:=r.position.x;var x1:=r.end.x;var z0:=r.position.y;var z1:=r.end.y
		var a:=Vector3(x0,roof_y(x0)+.06,z0);var b:=Vector3(x1,roof_y(x1)+1.25,z0)
		panel(n,a,b,Vector3(b.x,b.y,z1),Vector3(a.x,a.y,z1),"8a9d96",19)
		panel(n,Vector3(x1,roof_y(x1)-.38,z0),Vector3(x1,roof_y(x1)-.38,z1),Vector3(b.x,b.y,z1),b,"b1926a",22)
		for z in [z0,z1]:
			var tri:=PackedVector3Array([Vector3(x0,roof_y(x0)+.06,z),Vector3(x1,roof_y(x1)-.38,z),Vector3(x1,roof_y(x1)+1.25,z)])
			K.surface(n,two_sided(tri),"b1926a",22)
		for z in [z0,z1]:beam(n,Vector3(a.x,a.y,z),Vector3(b.x,b.y,z),.06,.07,"b8b7a4")
	for z in [-15.0,13.0]:
		for i in 12:
			var x0:float=44+i*53.4/12;var x1:float=44+(i+1)*53.4/12
			panel(n,Vector3(x0,roof_y(x0)-.4,z),Vector3(x1,roof_y(x1)-.4,z),Vector3(x1,roof_y(x1)+.35,z),Vector3(x0,roof_y(x0)+.35,z),"bfc5b6",0)
	for x in range(48,96,6):
		beam(n,Vector3(x,roof_y(x)-.8,-14.5),Vector3(x,roof_y(x)-.8,12.5),.22,.7)
	for z in range(-13,13,3):beam(n,Vector3(45,roof_y(45)-.6,z),Vector3(96,roof_y(96)-.6,z),.12,.22)

static func envelope(n: Node3D) -> void:
	# Close the shared tower end; its detailed core doors await the upper-floor plan.
	K.box(n,Vector3(44.85,16.2,-1),Vector3(.24,14.8,28),"b8bfb3",true,0)
	K.box(n,Vector3(45.0,17.2,-1),Vector3(.04,9.0,24),"b39b77",false,4)
	for z in [-15.0,13.0]:
		for i in 12:
			var x0:float=44+i*51.0/12;var x1:float=44+(i+1)*51.0/12
			panel(n,Vector3(x0,8.8,z),Vector3(x1,8.8,z),Vector3(x1,roof_y(x1),z),Vector3(x0,roof_y(x0),z),"b8bfb3",0,true)
		K.surface(n,two_sided(PackedVector3Array([Vector3(95,8.8,z),Vector3(97.4,roof_y(97.4),z),Vector3(95,roof_y(95),z)])),"b8bfb3",0,true)
		# Street drawing: opaque lower half gives way to glass toward the lake.
		K.box(n,Vector3(56.5,4.4,z),Vector3(25,8.8,.3),"b8bfb3",true,0)
		for x in range(47,68,2):
			for y in [5.8,7.4]:K.window(n,Vector3(x,y,z+signf(z)*.18),.45,.66,PI if z<0 else 0)
		for x in [50.0,55.5,62.0]:K.window(n,Vector3(x,4.2,z+signf(z)*.18),4.3,.65,PI if z<0 else 0)
		for y in [0.0,4.4]:glass(n,Vector3(69,y,z),Vector3(95,y,z),4.1,z>0 and y==0)
	for y in [0.0,4.4]:glass(n,Vector3(95,y,-15),Vector3(95,y,13),4.1,true)
	# Inclined lake glazing rises outwards, following section070.
	for i in 19:
		var z0:float=-15+i*28.0/19;var z1:float=-15+(i+1)*28.0/19
		var a:=Vector3(95,8.8,z0);var b:=Vector3(95,8.8,z1);var c:=Vector3(97.4,20.2,z1);var d:=Vector3(97.4,20.2,z0)
		panel(n,a,b,c,d,"728981",19,true);beam(n,a,d,.17,.2)
		beam(n,Vector3(95,8.6,z0),Vector3(99.4,8.6,z0),.15,.20)
	for y in [11.5,14.3,17.1,20.0]:
		var x:float=95+(y-8.8)/11.4*2.4
		beam(n,Vector3(x,y,-15),Vector3(x,y,13),.13,.14)
	# Simple exposed V members below the leaning front, visible in the section.
	for z in [-11.0,-1.0,9.0]:
		beam(n,Vector3(94.2,4.5,z),Vector3(95,8.65,z-1.8),.3,.3)
		beam(n,Vector3(94.2,4.5,z),Vector3(95,8.65,z+1.8),.3,.3)

static func seating(n: Node3D) -> void:
	# Tier geometry, row count and seat positions are fitted, not claimed capacity.
	for i in 14:
		var x:float=76-i*1.7;var y:float=8.8+(i+1)*.36
		for span in [Vector2(-10,-1.6),Vector2(-.2,8)]:
			K.box(n,Vector3(x,(y+8.65)/2,(span.x+span.y)/2),Vector3(1.7,y-8.65,span.y-span.x),"b1aaa0",true,22)
		for z in [-8.8,-7.6,-6.4,-5.2,-4.0,-2.8,1.0,2.2,3.4,4.6,5.8,7.0]:
			K.box(n,Vector3(x+.10,y+.42,z),Vector3(.7,.17,.65),"b0a590",true,22)
			K.box(n,Vector3(x-.25,y+.8,z),Vector3(.14,.74,.65),"a99f8c",true,22)
			for dz in [-.38,.38]:K.box(n,Vector3(x+.04,y+.55,z+dz),Vector3(.72,.08,.07),"8b7354",false,4)
	# Fine steps between seat platforms, with continuous physical slope for movement.
	for z in [-11.5,-.9,9.8]:
		var width:float=1.4 if z<1 and z> -2 else 2.3
		var a:=Vector3(79,8.8,z);var b:=Vector3(50.8,14.2,z)
		var ramp:=K.surface(n,K.quad(a+Vector3(0,.04,-width/2),b+Vector3(0,.065,-width/2),b+Vector3(0,.065,width/2),a+Vector3(0,.04,width/2)),"aaa393",22,true);ramp.hide()
		panel(n,a+Vector3(0,-.25,-width/2),b+Vector3(0,-.25,-width/2),b+Vector3(0,-.25,width/2),a+Vector3(0,-.25,width/2),"a6a396",22)
		for i in 30:
			var x:float=79-(i+.5)*28.2/30;var y:float=8.8+(i+1)*5.4/30
			K.box(n,Vector3(x,y-.12,z),Vector3(28.2/30,.24,width),"a6a396",false,22)
	floor_rect(n,46,50.8,-13,11.8,14.2)
	for span in [Vector2(-10,-1.6),Vector2(-.2,8)]:floor_rect(n,50.8,53.05,span.x,span.y,14.2)
	P.rail(n,Vector3(46,14.2,11.8),Vector3(50.8,14.2,11.8))
	P.rail(n,Vector3(46,14.2,-13),Vector3(50.8,14.2,-13))
	# Warm acoustic lining stays inside the opaque envelope.
	for z in [-14.7,12.7]:
		for x in range(48,84,2):
			var bottom:float=14.5 if x<60 else 10.5
			K.box(n,Vector3(x,(bottom+19.0)/2,z),Vector3(1.85,19-bottom,.08),"ae936b",false,4)
	# Flat front floor is kept clear; exact stage equipment has no source yet.
	K.box(n,Vector3(86,8.827,-1),Vector3(12,.02,16),"b59b75",false,4)

static func build(n: Node3D) -> void:
	floor_rect(n,44,95,-15,13,0)
	floor_rect(n,44,88.2,-15,13,4.4);floor_rect(n,91.8,95,-15,13,4.4);floor_rect(n,88.2,91.8,-15,-8,4.4)
	# Upper stair well is separate from the lower flight; no solid slab above it.
	floor_rect(n,44,83.2,-15,13,8.8);floor_rect(n,86.8,95,-15,13,8.8)
	floor_rect(n,83.2,86.8,-15,-8,8.8);floor_rect(n,83.2,86.8,11,13,8.8)
	P.stair(n,Vector3(90,0,11),Vector3(90,4.4,-8),3.2)
	for x in [88.2,91.8]:P.rail(n,Vector3(x,4.4,-8),Vector3(x,4.4,13))
	P.stair(n,Vector3(85,4.4,-8),Vector3(85,8.8,11),3.2)
	for x in [83.2,86.8]:P.rail(n,Vector3(x,8.8,-8),Vector3(x,8.8,11))
	envelope(n);roof(n);seating(n)
