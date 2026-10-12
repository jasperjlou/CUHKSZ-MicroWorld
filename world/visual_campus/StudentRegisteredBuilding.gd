extends RefCounted
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Sheet=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Court=preload("res://world/visual_campus/StudentTerracedCourts.gd")
const Entry=preload("res://world/visual_campus/StudentLowerEntrances.gd")
const Dining=preload("res://world/visual_campus/StudentPublicSpaces.gd")

static func slab(n:Node3D,points:Array,y:float,holes:Array=[])->void:
	var parts:Array[PackedVector2Array]=[P.polygon(points)]
	# A real internal stair opening: decompose into disjoint masks, never triangulate a hole as a solid polygon.
	if y>1 and y<23:
		parts=subtract_rect(parts,[[146,28],[226,28],[226,84],[146,84]])
		parts=subtract_rect(parts,[[730,29],[794,29],[794,77],[730,77]])
		parts=subtract_rect(parts,[[225,626],[266,626],[266,688],[225,688]])
		if y<12:parts=subtract_rect(parts,[[850,467],[920,467],[920,502],[850,502]])
	for hole in holes:
		# All authored holes here are axis-aligned rectangles; an enclosed notch needs disjoint masks.
		parts=subtract_rect(parts,hole)
	for poly in parts:
		Sheet.sheet(n,poly,y,"858d8a" if y>23 else "b5b5a7",18 if y>23 else (53 if y<13 else 26),true)
		# Thin visible roof finish covers coplanar wall caps; structural collision stays on y.
		if y>23:Sheet.sheet(n,poly,y+.025,"858d8a",18,false)
		Sheet.sheet(n,poly,y-.28,"c6c7bb",22,false,false,86,58,true)
		for i in poly.size():
			var a:=poly[i];var b:=poly[(i+1)%poly.size()];var d:=b-a
			K.box(n,Vector3((a.x+b.x)/2,y-.14,(a.y+b.y)/2),Vector3(d.length(),.28,.04),"babdb0",false,22,-atan2(d.y,d.x))

static func subtract_rect(parts:Array[PackedVector2Array],hole:Array)->Array[PackedVector2Array]:
	var poly:=P.polygon(hole);var r:=Rect2(poly[0],Vector2.ZERO)
	for p in poly:r=r.expand(p)
	var masks:Array[Rect2]=[Rect2(-1000,-1000,r.position.x+1000,2000),Rect2(r.end.x,-1000,1000-r.end.x,2000),Rect2(r.position.x,-1000,r.size.x,r.position.y+1000),Rect2(r.position.x,r.end.y,r.size.x,1000-r.end.y)]
	var result:Array[PackedVector2Array]=[]
	for part in parts:
		for mask in masks:
			var q:=PackedVector2Array([mask.position,Vector2(mask.end.x,mask.position.y),mask.end,Vector2(mask.position.x,mask.end.y)])
			for piece in Geometry2D.intersect_polygons(part,q):result.append(piece)
	return result

static func wall(n:Node3D,a:Array,b:Array,levels:Array,facade:Callable)->void:
	var p:=P.point(a[0],a[1]);var q:=P.point(b[0],b[1]);var d:=q-p
	facade.call(n,(p+q)/2,d.length(),levels,-atan2(d.z,d.x))

static func rail(n:Node3D,a:Array,b:Array,y:float)->void:
	Court.rail(n,P.point(a[0],a[1],y),P.point(b[0],b[1],y))

static func flat_wall(n:Node3D,a:Array,b:Array,low:float,high:float,color:String,kind:int)->void:
	var p:=P.point(a[0],a[1]);var q:=P.point(b[0],b[1]);var d:=q-p
	K.box(n,(p+q)/2+Vector3.UP*(low+high)/2,Vector3(d.length(),high-low,.18),color,true,kind,-atan2(d.z,d.x))
	if kind==44:
		var face:=K.holder(n,"FoldedRedMetalPanels",(p+q)/2);face.rotation.y=-atan2(d.z,d.x)
		var count:=maxi(1,roundi(d.length()/.95));var pitch:=d.length()/count
		var face_sign:float=-1 if a[1]<=240 else 1
		for i in range(count+1):
			var x:float=-d.length()/2+i*pitch
			K.box(face,Vector3(x,(low+high)/2,face_sign*.13),Vector3(.045,high-low,.13),"88473e",false,44)
		for y in [low+.04,high-.04,4.4,8.8,12.4,16.]:
			if y<low or y>high:continue
			K.box(face,Vector3(0,y,face_sign*.105),Vector3(d.length(),.035,.075),"88473e",false,44)
		K.finish(face)

