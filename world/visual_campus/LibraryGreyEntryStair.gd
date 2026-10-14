extends RefCounted
## V209:1F map left entrance stair + Sept2026 grey-baluster photograph.
## V239: pale tread/landing stone without projected floor grids; collision retained.
## Ends are fitted to the retained2F side gallery; not a surveyed common site datum.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const WIDTH:float=2.1
static func points()->Array[Vector3]:
	var foot:=P.point1(335,903,0);var top:=P.point1(175,903,4.4)
	var mid:Vector3=(foot+top)/2;var axis:Vector3=Vector3(top.x-foot.x,0,top.z-foot.z).normalized()
	return [foot,mid-axis*.55,mid+axis*.55,top,top+axis*3.1]

static func guard(n:Node3D,a:Vector3,b:Vector3)->void:
	var d:=b-a;var count:=maxi(1,ceili(Vector2(d.x,d.z).length()/.085))
	var yaw:float=-atan2(d.z,d.x)
	for i in range(count+1):
		K.box(n,a.lerp(b,float(i)/count)+Vector3.UP*.53,Vector3(.065,1.06,.035),"68757b",false,11,yaw)
	for y:float in [.10,1.09]:
		var beam:=K.holder(n,"GreyStairRail",(a+b)/2+Vector3.UP*y)
		beam.basis=Basis.looking_at(d.normalized(),Vector3.UP)
		K.box(beam,Vector3.ZERO,Vector3(.055,.06,d.length()),"6f7d81",false,11);K.finish(beam)
	var up:=Vector3.UP*1.07
	K.surface(n,PackedVector3Array([a,b,b+up,a,b+up,a+up,b+up,b,a,a+up,b+up,a]),"68757b",22,true).hide()

static func deck(n:Node3D,a:Vector3,b:Vector3,steps:int)->void:
	var direction:=Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var side:=Vector3(-direction.z,0,direction.x)*WIDTH/2
	var run:=Vector2(b.x-a.x,b.z-a.z).length()
	var yaw:float=-atan2(direction.z,direction.x)
	if steps>0:
		for i in steps:
			var p:Vector3=a.lerp(b,(i+.5)/steps)
			p.y=lerpf(a.y,b.y,float(i+1)/steps)
			K.box(n,p-Vector3.UP*.095,Vector3(run/steps+.015,.19,WIDTH),"b7bcb4",false,74,yaw)
			K.box(n,p-direction*(run/steps/2-.018)+Vector3.UP*.008,Vector3(.022,.010,WIDTH-.04),"818b86",false,22,yaw)
	else:
		K.box(n,(a+b)/2-Vector3.UP*.12,Vector3(run,.28,WIDTH),"b7bcb4",false,74,yaw)
	K.surface(n,K.quad(a-side,a+side,b+side,b-side),"9da39f",58,true).hide()
	var down:=Vector3.DOWN*.28
	K.surface(n,K.quad(a-side+down,b-side+down,b+side+down,a+side+down),"c4c9c4",22,true)
	for sign in [-1,1]:
		var u:Vector3=a+side*sign;var v:Vector3=b+side*sign
		guard(n,u,v)
		K.surface(n,PackedVector3Array([u,v,v+down,u,v+down,u+down,v+down,v,u,u+down,v+down,u]),"929c9f",22)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryGreyEntryStairV209")
	var p:=points()
	deck(n,p[0],p[1],13);deck(n,p[1],p[2],0);deck(n,p[2],p[3],13);deck(n,p[3],p[4],0)
	n.set_meta("registration","1F schematic stair335..175,903;2Fsidegallery endpoint fitted")
	K.finish(n)
