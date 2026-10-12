extends RefCounted
## V110: upper floor geometry uses a distinct registered plan, lower floors stay independent.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const A=preload("res://world/visual_campus/LibraryAtrium.gd")
const C=preload("res://world/visual_campus/LibraryServiceCores.gd")
const R=preload("res://world/visual_campus/LibraryFourthReading.gd")
const S=preload("res://world/visual_campus/LibrarySixthFloor.gd")

static func segment(n:Node3D,a:Vector3,b:Vector3,width:float,height:float,hex:String,solid:bool=false,kind:int=22)->void:
	var d:=b-a;var h:=K.holder(n,"RegisteredMember",(a+b)/2);h.rotation.y=atan2(d.x,d.z);h.rotation.x=-atan2(d.y,Vector2(d.x,d.z).length())
	K.box(h,Vector3.ZERO,Vector3(width,height,d.length()),hex,solid,kind);K.finish(h)

static func stair(n:Node3D,a:Vector3,b:Vector3,width:float=1.65)->void:
	var delta:=b-a;var run:=Vector2(delta.x,delta.z).length();var rise:=delta.y
	var h:=K.holder(n,"MapPublicFlight",a);h.rotation.y=atan2(delta.x,delta.z)
	var count:=maxi(2,int(ceil(rise/.165)))
	for i in count:
		K.box(h,Vector3(0,(i+1)*rise/count-.06,(i+.5)*run/count),Vector3(width,.12,run/count+.01),"c9c7b9",false,12)
		K.box(h,Vector3(0,(i+1)*rise/count+.005,i*run/count+.045),Vector3(width-.08,.012,.06),"8c8e81",false,11)
	var vertices:=K.quad(Vector3(-width/2,0,0),Vector3(width/2,0,0),Vector3(width/2,rise,run),Vector3(-width/2,rise,run))
	K.surface(h,vertices,"c9c7b9",12,true).hide()
	var down:=PackedVector3Array()
	for i in range(0,vertices.size(),3):down.append_array(PackedVector3Array([vertices[i]-Vector3.UP*.22,vertices[i+2]-Vector3.UP*.22,vertices[i+1]-Vector3.UP*.22]))
	K.surface(h,down,"deddd1",22,true)
	for side in [-1,1]:
		A.rail(h,Vector3(side*(width/2+.06),0,0),Vector3(side*(width/2+.06),rise,run))
		segment(h,Vector3(side*width/2,-.15,0),Vector3(side*width/2,rise-.15,run),.16,.32,"deddd1")
	K.finish(h)

static func left_stair(n:Node3D,y:float)->void:
	var a:=P.point(470,780 if y==16.8 else 825,y);var turn:=P.point(470,710,y+2);var end:=P.point(589,710,y+4)
	var first_end:=turn+(a-turn).normalized()*1.05;first_end.y=y+2
	var second_start:=turn+(end-turn).normalized()*1.05;second_start.y=y+2
	if y==16.8:
		# The shorter5F flight must end at the landing edge, without a shallow box riser.
		first_end=turn+Vector3(a.x-turn.x,0,a.z-turn.z).normalized()*1.075
		second_start=turn+Vector3(end.x-turn.x,0,end.z-turn.z).normalized()*1.075
	stair(n,a,first_end);stair(n,second_start,end)
	# Finish the incline before the slab edge, avoiding a low headroom wedge beneath it.
	var top_landing:=P.polygon([[589,697],[629,697],[629,723],[589,723]])
	K.surface(n,P.floor_vertices([top_landing],y+4),"c9c7b9",12,true)
	K.box(n,turn-Vector3.UP*.10,Vector3(2.15,.20,2.15),"d1cfc1",true,12,-.056)
	# Outside corner of the landing; openings face both flights.
	var p0:=P.point(453,693,y+2);var p1:=P.point(486,693,y+2);var p2:=P.point(453,726,y+2)
	A.rail(n,p0,p1);A.rail(n,p0,p2)

