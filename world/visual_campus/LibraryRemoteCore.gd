extends RefCounted
## V112 remote stair registered to public4F and independently fitted5F. Absent in6F.
## Location and metre dimensions are fitted; no claim of surveyed fire-code compliance.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const YAW:float=-.0560585
const LEVELS := [0.0,4.4,8.8,12.8,16.8]
const WELL := Rect2(-2.05,-1.85,4.10,3.70)

static func point(p:Vector3)->Vector3:
	return P.point(204,361.5)+Basis(Vector3.UP,YAW)*p

static func rect_poly(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])

static func cut_openings(parts: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var result:Array[PackedVector2Array]=[]
	for p:PackedVector2Array in parts:
		var local:=PackedVector2Array()
		for v in p:
			var q:=Basis(Vector3.UP,-YAW)*(Vector3(v.x,0,v.y)-point(Vector3.ZERO));local.append(Vector2(q.x,q.z))
		for r:Rect2 in [Rect2(-150,-150,WELL.position.x+150,300),Rect2(WELL.end.x,-150,150-WELL.end.x,300),Rect2(WELL.position.x,-150,WELL.size.x,WELL.position.y+150),Rect2(WELL.position.x,WELL.end.y,WELL.size.x,150-WELL.end.y)]:
			for fragment:PackedVector2Array in Geometry2D.intersect_polygons(local,rect_poly(r)):
				var out:=PackedVector2Array()
				for v in fragment:
					var q:=point(Vector3(v.x,0,v.y));out.append(Vector2(q.x,q.z))
				result.append(out)
	return result

static func core_plaque(b:Node3D,text:String,p:Vector3,yaw:float=0) -> void:
	K.box(b,p,Vector3(1.7,.30,.04),"527d66",false,22,yaw)
	var label:=K.label(b,text,p+Basis(Vector3.UP,yaw)*Vector3(0,0,.025),.0024);label.rotation.y=yaw

static func floor_vertices(p:PackedVector2Array,y:float) -> PackedVector3Array:
	var ids:=Geometry2D.triangulate_polygon(p);var result:=PackedVector3Array()
	for i in range(0,ids.size(),3):
		var a:=Vector3(p[ids[i]].x,y,p[ids[i]].y);var c:=Vector3(p[ids[i+1]].x,y,p[ids[i+1]].y);var e:=Vector3(p[ids[i+2]].x,y,p[ids[i+2]].y)
		result.append_array(PackedVector3Array([a,e,c] if (c-a).cross(e-a).y>0 else [a,c,e]))
	return result

static func flight(parent:Node3D,p:Vector3,yaw:float,rise:float) -> void:
	var n:=K.holder(parent,"RemoteFireFlight",p);n.rotation.y=yaw
	var length:float=3.7;var width:float=1.55;var count:int=14
	for i in count:
		var h:float=(i+1)*rise/count;var z:float=(i+.5)*length/count
		K.box(n,Vector3(0,h-.065,z),Vector3(width,.13,length/count+.02),"b8b9ad",false,12)
		K.box(n,Vector3(0,h+.007,z-length/count*.42),Vector3(width-.08,.015,.06),"787e73",false,11)
	var a:=Vector3.ZERO;var c:=Vector3(0,rise,length)
	var ramp:=K.surface(n,K.quad(a+Vector3(-width/2,0,0),a+Vector3(width/2,0,0),c+Vector3(width/2,0,0),c+Vector3(-width/2,0,0)),"b8b9ad",12,true);ramp.hide()
	var top:=K.quad(a+Vector3(-width/2,-.22,0),a+Vector3(width/2,-.22,0),c+Vector3(width/2,-.22,0),c+Vector3(-width/2,-.22,0));var down:=PackedVector3Array()
	for i in range(0,top.size(),3):down.append_array(PackedVector3Array([top[i],top[i+2],top[i+1]]))
	K.surface(n,down,"c5c7bc",22,true)
	for side in [-1,1]:
		var rail:=K.holder(n,"RemoteStairRail",Vector3(side*.81,rise/2+.82,length/2));rail.rotation.x=-atan2(rise,length)
		# Shorten sloping infill at both ends so it does not project into the turning landing.
		K.box(rail,Vector3.ZERO,Vector3(.065,.62,sqrt(length*length+rise*rise)-.8),"abb1a6",true,11)
		K.box(rail,Vector3(0,.35,0),Vector3(.075,.065,sqrt(length*length+rise*rise)-.3),"d0d3c8",false,11);K.finish(rail)
	K.finish(n)

static func toilets(parent:Node3D,level:int,y:float) -> void:
	# Maps show a larger1F/2F rear block, smaller paired rooms on3F-5F.
	# Only public frontage/vestibules are represented; unseen fittings are not invented.
	if level>=3:
		upper_toilets(parent,level,y);return
	var n:=K.holder(parent,"RemoteToiletFrontage"+str(level))
	# Lower room identities retained. Front boundary trimmed to meet the registered stair rear.
	var spans:Array=[Vector2(-25.2,-23.45),Vector2(-23.45,-21.35),Vector2(-21.35,-19.35)]
	var names:Array=["女卫生间","无障碍卫生间","男卫生间"] if level<=2 else ["女卫生间","男卫生间"]
	var back:float=spans[0].x;var front:float=spans[-1].y
	# Flush visual facing closes the tiny seams between shared-room wall volumes.
	K.box(n,Vector3(-34.095,y+1.8,(back+front)/2),Vector3(.025,3.6,front-back),"b9bcb0",false,22)
	for i in spans.size():
		var span:Vector2=spans[i];var z:float=(span.x+span.y)/2
		K.box(n,Vector3(-37.2,y+1.8,z),Vector3(6.2,3.6,span.y-span.x-.06),"b9bcb0",true,22)
		# Recessed closed door, contrasting frame and handle; entry identity is map-backed.
		K.box(n,Vector3(-34.065,y+1.24,z),Vector3(.08,2.48,1.24),"8b998b",false,22)
		for edge in [-1,1]:K.box(n,Vector3(-34.0,y+1.26,z+edge*.65),Vector3(.14,2.52,.065),"bcc3b5",false,11)
		K.box(n,Vector3(-34.0,y+2.53,z),Vector3(.14,.065,1.36),"bcc3b5",false,11)
		K.box(n,Vector3(-33.94,y+1.05,z+.42),Vector3(.035,.30,.035),"d1d4c8",false,11)
		core_plaque(n,names[i],Vector3(-33.94,y+2.91,z),PI/2)
	K.box(n,Vector3(-32.75,y+.12,-21.0),Vector3(2.0,.025,10.0),"b4b6a9",false,12)
	dispenser(n,Vector3(-33.3,y,-18.2))
	K.finish(n)

static func dispenser(n:Node3D,p:Vector3)->void:
	K.box(n,p+Vector3(0,.57,0),Vector3(.65,1.14,.62),"acb9b1",true,11)
	K.box(n,p+Vector3(0,1.20,0),Vector3(.68,.12,.64),"707f78",false,11)
	K.box(n,p+Vector3(0,.96,.37),Vector3(.38,.06,.08),"d1d8cd",false,11)

static func upper_toilets(parent:Node3D,level:int,y:float)->void:
	var n:=K.holder(parent,"RegisteredRemoteToilets"+str(level))
	# Map4F and registered5F show paired unequal rooms, with doors on the rear cross aisle.
	for r in [[169,224,203,275,"女卫生间"],[203,224,237,310,"男卫生间"]]:
		var a:=P.point(r[0],r[1],y);var b:=P.point(r[2],r[3],y)
		var width:=P.point(r[0],r[1]).distance_to(P.point(r[2],r[1]));var depth:=P.point(r[0],r[1]).distance_to(P.point(r[0],r[3]))
		var h:=K.holder(n,"MapPairedToilet",(a+b)/2);h.rotation.y=YAW
		K.box(h,Vector3(0,1.8,0),Vector3(width,3.6,depth),"b9bcb0",true,22)
		K.box(h,Vector3(0,1.2,-depth/2-.025),Vector3(1.05,2.4,.05),"8b998b",false,22)
		for x in [-.56,.56]:K.box(h,Vector3(x,1.24,-depth/2-.07),Vector3(.065,2.48,.10),"c4c9bd",false,11)
		K.box(h,Vector3(0,2.5,-depth/2-.07),Vector3(1.2,.065,.10),"c4c9bd",false,11)
		core_plaque(h,r[4],Vector3(0,2.88,-depth/2-.12),PI);K.finish(h)
	dispenser(n,P.point(239,304,y))
	K.finish(n)

static func build(parent:Node3D) -> void:
	var b:=K.holder(parent,"LibraryRemoteLeftCore",point(Vector3.ZERO));b.rotation.y=YAW
	var height:float=20.6
	K.box(b,Vector3(0,.12,0),Vector3(4.2,.025,5.8),"b7b9ad",false,12)
	K.box(b,Vector3(-2.17,height/2,0),Vector3(.18,height,5.9),"b9bcb0",true,22)
	K.box(b,Vector3(2.17,height/2,-.625),Vector3(.18,height,4.65),"b9bcb0",true,22)
	for z in [-2.95,2.95]:K.box(b,Vector3(0,height/2,z),Vector3(4.5,height,.18),"b9bcb0",true,22)
	for i in LEVELS.size():
		var y:float=LEVELS[i]
		K.box(b,Vector3(0,y-.12,2.4),Vector3(4.2,.24,1.1),"b7b9ad",true,12)
		K.box(b,Vector3(2.17,y+3.35,2.35),Vector3(.18,.9,1.2),"b9bcb0",true,22)
		# Door kept open to the public aisle; jambs leave the full landing clear.
		for z in [1.77,2.87]:K.box(b,Vector3(2.23,y+1.3,z),Vector3(.13,2.6,.065),"788e80",false,11)
		core_plaque(b,str(i+1)+"F · 楼梯",Vector3(2.29,y+2.8,2.35),PI/2)
		K.box(b,Vector3(-.4,y+3.60,2.35),Vector3(1.2,.05,.35),"e2e0c9",false,17)
		var light:=OmniLight3D.new();light.position=Vector3(0,y+3,0);light.light_energy=.65;light.omni_range=8;light.light_color=Color("eeeddf");b.add_child(light)
		toilets(parent,i+1,y)
		if i==LEVELS.size()-1:continue
		var half:float=(LEVELS[i+1]-y)/2
		flight(b,Vector3(-1.02,y,1.85),PI,half)
		K.box(b,Vector3(0,y+half-.12,-2.4),Vector3(4.2,.24,1.1),"b7b9ad",true,12)
		flight(b,Vector3(1.02,y+half,-1.85),0,half)
		# Central landing edge prevents a shortcut through the well.
		K.box(b,Vector3(0,y+half+.60,-1.95),Vector3(.25,1.20,.10),"abb1a6",true,11)
	K.box(b,Vector3(0,height-.10,0),Vector3(4.5,.20,6.0),"b9bcb0",true,22)
	K.finish(b)
