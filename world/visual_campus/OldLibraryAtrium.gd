extends RefCounted
## V167 old-library panoramas + official2025-09-17 ground photograph.
## Shared lightwell footprint follows the retained roof cover; metric placement is fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const W=preload("res://world/visual_campus/WesternCampus.gd")
const LEVELS=[0.,4.6,8.3,12.]
const HOLE=Rect2(-22,-3.5,32,7)
const R=1.4

static func vertical(n:Node3D,a:Vector3,b:Vector3,height:float,color:String,solid:bool=true)->void:
	var c:=b+Vector3.UP*height;var d:=a+Vector3.UP*height
	K.surface(n,PackedVector3Array([a,b,c,a,c,d,c,b,a,d,c,a]),color,22,solid)

static func guard(n:Node3D,a:Vector3,b:Vector3)->void:
	vertical(n,a,b,1.02,"d4d8ce")
	W.beam(n,a+Vector3.UP*1.15,b+Vector3.UP*1.15,.075,.075,"795642")
	for t in [0.,1.]:K.box(n,a.lerp(b,t)+Vector3.UP*1.08,Vector3(.035,.14,.035),"66534a",false,11)

static func deck(n:Node3D,y:float)->void:
	K.box(n,Vector3(-.95,y-.10,0),Vector3(1.9,.20,7.),"ccd0c8",false,22)
	K.surface(n,K.quad(Vector3(-1.9,y,-3.5),Vector3(0,y,-3.5),Vector3(0,y,3.5),Vector3(-1.9,y,3.5)),"c1c5bd",26,true)
	if y>1:
		guard(n,Vector3(-1.9,y,-3.5),Vector3(-1.9,y,3.5))
		guard(n,Vector3(0,y,-.5),Vector3(0,y,.5))

static func flight(n:Node3D,a:Vector3,b:Vector3)->void:
	var ramp:=K.surface(n,K.quad(a+Vector3(0,0,-.8),b+Vector3(0,0,-.8),b+Vector3(0,0,.8),a+Vector3(0,0,.8)),"c5c8c0",26,true);ramp.visible=false
	for i in 20:
		var t:float=(i+.5)/20.;var q:=a.lerp(b,t);var high:float=lerpf(a.y,b.y,(i+1)/20.)
		K.box(n,Vector3(q.x,high-.09,q.z),Vector3(absf(b.x-a.x)/20.+.01,.18,1.6),"c4c8c0",false,26)
	# Thin sloping soffit, not a solid triangular block to ground.
	var underside:=K.quad(a+Vector3(0,-.2,-.8),b+Vector3(0,-.2,-.8),b+Vector3(0,-.2,.8),a+Vector3(0,-.2,.8));underside.reverse()
	K.surface(n,underside,"d5d8cf",22)
	for z:float in [-.84,.84]:guard(n,a+Vector3(0,0,z),b+Vector3(0,0,z))

static func turn_point(angle:float,radius:float,y:float)->Vector3:return Vector3(7+cos(angle)*radius,y,sin(angle)*radius)
static func turn(n:Node3D,y:float)->void:
	for i in 32:
		var a:float=-PI/2+i*PI/32;var b:float=a+PI/32
		var v:=K.quad(turn_point(a,.6,y),turn_point(b,.6,y),turn_point(b,2.2,y),turn_point(a,2.2,y))
		K.surface(n,v,"c4c8c0",26,true)
		var underside:=v.duplicate();for j in underside.size():underside[j].y-=.2
		underside.reverse();K.surface(n,underside,"d5d8cf",22)
		for r:float in [.6,2.2]:vertical(n,turn_point(a,r,y-.2),turn_point(b,r,y-.2),.2,"d5d8cf",false)
		for r:float in [.56,2.24]:guard(n,turn_point(a,r,y),turn_point(b,r,y))

static func roof_skin(n:Node3D,size:Vector2,y:float)->void:
	# Four disjoint rectangles around the real central void.
	for r:Rect2 in [Rect2(-size/2,Vector2(-22+size.x/2,size.y)),Rect2(Vector2(10,-size.y/2),Vector2(size.x/2-10,size.y)),Rect2(Vector2(-22,-size.y/2),Vector2(32,size.y/2-3.5)),Rect2(Vector2(-22,3.5),Vector2(32,size.y/2-3.5))]:
		K.box(n,Vector3(r.get_center().x,y,r.get_center().y),Vector3(r.size.x,.025,r.size.y),"68695f",false,36)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"OldLibraryAtriumV167",Vector3(0,0,-17.16))
	for y:float in LEVELS:deck(n,y+.12)
	K.surface(n,K.quad(Vector3(-3.1,0,-3.5),Vector3(-1.9,.12,-3.5),Vector3(-1.9,.12,3.5),Vector3(-3.1,0,3.5)),"c1c5bd",26,true)
	for i in 3:
		var low:float=LEVELS[i]+.12;var high:float=LEVELS[i+1]+.12;var mid:float=(low+high)/2
		flight(n,Vector3(0,low,-R),Vector3(7,mid,-R));turn(n,mid)
		flight(n,Vector3(7,mid,R),Vector3(0,high,R))
	for y:float in [4.72,8.42,12.12]:
		for z:float in [-3.5,3.5]:
			guard(n,Vector3(-22,y,z),Vector3(-1.9,y,z));guard(n,Vector3(0,y,z),Vector3(10,y,z))
		for x:float in [-22,10]:guard(n,Vector3(x,y,-3.5),Vector3(x,y,3.5))
	# Tall white cylindrical columns frame the skylit galleries.
	for x:float in [-20,-7,8]:
		for z:float in [-4.05,4.05]:
			var col:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=.3;mesh.bottom_radius=.3;mesh.height=15.5;mesh.radial_segments=24;col.mesh=mesh;col.position=Vector3(x,7.75,z);col.material_override=K.material("d9ddd3",22);n.add_child(col)
			var body:=StaticBody3D.new();var cs:=CollisionShape3D.new();var sh:=CylinderShape3D.new();sh.radius=.3;sh.height=15.5;cs.shape=sh;body.position=col.position;body.add_child(cs);n.add_child(body)
	# Ground curved timber shelf and white apron supported by2025 photograph.
	for i in 32:
		var a:float=-PI/2+i*PI/32;var b:float=a+PI/32
		vertical(n,turn_point(a,2.27,1.18),turn_point(b,2.27,1.18),1.25,"d4d8ce",false)
		vertical(n,turn_point(a,2.25,.08),turn_point(b,2.25,.08),1.1,"513c2d",false)
		for y:float in [.08,.62,1.18]:K.surface(n,K.quad(turn_point(a,2.25,y),turn_point(b,2.25,y),turn_point(b,2.65,y),turn_point(a,2.65,y)),"765039",4)
		if i%4==0:vertical(n,turn_point(a,2.25,.08),turn_point(a,2.65,.08),1.1,"765039",false)
	# Indirect fill assists the open skylight without changing the campus environment.
	var light:=OmniLight3D.new();light.position=Vector3(-6,13.5,0);light.light_color=Color("e2ece6");light.light_energy=.7;light.omni_range=24;n.add_child(light)
	K.finish(n)
