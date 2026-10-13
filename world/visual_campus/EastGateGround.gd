extends RefCounted
## Official East Gate Square 116443795: gray stone court, broad stair and planted sides.
## Heights/widths retain the fitted origin; side ramp alignment is not survey evidence.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const G := 2.24
const RAMP_X := 17.0
const FRONT := -35.0
const BACK := -64.0

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<=14.5 or x>=19.0 or z>FRONT or z<BACK:return base
	var weight: float=smoothstep(14.5,15.4,x)*(1.0-smoothstep(18.6,19.0,x))
	return lerpf(base,G*clampf((FRONT-z)/(FRONT-BACK),0,1),weight)

static func field(b: Node3D,builder,x0: float,x1: float,z0: float,z1: float,color: String,kind:int=60) -> void:
	var zs: Array[float]=[z0,z1]
	for z in range(ceili(z0),floori(z1)+1):
		if not zs.has(float(z)):zs.append(float(z))
	var xs: Array[float]=[x0,x1]
	for x: float in [-19.3,-18.9,-18.7,-15.9,-15.7,-15.3,14.5,15.4,18.6,19.0]:
		if x>x0 and x<x1:xs.append(x)
	xs.sort();zs.sort();var mesh:=PackedVector3Array()
	for i in xs.size()-1:
		for j in zs.size()-1:
			var a:=Vector3(xs[i],builder.height(xs[i],zs[j])+.112,zs[j])
			var c:=Vector3(xs[i+1],builder.height(xs[i+1],zs[j+1])+.112,zs[j+1])
			mesh.append_array(K.quad(a,Vector3(c.x,builder.height(c.x,a.z)+.112,a.z),c,Vector3(a.x,builder.height(a.x,c.z)+.112,c.z)))
	K.surface(b,mesh,color,kind)

static func slot_drain(b:Node3D,builder,a:Vector2,c:Vector2)->void:
	# Thin metal slot between the dark field and pale stone, visible in official down faces.
	# Fine bars are visual; the pre-existing walkable surface remains continuous.
	var d:=c-a;var normal:=Vector2(-d.y,d.x).normalized();var length:=d.length()
	for width:float in [.085,.045]:
		builder.ribbon(b,[[a.x,0,a.y],[c.x,0,c.y]],width,"7f8883" if width>.05 else "303b38",11,.132 if width>.05 else .134)
	for i in int(length/.24):
		var p:=a+d*((i+.5)*.24/length)
		var cross_a:=p-normal*.039;var cross_b:=p+normal*.039
		builder.ribbon(b,[[cross_a.x,0,cross_a.y],[cross_b.x,0,cross_b.y]],.012,"8d9690",11,.137)

static func beam(b: Node3D,a: Vector3,c: Vector3,width: float) -> void:
	var rail:=K.holder(b,"Rail")
	rail.look_at_from_position((a+c)/2,c,Vector3.UP)
	K.box(rail,Vector3.ZERO,Vector3(width,width,a.distance_to(c)),"8a9390",false,13)
	K.finish(rail)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"EastGateStoneCourt")
	# The former narrow ribbon and floating ramp rail are replaced by one registered surface.
	# Leave the teaching-side stair throat to its authored treads; the former
	# single field interpolated across that local grade and produced stone spikes.
	field(b,builder,-20,-15.3,-40,-14,"60696c")
	field(b,builder,-15.3,15.5,-41.9,-14,"60696c")
	field(b,builder,15.5,20.35,FRONT,-14,"60696c")
	for x in [-19.25,19.25]:
		builder.ribbon(b,[[x,0,-14],[x,0,-35 if x>0 else -40]],.64,"a5aaa8",61,.12)
		slot_drain(b,builder,Vector2(x-signf(x)*.37,-14.8),Vector2(x-signf(x)*.37,-34.5 if x>0 else -39.5))
	for z in [-14.4,-41.2]:
		builder.ribbon(b,[[-15.3 if z<-35 else -19.6,0,z],[15.4 if z<-35 else 19.6,0,z]],.42,"a5aaa8",61,.12)
	slot_drain(b,builder,Vector2(-18.88,-14.67),Vector2(18.88,-14.67))
	# Pale tread noses and full stair cheeks follow the same retained 2.24 m rise.
	var steps:=20;var run:=9.0
	for i in steps:
		var y: float=G*(i+1)/steps+.025;var z: float=-42-run*(i+.5)/steps
		K.box(b,Vector3(0,y/2,z),Vector3(28,y,run/steps+.012),"a5aaa8",false,61)
		K.box(b,Vector3(0,y+.004,z+run/steps/2-.045),Vector3(28,.008,.08),"b2b7b3",false,61)
		for side in [-1,1]:K.box(b,Vector3(side*14.2,y/2+.08,z),Vector3(.38,y+.16,run/steps+.012),"bbc0b5",false,15)
	# Landing bands are flush and never cap the ramp throat.
	K.box(b,Vector3(0,G+.12,-52.5),Vector3(28,.012,3),"a5aaa8",false,61)
	field(b,builder,15.5,18.5,BACK,FRONT,"959d99",61)
	field(b,builder,14.5,15.5,BACK,-51,"60696c")
	field(b,builder,18.5,19.0,BACK,-51,"60696c")
	for x in [15.5,18.5]:
		for i in 11:
			var z: float=lerpf(FRONT,BACK,float(i)/10);var y: float=builder.height(x,z)
			K.box(b,Vector3(x,y+.58,z),Vector3(.065,1.05,.065),"8a9390",false,13)
		beam(b,Vector3(x,.112+1.0,FRONT),Vector3(x,G+.112+1.0,BACK),.065)
		beam(b,Vector3(x,.112+.55,FRONT),Vector3(x,G+.112+.55,BACK),.045)
	# Lower drain and side planted banks, observed on both sides of the broad stair.
	K.box(b,Vector3(0,.12,-41.7),Vector3(28,.01,.30),"505955",false,13)
	for x in range(-14,14):
		for dx in [.15,.45,.75]:K.box(b,Vector3(x+dx,.122,-41.7),Vector3(.035,.008,.24),"acb1a7",false,13)
	for side in [-1,1]:
		var x: float=21.5 if side>0 else -26.5
		for z in [-43.5,-51.5]:
			var y: float=builder.height(x,z)
			K.tree(b,Vector3(x,y+.12,z),7.0,3830+absi(int(x+z)))
		# Low stone perimeter; fitted planting beds follow the grade rather than float above it.
		for edge: float in ([20.0,23.0] if side>0 else [-22.5,-30.5]):
			builder.ribbon(b,[[edge,0,-40],[edge,0,-56]],.25,"b9beb2",26,.14)
	K.finish(b)
