extends RefCounted
## Building-specific exteriors. East Gate anchors are retained; concealed portions are estimates.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const T := preload("res://world/visual_campus/TeachingBlocks.gd")
const IDS := ["zhang_lingbin","lee_yin_yee","hl_tu","shaw_east","shaw_west"]

static func handles(id: String) -> bool:
	return id in IDS

static func build(b: Node3D,r: Dictionary) -> void:
	match r.id:
		"zhang_lingbin":zhang(b,r)
		"lee_yin_yee","hl_tu":laboratory(b,r)
		"shaw_east":shaw_east(b,r)
		"shaw_west":shaw_west(b,r)

static func glazed_base(b: Node3D,length: float,z: float,label: String) -> void:
	for x in range(-int(length/2)+2,int(length/2),4):
		if abs(x)<5:continue
		K.window(b,Vector3(x,2.1,z),3.35,3.8)
		K.box(b,Vector3(x,4.05,z),Vector3(3.7,.18,.35),"aab3a8")
	K.label(b,label,Vector3(-length*.25,4.05,z+.26),.009)

static func guardrail(b: Node3D,p: Vector3,length: float,yaw: float=0) -> void:
	var basis:=Basis(Vector3.UP,yaw)
	K.box(b,p+basis*Vector3(0,1.1,0),Vector3(length,.075,.075),"52685a",false,0,yaw)
	for i in int(length/.75):
		K.box(b,p+basis*Vector3((i+.5)*.75-length/2,.53,0),Vector3(.04,1.06,.04),"52685a",false,0,yaw)

static func stair(b: Node3D,start: Vector3,end: Vector3,width: float=3.2) -> void:
	var step_count:=28;var run: float=end.z-start.z;var rise: float=end.y-start.y
	for i in step_count:
		var p:=start.lerp(end,(i+.5)/step_count);p.y=start.y+rise*(i+1)/step_count-.055
		K.box(b,p,Vector3(width,.11,absf(run)/step_count+.015),"9aa69c",false,6)
	var ramp:=K.surface(b,K.quad(start+Vector3(-width/2,0,0),start+Vector3(width/2,0,0),end+Vector3(width/2,0,0),end+Vector3(-width/2,0,0)),"9aa69c",6,true);ramp.hide()
	for side in [-1,1]:
		for i in 9:
			var p:=start.lerp(end,i/8.0)+Vector3(side*(width/2+.1),.54,0)
			K.box(b,p,Vector3(.05,1.08,.05),"566d5e")
		var rail:=K.holder(b,"StairRail",(start+end)/2+Vector3(side*(width/2+.1),1.1,0))
		rail.rotation.x=-atan2(rise,run)
		K.box(rail,Vector3.ZERO,Vector3(.07,.07,start.distance_to(end)),"566d5e");K.finish(rail)

static func laboratory(b: Node3D,r: Dictionary) -> void:
	preload("res://world/visual_campus/ResearchDetail.gd").build(b,r)
	if r.id=="hl_tu":
		var x: float=r.width*.32;var z: float=r.depth/2+3;var y: float=r.floor_levels[1]
		stair(b,Vector3(x,0,z+15),Vector3(x,y+.125,z),3)
		K.box(b,Vector3(x,y,z-1.65),Vector3(3.4,.25,3.3),"9daa9e",true,12)
		for side in [-1,1]:guardrail(b,Vector3(x+side*1.6,y+.125,z-1.65),3.3,PI/2)
		T.stair_soffit(b,Vector3(x,0,z+15),Vector3(x,y+.125,z),3)

