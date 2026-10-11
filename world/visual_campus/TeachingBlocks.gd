extends RefCounted
## Teaching A/B/C: staggered bars, porous base, stone slit facade and screened court.
## The 2018 school aerial is the massing reference; Phase II photos are not assigned to TA.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func wall(root: Node3D,length: float,depth: float,levels: Array,axis: int,side: int,inner: bool,pitch: float,style: Dictionary={}) -> void:
	var count:=maxi(2,roundi(length/pitch));var cell:=length/count
	var yaw:=0.0 if axis==0 else PI/2
	var basis:=Basis(Vector3.UP,yaw)
	var origin:=Vector3(0,0,side*depth/2) if axis==0 else Vector3(side*depth/2,0,0)
	var screened: bool=inner and style.get("screened",true)
	var face_color: String=style.get("inner_color","937466") if inner else style.get("stone","bcbcaf")
	var finish: int=int(style.get("finish",0))
	for floor in range(levels.size()-1):
		if [axis,side,floor] in style.get("omitted_faces",[]):continue
		if inner and floor==style.get("omit_inner_floor",-1):continue
		if axis==1 and side==-1 and floor==style.get("omit_west_floor",-1):continue
		var bottom: float=levels[floor];var top: float=levels[floor+1]
		var window_height:=top-bottom-1.18;var window_width:=cell-.22 if screened else float(style.get("window_width",.64))
		for i in count:
			var u: float=(i+.5)*cell-length/2
			if axis==1 and floor<int(style.get("front_arcade_trim_floors",0)) and u < -length/2+4.0:continue
			var center:=origin+basis*Vector3(u,(bottom+top)/2,0)
			var door:bool=(inner and floor==style.get("inner_door_floor",-1) and absf(u-float(style.get("inner_door_center",0)))<cell*.49) or (axis==0 and side==-1 and floor==style.get("back_door_floor",-1) and absf(u-float(style.get("back_door_center",0)))<cell*1.01)
			for entry:Array in style.get("additional_doors",[]):
				if axis==entry[0] and side==entry[1] and floor==entry[2] and absf(u-float(entry[3]))<cell*.49:door=true
			if door:
				K.box(root,origin+basis*Vector3(u,bottom+2.9+(top-bottom-2.9)/2,0),Vector3(cell,top-bottom-2.9,.36),face_color,true,finish,yaw)
				continue
			if inner and floor==style.get("gallery_floor",-1) and absf(u)<length*.32:
				# The TA view has a broad open gallery interrupting the narrow-window wall.
				K.box(root,center+basis*Vector3(0,-(top-bottom)/2+.06,side*.13),Vector3(cell,.12,.55),face_color,false,finish,yaw)
				if absf(u+.7)>1.5:
					for q in 3:K.box(root,origin+basis*Vector3(u+(q-1)*cell/3,bottom+.55,side*.22),Vector3(.035,1.1,.035),"666d65",false,11,yaw)
					K.box(root,origin+basis*Vector3(u,bottom+1.10,side*.22),Vector3(cell,.065,.065),"666d65",false,11,yaw)
				continue
			# Separate masonry around a real opening; the glass is inset in the reveal.
			for edge in [-1,1]:
				var stone_width: float=(cell-window_width)/2
				K.box(root,center+basis*Vector3(edge*(window_width/2+stone_width/2),0,0),Vector3(stone_width,top-bottom,.36),face_color,true,finish,yaw)
				K.box(root,center+basis*Vector3(0,edge*(window_height/2+.295),0),Vector3(window_width,.59,.36),face_color,true,finish,yaw)
			var outward_yaw:=yaw+(PI if side<0 else 0.0)
			K.window(root,center-basis*Vector3(0,0,side*.14),window_width,window_height,outward_yaw)
			if not screened:K.box(root,center+basis*Vector3(0,-.22,side*.025),Vector3(window_width,.075,.17),"66716c",false,11,yaw)
			# The reveal and projecting sill cast real shadows rather than painted lines.
			K.box(root,center+basis*Vector3(0,-window_height/2-.025,side*.20),Vector3(window_width+.16,.075,.45),"b2b3a8",false,0,yaw)
			for jamb in [-1,1]:K.box(root,center+basis*Vector3(jamb*(window_width/2+.025),0,side*.08),Vector3(.055,window_height+.08,.24),"a8aca3",false,0,yaw)
			if screened:
				for fin in 4:K.box(root,center+basis*Vector3(-window_width/2+(fin+.5)*window_width/4,0,side*.26),Vector3(.055,window_height,.38),"92755a",false,4,yaw)
		# Thin floor strips give continuous horizontal shadow lines within the court.
		if inner:K.box(root,origin+Vector3.UP*bottom,Vector3(length,.18,.48) if axis==0 else Vector3(.48,.18,length),"b6bab2")

