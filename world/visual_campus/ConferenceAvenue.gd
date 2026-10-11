extends RefCounted
## Official ICC Avenue 116443783: recessed timber doors, stone piers, panel soffit,
## green glazed floor strips and broad stone walk. Bay spacing remains fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func fitted_height(x: float,z: float,base: float) -> float:
	# Local bench beneath the retained ICC base. The old campus-wide gate slope passed through it.
	if x<=34 or x>=113 or z<=-134 or z>=-18:return base
	var weight: float=smoothstep(34,42,x)*(1.0-smoothstep(106,113,x))*(1.0-smoothstep(-22,-18,z))
	return lerpf(base,2.24,weight)

static func floor_point(b: Node3D,builder,x: float,z: float) -> Vector3:
	var p:=b.to_global(Vector3(x,0,z))
	return Vector3(x,builder.height(p.x,p.z)-b.global_position.y+.108,z)

static func floor_rect(b: Node3D,builder,x0: float,x1: float,z0: float,z1: float,finish: int=40,color: String="969c94") -> void:
	var mesh:=PackedVector3Array();var nx:=ceili(x1-x0);var nz:=ceili(z1-z0)
	for i in nx:
		for j in nz:
			var x: float=lerpf(x0,x1,float(i)/nx);var xx: float=lerpf(x0,x1,float(i+1)/nx)
			var z: float=lerpf(z0,z1,float(j)/nz);var zz: float=lerpf(z0,z1,float(j+1)/nz)
			mesh.append_array(K.quad(floor_point(b,builder,x,z),floor_point(b,builder,xx,z),floor_point(b,builder,xx,zz),floor_point(b,builder,x,zz)))
	K.surface(b,mesh,color,finish)

static func build(b: Node3D,builder) -> void:
	# Door leaves used to stand alone in the open undercroft. Complete their enclosing wall.
	var cursor:=-33.0
	for center in [-26.0,-14.0,-2.0,10.0,22.0]:
		var left: float=center-2.06
		K.box(b,Vector3((cursor+left)/2,2.2,-2.67),Vector3(left-cursor,4.4,.40),"b7ae97",true,15)
		K.box(b,Vector3(center,4.10,-2.67),Vector3(4.12,.60,.40),"b7ae97",true,15)
		for side in [-1,1]:K.box(b,Vector3(center+side*2.08,1.98,-2.31),Vector3(.14,3.96,.45),"929a91",false,13)
		# Dark threshold and green glazed panels are flush with the stone walking surface.
		K.box(b,Vector3(center,.112,-1.86),Vector3(4.1,.018,.85),"535d53",false,26)
		for i in 4:
			K.box(b,Vector3(center-1.5+i,.114,.91),Vector3(.94,.016,1.46),"375b50",false,27)
			for edge in [-1,1]:K.box(b,Vector3(center-1.5+i+edge*.48,.13,.91),Vector3(.035,.016,1.50),"9a9c8b",false,13)
		for z in [.16,1.66]:K.box(b,Vector3(center,.13,z),Vector3(4,.016,.035),"9a9c8b",false,13)
		cursor=center+2.06
	K.box(b,Vector3((cursor+25)/2,2.2,-2.67),Vector3(25-cursor,4.4,.40),"b7ae97",true,15)
	# Opaque returns close the existing hall/service footprint; unseen rooms are not furnished.
	for x in [-33.0,25.0]:K.box(b,Vector3(x,2.2,-16.5),Vector3(.32,4.4,28),"b7ae97",true,15)
	K.box(b,Vector3(-4,2.2,-30.5),Vector3(58,4.4,.32),"b7ae97",true,15)
	floor_rect(b,builder,-34,40,-2.4,10)
	# Two open-ended apron connections join the lower avenue to the existing entry forecourt.
	# Their width/alignment are fitted interfaces, not an asserted surveyed plan.
	floor_rect(b,builder,-15,-11,10,42.5)
	floor_rect(b,builder,37,41,10,36)
	# This apron was absent between the projecting glazed wing and its adjacent side aisle.
	floor_rect(b,builder,21,41,10,20)
	for x in [-32.5,39.4]:K.box(b,Vector3(x,.115,3.8),Vector3(.18,.015,12),"66726a",false,26)
	for x in range(-32,40,6):
		K.box(b,Vector3(x,.12,8.7),Vector3(1.0,.018,.22),"58665e",false,13)
		for i in 8:K.box(b,Vector3(x-.42+i*.12,.134,8.7),Vector3(.024,.012,.18),"9fa799",false,13)
	# Fine square ceiling panels replace the blank slab above the door row.
	for x in range(-33,25):
		for z in range(-2,3):K.box(b,Vector3(x+.5,4.015,z+.5),Vector3(.98,.035,.98),"bfc2b8",false,20)
	for x in [-26,-14,-2,10,22]:
		K.box(b,Vector3(x,3.986,.25),Vector3(.32,.032,.32),"555e53",false,13)
		K.box(b,Vector3(x,3.965,.25),Vector3(.21,.008,.21),"e1ddc6",false,17)
	# A shallow fascia separates the stone piers from the tiled soffit.
	K.box(b,Vector3(-4,3.95,2.94),Vector3(58,.18,.16),"a6aca0",false,15)