static func yellow(n:Node3D,u:float,v0:float,v1:float,low:float,high:float,stair_v:float=-999,allow_doors:bool=true)->void:
	# Same continuous interval logic as V151, now fitted to this traced facade width.
	var width:float=(v1-v0)/P.PIXELS_PER_METRE
	var h:=K.holder(n,"RegisteredYellowCourt",P.point(u,(v0+v1)/2))
	var count:=maxi(3,roundi(width/3.0));var pitch:=width/count;var cursor:float=-width/2
	for i in count:
		var x:float=-width/2+(i+.5)*pitch
		var centre_v:float=(v0+v1)/2-x*P.PIXELS_PER_METRE
		if absf(centre_v-stair_v)<40:
			# Keep the complete flight, including its rail clearance, open.
			var cut0:float=((v0+v1)/2-stair_v)/P.PIXELS_PER_METRE-2.25
			var cut1:float=cut0+4.5
			if cut0>cursor:K.box(h,Vector3((cursor+cut0)/2,(low+high)/2,0),Vector3(cut0-cursor,high-low,.28),"c4af5f",true,52)
			cursor=maxf(cursor,cut1);continue
		var left:float=x-.8
		if left<cursor:continue
		if left>cursor:K.box(h,Vector3((left+cursor)/2,(low+high)/2,0),Vector3(left-cursor,high-low,.28),"c4af5f",true,52)
		var ys:Array[float]=[]
		for y in [0.,4.4,8.8,12.4,16.]:
			if y>=low and y<=high:ys.append(y)
		for j in range(ys.size()-1):
			var y:float=ys[j];var top:float=ys[j+1]
			K.box(h,Vector3(x,top-.5,0),Vector3(1.6,1,.25),"999e93",true,22)
			var doorway:bool=allow_doors and j==0 and i in [1,count-2]
			if doorway:Entry.court_door(h,x,0,y,top)
			else:
				K.box(h,Vector3(x,(y+top-1)/2,-.1),Vector3(1.6,top-y-1,.1),"627b80",true,5)
				for side in [-1,1]:K.box(h,Vector3(x+side*.6675,(y+top)/2,.015),Vector3(.265,top-y,.28),"c4af5f",false,52)
				for dy in [.68,top-y-1.45]:K.box(h,Vector3(x,y+dy,.015),Vector3(1.09,.06,.15),"53646b",false,11)
			for side in [-1,1]:K.box(h,Vector3(x+side*(.82 if doorway else .55),(y+top)/2,0),Vector3(.065,top-y,.20),"53646b",false,11)
			if j==0:
				K.box(h,Vector3(x+1.06,y+1.92,.20),Vector3(.20,.20,.25),"b9bdb2",false,22)
				K.box(h,Vector3(x+1.06,y+1.91,.332),Vector3(.18,.085,.014),"e0e0d1",false,22)
		cursor=x+.8
	if cursor<width/2:K.box(h,Vector3((cursor+width/2)/2,(low+high)/2,0),Vector3(width/2-cursor,high-low,.28),"c4af5f",true,52)
	K.finish(h)

