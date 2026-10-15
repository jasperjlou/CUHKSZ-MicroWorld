extends RefCounted
## The older lower-campus cluster uses plain rendered walls, ribbons and equipment cages.
## Photos establish visible features; footprints and incomplete elevations stay estimated.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const F := preload("res://world/visual_campus/StartZoneFacades.gd")
const Public := preload("res://world/visual_campus/StartZonePublic.gd")
const IDS := ["cheng_dao","le_tian","zhi_ren","zhi_xin","dao_yuan"]

static func handles(id: String) -> bool:
	return id in IDS

static func facade(b: Node3D,length: float,depth: float,levels: Array,axis: int,side: int,ribbon: bool,cages: bool) -> void:
	F.build(b,length,depth,levels,axis,side,ribbon,cages)

static func bar(parent: Node3D,id: String,p: Vector3,size: Vector2,levels: Array,ribbon: bool=false,cages: bool=false) -> void:
	var b:=K.holder(parent,id,p);var top: float=levels[-1];var base: float=levels[0]
	for y:float in levels:
		if id=="ZhiXinRibbonLibraryWing":preload("res://world/visual_campus/OldLibraryCores.gd").slab(b,size,y)
		elif id=="ZhiXinTeachingReturn" and y<=15.7:
			# Lower union belongs to the rear library slab; never double-fill its stair hole.
			K.box(b,Vector3(0,y,4.29),Vector3(size.x,.24,14.82),"c2c6bd",true,15)
		else:K.box(b,Vector3(0,y,0),Vector3(size.x,.24,size.y),("797c74" if id.begins_with("ZhiXin") or id.begins_with("DaoYuan") else "a0aa9b") if y==top else "c2c6bd",true,(36 if id.begins_with("ZhiXin") or id.begins_with("DaoYuan") else 18) if y==top else 15)
	for axis in [0,1]:
		for side in [-1,1]:
			if id in ["ZhiXinLibraryReturn","ZhiXinTeachingReturn"] and axis==0 and side==1:
				continue # Joined front wing, no transverse wall across the gallery.
			elif id.begins_with("ZhiXinFront") and axis==0 and side==-1:
				var step_levels:Array=[15.7,19.4,23.1] if p.x<0 else [19.4,23.1]
				facade(b,size.x,size.y,step_levels,axis,side,false,false)
			elif id=="ZhiXinTeachingReturn" and axis==0 and side==-1:
				facade(b,size.x,size.y,[15.7,19.4],axis,side,false,false)
			elif id=="ZhiXinTeachingReturn" and axis==1:
				var exposed:=K.holder(b,"UnionExposedSideV166",Vector3(0,0,4.29))
				facade(exposed,14.82,size.x,[4.6,8.3,12.,15.7],axis,side,side<0,false)
				facade(b,size.y,size.x,[15.7,19.4],axis,side,side<0,false)
			elif id=="ZhiXinLibraryReturn" and axis==0 and side==-1:
				continue # V88 this wall is inside the joined rear bar.
			elif id=="ZhiXinRibbonLibraryWing" and axis==0 and side==1:
				# Return wings occupy both ends; only the courtyard opening is exposed.
				facade(b,size.x*.52,size.y,levels,axis,side,true,false)
			elif id.begins_with("ZhiXinFront") and axis==0 and side==1:
				zhixin_end(b,size.x,size.y,levels)
			elif id in ["ZhiXinLibraryReturn","ZhiXinRibbonLibraryWing","ZhiXinFront-1"] and axis==1 and side==-1:
				preload("res://world/visual_campus/OldLibraryFacade.gd").build(b,size.y,size.x,levels)
			elif axis==1 and ((id.begins_with("ZhiXinFront") and side==-signi(int(p.x))) or (id=="ZhiXinTeachingReturn" and side==-1)):
				# V76 named Main Square views: courtyard faces have wide continuous ribbons.
				# Keep the sparse STREET END and outer classroom faces separately evidenced.
				facade(b,size.y,size.x,levels,axis,side,true,false)
			else:facade(b,size.x if axis==0 else size.y,size.y if axis==0 else size.x,levels,axis,side,ribbon and ((size.x>=size.y and axis==0) or (size.y>size.x and axis==1)),cages and ((size.x>=size.y and axis==0) or (size.y>size.x and axis==1)))
	for x in range(-int(size.x/2)+2,int(size.x/2),6):
		for side in [-1,1]:K.column(b,Vector3(x,0,side*(size.y/2-.55)),base,.60)
	for side in [-1,1]:
		if id=="ZhiXinRibbonLibraryWing" and side==1:
			K.box(b,Vector3(0,top+.35,size.y/2-.12),Vector3(size.x*.52,.7,.24),"c8c9bf",false,22)
		elif not (id=="ZhiXinLibraryReturn" or (id=="ZhiXinTeachingReturn" and side==1)):
			K.box(b,Vector3(0,top+.35,side*(size.y/2-.12)),Vector3(size.x,.7,.24),"c8c9bf",false,22)
		if id=="ZhiXinRibbonLibraryWing" and side==1:
			K.box(b,Vector3(size.x/2-.12,top+.35,-4.29),Vector3(.24,.7,5.98),"c8c9bf",false,22)
		else:K.box(b,Vector3(side*(size.x/2-.12),top+.35,0),Vector3(.24,.7,size.y),"c8c9bf",false,22)
	K.finish(b)

