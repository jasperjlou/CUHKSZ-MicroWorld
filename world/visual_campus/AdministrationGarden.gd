extends RefCounted
## V71 official hill panorama116443781/resource70040625. Capture date unknown.
## Pavilion/stepped-stone walk observed; hexagonal plan, coordinates and grades fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const CENTRE := Vector3(152,16.44,-180)

static func profile(x: float) -> float:
	var keys: Array[Vector2]=[Vector2(117,14.64),Vector2(126,14.64),Vector2(129,15.24),Vector2(135,15.24),Vector2(138,15.84),Vector2(144,15.84),Vector2(147,16.44),Vector2(162,16.44)]
	for i in range(keys.size()-1):
		if x<=keys[i+1].x:return lerpf(keys[i].y,keys[i+1].y,clampf((x-keys[i].x)/(keys[i+1].x-keys[i].x),0,1))
	return 16.44

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<117 or x>177 or z< -197 or z> -158:return base
	var w:float=smoothstep(117,121,x)*(1-smoothstep(164,177,x))*smoothstep(-197,-190,z)*(1-smoothstep(-170,-158,z))
	return lerpf(base,profile(x),w)

static func path(n: Node3D,x0: float,x1: float,y: float,width: float=2.6) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.05,-180),Vector3(x1-x0,.22,width),"818b85",true,26)
	for z in [-181.35,-178.65]:K.box(n,Vector3((x0+x1)/2,y+.075,z),Vector3(x1-x0,.03,.1),"92998d",false,22)

static func short_stair(n: Node3D,x0: float,x1: float,y0: float,y1: float) -> void:
	var count:=maxi(2,ceili((y1-y0)/.15))
	for i in count:
		var x:float=lerpf(x0,x1,(i+.5)/count);var y:float=lerpf(y0,y1,float(i+1)/count)
		K.box(n,Vector3(x,y-.09,-180),Vector3((x1-x0)/count+.012,.18,2.6),"9ca299",false,26)
		if i==0 or i==count-1:K.box(n,Vector3(x-(x1-x0)/count/2+.035,y+.008,-180),Vector3(.065,.016,2.54),"c2a344",false,22)
	var ramp:=K.surface(n,K.quad(Vector3(x0,y0+.04,-181.3),Vector3(x1,y1+.065,-181.3),Vector3(x1,y1+.065,-178.7),Vector3(x0,y0+.04,-178.7)),"969c90",26,true);ramp.hide()

static func polygon_floor(n: Node3D,y: float,r: float) -> void:
	var top:=PackedVector3Array();var edges:=PackedVector3Array()
	for i in 6:
		var a:=Vector3(cos(PI/6+i*TAU/6)*r,y,sin(PI/6+i*TAU/6)*r)
		var b:=Vector3(cos(PI/6+(i+1)*TAU/6)*r,y,sin(PI/6+(i+1)*TAU/6)*r)
		top.append_array(K.quad(Vector3(0,y,0),a,b,Vector3(0,y,0)))
		var q:=K.quad(a,b,b+Vector3.DOWN*.32,a+Vector3.DOWN*.32)
		var rev:=q.duplicate();rev.reverse();edges.append_array(q);edges.append_array(rev)
	K.surface(n,top,"adae9f",26,true);K.surface(n,edges,"a0a495",26,true)

static func cylinder(n: Node3D,p: Vector3,r: float,h: float,color: String,solid: bool=false) -> void:
	var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.radial_segments=20
	var m:=MeshInstance3D.new();m.mesh=mesh;m.position=p;m.material_override=K.material(color,22);n.add_child(m)
	if solid:m.create_convex_collision()

static func bar(n: Node3D,a: Vector3,b: Vector3,width: float,height: float,color: String) -> void:
	var d:=b-a;K.box(n,(a+b)/2,Vector3(width,height,d.length()),color,false,22,atan2(d.x,d.z))

