extends RefCounted
## V116: public2F entry/exhibition boundary, public3F return and built brick/glass vocabulary.
## Maps are schematic. Absolute levels and the retained exterior approach remain provisional.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const Slab=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")

static func door_center()->Vector3:return P.point2(1174.5,710,4.4)
static func door_axis()->Vector3:return (P.point2(1274,610)-P.point2(1075,810)).normalized()
static func door_out()->Vector3:
	var axis:=door_axis();return Vector3(-axis.z,0,axis.x)
static func dp(along:float,out:float,y:float=4.4)->Vector3:
	var p:=door_center()+door_axis()*along+door_out()*out;p.y=y;return p
static func edge(points:Array,level:int)->PackedVector2Array:
	var out:=PackedVector2Array()
	for p in points:
		var q:Vector3=P.point2(p[0],p[1]) if level==2 else P.point3(p[0],p[1]);out.append(Vector2(q.x,q.z))
	return out
static func glass(n:Node3D,a:Vector2,b:Vector2,bottom:float,top:float,coral:bool=false)->void:
	var delta:=b-a;var length:=delta.length();var yaw:float=-atan2(delta.y,delta.x)
	var basis:=Basis(Vector3.UP,yaw);var h:float=top-bottom
	Pods.strip(n,a,b,(top+bottom)/2,h,.12,"899f99",19,true)
	for y in [bottom+.10,top-.10]:Pods.strip(n,a,b,y,.2,.48,"aeb5aa",22)
	var count:=maxi(2,int(ceil(length/1.35)))
	for i in range(count+1):
		var q:=a.lerp(b,float(i)/count)
		K.box(n,Vector3(q.x,(top+bottom)/2,q.y),Vector3(.075,h,.22),"aab4a6",false,11,yaw)
		if coral and i>0 and i<count:K.box(n,Vector3(q.x,(top+4.6)/2,q.y)+basis*Vector3(0,0,.34),Vector3(.075,top-4.6,.7),"b2ac93",false,11,yaw)
	if coral:
		# V119: 2023 overview + architect built photo012 show a white portal,
		# warm recessed side/soffit panels and upper fins, not a thin coral outer frame.
		var mid:=Vector3((a.x+b.x)/2,0,(a.y+b.y)/2)
		for side in [-1,1]:
			K.box(n,mid+basis*Vector3(side*(length/2-.27),(top+bottom)/2,.68),Vector3(.54,h,1.5),"d1d2c7",true,22,yaw)
			K.box(n,mid+basis*Vector3(side*(length/2-.57),(top+bottom-.65)/2,.38),Vector3(.075,h-.65,1.02),"b78269",false,22,yaw)
			# Thin courses are limited to the return plane; spacing is photograph-fitted.
			for j in range(1,int((h-.7)/.42)):
				K.box(n,mid+basis*Vector3(side*(length/2-.615),bottom+j*.42,.38),Vector3(.018,.012,1.0),"98715e",false,22,yaw)
		K.box(n,mid+basis*Vector3(0,top-.325,.68),Vector3(length,.65,1.5),"d1d2c7",false,22,yaw)
		K.box(n,mid+basis*Vector3(0,top-.675,.38),Vector3(length-1.08,.05,1.02),"b78269",false,22,yaw)
		# Projecting pale transom separates lower glazing from the tall screened opening.
		K.box(n,mid+basis*Vector3(0,4.43,.50),Vector3(length-1.08,.18,.94),"c3c9bd",false,22,yaw)

