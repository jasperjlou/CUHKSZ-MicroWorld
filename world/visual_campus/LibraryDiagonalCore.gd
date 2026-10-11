extends RefCounted
## Registered1F diagonal wing: stair on one side, lift/WC lobby beside it, open public return.
## Plan proportions only; internal dimensions and all vertical datums remain fitted.
const K=preload("res://world/visual_campus/LibraryCorePlanKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Stairs=preload("res://world/visual_campus/LibraryStairKit.gd")
const ORIGIN=Vector3(.5,0,20.8)
const PLAN_SCALE=Vector3(9.2/15.2,1,11.5/15.2)
const YAW=PI/4
const LEVELS=[0.0,4.4,8.8,12.8,16.8,20.8]
const WELL=Rect2(-7.05,-5.45,5.55,6.65)

static func point(p:Vector3)->Vector3:
	return ORIGIN+Basis(Vector3.UP,YAW)*(p*PLAN_SCALE)

static func inverse_point(p:Vector3)->Vector3:
	return (Basis(Vector3.UP,-YAW)*(p-ORIGIN))/PLAN_SCALE

static func rect_polygon(r:Rect2)->PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])

static func public_parts(r:Rect2,y:float)->Array[PackedVector2Array]:
	var polygon=rect_polygon(r)
	if y<8.1 or y>8.9:return [polygon]
	# The2F/3F public stair begins beside this wing. Every new slab/soffit must share its void.
	var entry=load("res://world/visual_campus/LibraryEntryLevels.gd")
	var local=PackedVector2Array();var result:Array[PackedVector2Array]=[]
	for p in polygon:
		var q=Basis(Vector3.UP,-entry.YAW)*(point(Vector3(p.x,0,p.y))-entry.ORIGIN);local.append(Vector2(q.x,q.z))
	for strip:Rect2 in [Rect2(-100,-100,97.1,200),Rect2(12,-100,100,200),Rect2(-2.9,-100,14.9,99.6),Rect2(-2.9,entry.RUN+.25,14.9,100)]:
		for part:PackedVector2Array in Geometry2D.intersect_polygons(local,rect_polygon(strip)):
			var out=PackedVector2Array()
			for p in part:
				var q=inverse_point(entry.horizontal(Vector3(p.x,0,p.y)));out.append(Vector2(q.x,q.z))
			result.append(out)
	return result

static func plate(n:Node3D,r:Rect2,y:float)->void:
	for polygon in public_parts(r,y):
		var fitted:=PackedVector2Array()
		for p in polygon:fitted.append(p*Vector2(PLAN_SCALE.x,PLAN_SCALE.z))
		P.sheet(n,fitted,y,"b9bdb1",12,true)
		if y==0 and r.position.x>-2:P.sheet(n,fitted,.137,"c4c5c1",46)
		P.sheet(n,fitted,y-.24,"bec5b6",22,false,false,86,58,true)

static func sign_at(n:Node3D,text:String,p:Vector3,yaw:float=0)->void:
	K.box(n,p,Vector3(1.8,.30,.045),"6d6280",false,22,yaw)
	var label=K.label(n,text,p+Basis(Vector3.UP,yaw)*Vector3(0,0,.035),.003);label.rotation.y=yaw