static func glass_entry(b: Node3D,w: float,z: float,awning: bool) -> void:
	Public.glazing(b,w,z,awning)

static func zhixin_end(b: Node3D,w: float,d: float,levels: Array) -> void:
	# Five sparse upper rows on the taller end walls; the courtyard wing is lower.
	var z: float=d/2
	for i in levels.size()-1:
		var lo: float=levels[i];var hi: float=levels[i+1];var mid: float=(lo+hi)/2
		K.box(b,Vector3(0,mid,z-.19),Vector3(w,hi-lo,.32),"d2d3cb",true,22)
		K.box(b,Vector3(w*.22,mid,z-.012),Vector3(w*.30,2.12,.055),"9fa4a6",false,22)
		for x in [-w*.30,w*.065,w*.375]:F.window(b,Vector3(x,mid,z+.13),.98,2.1)
		K.box(b,Vector3(0,lo+.04,z+.012),Vector3(w,.045,.04),"b6bcb6",false,22)

static func banner(b: Node3D,p: Vector3,text: String) -> void:
	K.box(b,p,Vector3(1.9,13,.13),"63456e")
	K.label(b,text,p+Vector3(0,0,.09),.009)

static func build(b: Node3D,r: Dictionary) -> void:
	if r.id in ["cheng_dao","zhi_ren"]:
		preload("res://world/visual_campus/SquareClassroomBars.gd").build(b,r)
		return
	var w: float=r.width;var d: float=r.depth;var levels: Array=r.floor_levels.slice(1)
	match r.id:
		"le_tian":
			bar(b,"LeTianLongWindowBar",Vector3(0,0,-d*.16),Vector2(w,d*.43),levels,false,false)
			# V77 the former return overlapped the restored long Zhiren bar.
			glass_entry(b,w,d*.055,true)
			K.box(b,Vector3(0,.025,d*.25),Vector3(w*.80,.04,d*.42),"ad8071",false,7)
			for x in [-w*.32,w*.32]:K.planter(b,Vector3(x,0,d*.12));K.bench(b,Vector3(x,0,d*.30))
		"zhi_xin":
			var low: Array=[4.6,8.3,12.0,15.7]
			var tall: Array=[4.6,8.3,12.0,15.7,19.4,23.1]
			bar(b,"ZhiXinRibbonLibraryWing",Vector3(0,0,-d*.33),Vector2(w,d*.28),low,true)
			# Butt against the rear bar; overlapping shells formerly drew two window grids.
			bar(b,"ZhiXinLibraryReturn",Vector3(-w*.38,0,-d*.0475),Vector2(w*.24,d*.285),low,true)
			bar(b,"ZhiXinTeachingReturn",Vector3(w*.38,0,-d*.13),Vector2(w*.24,d*.45),[4.6,8.3,12.0,15.7,19.4],false)
			for side in [-1,1]:bar(b,"ZhiXinFront"+str(side),Vector3(side*w*.38,0,d*.29),Vector2(w*.24,d*.39),tall,false)
			glass_entry(b,w*.52,-d*.19,false)
			# Broad horizontal windows and teal ground glazing from the named square panorama.
			# V254 courtyard paving has one owner: ZhixinCourt, including the entrance seam.
			preload("res://world/visual_campus/ZhixinRoofPlant.gd").build(b,w,d)
			preload("res://world/visual_campus/OldLibraryCores.gd").build(b,w,d)
			preload("res://world/visual_campus/OldLibraryAtrium.gd").build(b)
			preload("res://world/visual_campus/OldLibraryStudy.gd").build(b)
			preload("res://world/visual_campus/OldLibraryCozyZone.gd").build(b)
		"dao_yuan":
			preload("res://world/visual_campus/DaoYuanRearWing.gd").build(b,w,d,levels)
			bar(b,"DaoYuanLowerClassroomWing",Vector3(-w*.35,0,-d*.07),Vector2(w*.30,d*.58),levels)
			preload("res://world/visual_campus/DaoYuanEnvelope.gd").build(b,w,d)
	Public.build(b,r)
	if r.id=="zhi_xin":
		var title:=K.label(b,"知新楼\nZhi Xin Building",Vector3(w*.38,6.2,d*.485+.10),.011);title.modulate=Color("334f46")
	else:
		var zz: float=d*.055+.2 if r.id=="le_tian" else (d*.29+3.6 if r.id=="zhi_ren" else (d*.35+4.6 if r.id=="dao_yuan" else d*.36+.2))
		K.box(b,Vector3(0,4.43,zz-.08),Vector3(9,.48,.10),"5f7367",false,11)
		K.label(b,r.name,Vector3(0,4.45,zz),.010)
