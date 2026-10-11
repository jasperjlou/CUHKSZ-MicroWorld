extends RefCounted
## Research A/B: official passage 116697227 and H.L.Tu road view 116443797.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const T := preload("res://world/visual_campus/TeachingBlocks.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth;var levels: Array=r.floor_levels.slice(1)
	var lee: bool=r.id=="lee_yin_yee"
	for y: float in levels:K.box(b,Vector3(0,y,0),Vector3(w,.25,d),"a0a397",true,18 if y==levels[-1] else 22)
	if lee:
		var style: Dictionary={"stone":"b5b2a4","finish":22,"window_width":.67}
		for axis in [0,1]:
			for side in [-1,1]:T.wall(b,w if axis==0 else d,d if axis==0 else w,levels,axis,side,false,3.15,style)
	else:
		fin_elevation(b,w,d,levels)
		passage_elevation(b,w,d,levels)
		for side in [-1,1]:
			var style:Dictionary={"stone":"aeb2a7","finish":22,"window_width":.85}
			if side==-1:
				# 20261010_222404 shows a blank name-bearing end panel beside the court.
				T.wall(b,d,w,levels.slice(1),1,side,false,2.2,style)
				var remainder:=K.holder(b,"TuEndBesideNamePanel",Vector3(0,0,4))
				T.wall(remainder,d-8,w,levels.slice(0,2),1,side,false,2.2,style);K.finish(remainder)
				K.box(b,Vector3(-w/2,(levels[0]+levels[1])/2,-d/2+4),Vector3(.36,levels[1]-levels[0],8),"bdb7a5",true,22)
			else:T.wall(b,d,w,levels,1,side,false,2.2,style)
	for x in range(-int(w/2)+2,int(w/2),6):
		var px: float=x
		if absf(px)<2.4:px=-2.8 if px<0 else 2.8
		for side in [-1,1]:K.box(b,Vector3(px,2.24,side*(d/2-.6)),Vector3(.58,4.48,.58),"acb1a6",true,22)
	for side in [-1,1]:K.box(b,Vector3(0,levels[-1]+.38,side*(d/2-.13)),Vector3(w,.65,.26),"aeb3a7",false,22)
	for x in [-w*.25,0,w*.25]:K.box(b,Vector3(x,levels[-1]+.7,0),Vector3(2.7,1.2,2.2),"879488",false,18)
	public_floor(b,w,d,lee)
	if not lee:road_arcade(b,w,d)

static func fin_elevation(b: Node3D,w: float,d: float,levels: Array) -> void:
	var count:=roundi(w/1.12);var pitch: float=w/count
	for f in range(levels.size()-1):
		var low: float=levels[f];var high: float=levels[f+1]
		for i in count:
			var x: float=(i+.5)*pitch-w/2
			# Two recessed public terrace levels seen on the road-side right-hand part.
			if f<2 and x>15 and x<31:continue
			K.box(b,Vector3(x,(low+high)/2,d/2-.12),Vector3(pitch-.10,high-low-.22,.08),"526c79",true,5)
			K.box(b,Vector3(x,(low+high)/2,d/2+.29),Vector3(.27,high-low,.72),"b8beb0",false,22)
			K.box(b,Vector3(x,low,d/2+.32),Vector3(pitch,.22,.82),"c0c4b7",false,22)
	K.box(b,Vector3(w*.24,levels[-1]-1.05,d/2+.78),Vector3(17,2.1,.14),"9da79c",false,22)
	K.label(b,"涂辉龙楼\nH.L. Tu Building",Vector3(w*.24,levels[-1]-1.05,d/2+.91),.009)
	# The model stair meets the first terrace; the second is represented architecturally only.
	for f in 2:
		var y: float=levels[f];var h: float=levels[f+1]-y
		K.box(b,Vector3(23,y+h/2,17.4),Vector3(16,h-.25,.10),"637f83",true,19)
		for x in [15.0,31.0]:K.box(b,Vector3(x,y+h/2,19.25),Vector3(.22,h,3.5),"a4aa9d",true,22)
		for x in range(16,31,3):K.box(b,Vector3(x,y+h/2,17.3),Vector3(.065,h,.16),"596d60",false,11)
		K.box(b,Vector3(23,y+.136,19.2),Vector3(15.7,.018,3.4),"999d8e",false,12)
		for i in 32:
			var x: float=15.3+i*.48
			if f==0 and absf(x-w*.32)<1.85:continue
			K.box(b,Vector3(x,y+.68,20.8),Vector3(.035,1.08,.035),"50675a",false,11)
		if f==0:
			K.box(b,Vector3(19.4,y+1.22,20.8),Vector3(8.0,.06,.06),"50675a",false,11)
			K.box(b,Vector3(28.85,y+1.22,20.8),Vector3(3.7,.06,.06),"50675a",false,11)
		else:K.box(b,Vector3(23,y+1.22,20.8),Vector3(15.7,.06,.06),"50675a",false,11)