static func build(parent:Node3D)->void:
	var n=K.holder(parent,"LibraryDiagonalServiceCore",ORIGIN);n.rotation.y=YAW
	n.set_meta("core_plan_scale",PLAN_SCALE)
	const HEIGHT=24.6
	# The outside returns bound the broad wing; its inner half opens into the reading floor.
	K.box(n,Vector3(-7.6,HEIGHT/2,0),Vector3(.20,HEIGHT,15.2),"c4c7bb",true,22)
	K.box(n,Vector3(0,HEIGHT/2,7.6),Vector3(15.4,HEIGHT,.20),"c4c7bb",true,22)
	# Fire-stair separation has a real side doorway at every full landing.
	K.box(n,Vector3(-1.35,HEIGHT/2,-.75),Vector3(.18,HEIGHT,7.5),"c6c9bd",true,22)
	K.box(n,Vector3(-4.50,HEIGHT/2,-7.5),Vector3(6.4,HEIGHT,.18),"c6c9bd",true,22)
	for i in LEVELS.size():
		var y:float=LEVELS[i]
		# One continuous lobby floor joins the inner building and both service frontages.
		plate(n,Rect2(-1.25,-7.6,8.85,15.2),y)
		plate(n,Rect2(-7.5,-7.45,6.2,2.0),y)
		plate(n,Rect2(-7.5,3.0,6.2,4.5),y)
		K.box(n,Vector3(-1.35,y+3.45,-6),Vector3(.18,.9,2.8),"c6c9bd",true,22)
		sign_at(n,str(i+1)+"F · 楼梯",Vector3(-1.23,y+2.8,-6.1),PI/2)
		# Lift doors face the lobby. Closed lift is architectural detail, not a working lift.
		var lift=K.holder(n,"DiagonalLiftFront",Vector3(.15,y,4.25));lift.rotation.y=PI
		K.box(lift,Vector3(0,1.6,-.85),Vector3(2.65,3.2,1.8),"b9c2b5",true,22)
		for side in [-1,1]:
			K.box(lift,Vector3(side*.5,1.28,.085),Vector3(.97,2.56,.06),"9caaa1",false,11)
			K.box(lift,Vector3(side*1.07,1.3,.13),Vector3(.10,2.6,.12),"68776d",false,11)
		K.box(lift,Vector3(0,2.65,.13),Vector3(2.25,.10,.12),"68776d",false,11)
		sign_at(lift,str(i+1)+"F",Vector3(0,2.95,.12))
		K.box(lift,Vector3(1.22,1.08,.12),Vector3(.13,.24,.04),"7f8d83",false,11)
		K.finish(lift)
		# The map identifies two WC frontages; interiors are not invented from icons.
		for side in [-1,1]:
			var x:float=-4.55 if side<0 else 4.55
			K.box(n,Vector3(x,y+1.65,4.95),Vector3(5.7,3.3,.18),"c7c9bd",true,22)
			K.box(n,Vector3(x,y+1.35,4.83),Vector3(1.4,2.7,.06),"b1b9ac",false,22)
			sign_at(n,"卫生间",Vector3(x,y+2.99,4.80),PI)
			K.box(n,Vector3(x+.5,y+1.15,4.78),Vector3(.04,.50,.04),"76877a",false,11)
		# The stair enclosure is not filled by a duplicated floor/ceiling rectangle.
		for rect in [Rect2(-1.25,-7.6,8.85,15.2),Rect2(-7.5,-7.45,6.2,2.0),Rect2(-7.5,3.0,6.2,4.5)]:
			for part in public_parts(rect,y+3.98):
				var fitted:=PackedVector2Array()
				for p in part:fitted.append(p*Vector2(PLAN_SCALE.x,PLAN_SCALE.z))
				P.sheet(n,fitted,y+3.98,"c4cabd",44,false,false,86,58,true)
		for x in [1.5,5.3]:
			for z in [-5.5,-1.8,2.0]:
				if y==4.4 and z<-.5:continue
				K.box(n,Vector3(x,y+3.93,z),Vector3(1.25,.025,.7),"e1e8d5",false,17)
		var lamp=OmniLight3D.new();lamp.position=Vector3(2.4,y+3.2,-1.2)*PLAN_SCALE;lamp.light_energy=.55;lamp.omni_range=10;lamp.light_color=Color("eef0dc");n.add_child(lamp)
		if i==LEVELS.size()-1:continue
		var half:float=(LEVELS[i+1]-y)/2
		var first=K.holder(n,"DiagonalStairOut",Vector3(-5.7,y,-5.4))
		Stairs.flight(first,6.5*PLAN_SCALE.z,half,2.0*PLAN_SCALE.x);K.finish(first)
		plate(n,Rect2(-7.05,1.1,5.55,1.9),y+half)
		var second=K.holder(n,"DiagonalStairReturn",Vector3(-3.0,y+half,1.1));second.rotation.y=PI
		Stairs.flight(second,6.5*PLAN_SCALE.z,half,2.0*PLAN_SCALE.x);K.finish(second)
		K.box(n,Vector3(-4.25,y+half+.55,2.85),Vector3(5.5,1.1,.10),"7b8a7d",true,11)
	# Ground handrail/threshold details stay off the open connection to the public floor.
	K.box(n,Vector3(0,HEIGHT-.06,0),Vector3(15.4,.12,15.4),"bbc1b3",false,22)
	K.finish(n)
