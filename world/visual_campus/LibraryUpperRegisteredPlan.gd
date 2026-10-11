extends RefCounted
## Public4F 1920x1295 display frame, composed with V109 ground registration.
## Hand-traced boundaries and fitted heights, never survey coordinates or true north.
static func point(x:float,z:float,y:float=0)->Vector3:
	var gx:float=1.2669245081364755*x-.0541946433834103*z-185.6489669179393
	var gz:float=.0541946433834103*x+1.2669245081364755*z-191.56651031661772
	return Vector3(.04977559923487591*gx-.0006624529060538255*gz-39.90463089502321,y,.0006624529060538255*gx+.04977559923487591*gz-29.700326258492026)

static func polygon(points:Array)->PackedVector2Array:
	var out:=PackedVector2Array()
	for v in points:
		var p:=point(v[0],v[1]);out.append(Vector2(p.x,p.z))
	return out

static func point5(x:float,z:float,y:float=0)->Vector3:
	return point(.8249289204508851*x+.0008083662350958268*z+154.90246356211125,-.0008083662350958268*x+.8249289204508851*z+20.37877273807726,y)

static func point6(x:float,z:float,y:float=0)->Vector3:
	return point(.9620044203509754*x+.01026917229407026*z+166.16035563659386,-.01026917229407026*x+.9620044203509754*z+7.520286183500161,y)

static func map_polygon(points:Array,level:int)->PackedVector2Array:
	var out:=PackedVector2Array()
	for v in points:
		var q:=point5(v[0],v[1]) if level==5 else point6(v[0],v[1]);out.append(Vector2(q.x,q.z))
	return out

static func rare_room()->PackedVector2Array:
	return map_polygon([[178,952],[448,952],[486,964],[543,988],[584,1013],[622,1040],[535,1150],[440,1140],[178,1133]],5)

static func fifth_diagonal_bridge()->PackedVector2Array:
	return map_polygon([[550,795],[603,798],[543,950],[489,940]],5)

static func rare_landing()->PackedVector2Array:
	return polygon([[442,779],[558,779],[604,804],[604,823],[442,818]])

static func fifth_left_void()->PackedVector2Array:
	return map_polygon([[12,785],[198,785],[198,947],[176,947],[176,1133],[12,1133]],5)

static func sixth_front_void()->PackedVector2Array:
	return map_polygon([[-100,700],[279,700],[279,837],[414,837],[463,845],[510,857],[557,884],[584,916],[547,951],[698,1099],[643,1157],[-100,1500]],6)

static func outline()->PackedVector2Array:
	return polygon([[240,20],[570,20],[570,415],[635,445],[705,478],[765,503],[782,504],[784,518],[802,518],[819,475],[849,433],[889,385],[1140,110],[1406,370],[1351,420],[1307,476],[1264,550],[1228,635],[1199,728],[1179,812],[1175,872],[1188,934],[889,1220],[823,1148],[757,1077],[695,1000],[641,979],[563,967],[459,962],[330,960],[156,960],[156,192],[240,192]])

static func holes()->Array[PackedVector2Array]:
	# Map outlines include landing/stair symbols. Leave the shared core boundary at x435
	# intact; x450 is the clear opening, rather than cutting through the lift enclosure.
	return [polygon([[450,690],[609,695],[578,809],[450,809]]),polygon([[650,690],[682,694],[717,705],[750,724],[788,757],[823,790],[730,881],[701,852],[663,831],[612,814]])]

static func sixth_bridge()->PackedVector2Array:
	return polygon([[609,658],[682,665],[733,682],[770,710],[808,744],[850,787],[830,804],[787,765],[751,734],[718,710],[679,694],[609,690]])

static func cross(a:Vector2,b:Vector2,p:Vector2)->float:
	return (b-a).cross(p-a)

static func halfplane(p:PackedVector2Array,a:Vector2,b:Vector2,inside:bool)->PackedVector2Array:
	var result:=PackedVector2Array()
	if p.size()<3:return result
	var sign_value:float=1 if inside else -1
	for i in p.size():
		var u:=p[i];var v:=p[(i+1)%p.size()];var du:float=cross(a,b,u)*sign_value;var dv:float=cross(a,b,v)*sign_value
		if du>=-.00001:result.append(u)
		if (du>0 and dv<0) or (du<0 and dv>0):result.append(u.lerp(v,du/(du-dv)))
	return result if result.size()>=3 else PackedVector2Array()

static func subtract_convex(subject:PackedVector2Array,hole:PackedVector2Array)->Array[PackedVector2Array]:
	var out:Array[PackedVector2Array]=[];var remaining:=subject;var clip:=hole.duplicate();var area:float=0
	for i in clip.size():area+=clip[i].cross(clip[(i+1)%clip.size()])
	if area<0:clip.reverse()
	for i in clip.size():
		if remaining.is_empty():break
		var a:=clip[i];var b:=clip[(i+1)%clip.size()]
		var outside:=halfplane(remaining,a,b,false)
		if not outside.is_empty():out.append(outside)
		remaining=halfplane(remaining,a,b,true)
	return out

static func subtract(parts:Array[PackedVector2Array],hole:PackedVector2Array)->Array[PackedVector2Array]:
	var result:=parts
	for convex:PackedVector2Array in Geometry2D.decompose_polygon_in_convex(hole):
		var next:Array[PackedVector2Array]=[]
		for p in result:next.append_array(subtract_convex(p,convex))
		result=next
	return result

static func pieces(level:int)->Array[PackedVector2Array]:
	var result:Array[PackedVector2Array]=[];var boundary:=outline();var ids:=Geometry2D.triangulate_polygon(boundary)
	for i in range(0,ids.size(),3):result.append(PackedVector2Array([boundary[ids[i]],boundary[ids[i+1]],boundary[ids[i+2]]]))
	for h in holes():result=subtract(result,h)
	if level>=5:
		# Public5F green areas are double-height voids, not green floor material.
		result=subtract(result,polygon([[303,35],[555,35],[555,369],[303,369]]))
		result=subtract(result,polygon([[1238,232],[1370,365],[1277,460],[1145,328]]))
	if level==5:
		result=subtract(result,fifth_left_void())
		result=subtract(result,rare_landing())
		result=subtract(result,fifth_diagonal_bridge())
	if level==6:
		# Reduced upper floor: rear/left wing absent, narrow bridge retained over the stair.
		result=subtract(result,polygon([[100,-100],[790,-100],[790,520],[770,650],[770,710],[733,682],[682,665],[609,658],[100,658]]))
		result=subtract(result,polygon([[-100,-100],[450,-100],[450,1500],[-100,1500]]))
		result=subtract(result,sixth_front_void())
		result=subtract(result,sixth_bridge())
	return result

static func floor_vertices(parts:Array[PackedVector2Array],y:float,down:bool=false)->PackedVector3Array:
	var vertices:=PackedVector3Array()
	for p in parts:
		var ids:=Geometry2D.triangulate_polygon(p)
		for i in range(0,ids.size(),3):
			var a:=Vector3(p[ids[i]].x,y,p[ids[i]].y);var b:=Vector3(p[ids[i+1]].x,y,p[ids[i+1]].y);var c:=Vector3(p[ids[i+2]].x,y,p[ids[i+2]].y)
			if (b-a).cross(c-a).length_squared()<.000000001:continue
			vertices.append_array(PackedVector3Array([a,c,b] if ((b-a).cross(c-a).y>0)!=down else [a,b,c]))
	return vertices
