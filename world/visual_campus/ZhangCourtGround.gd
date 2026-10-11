extends RefCounted
## V137: front terrace and lower rear street are separate datums (V136 probes).
## Road4.565m below front is a legacy-derived fit, NOT a survey. Footprint fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const Site:=preload("res://world/visual_campus/LowerCampusLandscape.gd")
const Core:=preload("res://world/visual_campus/ZhangCourtCore.gd")
const Public:=preload("res://world/visual_campus/TeachingPublicSpaces.gd")
const LOW:float=-4.8
const ROAD:float=-4.565
# D-local x/z rectangles, converted using retained90deg body orientation.
const CUTS:Array[Rect2]=[Rect2(-41,-54,82,72),Rect2(-56.5,-55.23,18,9.48)]
static func cutout(x:float,z:float)->bool:
	var p:=Vector2(-420-z,x+82.64)
	for rect:Rect2 in CUTS:
		if rect.has_point(p):return true
	return false
static func terrain_breaks()->Dictionary:
	var xs:Array[float]=[];var zs:Array[float]=[]
	for rect:Rect2 in CUTS:
		xs.append(-82.64+rect.position.y);xs.append(-82.64+rect.end.y)
		zs.append(-420-rect.position.x);zs.append(-420-rect.end.x)
	return {"x":xs,"z":zs}
static func floor_rect(n:Node3D,x0:float,x1:float,z0:float,z1:float,y:float,kind:int=42)->void:
	K.box(n,Vector3((x0+x1)/2,y-.125,(z0+z1)/2),Vector3(x1-x0,.25,z1-z0),"a3a79e",true,kind)
	if y>0:K.box(n,Vector3((x0+x1)/2,y-.258,(z0+z1)/2),Vector3(x1-x0,.015,z1-z0),"bfc1b7",false,22)

static func retaining(n:Node3D,a:Vector3,c:Vector3,top:float)->void:
	var d:=c-a;var h:float=top-a.y
	K.box(n,(a+c)/2+Vector3.UP*h/2,Vector3(d.length(),h,.24),"a9aba1",true,15,atan2(-d.z,d.x))
static func slope(n:Node3D,a:Vector3,c:Vector3,width:float)->void:
	var d:Vector3=c-a;var across:=Vector3(d.z,0,-d.x).normalized()*width/2
	K.surface(n,K.quad(a-across,a+across,c+across,c-across),"a3a79e",42,true)
static func flight(n:Node3D,low:Vector3,high:Vector3,width:float)->void:
	var d:Vector3=high-low;var run:=Vector2(d.x,d.z).length()
	var part:=K.holder(n,"GradeStair",low);part.rotation.y=atan2(d.x,d.z)
	Public.flight(part,Vector3.ZERO,Vector3(0,d.y,run),width,"aeb0a5",42)
	for s in [-1,1]:Core.rail(part,Vector3(s*(width/2+.1),0,0),Vector3(s*(width/2+.1),d.y,run))
	K.finish(part)
static func build(b:Node3D,_r:Dictionary)->void:
	var n:=K.holder(b,"ZhangLowerGroundAndRearStreetV137")
	# Continuous lower substrate replaces the excavated terrain; street has a
	# separate top and a short shallow threshold to the public undercroft.
	floor_rect(n,-41,41,-54,18,LOW,26)
	floor_rect(n,-40.6,40.6,-51.25,-45.75,ROAD)
	for z in [-51.38,-45.62]:K.box(n,Vector3(0,ROAD+.08,z),Vector3(81,.16,.18),"aeb0a5",false,6)
	slope(n,Vector3(0,ROAD,-47.5),Vector3(0,LOW,-41.5),5.4)
	Site.drain(n,Vector3(0,ROAD+.013,-49.5),74)
	# Front-level structural platform: retain a real opening for the rear core.
	var xs:Array[float]=[-34.45,-22.8,-18,34.45]
	var zs:Array[float]=[-44,-40.65,-24.44,36]
	for i in 3:
		for j in 3:
			if i==1 and j==1:continue
			floor_rect(n,xs[i],xs[i+1],zs[j],zs[j+1],.08)
	floor_rect(n,-30,30,36,38.16,.08)
	# Bound the lower covered public space. Room subdivisions and individual
	# service doors remain unregistered; leave an honest open circulation shell.
	for span:Vector2 in [Vector2(-34.45,-3),Vector2(3,34.45)]:
		retaining(n,Vector3(span.x,LOW,-43.9),Vector3(span.y,LOW,-43.9),-.12)
	for side in [-1,1]:retaining(n,Vector3(side*34.45,LOW,-44),Vector3(side*34.45,LOW,18),-.12)
	retaining(n,Vector3(-34.45,LOW,18),Vector3(34.45,LOW,18),-.12)
	for x in [-10,8,26]:
		for z in [-36,-20,-4,12]:K.column(n,Vector3(x,LOW,z),4.68,.50)
	for z in [-38,-25,-12,1,14]:
		K.box(n,Vector3(0,-.29,z),Vector3(64,.32,.32),"b8b9ae",false,22)
		K.box(n,Vector3(0,-.48,z),Vector3(1.8,.05,.20),"e1e2d5",false,17)
	for z in [-36,-20,-4]:
		var light:=OmniLight3D.new();light.position=Vector3(0,-1.0,z);light.light_energy=.32;light.omni_range=12;n.add_child(light)
	# Rear terrace edge cannot be walked off into the lower street.
	Core.rail(n,Vector3(-34.3,.08,-44),Vector3(34.3,.08,-44))
	for side in [-1,1]:
		Core.rail(n,Vector3(side*34.5,.08,-44),Vector3(side*34.5,.08,18))
		# Side descent is fitted to this common grade; exact stair location awaits
		# a contemporary side photograph. No grass slope painted through steps.
		floor_rect(n,side*38.5-2,side*38.5+2,-49.5,-32,ROAD)
		flight(n,Vector3(side*38.5,ROAD,-32),Vector3(side*38.5,.08,-8),3.8)
		floor_rect(n,side*38.5-2,side*38.5+2,-8,48,.08)
		for span:Vector2 in ([Vector2(-54,-51.4),Vector2(-45.6,18)] if side<0 else [Vector2(-54,18)]):
			retaining(n,Vector3(side*41,LOW,span.x),Vector3(side*41,LOW,span.y),.02)
	# Outer earth face and lower rear strip are separate from the building wall.
	retaining(n,Vector3(-41,LOW,-54),Vector3(41,LOW,-54),.02)
	# V138 C rear now shares this low datum. Remove the temporary stair adapter.
	floor_rect(n,-56.5,-38.5,-55.23,-45.75,LOW)
	var a:=Vector3(-56.5,ROAD,-52.48);var c:=Vector3(-38.5,ROAD,-48.5)
	slope(n,a,c,5.5)
	for edge in [-1,1]:Core.rail(n,a.lerp(c,.14)+Vector3(0,0,edge*2.85),a.lerp(c,.86)+Vector3(0,0,edge*2.85))
	for z in [-55.23,-45.75]:retaining(n,Vector3(-54.5,LOW,z),Vector3(-41,LOW,z),.02)
	K.finish(n)