static func wing(parent: Node3D,id: String,position: Vector3,size: Vector2,levels: Array,inner_axis: int,inner_side: int,pitch: float,style: Dictionary={}) -> void:
	var root:=K.holder(parent,id,position)
	root.rotation.y=float(style.get("yaw",0.0))
	var width:=size.x;var depth:=size.y;var base: float=levels[0];var top: float=levels[-1]
	for level: float in levels:
		var slab_y:float=level-(.125 if style.get("floor_top_level",false) else 0.0)
		if (level==base and style.has("base_opening")) or (level<top and style.has("core_opening")):
			var opening:Rect2=style.get("core_opening",style.get("base_opening",Rect2()))
			var xs:Array[float]=[-width/2,opening.position.x,opening.end.x,width/2]
			var zs:Array[float]=[-depth/2,opening.position.y,opening.end.y,depth/2]
			xs.sort();zs.sort()
			for i in 3:
				for j in 3:
					var mid:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2)
					if xs[i+1]-xs[i]<.001 or zs[j+1]-zs[j]<.001 or opening.has_point(mid):continue
					K.box(root,Vector3(mid.x,slab_y,mid.y),Vector3(xs[i+1]-xs[i],.25,zs[j+1]-zs[j]),"aeb2a8",true,15)
		else:K.box(root,Vector3(0,slab_y,0),Vector3(width,.25,depth),"94978c" if level==top else "aeb2a8",true,18 if level==top else 15)
	for axis in [0,1]:
		var length: float=width if axis==0 else depth;var cross: float=depth if axis==0 else width
		for side in [-1,1]:wall(root,length,cross,levels,axis,side,axis==inner_axis and side==inner_side,pitch,style)
	# The ground arcade is structural space, not another row of tiny windows.
	for x in (range(-int(width/2)+2,int(width/2),6) if style.get("ground_columns",true) else []):
		for side in [-1,1]:
			var p:=Vector3(x,0,side*(depth/2-.6))
			if style.has("ground_door_center") and side==inner_side:
				var opening_center: float=style.ground_door_center
				if absf(p.x-opening_center)<3.5:p.x=opening_center+(4.4 if p.x>=opening_center else -4.4)
			K.box(root,p+Vector3.UP*base/2,Vector3(.58,base,.58),"b9bcb6",true,int(style.get("column_finish",0)))
			K.box(root,p+Vector3.UP*.18,Vector3(.72,.36,.72),"909b94")
			K.box(root,p+Vector3.UP*(base-.22),Vector3(.80,.40,.80),"b4b9af")
	for side in [-1,1]:K.box(root,Vector3(0,base-.20,side*(depth/2-.6)),Vector3(width,.40,.48),"a3ada5")
	if style.get("long_columns",false):
		# Deep rectilinear side wings need repeated supports along their long direction.
		for z in range(-int(depth/2)+8,int(depth/2)-4,6):
			for side in [-1,1]:
				K.box(root,Vector3(side*(width/2-.6),base/2,z),Vector3(.58,base,.58),"b9bcb6",true,22)
		for side in [-1,1]:K.box(root,Vector3(side*(width/2-.6),base-.20,0),Vector3(.48,.40,depth),"a3ada5")
	for side in [-1,1]:
		if not style.get("parapet",true):continue
		K.box(root,Vector3(0,top+.44,side*(depth/2-.13)),Vector3(width,.8,.26),"bcbcaf")
		K.box(root,Vector3(side*(width/2-.13),top+.44,0),Vector3(.26,.8,depth),"bcbcaf")
	# Small service boxes on the flat roof, as in the school aerial.
	for i in (3 if style.get("roof_equipment",true) else 0):
		K.box(root,Vector3(-width*.25+i*width*.25,top+.8,0),Vector3(2.7,1.4,2.2),"a3aaa2")
		for v in 5:K.box(root,Vector3(-width*.25+i*width*.25,top+1.53,-.8+v*.4),Vector3(2.1,.04,.07),"67746e")
	K.finish(root)

