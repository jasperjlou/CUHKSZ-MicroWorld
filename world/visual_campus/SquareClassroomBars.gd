extends RefCounted
## V77: Main Square and anniversary views show narrow end walls facing the lawn.
## Paired six-storey bars run towards the rear terrace; all metric sizes remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const F:=preload("res://world/visual_campus/StartZoneFacades.gd")
const Public:=preload("res://world/visual_campus/StartZonePublic.gd")

static func front_end(n: Node3D,w: float,d: float,levels: Array,motto: String) -> void:
	var front:float=d/2
	for i in levels.size()-1:
		var low:float=levels[i];var high:float=levels[i+1];var mid:float=(low+high)/2
		K.box(n,Vector3(0,mid,front-.18),Vector3(w,high-low,.32),"d0d1c8",true,22)
		K.box(n,Vector3(-w*.06,mid,front+.003),Vector3(w*.23,2.13,.035),"aab0ac",false,22)
		for x in [-w*.23,w*.04,w*.17,w*.30]:F.window(n,Vector3(x,mid,front+.10),1.06,2.10)
		K.box(n,Vector3(0,low+.04,front+.014),Vector3(w,.045,.04),"b8bdb6",false,22)
	K.box(n,Vector3(-w*.39,13.4,front+.06),Vector3(1.78,19,.10),"5c4069",false,22)
	var label:=K.label(n,motto,Vector3(-w*.39,13.4,front+.13),.024)
	label.modulate=Color("ded39b")

static func build(parent: Node3D,r: Dictionary) -> void:
	var n:=K.holder(parent,"SquareEndFacingClassroomV77")
	var w:float=r.width;var d:float=r.depth;var levels:Array=r.floor_levels.slice(1)
	var zhiren:bool=r.id=="zhi_ren"
	for y:float in levels:
		K.box(n,Vector3(0,y,0),Vector3(w,.24,d),"a0aa9b" if y==levels[-1] else "c2c6bd",true,18 if y==levels[-1] else 15)
	front_end(n,w,d,levels,"融\n会\n中\n国\n与\n西\n方" if zhiren else "结\n合\n传\n统\n与\n现\n代")
	# Long faces retain their own window rhythm; equipment cages belong to the garden side.
	for side in [-1,1]:F.build(n,d,w,levels,1,side,false,zhiren and side==-1)
	F.build(n,w,d,levels,0,-1,false,false)
	for side in [-1,1]:
		K.box(n,Vector3(side*(w/2-.12),levels[-1]+.35,0),Vector3(.24,.7,d),"c8c9bf",false,22)
		K.box(n,Vector3(0,levels[-1]+.35,side*(d/2-.12)),Vector3(w,.7,.24),"c8c9bf",false,22)
	# Open lower colonnade is visible in the named Zhiren garden panorama.
	# Do not fill it with the old transverse classroom wall or invented room furniture.
	for z in range(-int(d/2)+2,int(d/2),6):
		for side in [-1,1]:K.box(n,Vector3(side*(w/2-.45),2.3,z),Vector3(.64,4.6,.64),"c9ccc3",true,22)
		K.box(n,Vector3(0,4.30,z),Vector3(w,.36,.30),"bdc3b7",false,15)
	K.box(n,Vector3(0,.085,0),Vector3(w,.04,d),"b4b5aa",false,26)
	# The slim street end has teal glazing. The public door remains centred on its stair.
	Public.glazing(n,w,d/2+.02,false)
	for side in [-1,1]:
		K.box(n,Vector3(side*(w/2+.5),.092,0),Vector3(1,.025,d),"ad8978",false,7)
	# Front and side threshold details, leaving both end approaches clear.
	K.box(n,Vector3(0,.088,d/2+1.05),Vector3(w+.8,.02,2),"9d9f93",false,26)
	K.box(n,Vector3(0,.105,d/2+.18),Vector3(8.8,.012,.16),"57675d",false,11)
	var title:=K.label(n,r.name,Vector3(w*.30,4.22,d/2+.20),.009)
	title.modulate=Color("364f43")
	if zhiren:
		# The garden photo shows a recessed painted wall behind the open colonnade.
		# Two fitted door gaps connect the existing public walk; room plans remain unknown.
		for interval:Vector2 in [Vector2(-30,-10),Vector2(-4,9),Vector2(15,30)]:
			K.box(n,Vector3(-3,2.15,(interval.x+interval.y)/2),Vector3(.22,4.3,interval.y-interval.x),"c4c6ba",true,22)
		var side_title:=K.holder(n,"ZhirenGardenName",Vector3(-w/2-.06,0,d/2-2.4));side_title.rotation.y=-PI/2
		var label:=K.label(side_title,"志仁楼\nZhi Ren Building",Vector3(0,3.9,0),.008);label.modulate=Color("354e45")
		for z in [-22,-10,2,14]:
			Public.flowering_pot(n,Vector3(-w/2-2.2,0,z),7700+absi(z))
			K.box(n,Vector3(-w/2+3,4.36,z),Vector3(4,.05,.2),"ded8bd",false,17)
	K.finish(n)
