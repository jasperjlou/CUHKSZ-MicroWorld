extends RefCounted
## Public4F/5F/6F maps + architect-supplied historical atrium photographs.
## Curve, tread count, heights and details are fitted; no surveyed/as-built claim.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const A=preload("res://world/visual_campus/LibraryAtrium.gd")
const WIDTH:float=1.8

static func at(t:float,y:float)->Vector3:
	var u:float=1-t
	var x:float=u*u*662+2*u*t*726+t*t*793
	var z:float=u*u*716+2*u*t*721+t*t*787
	return P.point(x,z,y)

static func offset(t:float)->Vector3:
	var delta:=at(minf(1,t+.001),0)-at(maxf(0,t-.001),0)
	return Vector3(-delta.z,0,delta.x).normalized()*WIDTH/2

static func elevation(t:float)->float:
	if t<=.42:return 2*t/.42
	if t<=.58:return 2
	return 2+2*(t-.58)/.42

static func flat_link(n:Node3D,a:Vector3,b:Vector3,width:float=WIDTH)->void:
	var dir:Vector3=(b-a).normalized();var v:=Vector3(-dir.z,0,dir.x)*width/2
	K.surface(n,K.quad(a-v,a+v,b+v,b-v),"a6a89d",25,true)
	var top:=K.quad(a-v-Vector3.UP*.24,a+v-Vector3.UP*.24,b+v-Vector3.UP*.24,b-v-Vector3.UP*.24);var down:=PackedVector3Array()
	for i in range(0,top.size(),3):down.append_array(PackedVector3Array([top[i],top[i+2],top[i+1]]))
	K.surface(n,down,"dddcd0",22)
	for side in [-1,1]:A.edge_piece(n,a+v*side,b+v*side)

static func curved_flight(parent:Node3D,base:float)->void:
	var n:=K.holder(parent,"CurvedPublicStair"+str(base))
	var ts:Array[float]=[]
	for i in 13:ts.append(.42*i/12)
	ts.append(.58)
	for i in range(1,13):ts.append(.58+.42*i/12)
	var walk_mesh:=PackedVector3Array();var soffit:=PackedVector3Array();var tread_mesh:=PackedVector3Array();var risers:=PackedVector3Array()
	for i in range(ts.size()-1):
		var t0:float=ts[i];var t1:float=ts[i+1]
		var a:=at(t0,base+elevation(t0));var b:=at(t1,base+elevation(t1));var v0:=offset(t0);var v1:=offset(t1)
		walk_mesh.append_array(K.quad(a-v0,a+v0,b+v1,b-v1))
		var top_a:=Vector3(a.x,b.y,a.z)
		tread_mesh.append_array(K.quad(top_a-v0,top_a+v0,b+v1,b-v1))
		if b.y-a.y>.001:
			risers.append_array(K.quad(a-v0,a+v0,top_a+v0,top_a-v0))
			# Timber-coloured nosing across each actual curved tread, matching the photos.
			var h:=K.holder(n,"TreadNosing",top_a+Vector3.UP*.007);h.rotation.y=atan2(v0.x,v0.z)
			K.box(h,Vector3.ZERO,Vector3(.045,.016,WIDTH-.06),"bfa574",false,4);K.finish(h)
		for side in [-1,1]:A.rail(n,a+v0*side,b+v1*side)
		for side in [-1,1]:
			var q:=K.quad(a+v0*side-Vector3.UP*.27,b+v1*side-Vector3.UP*.27,b+v1*side,a+v0*side)
			q.append_array(PackedVector3Array([q[0],q[2],q[1],q[3],q[5],q[4]]));risers.append_array(q)
	for i in range(0,walk_mesh.size(),3):soffit.append_array(PackedVector3Array([walk_mesh[i]-Vector3.UP*.27,walk_mesh[i+2]-Vector3.UP*.27,walk_mesh[i+1]-Vector3.UP*.27]))
	K.surface(n,walk_mesh,"b8b9ac",12,true).hide()
	K.surface(n,tread_mesh,"92968d",25);K.surface(n,risers,"dddcd0",22);K.surface(n,soffit,"dddcd0",22,true)
	flat_link(n,P.point(625,710,base),at(0,base))
	flat_link(n,at(1,base+4),P.point(840,825,base+4))
	K.finish(n)