static func brick(n:Node3D,a:Vector2,b:Vector2,bottom:float,top:float,screen:bool)->void:
	var delta:=b-a;var length:=delta.length();var yaw:float=-atan2(delta.y,delta.x)
	var basis:=Basis(Vector3.UP,yaw);var origin:=Vector3((a.x+b.x)/2,0,(a.y+b.y)/2)
	var height:float=top-bottom
	if not screen or length<2.5:
		Pods.strip(n,a,b,(top+bottom)/2,height,.38,"929991",7,true)
	else:
		# A recessed physical glass layer closes the facade; the brick screen really has holes.
		K.box(n,origin+basis*Vector3(0,(top+bottom)/2,-.27),Vector3(length,height,.10),"7f918a",true,19,yaw)
		for sign in [-1,1]:K.box(n,origin+basis*Vector3(sign*(length/2-.28),(top+bottom)/2,0),Vector3(.56,height,.38),"929991",false,7,yaw)
		for y in [bottom+.34,top-.34]:K.box(n,origin+Vector3.UP*y,Vector3(length,.68,.38),"929991",false,7,yaw)
		var cols:=maxi(2,int((length-1.12)/.29));var rows:=maxi(2,int((height-1.36)/.16))
		var pitch:float=(length-1.12)/cols;var rise:float=(height-1.36)/rows
		for row in rows:
			for col in cols:
				if (row+col)%2==1:continue
				var x:float=-length/2+.56+(col+.5)*pitch;var y:float=bottom+.68+(row+.5)*rise
				K.box(n,origin+basis*Vector3(x,y,0),Vector3(pitch-.018,rise-.014,.24),"929991" if (row+col)%4==0 else "858e87",false,22,yaw)
	Pods.strip(n,a,b,top+.015,.16,.55,"b4baad",22)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryRegisteredEntryPavilionV116")
	var a:=P.point2(1075,810);var b:=P.point2(1274,610)
	var axis:=door_axis();var length:=a.distance_to(b);var yaw:float=-atan2(axis.z,axis.x)
	for side in [-1,1]:
		var lo:float=1.85;var hi:float=length/2
		var p:=dp(side*(lo+hi)/2,0,6.45)
		K.box(n,p,Vector3(hi-lo,3.94,.10),"8da29a",true,19,yaw)
		for x in [lo,hi]:K.box(n,dp(side*x,0,6.45),Vector3(.09,4.08,.24),"53655c",true,11,yaw)
		# Open leaves sit against the jambs, retaining the actual walkable central opening.
		K.box(n,dp(side*1.78,-.58,6.15),Vector3(.065,3.5,1.15),"8da29a",false,19,yaw)
		K.box(n,dp(side*1.7,-.72,5.8),Vector3(.04,.7,.05),"bec6b9",false,11,yaw)
	for y in [4.49,8.45]:K.box(n,dp(0,0,y),Vector3(length,.16,.26),"53655c",false,11,yaw)
	for x in [-5.4,-3.6,3.6,5.4]:K.box(n,dp(x,0,6.45),Vector3(.055,3.9,.16),"53655c",false,11,yaw)
	K.box(n,dp(0,-1.2,4.43),Vector3(3.5,.018,2.1),"777e73",false,25,yaw)
	# V117 replaces the provisional connecting deck with the source-aligned outdoor approach.
	# The built photograph has ONE continuous brick broadside and ONE coral end reveal.
	# Shared3F outer edge resolves the schematic2F/3F offset without two stacked pavilions.
	var front:=edge([[1608,798],[1785,620]],3)
	var entry_end:=P.point2(1274,610)
	var broadside:=edge([[1459,774],[1507,790],[1608,798]],3)
	broadside.insert(0,Vector2(entry_end.x,entry_end.z))
	for i in range(broadside.size()-1):brick(n,broadside[i],broadside[i+1],4.4,12.55,true)
	glass(n,front[0],front[1],.12,12.55,true)
	# Intermediate floor borders sit behind the reveal, not duplicated outer coral frames.
	for y in [4.4,8.8]:Pods.strip(n,front[0],front[1],y,.22,.25,"aeb5aa",22)
	var roof:=exhibition_outline()
	Slab.sheet(n,roof,12.66,"a2a99c",22);Slab.sheet(n,roof,12.48,"c8cbbd",22,false,false,86,58,true)
	# The right rear tip is continuous glazing. This return replaces the crossing old curved wall.
	var back:=edge([[1378,299],[1488,408],[1600,554],[1682,595],[1785,620]],3)
	for i in range(back.size()-1):glass(n,back[i],back[i+1],4.4,12.5)
	K.finish(n)

static func exhibition_outline()->PackedVector2Array:
	var outline:=edge([[1378,299],[1488,408],[1600,554],[1682,595],[1785,620],[1608,798],[1507,790],[1459,774]],3)
	var p:=P.point2(1274,610);outline.append(Vector2(p.x,p.z))
	p=P.point2(1238,382);outline.append(Vector2(p.x,p.z))
	return outline
