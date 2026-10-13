extends RefCounted
## V192: source-led street/sidewalk relation from panorama 116410030.
## Widths, grade, extent and planting positions are fitted, not a city survey.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")

static func plane(b: Node3D,x0: float,x1: float,z0: float,z1: float,y: float,color: String,kind: int,solid: bool=false) -> void:
	K.surface(b,K.quad(Vector3(x0,y,z0),Vector3(x1,y,z0),Vector3(x1,y,z1),Vector3(x0,y,z1)),color,kind,solid)

static func neck(b: Node3D,builder,x0: float,x1: float,z0: float,color: String,kind: int) -> void:
	var mesh:=PackedVector3Array()
	for x in range(floori(x0),ceili(x1)):
		for z in range(int(z0),50):
			var left:=maxf(x0,x);var right:=minf(x1,x+1)
			var points: Array[Vector3]=[Vector3(left,0,z),Vector3(right,0,z),Vector3(right,0,z+1),Vector3(left,0,z+1)]
			for i in 4:
				points[i].y=builder.height(points[i].x,points[i].z)+.112*smoothstep(z0,z0+3,points[i].z)
			mesh.append_array(K.quad(points[0],points[1],points[2],points[3]))
	K.surface(b,mesh,color,kind,true)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"EastGateExteriorV192")
	b.set_meta("source_scene",116410030)
	b.set_meta("registration","Local east-gate frame; street width/length and grade fitted; geographic north unknown")
	# Join the existing ceremonial apron and the side vehicle throat. Their
	# fitted grades differ until z=50: follow the authored terrain in this neck.
	neck(b,builder,-26,24.5,42,"929794",31)
	neck(b,builder,33.5,42,43,"929794",31)
	neck(b,builder,24.5,33.5,43,"484d4d",2)
	plane(b,24.5,33.5,50,60,.112,"484d4d",2,true)
	for span: Vector2 in [Vector2(-170,24.5),Vector2(33.5,170)]:
		plane(b,span.x,span.y,50,60,.112,"929794",31,true)
		# Flush drain and pale edge do not create a raised lip at the drive.
		plane(b,span.x,span.y,59.5,59.68,.13,"4d5552",11)
		plane(b,span.x,span.y,59.8,60,.14,"b8bcb4",26)
	plane(b,-170,170,60,84,.112,"484d4d",2,true)
	plane(b,-170,170,84,92,.112,"929794",31,true)
	plane(b,-170,170,84,84.22,.14,"b8bcb4",26)
	# The opposite planted verge is real in the panorama; no invented hill.
	plane(b,-170,170,92,106,.105,"585640",8)
	for z in [92.0,106.0]:
		K.box(b,Vector3(0,.20,z),Vector3(340,.20,.24),"999e91",false,26)
	for x in range(-160,161,12):
		K.tree(b,Vector3(x,.12,96),7.5+float(posmod(x,5))*.30,192000+x)
		V.shrub(b,Vector3(x,.13,92.8),Vector3(5.5,.85,1.3),192500+x)
		V.shrub(b,Vector3(x+6,.13,92.8),Vector3(5.5,.70,1.3),192700+x)
	# Dash/centre line count is a fitted depiction, not a lane survey.
	for x in range(-164,165,10):
		if x>16 and x<44:continue
		for z in [66.0,78.0]:
			K.box(b,Vector3(x,.131,z),Vector3(4,.016,.13),"d0d1bd",false,22)
	for span: Vector2 in [Vector2(-170,18),Vector2(40,170)]:
		for z in [71.85,72.15]:
			plane(b,span.x,span.y,z-.055,z+.055,.14,"c6aa5e",22)
	# Keep the vehicle entrance open. The source has a striped pedestrian
	# apron across its mouth; none of these paint strips adds collision.
	for z in range(51,60,2):
		plane(b,24.5,33.5,z,z+.75,.15,"d8d9c8",22)
	for x in range(-148,161,44):
		var lamp:=K.holder(b,"StreetLamp",Vector3(x,.12,90.4))
		K.box(lamp,Vector3(0,4.6,0),Vector3(.13,9.2,.13),"929b91",false,11)
		for side in [-1,1]:
			K.box(lamp,Vector3(side*.95,9.05,0),Vector3(2.0,.10,.10),"929b91",false,11)
			K.box(lamp,Vector3(side*1.8,9.02,0),Vector3(.65,.13,.27),"69756f",false,11)
		K.finish(lamp)
	K.finish(b)
