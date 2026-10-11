extends RefCounted
## Roadside elevation from user 20261010_222552/613, distinct from courtyard ribbons.
## Window pitch/height and finish colours are proportional fits, not surveyed values.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func window(n:Node3D,x:float,y:float,width:float,height:float,seed:int) -> void:
	K.box(n,Vector3(x,y,-.24),Vector3(width,height,.06),"536460",false,22)
	K.box(n,Vector3(x,y,-.095),Vector3(width,height,.045),"a3b9b4",false,19)
	for side in [-1,1]:
		K.box(n,Vector3(x+side*(width/2+.035),y,-.055),Vector3(.07,height+.14,.14),"63706a",false,11)
		K.box(n,Vector3(x,y+side*(height/2+.035),-.055),Vector3(width+.14,.07,.14),"63706a",false,11)
	K.box(n,Vector3(x,y-.20,.005),Vector3(width,.065,.13),"56625e",false,11)
	K.box(n,Vector3(x,y-height/2-.08,.025),Vector3(width+.15,.09,.26),"b1b3a5",false,39)
	# Partially lowered blinds seen in the photo; deterministic variation, no fake rooms.
	var blind:float=height*(.42+float(seed%5)*.085)
	var top:float=y+height/2-.04
	K.box(n,Vector3(x,top-blind/2,-.155),Vector3(width-.08,blind,.016),"b8bcb0",false,22)
	for i in int(blind/.055):
		K.box(n,Vector3(x,top-.04-i*.055,-.134),Vector3(width-.09,.013,.014),"89968c",false,11)
	K.box(n,Vector3(x,top-blind,-.13),Vector3(width-.06,.035,.045),"a4afa2",false,11)

static func build(parent:Node3D,length:float,depth:float,levels:Array) -> void:
	var n:=K.holder(parent,"PhotoLibraryRoadElevationV88",Vector3(-depth/2,0,0));n.rotation.y=-PI/2
	var count:=maxi(2,roundi(length/3.2));var pitch:float=length/count
	for f in levels.size()-1:
		var low:float=levels[f];var high:float=levels[f+1];var h:float=high-low
		var wh:float=minf(2.18,h*.60);var mid:float=(low+high)/2+.06
		# Wide continuous plaster bands replace generic white pilasters at every window.
		var bottom:float=mid-wh/2;var top:float=mid+wh/2
		K.box(n,Vector3(0,(low+bottom)/2,-.22),Vector3(length,bottom-low,.38),"c5c1b2",true,39)
		K.box(n,Vector3(0,(top+high)/2,-.22),Vector3(length,high-top,.38),"c5c1b2",true,39)
		for i in count:
			var x:float=-length/2+(i+.5)*pitch;var ww:float=minf(1.13,pitch*.36)
			var pier:float=(pitch-ww)/2
			for side in [-1,1]:K.box(n,Vector3(x+side*(ww/2+pier/2),mid,-.22),Vector3(pier,wh,.38),"b5b09f",true,39)
			window(n,x,mid,ww,wh,17*f+i)
		# Flush floor-edge skin avoids the protruding white shelf of the old bar model.
		K.box(n,Vector3(0,low,-.010),Vector3(length,.25,.035),"c5c1b2",false,39)
	var roof:float=levels[-1]
	K.box(n,Vector3(0,roof+.35,-.06),Vector3(length,.71,.12),"c5c1b2",false,39)
	K.box(n,Vector3(0,roof+.72,.01),Vector3(length,.065,.19),"b7b8aa",false,39)
	K.finish(n)