static func passage_elevation(b: Node3D,w: float,d: float,levels: Array) -> void:
	var count:=roundi(w/2.8);var pitch: float=w/count
	for f in range(levels.size()-1):
		var low: float=levels[f];var high: float=levels[f+1];var h: float=high-low
		K.box(b,Vector3(0,low+.22,-d/2),Vector3(w,.44,.30),"93988d",true,22)
		K.box(b,Vector3(0,high-.19,-d/2),Vector3(w,.38,.34),"aeb4a7",true,22)
		for i in count:
			var x: float=(i+.5)*pitch-w/2
			K.box(b,Vector3(x,(low+high)/2,-d/2+.12),Vector3(pitch-.10,h-.74,.08),"496572",true,5)
			for edge in [-1,1]:K.box(b,Vector3(x+edge*pitch/2,(low+high)/2,-d/2-.08),Vector3(.075,h-.56,.22),"5b6b65",false,11)
			if (i+f)%4 in [1,2]:
				K.box(b,Vector3(x,(low+high)/2,-d/2-.14),Vector3(pitch-.15,h-.80,.065),"58605a",false,16)
			else:K.box(b,Vector3(x,low+h*.57,-d/2-.07),Vector3(pitch,.065,.15),"78877d",false,11)

static func glazing(b: Node3D,w: float,z: float,side: int,lee: bool) -> void:
	var count:=roundi(w/4.5);var pitch: float=w/count
	for i in count:
		var x: float=(i+.5)*pitch-w/2
		if absf(x)<4.9:continue
		var aperture: float=pitch-1.55 if lee else pitch-.15
		K.box(b,Vector3(x,2.10,z),Vector3(aperture,4.02,.075),"536f73",true,19)
		for edge in [-1,1]:
			K.box(b,Vector3(x+edge*(pitch/2-.04),2.24,z),Vector3(.08,4.48,.17),"516257",false,11)
			if lee:K.box(b,Vector3(x+edge*(aperture/2+.3875),2.24,z),Vector3(.775,4.48,.28),"b5b2a4",true,22)
	K.box(b,Vector3(0,4.13,z),Vector3(w,.66,.32),"b5b2a4" if lee else "939b8e",true,22)
	for edge in [-1,1]:
		K.box(b,Vector3(edge*1.7,1.88,z),Vector3(.10,3.76,.18),"344b42",true,11)
		K.box(b,Vector3(edge*3.4,1.9,z),Vector3(3.2,3.8,.07),"648885",true,19)
		K.box(b,Vector3(edge*1.77,1.87,z-side*.72),Vector3(.07,3.65,1.35),"75978c",false,19)
	K.label(b,"Research A" if lee else "Research B",Vector3(-7.3,3.98,z+side*.25),.009).rotation.y=0 if side>0 else PI

static func public_floor(b: Node3D,w: float,d: float,lee: bool) -> void:
	K.box(b,Vector3(0,.052,0),Vector3(w,.07,d),"a09c8d",false,23)
	for side in [-1,1]:
		K.box(b,Vector3(0,.055,side*(d/2+2)),Vector3(w,.06,4),"9d9a8f",false,23)
		glazing(b,w,side*d/2,side,lee)
	# A straight public entrance hall, with a genuine clear central walking line.
	for side in [-1,1]:K.box(b,Vector3(side*5,2.2,0),Vector3(.18,4.4,d-.25),"858a7d",true,22)
	K.box(b,Vector3(0,4.35,0),Vector3(10,.12,d),"9da497",false,22)
	for z in range(-18,19,6):
		K.box(b,Vector3(0,4.24,z),Vector3(2,.05,.18),"dfdfca",false,17)
	for side in [-1,1]:K.bench(b,Vector3(side*3.4,0,5),side*PI/2)
	for x in range(-int(w/2)+3,int(w/2),6):K.box(b,Vector3(x,4.27,0),Vector3(.26,.40,d),"a6aea0",false,22)
	for side in [-1,1]:K.box(b,Vector3(side*3.8,4.06,0),Vector3(.12,.12,d),"6e7c71",false,11)

static func road_arcade(b: Node3D,w: float,d: float) -> void:
	# Suspended bronze fins face the landscape, not the Research A/B internal passage.
	K.box(b,Vector3(0,4.55,23.1),Vector3(w,.18,4.2),"a0a79a",false,22)
	for i in range(int(w/.46)):
		var x: float=-w/2+(i+.5)*.46
		if absf(x-w*.32)<2.05:continue
		K.box(b,Vector3(x,3.82,24.7),Vector3(.085,1.55,.46),"896e58",false,11)
	for y in [3.13,4.48]:K.box(b,Vector3(0,y,24.62),Vector3(w,.07,.09),"454f47",false,11)
	for x in range(-int(w/2)+2,int(w/2),6):
		K.box(b,Vector3(x,4.24,23.0),Vector3(.15,.26,4.2),"68756a",false,11)
		K.box(b,Vector3(x,4.08,22.8),Vector3(1.2,.045,.12),"e2dfcb",false,17)
		var brace:=K.holder(b,"BronzeScreenBrace",Vector3(x,3.94,23.45));brace.rotation.x=atan2(.68,2.25)
		K.box(brace,Vector3.ZERO,Vector3(.055,.065,2.35),"48574d",false,11);K.finish(brace)