static func ring(n:Node3D,p:PackedVector2Array,y:float,left:bool=false)->void:
	for i in p.size():
		var a:=p[i];var b:=p[(i+1)%p.size()]
		if not left and p.size()==10:
			# Openings at the lower connecting bridge and upper curved-flight landing.
			if i==9 and y<20.8:b=a.lerp(b,.66)
			if i==5 and y>=16.8:a=a.lerp(b,.36)
		if left and i==1:
			if y==16.8:continue # V113 diagonal5F bridge owns this edge and its stair portal.
			# Upper landing crosses the sloping right edge near its top.
			a=a.lerp(b,.36)
		if left and i==2:
			if y==16.8:
				continue # Platform fills this edge and joins the rare-room doorway.
			# Lower flight crosses the bottom edge at public x470; leave a door-size gap.
			var q0:=P.point(489,809,y);var q1:=P.point(451,809,y)
			A.edge_piece(n,Vector3(a.x,y,a.y),q0)
			if Vector2(q1.x,q1.z).distance_to(b)>.1:A.edge_piece(n,q1,Vector3(b.x,y,b.y))
			continue
		A.edge_piece(n,Vector3(a.x,y,a.y),Vector3(b.x,y,b.y))

static func room401(n:Node3D)->void:
	var centre:=P.point(930,402,12.8);var r:=K.holder(n,"FabLab401MapEnvelope",centre);r.rotation.y=PI/4-.056
	var w:float=6.25;var d:float=5.4
	for side in [-1,1]:K.box(r,Vector3(side*w/2,1.6,0),Vector3(.14,3.2,d),"d3d2c4",true,22)
	K.box(r,Vector3(0,1.6,-d/2),Vector3(w,3.2,.14),"d3d2c4",true,22)
	for side in [-1,1]:K.box(r,Vector3(side*(w/4+.45),1.6,d/2),Vector3(w/2-.9,3.2,.12),"b7c7c0",true,19)
	K.box(r,Vector3(0,2.95,d/2),Vector3(1.8,.50,.16),"ced2c4",true,22)
	K.label(r,"401 · FabLab",Vector3(0,2.95,d/2+.10),.0038).modulate=Color("42574e")
	K.box(r,Vector3(0,.72,-.7),Vector3(3.8,.12,1.2),"c0ac83",true,4)
	for x in [-1.6,1.6]:K.box(r,Vector3(x,.34,-.7),Vector3(.10,.68,.95),"6a7870",false,11)
	K.finish(r)

static func reading(n:Node3D)->void:
	# Reuse the 2024-backed furniture details, but place them in the registered plan.
	for x in [286,340,394,448,502,556,610,664]:R.shelf(n,P.point(x,552,12.8),PI/2-.056,4.5,"H–P")
	for i in 9:R.shelf(n,P.point(916+i*32,656-i*34,12.8),-PI/4-.056,4.4,"P–Z")
	for x in [286,344,402,460]:R.shelf(n,P.point(x,890,12.8),PI/2-.056,4.3,"D–H")
	# Keep the complete cornice inside the curved shell, not just the shelf centre.
	for i in 4:R.shelf(n,P.point(530+i*52,860+i*25,12.8),PI/2+.20+i*.10-.056,3.6,"A–D")
	# Twenty added four-seat tables; the map icons are not an exact total furniture census.
	for x in [320,410,500]:
		for z in [205,285,365]:R.table(n,P.point(x,z,12.8),-.056)
	for z in [480,560,640]:R.table(n,P.point(206,z,12.8),PI/2-.056)
	for i in 4:R.table(n,P.point(1245-i*38,407+i*62,12.8),PI/4-.056)
	for i in 4:R.table(n,P.point(876+i*48,1110-i*48,12.8),PI/4-.056)
	var cam:=K.holder(n,"RegisteredCambridgeBay",P.point(416,115,0)-Vector3(-27,0,-22.5))
	R.cambridge_bay(cam);K.finish(cam)
	room401(n)

