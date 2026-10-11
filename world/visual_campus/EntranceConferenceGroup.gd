extends RefCounted
## V68: architect03/04 and May2026 map. This is the gate-right assembly group,
## not the pre-existing Shaw ICC. Metric footprint, levels and lake edge are fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const Site := preload("res://world/visual_campus/EastGatePortal.gd")

static func floor_rect(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.13,(z0+z1)/2),Vector3(x1-x0,.26,z1-z0),"a4a89e",true,22)
	K.box(n,Vector3((x0+x1)/2,y+.008,(z0+z1)/2),Vector3(x1-x0,.016,z1-z0),"919990",false,26)

static func cylinder(n: Node3D,p: Vector3,r: float,h: float) -> void:
	var m:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.radial_segments=24;m.mesh=mesh;m.position=p;m.material_override=K.material("b5bab0",22);n.add_child(m)
	var body:=StaticBody3D.new();body.position=p;n.add_child(body)
	var c:=CollisionShape3D.new();var s:=CylinderShape3D.new();s.radius=r;s.height=h;c.shape=s;body.add_child(c)

static func glass_wall(n: Node3D,a: Vector3,c: Vector3,h: float,door: bool=false) -> void:
	var delta:=c-a;var length:=delta.length();var count:=ceili(length/1.5);var yaw:=atan2(delta.x,delta.z)
	for i in count:
		var u: float=(i+.5)/count;var p:=a.lerp(c,u)
		if door and absf(u-.5)<.11:continue
		K.box(n,p+Vector3.UP*h/2,Vector3(.10,h,length/count+.02),"6c8883",true,19,yaw)
		K.box(n,a.lerp(c,float(i)/count)+Vector3.UP*h/2,Vector3(.12,h,.12),"a8b6ad",false,22)
	K.box(n,(a+c)/2+Vector3.UP*(h-.12),Vector3(.20,.24,length),"aab3a8",false,22,yaw)

static func assembly(n: Node3D) -> void:
	preload("res://world/visual_campus/AssemblyHall.gd").build(n)

static func terrace(n: Node3D,y: float) -> void:
	# Three strips leave the entire spiral well genuinely open.
	floor_rect(n,95,99.5,-34,-15,y)
	floor_rect(n,108.5,122,-34,-15,y)
	floor_rect(n,99.5,108.5,-34,-28.5,y)
	floor_rect(n,99.5,108.5,-19.5,-15,y)
	# Radial arrival tongue touches the stair's end, rather than capping its well.
	floor_rect(n,107,108.6,-25.05,-22.95,y)
	P.rail(n,Vector3(99.5,y,-15),Vector3(122,y,-15))
	for span: Vector2 in [Vector2(95,106),Vector2(112,122)]:P.rail(n,Vector3(span.x,y,-34),Vector3(span.y,y,-34))
	P.rail(n,Vector3(122,y,-34),Vector3(122,y,-15))
	for seg: Array in [[Vector3(99.5,y,-28.5),Vector3(108.5,y,-28.5)],[Vector3(99.5,y,-28.5),Vector3(99.5,y,-19.5)],[Vector3(99.5,y,-19.5),Vector3(108.5,y,-19.5)],[Vector3(108.5,y,-28.5),Vector3(108.5,y,-25.1)],[Vector3(108.5,y,-22.9),Vector3(108.5,y,-19.5)]]:P.rail(n,seg[0],seg[1])

static func spiral_point(angle: float,r: float,y: float) -> Vector3:
	return Vector3(104+cos(angle)*r,y,-24+sin(angle)*r)