static func footprint(p: Vector3,size: Vector2,yaw: float=0) -> PackedVector2Array:
	var points:=PackedVector2Array();var basis:=Basis(Vector3.UP,yaw)
	for v in [Vector3(-size.x/2,0,-size.y/2),Vector3(size.x/2,0,-size.y/2),Vector3(size.x/2,0,size.y/2),Vector3(-size.x/2,0,size.y/2)]:
		var q: Vector3=p+basis*v;points.append(Vector2(q.x,q.z))
	return points

static func joined_parapet(b: Node3D,polygons: Array[PackedVector2Array],height: float) -> void:
	var outline: PackedVector2Array=polygons[0]
	for polygon: PackedVector2Array in polygons.slice(1):
		var joined:=Geometry2D.merge_polygons(outline,polygon)
		if joined.size()==1:outline=joined[0]
	for i in outline.size():
		var a: Vector2=outline[i];var c: Vector2=outline[(i+1)%outline.size()];var delta:=c-a;var middle: Vector2=(a+c)/2
		K.box(b,Vector3(middle.x,height+.40,middle.y),Vector3(delta.length(),.65,.22),"adafa3",false,15,atan2(-delta.y,delta.x))

static func diagonal_massing(b: Node3D,r: Dictionary) -> void:
	# Rocco's ground/3F/roof plans: three oblique classroom courts, plus the separate rectilinear A.
	# Plan image right is toward the East Gate; local +X is toward the deeper campus, hence reversed.
	var w: float=r.width;var d: float=r.depth
	var levels: Array=[4.8,8.5,12.2,15.9,19.6]
	if r.id in ["zhang_lingbin","teaching_c"]:levels.append(23.3)
	if r.id=="teaching_b":levels=[4.8,12.2,15.9,19.6,23.3]
	var stone: Dictionary={"stone":"b7ad9e","inner_color":"b7ad9e","screened":false,"finish":15,"window_width":.82,"parapet":false}
	var bronze: Dictionary={"stone":"b7ad9e","inner_color":"94725b","screened":true,"finish":15,"parapet":r.id=="teaching_b"}
	var a:=Vector3(w*.25,0,d*.36);var c:=Vector3(-w*.17,0,-d*.36)
	var diagonal: Dictionary=stone.duplicate();diagonal["yaw"]=atan2(a.x-c.x,a.z-c.z)
	if r.id=="teaching_b":
		diagonal["front_arcade_trim_floors"]=1
		diagonal["omitted_faces"]=[[0,1,0]]
	if r.id=="teaching_c":
		diagonal["front_arcade_trim_floors"]=2
		diagonal["omitted_faces"]=[[0,1,0],[0,1,1]] # Observed high entry owns these faces; avoid slit windows through its plain surround.
		diagonal["additional_doors"]=[[0,1,0,-1.96],[0,1,0,0.0],[0,1,0,1.96],[0,-1,0,-1.96],[0,-1,0,0.0],[0,-1,0,1.96],[1,-1,0,-1.03],[1,-1,0,1.03]]
	wing(b,"ObliqueClassroomBar",(a+c)/2,Vector2(w*.19,a.distance_to(c)),levels,1,-1,2.05,diagonal)
	var return_levels:Array=levels.slice(0,4) if r.id=="teaching_b" else levels
	var return_style:Dictionary=bronze.duplicate()
	if r.id=="zhang_lingbin":
		# V133: legacy triangle probes show three slab levels on this low return,
		# six on the diagonal/rear/front bars. Keep fitted storey spacing, not raw units.
		return_levels=levels.slice(0,3)
		return_style["parapet"]=false;return_style["roof_equipment"]=false
	if r.id=="zhang_lingbin":preload("res://world/visual_campus/ZhangSteppedWing.gd").build(b)
	elif r.id=="teaching_c":preload("res://world/visual_campus/ZhangSteppedWing.gd").build(b,false)
	elif r.id=="teaching_b":preload("res://world/visual_campus/TeachingBLowWing.gd").build(b)
	else:wing(b,"StraightCourtReturn",Vector3(-w*.41,0,0),Vector2(w*.16,d*.88),return_levels,1,1,2.0,return_style)
	var rear_style:Dictionary=stone.duplicate()
	if r.id=="zhang_lingbin":
		# Historic plan shows the rear return stair; fitted shaft leaves the roof intact.
		rear_style["core_opening"]=Rect2(-3.9,-6.86,4.8,12.5)
		rear_style["additional_doors"]=[]
		for floor in levels.size()-1:
			for u in [-1.96,0.0]:rear_style.additional_doors.append([0,1,floor,u])
	wing(b,"ShortRoadReturn",Vector3(-w*.27,0,-d*.36),Vector2(w*.42,d*.20),[4.8,9.425,15.9,19.6,23.3] if r.id=="teaching_b" else levels,0,1,2.0,rear_style)
	if r.id in ["teaching_b","teaching_c"]:
		var end_parent:Node3D=K.holder(b,"RetainedCPhotoEnd",Vector3(0,4.8,0)) if r.id in ["teaching_b","teaching_c"] else b
		preload("res://world/visual_campus/TeachingBFront.gd").end_block(end_parent,r)
	else:wing(b,"PromenadeEndBlock",Vector3(w*.24,0,d*.36-maxf(0,d-45)*.10),Vector2(w*.33,d*.20),levels,0,-1,2.0,stone)
	var roof_polygons: Array[PackedVector2Array]=[footprint((a+c)/2,Vector2(w*.19,a.distance_to(c)),float(diagonal.yaw)),footprint(Vector3(-w*.27,0,-d*.36),Vector2(w*.42,d*.20))]
	if r.id=="teaching_b":pass # B low wing / retained metal end own their roofs.
	elif r.id!="teaching_c":
		roof_polygons.insert(1,footprint(Vector3(w*.24,0,d*.36-maxf(0,d-45)*.10),Vector2(w*.33,d*.20)))
		if r.id!="zhang_lingbin":roof_polygons.append(footprint(Vector3(-w*.41,0,0),Vector2(w*.16,d*.88)))
	joined_parapet(b,roof_polygons,float(levels[-1]))
	# A narrow open walk links the otherwise distinct front ends; it is not a full-height fourth bar.
	if r.id=="teaching_c":
		# Keep the stair gallery behind the glazing, leaving the photographed high arcade open.
		K.box(b,Vector3(-w*.10,9.6,10.7+d*.46-21.62),Vector3(w*.62,.25,3.4),"b0b2a6",true,15)
	else:
		K.box(b,Vector3(-w*.10,9.6 if r.id=="teaching_b" else 4.8,d*.32),Vector3(w*.62,.25,6.4),"b0b2a6",true,15)
		for x in [-w*.36,-w*.10,w*.09]:K.column(b,Vector3(x,0,d*.30),4.7,.52)
	# Ground court remains permeable beneath the oblique building; dark arcade soffit gives its depth.
	var underside:=K.holder(b,"ObliqueArcadeSoffit",(a+c)/2);underside.rotation.y=float(diagonal.yaw)
	K.box(underside,Vector3(0,4.61,0),Vector3(w*.19,.12,a.distance_to(c)),"717870",false,18)
	for z in range(-int(a.distance_to(c)/2)+2,int(a.distance_to(c)/2),5):K.box(underside,Vector3(0,4.40,z),Vector3(w*.19,.28,.26),"8b958a",false,15)
	K.finish(underside)

