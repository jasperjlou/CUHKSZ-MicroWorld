extends RefCounted
## Public1F plan202401: polygonal116 and shared rounded117/118. Metres remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
const P=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const STUDIO_ORIGIN=Vector3(24.35,0,-3.05)
const STUDIO_YAW=PI*.75
static func stacks_outline()->PackedVector2Array:
	return PackedVector2Array([Vector2(17.6,-.15),Vector2(30.1,8.8),Vector2(20.35,18.3),Vector2(10,8.6)])
static func contains(x:float,z:float)->bool:
	return Geometry2D.is_point_in_polygon(Vector2(x,z),stacks_outline())
static func studio_point(p:Vector3)->Vector3:
	return STUDIO_ORIGIN+Basis(Vector3.UP,STUDIO_YAW)*p
static func build(parent:Node3D)->void:
	var b=K.holder(parent,"RegisteredCompactStacks116")
	var outline:PackedVector2Array=stacks_outline()
	var approach=preload("res://world/visual_campus/LibraryEntryApproach.gd")
	for i in outline.size():
		var a:=outline[i];var c:=outline[(i+1)%outline.size()]
		var qa:Vector2=approach.coords(a);var qc:Vector2=approach.coords(c)
		var stops:Array[float]=[0.0,1.0]
		for cut:float in [-approach.HALF_WIDTH,approach.HALF_WIDTH]:
			if absf(qc.x-qa.x)>.0001:
				var t:float=(cut-qa.x)/(qc.x-qa.x)
				if t>0 and t<1:stops.append(t)
		for cut:float in [approach.TOP,approach.FOOT]:
			if absf(qc.y-qa.y)>.0001:
				var t:float=(cut-qa.y)/(qc.y-qa.y)
				if t>0 and t<1:stops.append(t)
		stops.sort()
		for j in range(stops.size()-1):
			var u:=a.lerp(c,stops[j]);var v:=a.lerp(c,stops[j+1]);var mid:=(u+v)/2
			var h0:float=approach.ceiling_y(u.lerp(mid,.0001));var h1:float=approach.ceiling_y(v.lerp(mid,.0001))
			var p0:=Vector3(u.x,0,u.y);var p1:=Vector3(v.x,0,v.y);var p2:=Vector3(v.x,h1,v.y);var p3:=Vector3(u.x,h0,u.y)
			# Thin solid wall avoids a zero-thickness, double-faced shadow seam.
			var normal:=Vector3(v.y-u.y,0,u.x-v.x).normalized()*.045
			var wall_vertices:=PackedVector3Array()
			var front:Array[Vector3]=[p0+normal,p1+normal,p2+normal,p3+normal]
			var back:Array[Vector3]=[p0-normal,p1-normal,p2-normal,p3-normal]
			wall_vertices.append_array(PackedVector3Array([front[0],front[1],front[2],front[0],front[2],front[3],back[0],back[2],back[1],back[0],back[3],back[2]]))
			for k in 4:
				var l: int=(k+1)%4
				wall_vertices.append_array(PackedVector3Array([front[k],back[k],back[l],front[k],back[l],front[l]]))
			var wall:=K.surface(b,wall_vertices,"bbbcae",22,true)
			wall.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	P.sheet(b,outline,.012,"b9b4a4",12,true)
	approach.closed_stack_ceiling(b,outline)
	# Closed collection access on the northwest public frontage, near its lower end.
	var a=outline[3];var c=outline[0];var delta=c-a
	var n=K.holder(b,"ClosedCollectionDoor",Vector3(a.x+delta.x*.23,0,a.y+delta.y*.23))
	n.rotation.y=PI-atan2(delta.y,delta.x)
	K.box(n,Vector3(0,1.5,.105),Vector3(1.8,3,.06),"899b91",false,11)
	for x in [-.11,.11]:K.box(n,Vector3(x,1.35,.16),Vector3(.04,.65,.04),"cdd3c7",false,11)
	K.box(n,Vector3(0,3.43,.13),Vector3(3.4,.34,.035),"596956",false,22)
	K.label(n,"116 · 密集书库",Vector3(0,3.43,.16),.004)
	K.finish(n);K.finish(b)
	# V241 unified public carpet includes this approach.
	studios(parent)
static func studios(parent:Node3D)->void:
	var b=K.holder(parent,"SharedEditingStudios117118",STUDIO_ORIGIN);b.rotation.y=STUDIO_YAW
	# One capsule boundary and one partition; no doubled middle walls or corner slit.
	const R=1.6
	const HALF_STRAIGHT=1.2
	Pods.panel(b,Vector2(-HALF_STRAIGHT,-R),Vector2(HALF_STRAIGHT,-R))
	for side in [-1,1]:
		var start:float=-PI/2 if side>0 else PI/2
		for j in 20:
			var a:float=start+j*PI/20;var c:float=start+(j+1)*PI/20
			Pods.panel(b,Vector2(side*HALF_STRAIGHT+cos(a)*R,sin(a)*R),Vector2(side*HALF_STRAIGHT+cos(c)*R,sin(c)*R),false)
	K.box(b,Vector3(0,1.81,0),Vector3(.12,3.62,3.2),"c7cabd",true,22)
	Pods.strip(b,Vector2(-1.2,R),Vector2(1.2,R),3.73,.38,.13,"d0d2c8",81)
	for side in [-1,1]:
		var x:float=side*.64
		var title:String="117" if side<0 else "118"
		K.box(b,Vector3(x,3.3,R+.07),Vector3(.8,.3,.04),"63725e",false,22)
		K.label(b,title,Vector3(x,3.3,R+.10),.004)
		var door:=K.holder(b,"StudioDoorFinish"+title,Vector3(x,0,R))
		Pods.Finish.jambs(door,1.08,0)
		Pods.Finish.open_leaf(door,side*.09-x,1.05-R,1.0,side)
		K.finish(door)
		# Workstations face the rear; entry beside the shared wall stays clear.
		K.box(b,Vector3(side*1.3,.75,-.70),Vector3(2.15,.09,.65),"baa885",true,43)
		for dx in [-.85,.85]:K.box(b,Vector3(side*1.3+dx,.36,-.7),Vector3(.045,.72,.5),"bfc6bb",false,11)
		K.box(b,Vector3(side*1.3,.46,.3),Vector3(.46,.08,.46),"627c88",false,22)
		K.box(b,Vector3(side*1.3,.77,.51),Vector3(.46,.55,.05),"64716d",false,16)
		for dx in [-.17,.17]:
			for dz in [-.17,.17]:K.box(b,Vector3(side*1.3+dx,.21,.3+dz),Vector3(.025,.42,.025),"aab4a7",false,11)
		K.box(b,Vector3(side*1.3,1.15,-.86),Vector3(.85,.52,.08),"343e3f",false,22)
		K.box(b,Vector3(side*1.3,1.15,-.811),Vector3(.77,.43,.015),"617778",false,5)
	K.finish(b)
