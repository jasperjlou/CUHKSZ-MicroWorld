extends RefCounted
## V139 legacy B low-wing trace. Native units/date unverified; uniform local fit.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ZhangSteppedWing.gd")
static func outline()->PackedVector2Array:
	var p:=PackedVector2Array()
	for v:Vector2 in [Vector2(-664.5,-231.5),Vector2(-625.5,-231.5),Vector2(-605.4,-209.7),Vector2(-616.5,-118.5),Vector2(-616.5,-101.3),Vector2(-664.5,-101.3)]:p.append(Vector2(-34.3,-24.44)+(v-Vector2(-664.5,-231.5))*.4625)
	return p
static func face(n:Node3D,a:Vector2,c:Vector2,bottom:float,top:float)->void:
	var length:=a.distance_to(c);var count:=maxi(1,roundi(length/2.1));var bay:=length/count
	var yaw:=atan2(-(c.y-a.y),c.x-a.x);var basis:=Basis(Vector3.UP,yaw);var mid:=Vector3((a.x+c.x)/2,0,(a.y+c.y)/2)
	for i in count:
		var x:float=(i+.5)*bay-length/2;var ww:float=bay-.38
		for side in [-1,1]:
			K.box(n,mid+basis*Vector3(x+side*(ww/2+.095),(bottom+top)/2,0),Vector3(.19,top-bottom,.30),"b7ad9e",true,15,yaw)
			K.box(n,mid+basis*Vector3(x,(bottom+top)/2+side*((top-bottom)/2-.36),0),Vector3(ww,.72,.30),"b7ad9e",true,15,yaw)
		var wh:float=top-bottom-1.44
		K.window(n,mid+basis*Vector3(x,(bottom+top)/2,-.06),ww,wh,yaw+PI)
		K.box(n,mid+basis*Vector3(x,(bottom+top)/2,-.06),Vector3(ww,wh,.06),"627b7d",true,5,yaw)
		for f in 4:K.box(n,mid+basis*Vector3(x-ww/2+(f+.5)*ww/4,(bottom+top)/2,-.22),Vector3(.055,wh,.30),"94725b",false,4,yaw)
static func build(b:Node3D)->void:
	var n:=K.holder(b,"TeachingBLowWingV139");var p:=outline()
	P.slab(n,p,4.8);P.slab(n,p,15.9)
	# Upper slab has a real slot around the retained front stair; no phantom slab.
	for rect:Rect2 in [Rect2(-80,-80,59.06,160),Rect2(-17.94,-80,100,160),Rect2(-20.94,-80,3,87.04),Rect2(-20.94,24.04,3,60)]:
		var q:=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
		for clipped:PackedVector2Array in Geometry2D.intersect_polygons(p,q):P.slab(n,clipped,9.425)
	for i in range(1,p.size()):
		var a:Vector2=p[i];var c:Vector2=p[(i+1)%p.size()]
		if i==3:pass # First-level photographed lobby owns this front side-wall segment.
		elif i==4:face(n,Vector2(-23,a.y),c,4.8,9.425)
		else:face(n,a,c,4.8,9.425)
		if i==4:
			face(n,a,Vector2(-17.8,a.y),9.425,15.9);face(n,Vector2(-21.1,a.y),c,9.425,15.9)
			K.box(n,Vector3(-19.45,14.1625,a.y),Vector3(3.3,3.475,.30),"b7ad9e",true,15)
		else:face(n,a,c,9.425,15.9)
		var d:=c-a;var yaw:=atan2(-d.y,d.x)
		K.box(n,Vector3((a.x+c.x)/2,16.54,(a.y+c.y)/2),Vector3(d.length(),1.02,.22),"b7ad9e",true,15,yaw)
	for x in [-31,-23,-15]:
		for z in [-19,-4,12,26]:
			if Geometry2D.is_point_in_polygon(Vector2(x,z),p):K.column(n,Vector3(x,0,z),4.675,.50)
	var C:Script=load("res://world/visual_campus/ZhangCourtCore.gd")
	for x in [-20.94,-17.94]:C.rail(n,Vector3(x,9.55,7.04),Vector3(x,9.55,24.04))
	C.rail(n,Vector3(-20.94,9.55,7.04),Vector3(-17.94,9.55,7.04))
	K.finish(n)