static func pavilion(parent: Node3D) -> void:
	var n:=K.holder(parent,"HillRedColumnPavilion",CENTRE)
	polygon_floor(n,.15,3.9);polygon_floor(n,.30,3.6)
	var posts:Array[Vector3]=[]
	for i in 6:
		var a:float=PI/6+i*TAU/6;var p:=Vector3(cos(a)*3.05,0,sin(a)*3.05);posts.append(p)
		cylinder(n,p+Vector3.UP*1.85,.18,3.10,"823b34",true)
		cylinder(n,p+Vector3.UP*.42,.25,.24,"adae9f")
	for i in 6:
		var a:=posts[i];var b:=posts[(i+1)%6];var d:=b-a
		for h in [2.7,3.28]:bar(n,a+Vector3.UP*h,b+Vector3.UP*h,.15,.18,"783b32")
		# The photographed warm lattice band is an open structure above the columns.
		for j in 8:
			var p:=a.lerp(b,(j+.5)/8);K.box(n,p+Vector3.UP*2.99,Vector3(.05,.54,.05),"b79561",false,22)
		for h in [2.87,3.09]:bar(n,a+Vector3.UP*h,b+Vector3.UP*h,.06,.05,"b79561")
		if i!=2 and i!=5:
			bar(n,a+Vector3.UP*.78,b+Vector3.UP*.78,.48,.14,"854b37")
	# Six curved roof sectors, tiled ridges and raised eave corners.
	var surface:=PackedVector3Array();var underside:=PackedVector3Array()
	var rings:Array[Vector2]=[Vector2(.12,5.0),Vector2(.75,4.65),Vector2(1.8,4.03),Vector2(3.0,3.60),Vector2(4.25,3.72)]
	for sector in 6:
		var va:=Vector3(cos(PI/6+sector*TAU/6),0,sin(PI/6+sector*TAU/6))
		var vb:=Vector3(cos(PI/6+(sector+1)*TAU/6),0,sin(PI/6+(sector+1)*TAU/6))
		for band in range(rings.size()-1):
			for j in 12:
				var u:float=float(j)/12;var v:float=float(j+1)/12
				var pts:Array[Vector3]=[]
				for pair in [Vector2(u,band),Vector2(v,band),Vector2(v,band+1),Vector2(u,band+1)]:
					var rr:=rings[int(pair.y)];var corner:float=pow(absf(pair.x-.5)*2,4)*maxf(0,(rr.x-3)/1.25)*.32
					pts.append(va.lerp(vb,pair.x)*rr.x+Vector3.UP*(rr.y+corner))
				var q:=K.quad(pts[0],pts[1],pts[2],pts[3]);surface.append_array(q)
				for k in range(q.size()-1,-1,-1):underside.append(q[k]+Vector3.DOWN*.12)
				# Thin relief ribs read as grey tile runs without separate runtime objects.
				var a:=pts[0]+Vector3.UP*.025;var b:=pts[3]+Vector3.UP*.025
				var mid:=(a+b)/2;var d:=b-a
				var h:=K.holder(n,"TileRib",mid);h.rotation=Vector3(-atan2(d.y,Vector2(d.x,d.z).length()),atan2(d.x,d.z),0)
				K.box(h,Vector3.ZERO,Vector3(.045,.045,d.length()),"596058",false,22);K.finish(h)
	K.surface(n,surface,"6f7668",22,true);K.surface(n,underside,"684736",22,true)
	cylinder(n,Vector3(0,5.13,0),.25,.3,"627366",true)
	var sphere:=MeshInstance3D.new();var sm:=SphereMesh.new();sm.radius=.28;sm.height=.56;sphere.mesh=sm;sphere.position=Vector3(0,5.52,0);sphere.material_override=K.material("617366",22);n.add_child(sphere)
	cylinder(n,Vector3(0,5.9,0),.07,.4,"627366")
	K.finish(n)

