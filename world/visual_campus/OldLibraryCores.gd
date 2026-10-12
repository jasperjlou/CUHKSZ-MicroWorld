extends RefCounted
## V166 official old-library guide1/3/4F: paired stairs at one end, third stair and lift opposite.
## Topology only: guide is not a scaled architectural plan and predates the2026 refit.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const LEVELS=[0.,4.6,8.3,12.]
const CX=-35.0
const CZ=[-3.84,4.16] # Relative to the retained rear bar, z=-17.16 in building space.

static func slab(n:Node3D,size:Vector2,y:float)->void:
	var parts:Array[Rect2]=[Rect2(-size/2,size)]
	var holes:Array[Rect2]=[preload("res://world/visual_campus/OldLibraryAtrium.gd").HOLE]
	if y<15.:holes.append_array([Rect2(CX-4.72,CZ[0]-1.73,7.74,3.46),Rect2(CX-4.72,CZ[1]-1.73,7.74,3.46),Rect2(35.-3.02,4.16-1.73,7.74,3.46)])
	for h:Rect2 in holes:
		var next:Array[Rect2]=[]
		for p in parts:
			var cut:=p.intersection(h)
			if not cut.has_area():next.append(p);continue
			for q:Rect2 in [Rect2(p.position,Vector2(cut.position.x-p.position.x,p.size.y)),Rect2(Vector2(cut.end.x,p.position.y),Vector2(p.end.x-cut.end.x,p.size.y)),Rect2(Vector2(cut.position.x,p.position.y),Vector2(cut.size.x,cut.position.y-p.position.y)),Rect2(Vector2(cut.position.x,cut.end.y),Vector2(cut.size.x,p.end.y-cut.end.y))]:
				if q.has_area():next.append(q)
		parts=next
	for p in parts:K.box(n,Vector3(p.get_center().x,y,p.get_center().y),Vector3(p.size.x,.24,p.size.y),"797c74" if y>15 else "c2c6bd",true,36 if y>15 else 15)

static func deck(n:Node3D,x0:float,x1:float,y:float)->void:
	K.box(n,Vector3((x0+x1)/2,y-.09,0),Vector3(x1-x0,.18,3.4),"b7bab2",false,26)
	K.surface(n,K.quad(Vector3(x0,y,-1.7),Vector3(x1,y,-1.7),Vector3(x1,y,1.7),Vector3(x0,y,1.7)),"b7bab2",26,true)

static func rail(n:Node3D,a:Vector3,b:Vector3)->void:
	var c:=b+Vector3.UP*1.06;var d:=a+Vector3.UP*1.06
	var collision:=K.surface(n,PackedVector3Array([a,b,c,a,c,d,c,b,a,d,c,a]),"59635f",11,true);collision.visible=false
	for i in 31:K.box(n,a.lerp(b,float(i)/30)+Vector3.UP*.52,Vector3(.025,1.04,.025),"59635f",false,11)
	var h:=K.holder(n,"Handrail",(a+b)/2+Vector3.UP*1.07)
	h.rotation.z=atan2(b.y-a.y,b.x-a.x)
	K.box(h,Vector3.ZERO,Vector3(a.distance_to(b),.065,.065),"59635f",false,11);K.finish(h)

static func flight(n:Node3D,a:Vector3,b:Vector3)->void:
	for i in 16:
		var p:=a.lerp(b,(i+.5)/16.);var top:float=lerpf(a.y,b.y,(i+1)/16.)
		K.box(n,Vector3(p.x,(a.y+top)/2,p.z),Vector3(absf(b.x-a.x)/16+.01,maxf(.04,top-a.y),1.45),"b7bab2",false,26)
	var ramp:=K.surface(n,K.quad(a+Vector3(0,0,-.725),b+Vector3(0,0,-.725),b+Vector3(0,0,.725),a+Vector3(0,0,.725)),"b7bab2",26,true);ramp.visible=false
	for z in [-.76,.76]:rail(n,a+Vector3(0,0,z),b+Vector3(0,0,z))

static func build(parent:Node3D,w:float,d:float)->void:
	var root:=K.holder(parent,"OldLibraryPairedCoresV165",Vector3(0,0,-d*.33))
	for z:float in CZ:core(root,Vector3(CX,0,z),PI,"PublicStair" if z<0 else "EndStair")
	core(root,Vector3(35,0,4.16),0,"OppositeStairV166")
	# Opposite-end lift remains a closed shaft; no pretend elevator operation.
	K.box(root,Vector3(35.8,7.85,-3.8),Vector3(3.2,15.7,3.1),"b9bdb4",true,22)
	for y:float in LEVELS:
		K.box(root,Vector3(34.18,y+1.5,-3.8),Vector3(.04,2.8,1.7),"778381",false,11)
		K.box(root,Vector3(34.15,y+1.5,-3.8),Vector3(.03,2.8,.035),"434f4c",false,11)
	K.finish(root)

static func core(root:Node3D,p:Vector3,yaw:float,id:String)->void:
	var n:=K.holder(root,id,p);n.rotation.y=yaw
	for side in [-1,1]:K.box(n,Vector3(0,7.85,side*1.86),Vector3(9.8,15.7,.18),"c6c7bc",true,22)
	K.box(n,Vector3(4.88,7.85,0),Vector3(.18,15.7,3.9),"c6c7bc",true,22)
	# Ground terrain is at0; ease the12cm structural deck edge into the hall.
	K.surface(n,K.quad(Vector3(-5.9,0,-1.5),Vector3(-4.7,.12,-1.5),Vector3(-4.7,.12,1.5),Vector3(-5.9,0,1.5)),"b7bab2",26,true)
	for y:float in LEVELS:
		deck(n,-4.7,-3.,y+.12)
		# Door head and side piers leave a3m public opening toward the shared aisle.
		for side in [-1,1]:K.box(n,Vector3(-4.88,y+1.55,side*1.72),Vector3(.18,3.1,.28),"c6c7bc",true,22)
		var ceiling:float=LEVELS[LEVELS.find(y)+1] if y<12 else 15.7
		K.box(n,Vector3(-4.88,(y+3.15+ceiling)/2,0),Vector3(.18,ceiling-y-3.15,3.9),"c6c7bc",true,22)
		K.box(n,Vector3(-4.05,y+2.96,0),Vector3(.62,.04,.2),"e2ddc7",false,17)
	for i in 3:
		var low:float=LEVELS[i]+.12;var high:float=LEVELS[i+1]+.12;var mid:float=(low+high)/2
		flight(n,Vector3(-3,low,-.85),Vector3(3,mid,-.85))
		deck(n,3,4.7,mid)
		flight(n,Vector3(3,mid,.85),Vector3(-3,high,.85))
	K.finish(n)