static func spiral(n: Node3D) -> void:
	# Architect04: two open flights with a continuous opaque helical edge.
	for turn in 2:
		var base: float=turn*4.4
		for i in 32:
			var a: float=i*TAU/32;var c: float=(i+1)*TAU/32
			var ya: float=base+4.4*i/32;var yc: float=base+4.4*(i+1)/32
			var ramp:=K.surface(n,K.quad(spiral_point(a,2,ya+.045),spiral_point(a,4,ya+.045),spiral_point(c,4,yc+.045),spiral_point(c,2,yc+.045)),"a3aaa0",26,true);ramp.hide()
			K.surface(n,K.quad(spiral_point(a,2,yc),spiral_point(a,4,yc),spiral_point(c,4,yc),spiral_point(c,2,yc)),"a5aea5",26)
			var riser:=K.quad(spiral_point(a,2,ya),spiral_point(a,4,ya),spiral_point(a,4,yc),spiral_point(a,2,yc))
			var back:=PackedVector3Array()
			for j in range(riser.size()-1,-1,-1):back.append(riser[j])
			riser.append_array(back);K.surface(n,riser,"939e96",22)
			for r in [2.0,4.0]:
				if r>3 and (i<2 or i>=30):continue # Real radial landing opening in the outer parapet.
				var p:=spiral_point(a,r,ya);var q:=spiral_point(c,r,yc)
				var panel:=K.quad(p,q,q+Vector3.UP*1.08,p+Vector3.UP*1.08)
				var reverse:=PackedVector3Array()
				for j in range(panel.size()-1,-1,-1):reverse.append(panel[j])
				panel.append_array(reverse);K.surface(n,panel,"b7c1bc",22)
				# Short physical guard follows the same slope and stops either travel direction.
				var guard:=StaticBody3D.new();guard.position=(p+q)/2+Vector3.UP*.54;n.add_child(guard)
				guard.rotation=Vector3(-atan2(q.y-p.y,Vector2(q.x-p.x,q.z-p.z).length()),atan2(q.x-p.x,q.z-p.z),0)
				var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(.10,1.08,p.distance_to(q)+.025);collision.shape=shape;guard.add_child(collision)

static func curved_link(n: Node3D) -> void:
	# Bowed glass connection across the upper court, with an open roof terrace.
	for i in 20:
		var t: float=float(i)/20;var u: float=float(i+1)/20
		var a:=Vector3(90+sin(t*PI)*3.8,13.2,-15-t*19)
		var c:=Vector3(90+sin(u*PI)*3.8,13.2,-15-u*19)
		for y in [0.0,3.5]:
			K.surface(n,K.quad(a+Vector3(-2,y,0),a+Vector3(2,y,0),c+Vector3(2,y,0),c+Vector3(-2,y,0)),"b0b8ac",22,true)
		for side in [-1,1]:
			glass_wall(n,a+Vector3(side*2,.5,0),c+Vector3(side*2,.5,0),2.4)
			for h in [.25,3.25]:
				var d:=c-a;K.box(n,(a+c)/2+Vector3(side*2,h,0),Vector3(.24,.5,d.length()+.04),"b6beb4",true,22,atan2(d.x,d.z))
			P.rail(n,a+Vector3(side*2,3.5,0),c+Vector3(side*2,3.5,0))

static func conference_tower(n: Node3D) -> void:
	# Lake-side tower is separate from the existing gateway tower and old ICC.
	var b:=K.holder(n,"LakeConferenceTower",Vector3(109,0,-55));b.scale.z=.60;var top:=39.6
	for y in [0.0,4.4,8.8,13.2,17.6,22.0,26.4,30.8,35.2,39.6]:K.box(b,Vector3(0,y-.13,0),Vector3(26,.26,24),"b7bbae",true,22)
	for z in [-12.0,12.0]:
		for span: Vector2 in [Vector2(-13,-3),Vector2(3,13)]:K.box(b,Vector3((span.x+span.y)/2,6.6,z),Vector3(span.y-span.x,13.2,.30),"b0b8a8",true,0)
		K.box(b,Vector3(0,12.05,z),Vector3(6,2.3,.30),"b0b8a8",true,0)
		K.box(b,Vector3(0,(top+17.6)/2,z),Vector3(26,top-17.6,.30),"b7beb0",true,0)
		for y in [19.7,24.1,28.5,32.9]:
			for x in [-8.0,-2.0,4.0]:K.window(b,Vector3(x,y,z+signf(z)*.20),1.3,2.4,PI if z<0 else 0)
	for x in [-13.0,13.0]:
		glass_wall(b,Vector3(x,0,-12),Vector3(x,0,12),4.1,true)
		# Upper lake face; an open framed gallery occupies the two levels below it.
		for f in 5:
			var y: float=17.6+f*4.4
			K.box(b,Vector3(x,y+2.2,0),Vector3(.30,4.4,24),"b7beb0",true,0)
			for z in [-8.0,-2.0,4.0,9.0]:
				for dz in [-.62,.62]:K.window(b,Vector3(x+signf(x)*.20,y+2.05,z+dz),.85,2.65,signf(x)*PI/2)
	for z in [-10.6,10.6]:cylinder(b,Vector3(12,8.8,z),.65,17.6)
	for y in [4.4,8.8,13.2]:P.rail(b,Vector3(13.1,y,-11),Vector3(13.1,y,11))
	K.finish(b)