static func fifth(n:Node3D)->void:
	preload("res://world/visual_campus/LibraryRareReading.gd").build(n)
	S.cell(n,501,P.point(893,448,16.8),PI/4-.056,3,3.2);S.cell(n,502,P.point(934,408,16.8),PI/4-.056,3,3.2)
	for x in [310,410,510]:
		for z in [485,565]:S.desk(n,P.point(x,z,16.8),-.056)
	for i in 5:S.desk(n,P.point(992+i*38,681-i*40,16.8),PI/4-.056)

static func sixth(n:Node3D)->void:
	preload("res://world/visual_campus/LibrarySixthCommons.gd").build(n)
	# Guard the newly reduced floor edges. Clip to the shell and stop at core walls.
	var edges:Array[PackedVector2Array]=[P.polygon([[450,658],[609,658]]),P.polygon([[450,658],[450,690]]),P.polygon([[790,520],[770,650]])]
	var front:=P.sixth_front_void()
	for i in range(2,10):edges.append(PackedVector2Array([front[i],front[i+1]]))
	for polyline in edges:
		for clipped:PackedVector2Array in Geometry2D.intersect_polyline_with_polygon(polyline,P.outline()):
			for i in range(clipped.size()-1):
				var a:=clipped[i];var b:=clipped[i+1];var count:=maxi(1,int(ceil(a.distance_to(b)/.5)))
				for j in count:
					var q:=a.lerp(b,(j+.5)/count);var v:=Vector3(q.x,20.8,q.y)
					var local:Vector3=Basis(Vector3.UP,-PI/4)*(v-C.CORES[1].position);local/=C.CORES[1].scale
					if absf(local.x)<8.1 and absf(local.z)<8.1:continue
					var u:=a.lerp(b,float(j)/count);var t:=a.lerp(b,(j+1.0)/count)
					A.edge_piece(n,Vector3(u.x,20.8,u.y),Vector3(t.x,20.8,t.y))

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryRegisteredUpperV110")
	for level in [4,5,6]:
		var y:float=12.8+(level-4)*4;var floor_parts:Array[PackedVector2Array]=[]
		for part in P.pieces(level):floor_parts.append_array(C.cut_openings(part))
		K.surface(n,P.floor_vertices(floor_parts,y),"999b94",45 if level==4 else 25,true)
		K.surface(n,P.floor_vertices(floor_parts,y-.28,true),"d6d6cc",22)
		for i in 2:ring(n,P.holes()[i],y,i==0)
		# Actual double-height bays get guardrails rather than green placeholder slabs.
		if level>=5:
			for h in [P.polygon([[303,35],[555,35],[555,369],[303,369]]),P.polygon([[1238,232],[1370,365],[1277,460],[1145,328]])]:
				if level==5:ring(n,h,y)
		for p in [[350,490],[1000,600],[930,1060]]:
			var lamp:=OmniLight3D.new();lamp.position=P.point(p[0],p[1],y+3);lamp.light_energy=.65;lamp.omni_range=19;lamp.light_color=Color("ecebdc");n.add_child(lamp)
	# Both public stair families appear in the floor maps; their connections stay distinct.
	for y in [8.8,12.8,16.8]:left_stair(n,y)
	preload("res://world/visual_campus/LibraryCurvedCirculation.gd").build(n)
	reading(n);fifth(n);sixth(n)
	# The former850,740 support hung over the2F-3F stair void. Fit this one pier
	# wholly onto the adjacent3F slab;1.3m correction, not a surveyed column grid.
	for p in [[430,640],[600,640],[865,754],[690,936]]:
		var base:=P.point(p[0],p[1],8.8)
		# Existing supports used to stop at25.2, below the shaped roof soffit.
		A.round_column(n,base,P.roof_height(Vector2(base.x,base.z))-.20-base.y)
	K.finish(n)