static func build(n:Node3D,builder,facade:Callable)->void:
	var b:=K.holder(n,"ScaleRegisteredStudent")
	var north:Array=[[25,24],[924,24],[924,240],[80,240]]
	var south:Array=[[218,560],[425,560],[425,505],[924,505],[924,691],[218,691]]
	var rear:Array=[[710,240],[924,240],[924,505],[710,505]]
	slab(b,P.outline(),.075)
	slab(b,[[100,242],[218,242],[218,560],[100,560]],.075)
	for y in [4.4,8.8,12.4]:
		if y>=8.8:slab(b,north,y,[[[310,80],[425,80],[425,200],[310,200]]])
		else:slab(b,north,y,[[[310,20],[425,20],[425,80],[310,80]]])
		slab(b,south,y)
		if y<12.4:slab(b,rear,y)
	# Court flight footprints now share the registered third-floor plan.
	var flights:=preload("res://world/visual_campus/StudentCourtStairs.gd").flights()
	var first:Dictionary=flights[0];var middle:Dictionary=flights[1];var upper:Dictionary=flights[2]
	slab(b,[[100,240],[425,240],[425,560],[100,560]],4.4,[[[first.u0-2,first.v0-1],[first.u1+1,first.v0-1],[first.u1+1,561],[first.u0-2,561]]])
	slab(b,[[425,240],[710,240],[710,459],[425,459]],8.8,[[[415,middle.v0-1],[middle.u1+1,middle.v0-1],[middle.u1+1,460],[415,460]]])
	slab(b,[[710,240],[924,240],[924,505],[710,505]],12.4)
	preload("res://world/visual_campus/StudentCourtStairs.gd").build(b,builder)
	# Historic3F: this aisle joins the middle court to the south wing; no gap or guard across it.
	slab(b,[[425,459],[710,459],[710,505],[425,505]],8.8)
	for edge in [[[100,240],[100,425],4.4],[[100,491],[100,559],4.4],[[100,559],[425,559],4.4],[[425,240],[425,middle.v0-1],8.8],[[425,459],[425,505],8.8],[[710,upper.v1+1],[710,505],12.4]]:rail(b,edge[0],edge[1],edge[2])
	# Guard the low end and side of the first stairwell from the upper promenade.
	rail(b,[first.u0-2,first.v0-1],[first.u1+1,first.v0-1],4.4)
	rail(b,[first.u0-2,first.v0-1],[first.u0-2,559],4.4)
	for y in [16.,19.6,23.2]:
		for poly in P.upper_parts():slab(b,poly,y)
	# Two lower wings have different front edges; the upper front wing cantilevers.
	# Retained library link enters at 2F. This fitted portal is not a verified historic door.
	for span in [[25,310],[425,924]]:wall(b,[span[0],24],[span[1],24],[0,4.4],facade)
	for span in [[25,235],[296,310],[425,924]]:wall(b,[span[0],24],[span[1],24],[4.4,8.8],facade)
	flat_wall(b,[235,24],[296,24],7.9,8.8,"b7bab5",7)
	wall(b,[25,24],[924,24],[8.8,12.4,16],facade)
	for y in [8.8,12.4]:
		rail(b,[310,80],[310,200],y);rail(b,[425,80],[425,200],y);rail(b,[310,200],[425,200],y);rail(b,[310,80],[425,80],y)
	wall(b,[924,691],[218,691],[0,4.4,8.8,12.4,16],facade)
	wall(b,[80,242],[25,24],[0,4.4,8.8,12.4,16],facade)
	wall(b,[218,691],[218,560],[0,4.4,8.8,12.4,16],facade)
	for span in [[24,428],[467,562],[598,691]]:wall(b,[924,span[0]],[924,span[1]],[0,4.4],facade)
	wall(b,[924,24],[924,691],[4.4,8.8,12.4],facade)
	upper_walls(b,facade)
	for span in [[24,240],[505,691]]:wall(b,[924,span[0]],[924,span[1]],[12.4,16],facade)
	# Side galleries open to the first court; red panels stop at the library-side passage.
	for span in [[80,250],[315,425]]:flat_wall(b,[span[0],240],[span[1],240],0,8.8,"9d5147",44)
	flat_wall(b,[250,240],[315,240],0,4.15,"9d5147",44)
	flat_wall(b,[218,560],[425,560],4.4,12.4,"9d5147",44)
	yellow(b,425,240,560,0,8.8,(middle.v0+middle.v1)/2)
	yellow(b,710,240,505,4.4,12.4,(upper.v0+upper.v1)/2)
	# The outer fourth-court edge has no landing beyond it; generic courtyard doors opened into air.
	yellow(b,924,240,505,12.4,16,-999,false)
	# Reuse detailed door frames at the actual traced rear positions.
	for spec in [[447.5,2.8],[580.,2.6]]:
		Entry.door(b,P.point(924,spec[0]),spec[1],3.25,PI)
		flat_wall(b,[924,spec[0]-spec[1]*P.PIXELS_PER_METRE/2],[924,spec[0]+spec[1]*P.PIXELS_PER_METRE/2],3.4,4.4,"a4aaa4",7)
	for v in [431,464]:flat_wall(b,[794,v],[924,v],0,4.2,"b8bcae",22)
	for q in [[175,380,4.4],[585,350,8.8],[825,380,12.4]]:Dining.table(b,P.point(q[0],q[1],q[2]))
	# Public ground dining, schematic fitout retained outside the new stair routes.
	for u in [330,470,610,750]:
		for v in [160,630]:Dining.table(b,P.point(u,v,.075))
	preload("res://world/visual_campus/StudentFrontCore.gd").build(b,builder)
	preload("res://world/visual_campus/StudentRearCore.gd").build(b,builder)
	preload("res://world/visual_campus/StudentSouthCore.gd").build(b,builder)
	preload("res://world/visual_campus/StudentUpperCrossWing.gd").build(b)
	preload("res://world/visual_campus/StudentRearLowerCore.gd").build(b,builder)
	preload("res://world/visual_campus/StudentPondUpperFacade.gd").build(b)
	preload("res://world/visual_campus/StudentPondEntry.gd").build(b)
	K.finish(b)