static func build(b: Node3D,builder) -> void:
	var n:=K.holder(b,"AssemblyHallRegistered");n.transform=b.transform.affine_inverse()
	assembly(n)
	for y in [4.4,8.8]:
		floor_rect(n,95,99.5,-15,13,y)
		P.rail(n,Vector3(99.5,y,-15),Vector3(99.5,y,13))
		P.rail(n,Vector3(95,y,13),Vector3(99.5,y,13))
	floor_rect(n,95,99.5,-15,18,0)
	K.finish(n)

static func build_conference(b: Node3D,builder) -> void:
	var frame:=K.holder(b,"CxIIPlanRegistration");frame.transform=b.transform.affine_inverse()
	var n:=K.holder(frame,"ConferenceIIPublicCourt",Vector3(50,2.24,-7.2));n.scale=Vector3(.8,1,.8)
	floor_rect(n,80,124,-66,-15,0)
	terrace(n,4.4);terrace(n,8.8);spiral(n);curved_link(n);conference_tower(n)
	for p in [Vector3(120,4.4,-17),Vector3(120,4.4,-32),Vector3(97,4.4,-32)]:cylinder(n,p,.34,8.8)
	for y in [4.4,8.8]:K.box(n,Vector3(108.5,y-.30,-15),Vector3(27,.40,.30),"aeb6aa",false,22)
	floor_rect(n,80,95,-36,-15,8.8)
	P.rail(n,Vector3(80,8.8,-36),Vector3(80,8.8,-15))
	P.rail(n,Vector3(80,8.8,-36),Vector3(95,8.8,-36))
	P.stair(n,Vector3(85,8.8,-33),Vector3(85,13.2,-15),3.2)
	floor_rect(n,83,94,-15,-11,13.2)
	P.rail(n,Vector3(83,13.2,-11),Vector3(94,13.2,-11))
	floor_rect(n,88,110,-49,-34,13.2)
	P.rail(n,Vector3(88,13.2,-49),Vector3(88,13.2,-34))
	# L-shaped low conference wing behind the public court, supported by the 1F plan.
	for y in [4.4,8.8,13.2]:floor_rect(n,80,101,-66,-39,y)
	for x in [80.0,101.0]:
		K.box(n,Vector3(x,6.6,-52.5),Vector3(.30,13.2,27),"b9c1b3",true,0)
		for y in [2.2,6.6,11.0]:
			for z in range(-64,-39,4):K.window(n,Vector3(x+signf(x-90)*.18,y,z),1.8,2.25,signf(x-90)*PI/2)
	for z in [-66.0,-39.0]:
		for span:Vector2 in [Vector2(80,87),Vector2(93,101)]:glass_wall(n,Vector3(span.x,0,z),Vector3(span.y,0,z),4.1)
		K.box(n,Vector3(90.5,9,z),Vector3(21,8.4,.25),"b9c1b3",true,0)
	K.box(n,Vector3(90.5,13.42,-52.5),Vector3(20,.12,26),"667d48",false,3)
	# Lake-side low wing and warm window strip from the built photo.
	K.box(n,Vector3(117.5,13.3,-24.5),Vector3(9,9,19),"b8bfb3",true,0)
	K.box(n,Vector3(122.1,10.8,-24.5),Vector3(.12,3.8,17),"9c6b41",false,20)
	for z in range(-32,-16):K.box(n,Vector3(122.25,10.8,z),Vector3(.15,3.8,.06),"c6c8b6",false,22)
	K.box(n,Vector3(117.5,17.85,-24.5),Vector3(8,.10,18),"647f43",false,3)
	K.finish(n)
