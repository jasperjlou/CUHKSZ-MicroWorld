extends RefCounted
## V221: historic030 large3F room, OSA301 photo and architect016/017.
## Gallery offset/heights are fitted; upper lightwell/roof remains a separate registration task.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
const LOW=8.8
const HIGH=15.65
static func opening()->Array:
	var result:Array=[]
	for p in [[500,548],[794,548],[794,691],[500,691]]:
		var q:=P.third_to_first(p[0],p[1]);result.append([q.x,q.y])
	return result
static func strip(n:Node3D,a:Vector2,b:Vector2,low:float,high:float,color:String,kind:int=67,solid:bool=true,width:float=.18)->void:
	var p:=R.point(a.x,a.y,(low+high)/2);var q:=R.point(b.x,b.y,(low+high)/2);var d:=q-p
	K.box(n,(p+q)/2,Vector3(d.length(),high-low,width),color,solid,kind,-atan2(d.z,d.x))
static func wood_wall(n:Node3D,a:Vector2,b:Vector2,top:float=12.4)->void:
	strip(n,a,b,LOW,top,"bea477")
	strip(n,a,b,LOW,LOW+.12,"8c795b",4,false,.20)
	var length:float=R.point(a.x,a.y).distance_to(R.point(b.x,b.y));var count:=maxi(1,roundi(length/.95))
	for i in range(1,count):
		var q:=a.lerp(b,float(i)/count)
		K.box(n,R.point(q.x,q.y,(LOW+top)/2),Vector3(.014,top-LOW,.22),"9e895f",false,4)
static func doorway(n:Node3D,a:Vector2,b:Vector2,closed:bool=false)->void:
	var p:=R.point(a.x,a.y);var q:=R.point(b.x,b.y);var d:=q-p;var width:=d.length()
	var h:=K.holder(n,"HallOpenDoubleDoor",(p+q)/2);h.rotation.y=-atan2(d.z,d.x)
	K.box(h,Vector3(0,3.25,0),Vector3(width,.70,.20),"bea477",true,67)
	if closed:
		# Historic door faces an unresolved level transition. Do not open into the lower court.
		K.box(h,Vector3(0,1.44,0),Vector3(width,2.88,.10),"bea477",true,67)
		for face in [-1,1]:
			K.box(h,Vector3(0,1.44,face*.058),Vector3(.025,2.88,.025),"786c53",false,11)
			for s in [-1,1]:
				K.box(h,Vector3(s*width*.24,1.72,face*.064),Vector3(.18,1.2,.025),"627c7b",false,5)
				K.box(h,Vector3(s*.12,1.10,face*.10),Vector3(.04,.26,.075),"bec5bf",false,11)
		K.finish(h);return
	for s in [-1,1]:
		K.box(h,Vector3(s*(width/2-.035),1.43,0),Vector3(.07,2.86,.22),"aa956e",true,4)
		# Open paired leaves park inside the hall, keeping the central route clear.
		var leaf:=K.holder(h,"OpenLeaf",Vector3(s*(width/2-.11),0,.60))
		K.box(leaf,Vector3(0,1.40,0),Vector3(.07,2.8,1.12),"b89f70",true,4)
		K.box(leaf,Vector3(s*.043,1.64,0),Vector3(.008,1.25,.18),"627c7b",false,19)
		K.box(leaf,Vector3(s*.07,1.05,.43),Vector3(.10,.028,.14),"bdc4be",false,11)
		K.finish(leaf)
	K.finish(h)