static func build(b: Node3D,r: Dictionary) -> void:
	if r.id=="teaching_a":
		load("res://world/visual_campus/TeachingACadPlan.gd").build(b,load("res://world/visual_campus/TeachingBlocks.gd"))
		return
	var w: float=r.width;var d: float=r.depth
	var extension: float=maxf(0,d-47) if r.id=="teaching_a" else 0.0
	var variant: String=r.id
	var standard: Array=[4.8,8.5,12.2,15.9,19.6]
	var higher: Array=[4.8,8.5,12.2,15.9,19.6,23.3]
	var pitch:=1.95 if variant=="teaching_a" else (2.15 if variant=="teaching_b" else 1.8)
	var stone: Dictionary={"stone":"b7ad9e","inner_color":"b7ad9e","screened":false,"finish":15,"window_width":.82}
	var bronze: Dictionary={"stone":"b7ad9e","inner_color":"977a68","screened":true,"finish":15}
	var front_style: Dictionary=stone.duplicate()
	if variant=="teaching_a":
		front_style["gallery_floor"]=0
		front_style["column_finish"]=22
		front_style["ground_door_center"]=w*.10
	# Offset bars interlock around an open court; they do not form one symmetrical U-box.
	if variant=="teaching_a":
		# The rightmost ROCCO court is rectilinear and deep, unlike the three oblique courts.
		# Hold the photographed front arcade in world space; grow only toward the rear.
		var front_shift: float=extension*.46
		var side_style: Dictionary=stone.duplicate();side_style["long_columns"]=true
		wing(b,"PromenadeStoneBar",Vector3(-w*.10,0,16.92+front_shift),Vector2(w*.80,10.34),standard.slice(1),0,-1,pitch,front_style)
		wing(b,"ScreenedRearBar",Vector3(w*.10,0,-16.92+front_shift-extension),Vector2(w*.80,10.34),higher,0,1,pitch,bronze)
		wing(b,"SouthCrossBar",Vector3(-w*.39,0,-3.76+front_shift-extension/2),Vector2(w*.22,35.25+extension),standard,1,1,pitch,side_style)
		wing(b,"NorthCrossBar",Vector3(w*.39,0,3.76+front_shift-extension/2),Vector2(w*.22,35.25+extension),standard,1,-1,pitch,side_style)
		preload("res://world/visual_campus/TeachingASite.gd").build(b,r)
		# Fixed observed entry/return-stair coordinates are authored in the original datum.
		b=K.holder(b,"ObservedFrontSpace",Vector3(0,0,front_shift))
		r=r.duplicate();r["depth"]=47.0;d=47.0
	elif variant=="teaching_b":diagonal_massing(K.holder(b,"BRegisteredBodiesV139",Vector3(0,-4.8,0)),r)
	elif variant=="teaching_c":diagonal_massing(K.holder(b,"CRegisteredBodiesV138",Vector3(0,-4.8,0)),r)
	else:diagonal_massing(b,r)
	# Stone court, a raised edge walk and a real open entrance under the front bar.
	if variant not in ["teaching_b","teaching_c"]:K.box(b,Vector3(0,.025,0),Vector3(w*.60,.045,d*.45),"929d96",false,6)
	# The front wing already supplies its two column rows; a second gallery duplicated them.
	if variant=="teaching_a":
		# The tall arcade joins the retained upper datum, with the lower stair gallery inside the court.
		K.box(b,Vector3(-w*.10,8.5,d*.46),Vector3(w*.80,.25,4.2),"b3b6ad",true,15)
		K.box(b,Vector3(0,4.8,10.5),Vector3(w*.60,.25,3),"b3b6ad",true,15)
	elif variant!="teaching_c":
		K.box(b,Vector3(0,4.8,d*.46-2.8),Vector3(w*.75,.25,4.2),"b3b6ad",true,15)
		for x in range(-int(w*.375),int(w*.375),1):K.box(b,Vector3(x,4.45,d*.46),Vector3(.08,.18,4.2),"876f53",false,4)
		for x in [-3.5,3.5]:K.box(b,Vector3(x,2.35,d*.28),Vector3(.13,4.7,.18),"394541",true)
		K.box(b,Vector3(0,4.65,d*.28),Vector3(7,.16,.20),"394541")
	# Two usable stair flights lead to a landing at the front wing's inner edge.
	for side in [-1,1]:
		if variant!="teaching_a" and side==1:continue
		var stair_x: float=side*w*.22 if variant=="teaching_a" else -w*.27
		var shift: float=d*.32-15.04 if variant=="teaching_b" else (d*.46-21.62 if variant=="teaching_c" else 0.0)
		var start:=Vector3(stair_x,0,-8+shift);var end:=Vector3(stair_x,4.925,9+shift)
		for step in 28:
			var p:=start.lerp(end,(step+.5)/28.0);p.y=(step+1)*4.925/28-.105
			K.box(b,p,Vector3(2.4,.21,17.0/28+.015),"a9aca2",false,6)
		stair_soffit(b,start,end,2.4)
		var ramp:=K.surface(b,K.quad(start+Vector3(-1.2,0,0),start+Vector3(1.2,0,0),end+Vector3(1.2,0,0),end+Vector3(-1.2,0,0)),"969f97",6,true);ramp.visible=false
		K.box(b,Vector3(stair_x,4.80,10.7+shift if variant=="teaching_c" else 12+shift),Vector3(2.8,.25,3.4 if variant=="teaching_c" else 6),"a7afa5",true,6)
		for edge in [-1,1]:
			for post in 9:
				var p:=start.lerp(end,post/8.0)+Vector3(edge*1.25,.53,0)
				K.box(b,p,Vector3(.045,1.06,.045),"64736b")
			var rail:=K.holder(b,"StairHandrail",(start+end)/2+Vector3(edge*1.25,1.08,0));rail.rotation.x=-atan2(4.925,17)
			K.box(rail,Vector3.ZERO,Vector3(.06,.06,start.distance_to(end)),"64736b");K.finish(rail)
		K.bench(b,Vector3(side*8,0,-2));K.planter(b,Vector3(side*8,0,3))
	# Glazed rooms behind the rear arcade leave the central passage unobstructed.
	for x in range(-int(w*.32),int(w*.32),3):
		if variant!="teaching_a":continue
		if abs(x)<6:continue
		K.window(b,Vector3(x,2.05,-d*.25-extension),2.75,3.9)
	# Rail along the first-floor court walk, with a gap at each stair landing.
	for x in range(-int(w*.30),int(w*.30)):
		if variant=="teaching_c":continue
		if (abs(abs(x)-w*.22)<1.8 if variant=="teaching_a" else abs(x+w*.27)<1.8):continue
		K.box(b,Vector3(x,5.48,d*.32-3.33 if variant=="teaching_b" else d*.25),Vector3(.05,1.1,.05),"596d61")
		K.box(b,Vector3(x,6.02,d*.32-3.33 if variant=="teaching_b" else d*.25),Vector3(1.0,.06,.06),"596d61")
	if variant!="teaching_c":K.label(b,r.name,Vector3(0,4.45,d*.48),.012)
	# Timber accents stay inside the arcade instead of hiding the entire elevation.
	preload("res://world/visual_campus/TeachingPublicSpaces.gd").build(b,r)
	if variant=="teaching_b":
		preload("res://world/visual_campus/TeachingBFront.gd").promenade(b,r)
		preload("res://world/visual_campus/TeachingBSite.gd").build(b,r)
	elif variant=="teaching_c":
		preload("res://world/visual_campus/TeachingBSite.gd").build(b,r)
		preload("res://world/visual_campus/TeachingCCirculation.gd").build(b,r)
	if variant=="teaching_a":K.finish(b)

static func stair_soffit(b: Node3D,start: Vector3,end: Vector3,width: float) -> void:
	var a:=start+Vector3(-width/2,-.20,0);var c:=end+Vector3(width/2,-.20,0)
	var v:=PackedVector3Array()
	for side in [-1,1]:
		var p:=start+Vector3(side*width/2,-.20,0);var q:=end+Vector3(side*width/2,-.20,0)
		v.append_array(PackedVector3Array([p,q,q-Vector3.UP*.28,p,q-Vector3.UP*.28,p-Vector3.UP*.28]))
		v.append_array(PackedVector3Array([p,q-Vector3.UP*.28,q,p,p-Vector3.UP*.28,q-Vector3.UP*.28]))
	v.append_array(K.quad(a-Vector3.UP*.28,a+Vector3(width,-.28,0),c-Vector3.UP*.28,c-Vector3(width,.28,0)))
	# The underside faces downward, opposite the top of the stair flight.
	var underside:=PackedVector3Array()
	for i in range(v.size()-6,v.size(),3):underside.append_array(PackedVector3Array([v[i],v[i+2],v[i+1]]))
	v.append_array(underside)
	K.surface(b,v,"a9aca2",15)