static func zhang(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	var registered:=K.holder(b,"ZhangRegisteredStoreysV137",Vector3(0,-4.8,0))
	T.diagonal_massing(registered,r)
	preload("res://world/visual_campus/ZhangCourtGround.gd").build(b,r)
	preload("res://world/visual_campus/ZhangCourtCore.gd").build(registered,r)
	# Deepen the oblique court rearward while keeping the user's photographed
	# frontage, exterior stair and transverse bridge at their established world points.
	var front_shift: float=(d-45.0)*.36
	b=K.holder(b,"RetainedPhotoFrontage",Vector3(0,0,front_shift))
	r=r.duplicate();r["depth"]=45.0;d=45.0
	for x in [-w*.22,w*.20]:K.column(b,Vector3(x,0,d*.38),4.8,.65)
	K.box(b,Vector3(0,4.8,d*.42),Vector3(w*.78,.25,5),"b3b6ad",true,15)
	K.box(b,Vector3(0,.025,0),Vector3(w*.5,.04,d*.43),"aaa496",false,6)
	for x in [-w*.2,w*.15]:K.bench(b,Vector3(x,0,0));K.planter(b,Vector3(x,0,-6))
	K.screen(b,Vector3(-w*.27,0,d*.36),w*.12,4.5,.35)
	# V133 removes the deep generic duplicate door/shop wall. The observed public
	# entrance lives in ZhangEntranceArcade; this court is not a second named entry.
	for x in [-w*.2,w*.18]:K.box(b,Vector3(x,4.4,0),Vector3(.18,.20,d*.8),"b4beb0")
	preload("res://world/visual_campus/ZhangPhotoFront.gd").build(b,r)
	K.finish(b)

static func terrace_opening(cell: int,floor: int,count: int,enabled: bool) -> int:
	if not enabled:return -1
	return preload("res://world/visual_campus/ShawWestDetail.gd").opening(cell,floor,count)

static func dorm_facade(b: Node3D,w: float,d: float,levels: Array,side: int,voids: bool) -> void:
	var count:=maxi(3,roundi(w/3.1));var cell:=w/count
	for f in range(levels.size()-1):
		var bottom: float=levels[f];var top: float=levels[f+1];var h:=top-bottom
		for i in count:
			var x: float=(i+.5)*cell-w/2
			if terrace_opening(i,f,count,voids)>=0:
				K.box(b,Vector3(x,(bottom+top)/2,0),Vector3(cell,h,.16),"92774f",false,4)
				if terrace_opening(i,f,count,voids)==f:
					guardrail(b,Vector3(x,bottom+.15,side*(d/2+.08)),cell)
					K.planter(b,Vector3(x,bottom+.15,side*d*.23))
				continue
			var p:=Vector3(x,(bottom+top)/2,side*d/2)
			for edge in [-1,1]:
				K.box(b,p+Vector3(edge*(cell/2-.32),0,0),Vector3(.64,h,.32),"b7bdb1",true)
				K.box(b,p+Vector3(0,edge*(h/2-.25),0),Vector3(cell-1.28,.5,.32),"b7bdb1",true)
			K.window(b,p+Vector3(0,0,side*.13),cell-1.35,h-.8,0 if side>0 else PI)
			# Deep white bay edges, small sill and selective external air-conditioning boxes.
			for edge in [-1,1]:K.box(b,p+Vector3(edge*(cell/2-.12),0,side*.30),Vector3(.16,h,.55),"c5caba")
			K.box(b,Vector3(x,bottom+.12,side*(d/2+.35)),Vector3(cell,.22,.7),"c5caba")
			if i%3==0:K.box(b,p+Vector3(cell*.27,-.5,side*.65),Vector3(.55,.5,.4),"9fae9e",false,11)

static func dorm_bar(parent: Node3D,id: String,p: Vector3,size: Vector2,top: float,screen_side: int=1,yaw: float=0,floor_base: float=4.8) -> void:
	var b:=K.holder(parent,id,p);b.rotation.y=yaw
	var w:=size.x;var d:=size.y;var floors:=maxi(3,roundi((top-floor_base)/3.3))
	var levels: Array=[floor_base]
	for i in floors:levels.append(floor_base+(top-floor_base)*(i+1)/floors)
	# Thin shells keep the lower courtyard and intermediate terraces hollow.
	var voids: bool=id.begins_with("West")
	var count:=maxi(3,roundi(w/3.1));var cell:=w/count
	for f in levels.size():
		var level: float=levels[f]
		for i in count:
			var x: float=(i+.5)*cell-w/2
			# Keep the floor at the terrace's bottom; omit its intermediate slab.
			var open_floor:=terrace_opening(i,f,count,voids)
			if open_floor>=0 and f>open_floor:
				# A central corridor remains behind the two opposing recessed terraces.
				K.box(b,Vector3(x,level-.125,0),Vector3(cell+.01,.25,2.0),"adb8ad",true)
			else:K.box(b,Vector3(x,level-.125,0),Vector3(cell+.01,.25,d),"adb8ad",true)
	for side in [-1,1]:
		if voids:preload("res://world/visual_campus/ShawWestDetail.gd").elevation(b,w,d,levels,side,id=="WestCrossDorm")
		else:preload("res://world/visual_campus/ShawEastDetail.gd").elevation(b,w,d,levels,side)
		for x in range(-int(w/2)+2,int(w/2),7):
			var support_x: float=-8 if id=="WestCrossDorm" and x==-5 else float(x)
			K.column(b,Vector3(support_x,0,side*(d/2-.65)),floor_base,.65)
	for side in [-1,1]:
		if voids:preload("res://world/visual_campus/ShawWestDetail.gd").end_wall(b,w,d,levels,side)
		else:preload("res://world/visual_campus/ShawEastDetail.gd").end_wall(b,w,d,levels,side,id in ["EastSouthDorm","EastNorthDorm"] and side==-1)
	for level: float in ([] if voids else levels.slice(1,-1)):
		var gallery_side: int=screen_side if voids or id=="EastRearDorm" else -screen_side
		var gallery_depth: float=2.6 if voids else 1.6
		var z: float=gallery_side*(d/2+gallery_depth/2)
		K.box(b,Vector3(0,level,z),Vector3(w*.95,.18,gallery_depth),"a5b0a3",true)
		guardrail(b,Vector3(0,level+.1,gallery_side*(d/2+gallery_depth-.1)),w*.95)
	for side in [-1,1]:K.box(b,Vector3(0,top+.5,side*(d/2-.15)),Vector3(w,.75,.3),"bdc8b9")
	for i in 3:K.box(b,Vector3((i-1)*w*.25,top+.65,0),Vector3(3,1,2.8),"809184")
	K.finish(b)

static func shaw_east(b: Node3D,r: Dictionary) -> void:
	var residential:=preload("res://world/visual_campus/ShawEastResidence.gd")
	# 4F/7F plan registration; cut footprints follow diagram proportions, vertical extents fitted.
	residential.build(b,"EastRearDorm",Vector3(10.25,.45,-22.3),Vector2(47.5,14),34.8,0,[
		AABB(Vector3(-14.78,21.6,.86),Vector3(12.38,14.2,6.14)),
		AABB(Vector3(16.05,21.6,-7),Vector3(7.7,14.2,14))])
	residential.build(b,"EastSouthDorm",Vector3(-27,.45,3.2),Vector2(36.9,14),34.8,PI/2,[
		AABB(Vector3(0,21.6,-7),Vector3(12.5,14.2,6.2))])
	residential.build(b,"EastNorthDorm",Vector3(27,.45,9.3),Vector2(24.6,14),31.5,PI/2,[
		AABB(Vector3(-12.3,21.6,-.7),Vector3(6.2,10.9,7.7))])
	residential.build(b,"EastFrontReturn",Vector3(20.9,.45,25.45),Vector2(26.2,7.7),31.5,0,[
		AABB(Vector3(5.4,21.6,-3.85),Vector3(7.7,10.9,7.7))])
	residential.build(b,"EastRearReturn",Vector3(27,.45,-13.2),Vector2(14,4.2),21.6,0,[])
	preload("res://world/visual_campus/ShawEastPodium.gd").build(b)

static func shaw_west(b: Node3D,r: Dictionary) -> void:
	# V143 fourth-floor drawing: two parallel long wings and a perpendicular middle bar.
	# Uniform plan fit retains the existing anchor and60m front/back extent; metres remain inferred.
	var plan:=preload("res://world/visual_campus/ShawWestPlan.gd")
	# Drawing right-hand roof exit faces the retained mountain side (+worldX).
	b=K.holder(b,"WestPlanFrameV143");b.rotation.y=PI/2
	var rear:Rect2=plan.rect(474,64,225,475)
	var middle:Rect2=plan.rect(474,615,541,222)
	var front:Rect2=plan.rect(1217,737,224,541)
	dorm_bar(b,"WestRearDorm",Vector3(rear.get_center().x,0,rear.get_center().y),Vector2(rear.size.y,rear.size.x),41.8,1,PI/2,12.1)
	dorm_bar(b,"WestCrossDorm",Vector3(middle.get_center().x,0,middle.get_center().y),middle.size,38.5,-1,0,12.1)
	dorm_bar(b,"WestFrontDorm",Vector3(front.get_center().x,0,front.get_center().y),Vector2(front.size.y,front.size.x),35.2,-1,PI/2,12.1)
	plan.build(b)

static func connections(root: Node3D) -> void:
	preload("res://world/visual_campus/ResearchPhotoCourt.gd").build(root)