static func rock(n: Node3D,p: Vector3,size: Vector3,seed: int) -> void:
	var mesh:=SphereMesh.new();mesh.radius=1;mesh.height=2;mesh.radial_segments=7;mesh.rings=4
	var m:=MeshInstance3D.new();m.mesh=mesh;m.position=p;m.scale=size;m.rotation=Vector3(.2,seed*.7,.13);m.material_override=K.material("8e8e7a",22);n.add_child(m)

static func build(root: Node3D,builder) -> void:
	var n:=K.holder(root,"AdministrationHillGarden")
	# Match the established ground route; enough visual clearance for triangulated slopes.
	for r:Dictionary in builder.data.routes:
		if r.id=="admin_garden_service_link":
			builder.ribbon(n,r.points,3.2,"818b85",26,.16)
			# Close the small paving thickness; no exposed floating underside at the lawn edge.
			for side in [-1,1]:
				var edge:Array=preload("res://world/visual_campus/LibraryRearRoad.gd").offset(r.points,side*1.6)
				for i in range(edge.size()-1):
					var a:=Vector3(edge[i][0],0,edge[i][2]);var b:=Vector3(edge[i+1][0],0,edge[i+1][2])
					var count:=maxi(1,ceili(a.distance_to(b)/2))
					for j in count:
						var p:=a.lerp(b,float(j)/count);var q:=a.lerp(b,float(j+1)/count)
						p.y=builder.height(p.x,p.z);q.y=builder.height(q.x,q.z)
						var vertices:=K.quad(p+Vector3.UP*.16,q+Vector3.UP*.16,q+Vector3.DOWN*.12,p+Vector3.DOWN*.12)
						var back:=vertices.duplicate();back.reverse();vertices.append_array(back);K.surface(n,vertices,"818b85",26)
	path(n,117,126,14.64);short_stair(n,126,129,14.64,15.24);path(n,129,135,15.24)
	short_stair(n,135,138,15.24,15.84);path(n,138,144,15.84);short_stair(n,144,147,15.84,16.44);path(n,147,148.7,16.44)
	short_stair(n,147.3,148.3,16.44,16.74);path(n,148.3,149.4,16.74)
	pavilion(n)
	for x in range(122,148,5):
		for z in [-184.2,-175.8]:
			var y:float=builder.height(x,z);V.shrub(n,Vector3(x,y,z),Vector3(2.9,.55,1.4),7100+x+int(z))
	for p in [Vector2(132,-186.5),Vector2(146,-169),Vector2(160,-186),Vector2(161,-173)]:
		rock(n,Vector3(p.x,builder.height(p.x,p.y)+.25,p.y),Vector3(1.45,.65,.85),int(p.x))
	for p in [Vector2(146,-190),Vector2(164,-181),Vector2(151,-168),Vector2(129,-170)]:
		K.tree(n,Vector3(p.x,builder.height(p.x,p.y),p.y),8.3,int(p.x*13+p.y))
	# Rounded pruned shrubs appear against the building and beside the pavilion.
	for p in [Vector2(122,-171),Vector2(137,-170),Vector2(158,-186)]:
		var base:=Vector3(p.x,builder.height(p.x,p.y),p.y)
		V.branch(n,base,base+Vector3.UP*3.9,.12)
		for j in 4:
			var offset:=Vector3(sin(j*2.4)*1.1,1.3+j*.9,cos(j*2.4)*.9)
			V.branch(n,base+Vector3.UP*(.6+j*.8),base+offset,.065)
			V.shrub(n,base+offset,Vector3(2.8,1.3,2.5),7200+int(p.x)+j)
	# Low garden lights sit off the pedestrian width.
	for x in [123,134,143]:
		var y:float=builder.height(x,-182.3)
		K.box(n,Vector3(x,y+.4,-182.3),Vector3(.16,.8,.20),"526057",false,22)
		K.box(n,Vector3(x-.09,y+.48,-182.3),Vector3(.02,.25,.16),"d9dcc2",false,17)
	K.finish(n)
