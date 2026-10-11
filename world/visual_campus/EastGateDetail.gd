extends RefCounted
## Scene 116410030: paired windows, blank street ends and distinct base screens.
## Heights and repeated bay counts fit the retained origin/anchors, not surveyed dimensions.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth;var levels: Array=r.floor_levels
	var left: bool=r.id=="gate_south"
	var street_end: float=-1.0 if left else 1.0
	# Enclosed upper floors; individual glass openings sit behind the projecting grid.
	for y: float in levels.slice(1):K.box(b,Vector3(0,y,0),Vector3(w,.25,d),"c5c7bc",true,15)
	for side in [-1,1]:
		for f in range(1,levels.size()-1):
			var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
			var cells:=12;var pitch:=w/cells
			for i in cells:
				var x: float=(i+.5)*pitch-w/2
				K.box(b,Vector3(x,h/2+low,side*d/2),Vector3(pitch,h,.28),"a79e8a",true,22)
				for dx in [-.71,.71]:
					K.window(b,Vector3(x+dx,low+h*.50,side*(d/2+.17)),1.05,h-.68,PI if side<0 else 0.0)
				for dx in [-pitch/2,0.0]:K.box(b,Vector3(x+dx,low+h/2,side*(d/2+.34)),Vector3(.26,h,.60),"d0d1c6",false,22)
			K.box(b,Vector3(0,low+.15,side*(d/2+.34)),Vector3(w,.30,.60),"d0d1c6",false,22)
		K.box(b,Vector3(0,levels[-1]+.44,side*(d/2-.12)),Vector3(w,.88,.24),"c9cbbf",false,22)
	# The right street end is stone; the left presents paired window bays toward arrival.
	for end in [-1,1]:
		K.box(b,Vector3(end*w/2,(levels[-1]+levels[1])/2,0),Vector3(.36,levels[-1]-levels[1],d),"bfc1b8",true,0)
		if left and float(end)==street_end:
			for f in range(1,levels.size()-1):
				var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
				for i in 6:
					var z: float=(i+.5)*d/6-d/2
					for dz in [-.71,.71]:K.window(b,Vector3(end*(w/2+.22),low+h/2,z+dz),1.05,h-.68,end*PI/2)
					for dz in [-d/12,0.0]:K.box(b,Vector3(end*(w/2+.4),low+h/2,z+dz),Vector3(.62,h,.26),"d0d1c6",false,22)
				K.box(b,Vector3(end*(w/2+.4),low+.15,0),Vector3(.62,.30,d),"d0d1c6",false,22)
		if float(end)!=street_end:
			for f in range(1,levels.size()-1):
				for z in [-d*.28,d*.28]:K.window(b,Vector3(end*(w/2+.2),(levels[f]+levels[f+1])/2,z),.8,2.3,end*PI/2)
		K.box(b,Vector3(end*(w/2-.12),levels[-1]+.44,0),Vector3(.24,.88,d),"c9cbbf",false,22)
	K.gallery(b,Vector3.ZERO,w,d,levels[1])
	K.box(b,Vector3(0,.035,0),Vector3(w+.5,.05,d+.5),"989d94",false,23)
	# Distinct hanging screens leave a walkable apron in front and an open central undercroft.
	var screen_color: String="445249" if left else "926143"
	var sx: float=street_end*(w*.24)
	for i in 34:
		K.box(b,Vector3(sx+(i-16.5)*.34,2.8,d/2+.45),Vector3(.12,2.8,.48),screen_color,false,11 if left else 4)
	for y in [1.45,4.2]:K.box(b,Vector3(sx,y,d/2+.45),Vector3(11.6,.10,.53),"566257",false,11)
	for x in [-w*.35,w*.35]:
		K.box(b,Vector3(x,4.0,0),Vector3(3,.08,.28),"e1ddbf",false,20)
		K.bench(b,Vector3(x,0,-d/2+2),PI)