# Upper gallery follows the fifth-floor drawing. The sixth-floor repeat remains a fit.
static func fifth(q:Array)->Array:
	var p:=P.fifth_to_first(q[0],q[1]);return [p.x,p.y]

static func upper_portal(n:Node3D,a:Array,b:Array,levels:Array=[16.,19.6])->void:
	for y in levels:
		flat_wall(n,fifth(a),fifth(b),y+3.05,y+3.6,"b7bab5",7)

static func upper_walls(n:Node3D,facade:Callable)->void:
	var raw:=P.upper_raw_parts()
	for index in range(4):
		var poly:Array=raw[index]
		for i in poly.size():
			var a:Array=poly[i];var b:Array=poly[(i+1)%poly.size()]
			if index==0 and a==[300,24] and b==[300,548]:
				for span in [[24,187],[240,548]]:wall(n,fifth([300,span[0]]),fifth([300,span[1]]),[16,19.6,23.2],facade)
				upper_portal(n,[300,187],[300,240]);continue
			if index==1:
				# Two rooms stop before the circulation strip, as shown by the two doors in 031.
				if a[1]==228 and b[1]==228:
					for span in [[410,438],[464,544],[570,592]]:wall(n,fifth([span[1],187]),fifth([span[0],187]),[16,19.6],facade)
					for span in [[438,464],[544,570]]:upper_portal(n,[span[0],187],[span[1],187],[16.])
					continue
				if a[1]==228:a=[a[0],187]
				if b[1]==228:b=[b[0],187]
			if index==2 and a==[688,228] and b==[688,24]:
				wall(n,fifth([688,187]),fifth([688,24]),[16,19.6,23.2],facade)
				upper_portal(n,[688,187],[688,228]);continue
			if index==3 and a==[410,440] and b==[893,440]:
				wall(n,fifth(a),fifth(b),[16,19.6],facade)
				wall(n,fifth([592,440]),fifth(b),[19.6,23.2],facade);continue
			wall(n,fifth(a),fifth(b),[16,19.6,23.2],facade)
	flat_wall(n,fifth([494,24]),fifth([494,187]),16,23.2,"b8b9ad",22)
	for y in [16.,19.6]:
		for span in [[300,410],[592,688]]:rail(n,fifth([span[0],187]),fifth([span[1],187]),y)
		if y<19:rail(n,fifth([300,240]),fifth([695,240]),y)
		else:
			for span in [[300,410],[592,695]]:rail(n,fifth([span[0],240]),fifth([span[1],240]),y)
		rail(n,fifth([695,240]),fifth([695,228]),y)