static func book_grid(n:Node3D,a:Vector3,b:Vector3,height:float)->void:
	var length:=a.distance_to(b);var q:=K.holder(n,"AtriumTallBookGrid",(a+b)/2);q.rotation.y=-atan2(b.z-a.z,b.x-a.x)+PI
	K.box(q,Vector3(0,height/2,0),Vector3(length,height,.26),"bb9561",true,4)
	var cols:=maxi(2,int(length/.85));var rows:=int(height/.56)
	for i in range(cols+1):K.box(q,Vector3(-length/2+length*i/cols,height/2,.22),Vector3(.045,height,.55),"cdb17b",false,4)
	for j in range(rows+1):K.box(q,Vector3(0,height*j/rows,.22),Vector3(length,.045,.55),"d1b783",false,4)
	for i in cols:
		for j in rows:
			if (i*7+j)%11!=0:continue
			for k in 3:K.box(q,Vector3(-length/2+(i+.2)*length/cols+k*.13,(j+.4)*height/rows,.43),Vector3(.09,.32,.14),["79918d","a29373","b8b49b"][k],false,22)
	K.finish(q)

static func roof_baffles(n:Node3D)->void:
	for area in [[[478,748],[577,748]],[[665,763],[753,807]]]:
		var a:=P.point(area[0][0],area[0][1],26.7);var b:=P.point(area[1][0],area[1][1],26.7);var direction:Vector3=(b-a).normalized()
		for i in 4:
			var p:=a.lerp(b,(i+.5)/4);var h:=K.holder(n,"AtriumPerforatedBaffle",p);h.rotation.y=atan2(direction.x,direction.z)+PI/2
			K.surface(h,K.quad(Vector3(-2,-.8,0),Vector3(2,-.8,0),Vector3(2,.8,0),Vector3(-2,.8,0)),"ccd6d2",19)
			for j in 24:K.box(h,Vector3(-2+j*4.0/23,0,0),Vector3(.022,1.6,.025),"d4dccf",false,22)
			for y in [-.8,0,.8]:K.box(h,Vector3(0,y,0),Vector3(4,.025,.04),"c0cbc1",false,11)
			for x in [-1.8,1.8]:K.box(h,Vector3(x,1.13,0),Vector3(.018,.65,.018),"adbab1",false,11)
			K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryCurvedCirculationV111")
	for y in [12.8,16.8]:curved_flight(n,y)
	# The6F bridge follows the outer rim rather than cutting a straight rectangular strip.
	var bridge:=P.sixth_bridge();K.surface(n,P.floor_vertices([bridge],20.8),"a4a69b",25,true)
	K.surface(n,P.floor_vertices([bridge],20.55,true),"d9d9cc",22)
	for i in range(5):
		var a:=bridge[i];var b:=bridge[i+1];A.edge_piece(n,Vector3(a.x,20.8,a.y),Vector3(b.x,20.8,b.y))
	# The5F rare-room door interrupts the tall shelf wall; keep the transom and lower shelves.
	for span in [[505,520],[562,578]]:book_grid(n,P.point(span[0],813,8.8),P.point(span[1],813,8.8),17.3)
	book_grid(n,P.point(520,813,8.8),P.point(562,813,8.8),7.9)
	book_grid(n,P.point(520,813,19.7),P.point(562,813,19.7),6.4)
	book_grid(n,P.point(637,833,8.8),P.point(699,861,8.8),17.3)
	roof_baffles(n)
	var light:=OmniLight3D.new();light.position=P.point(635,755,24.9);light.light_color=Color("edf0df");light.light_energy=.75;light.omni_range=19;n.add_child(light)
	K.finish(n)