static func gallery_glass(n:Node3D,a:Vector2,b:Vector2)->void:
	strip(n,a,b,12.12,13.08,"d0cec0",22,true,.18)
	strip(n,a,b,13.08,HIGH,"8caaa6",19,true,.065)
	strip(n,a,b,13.08,13.15,"626f6e",11,false,.10)
	strip(n,a,b,HIGH-.08,HIGH,"626f6e",11,false,.10)
	# V232 photo016/017: a broad white head return separates gallery glazing
	# from the daylight blades. Visual facing only; retain the existing solid glass.
	strip(n,a,b,14.88,HIGH+.04,"d0cec0",22,false,.14)
	strip(n,a,b,14.82,14.88,"626f6e",11,false,.15)
	var count:=maxi(1,roundi(R.point(a.x,a.y).distance_to(R.point(b.x,b.y))/1.05))
	for i in range(count+1):
		var q:=a.lerp(b,float(i)/count)
		K.box(n,R.point(q.x,q.y,(13.08+14.88)/2),Vector3(.055,14.88-13.08,.055),"626f6e",false,11)
static func window_lining(n:Node3D)->void:
	# Reuse the existing facade bay calculation exactly; no panels across the glass openings.
	var count:=int(((924.-218.)/P.PIXELS_PER_METRE)/1.85)
	var pitch:float=(924.-218.)/count;var aperture:float=pitch*.43
	var bounds:=Vector2(P.third_to_first(425,691).x,P.third_to_first(794,691).x)
	var lining:=K.holder(n,"HallInteriorWindowLining")
	for y in [8.8,12.4]:
		var high:float=y+3.6
		for i in count:
			var centre:float=924.-(i+.5)*pitch
			for span in [[centre-pitch/2,centre-aperture/2],[centre+aperture/2,centre+pitch/2]]:
				var a:float=maxf(bounds.x,span[0]);var b:float=minf(bounds.y,span[1])
				if b<=a:continue
				K.box(lining,P.point((a+b)/2,683.4,(y+high)/2),Vector3(.035,high-y,(b-a)/P.PIXELS_PER_METRE),"bea477",false,67)
		for row in [[y,y+.36],[high-.34,high]]:
			K.box(lining,P.point((bounds.x+bounds.y)/2,683.4,(row[0]+row[1])/2),Vector3(.035,row[1]-row[0],(bounds.y-bounds.x)/P.PIXELS_PER_METRE),"bea477",false,67)
	K.finish(lining)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentMultiHallV221")
	K.surface(n,K.quad(R.point(427,507,LOW+.025),R.point(792,507,LOW+.025),R.point(792,687,LOW+.025),R.point(427,687,LOW+.025)),"c4ad84",66)
	# Large3F room boundary and three openings traced from030, not repeated onto other floors.
	wood_wall(n,Vector2(425,505),Vector2(728,505))
	doorway(n,Vector2(728,505),Vector2(770,505))
	wood_wall(n,Vector2(770,505),Vector2(794,505))
	for span in [[505,518],[554,668],[684,691]]:wood_wall(n,Vector2(425,span[0]),Vector2(425,span[1]))
	# V233 west leaf now meets a registered3F landing and2F-to3F flight.
	for span in [[518,554],[668,684]]:doorway(n,Vector2(425,span[1]),Vector2(425,span[0]))
	wood_wall(n,Vector2(794,505),Vector2(794,605),HIGH)
	# End glazing seen in016; retain it as a closed visual interface, not an unverified exit.
	strip(n,Vector2(794,605),Vector2(794,691),LOW,LOW+3.0,"8caaa6",19,true,.07)
	strip(n,Vector2(794,605),Vector2(794,691),LOW+3.0,HIGH,"bea477")
	for i in range(9):
		var v:=lerpf(605,691,i/8.0)
		K.box(n,R.point(794,v,LOW+1.5),Vector3(.09,3.0,.055),"596967",false,11)
	# Photo-constrained glazed upper viewing strip; exact4F gallery depth is not measured.
	gallery_glass(n,Vector2(500,548),Vector2(794,548))
	gallery_glass(n,Vector2(500,548),Vector2(500,691))
	window_lining(n)
	n.set_meta("source","historic030 + OSA301 + architect016/017; fitted4Fgallery; roof pending")
	K.finish(n)
