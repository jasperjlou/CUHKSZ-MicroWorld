extends RefCounted
## V170: built photographs009/010/011/004 and architect axo073 (published2025-12-24).
## Curved stone transition, open diagonal sunshades and stepped glazed return; dimensions fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const BASE=11.5

static func wall(n:Node3D,a:Vector3,b:Vector3,c:Vector3,d:Vector3,color:String,kind:int=22,solid:bool=false)->void:
	K.surface(n,PackedVector3Array([a,b,c,a,c,d,c,b,a,d,c,a]),color,kind,solid)

static func curve(t:float)->Vector2:return Vector2(18+6*sin(t*PI/2),39-6*cos(t*PI/2))

static func slab(n:Node3D,y:float)->void:
	var polygon:=PackedVector2Array([Vector2(-38,15),Vector2(-38,33)])
	for i in 17:polygon.append(curve(i/16.))
	polygon.append(Vector2(24,15))
	var indices:=Geometry2D.triangulate_polygon(polygon);var top:=PackedVector3Array();var bottom:=PackedVector3Array()
	for i in range(0,indices.size(),3):
		var a:=Vector3(polygon[indices[i]].x,y,polygon[indices[i]].y)
		var b:=Vector3(polygon[indices[i+1]].x,y,polygon[indices[i+1]].y)
		var c:=Vector3(polygon[indices[i+2]].x,y,polygon[indices[i+2]].y)
		if (b-a).cross(c-a).y>0:
			var swap:=b;b=c;c=swap
		top.append_array(PackedVector3Array([a,b,c]));bottom.append_array(PackedVector3Array([a-Vector3.UP*.28,c-Vector3.UP*.28,b-Vector3.UP*.28]))
	K.surface(n,top,"c1c4ba",15,true);K.surface(n,bottom,"c7cbc1",22)

static func shade(n:Node3D,x:float,y:float)->void:
	# The observed shade is an open white cheek plus a diagonal gold tray, not a solid gold box.
	wall(n,Vector3(x-2.3,y+.8,33.1),Vector3(x-2.3,y+.8,35),Vector3(x-2.3,y+3.6,35),Vector3(x-2.3,y+3.6,33.1),"d1cbbb")
	var a:=Vector3(x-2.3,y+.75,35);var b:=Vector3(x+2.3,y+.75,33.35)
	wall(n,Vector3(x-2.3,y+.75,33.1),Vector3(x+2.3,y+.75,33.1),b,a,"c79742")
	wall(n,a,b,b-Vector3.UP*.20,a-Vector3.UP*.20,"bc8b38")
	wall(n,Vector3(x-2.3,y+3.55,33.1),Vector3(x+2.3,y+3.55,33.1),Vector3(x+2.3,y+3.55,33.35),Vector3(x-2.3,y+3.55,35),"d1cbbb")

static func ribbon(n:Node3D,z:float,low:float,width:float,cx:float,entry:bool)->void:
	if not entry:K.box(n,Vector3(cx,low+.45,z),Vector3(width,.90,.22),"c8c2b1",true,22)
	K.box(n,Vector3(cx,low+3.75,z),Vector3(width,.50,.22),"ccc7b9",true,22)
	if entry:
		# Keep the existing central public axis open, including its threshold.
		for span:Vector2 in [Vector2(-38,-3.5),Vector2(3.5,cx+width/2)]:
			K.box(n,Vector3((span.x+span.y)/2,low+1.8,z),Vector3(span.y-span.x,3.6,.12),"637f82",true,19)
	else:
		K.box(n,Vector3(cx,low+2.05,z),Vector3(width,2.5,.12),"4e6770",true,5)
		var offset:float=.12 if z>20 else -.12
		for x in range(-37,int(cx+width/2),3):
			K.box(n,Vector3(x,low+2.05,z+offset),Vector3(.07,2.6,.17),"86968e",false,11)
		K.box(n,Vector3(cx,low+2.25,z+offset),Vector3(width,.065,.14),"84968e",false,11)

static func glass_arm(n:Node3D,x0:float,x1:float,levels:int)->void:
	var w:=x1-x0;var h:=levels*4.
	for i in levels+1:K.box(n,Vector3((x0+x1)/2,BASE+i*4-.14,27),Vector3(w,.28,24),"c9cfc4",true,22)
	K.box(n,Vector3((x0+x1)/2,BASE+h/2,39),Vector3(w,h,.12),"496878",true,5)
	for x:float in [x0,x1]:
		if x==44:
			for i in levels:
				# V172 built009 side view and aerial92544949: narrow windows in pale stone.
				K.box(n,Vector3(x,BASE+i*4+.66,27),Vector3(.26,1.32,24),"c4bca9",true,26)
				K.box(n,Vector3(x,BASE+i*4+3.47,27),Vector3(.26,1.06,24),"c4bca9",true,26)
				K.box(n,Vector3(x-.12,BASE+i*4+2.13,27),Vector3(.14,1.62,20),"4e6b77",true,5)
				for z:float in [16,38]:K.box(n,Vector3(x,BASE+i*4+2.13,z),Vector3(.26,1.62,2),"c4bca9",true,26)
				for z in range(18,38,2):K.box(n,Vector3(x+.10,BASE+i*4+2.13,z),Vector3(.16,1.62,.20),"aaa99c",false,26)
		else:K.box(n,Vector3(x,BASE+h/2,27),Vector3(.18,h,24),"b9c2b7",true,22)
	for i in ceili(w/.72)+1:
		var x:float=lerpf(x0,x1,float(i)/ceili(w/.72))
		K.box(n,Vector3(x,BASE+h/2,39.23),Vector3(.065,h+.25,.5),"bac3b8",false,22)
	for i in levels*2+1:K.box(n,Vector3((x0+x1)/2,BASE+i*2,39.10),Vector3(w,.07,.12),"637c7f",false,11)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"ResearchCurvedFrontV170")
	for i in 9:slab(n,BASE+i*4)
	for i in 8:
		var y:float=BASE+i*4
		ribbon(n,33,y,56,-10,i==0)
		ribbon(n,15,y,62,-7,i==0)
		# Curved corner has fine horizontal louvers between white stone bands.
		for j in 16:
			var a:=curve(j/16.);var b:=curve((j+1)/16.)
			if i==0:
				# Official backdoor view: curved upper wall projects over recessed ground glass.
				var ai:=a-Vector2(0,2);var bi:=b-Vector2(0,2)
				wall(n,Vector3(ai.x,y+.03,ai.y),Vector3(bi.x,y+.03,bi.y),Vector3(bi.x,y+3.55,bi.y),Vector3(ai.x,y+3.55,ai.y),"637f82",19,true)
				wall(n,Vector3(a.x,y+3.55,a.y),Vector3(b.x,y+3.55,b.y),Vector3(b.x,y+4,b.y),Vector3(a.x,y+4,a.y),"c9c2ae",22,true)
				wall(n,Vector3(a.x,y+3.55,a.y),Vector3(b.x,y+3.55,b.y),Vector3(bi.x,y+3.55,bi.y),Vector3(ai.x,y+3.55,ai.y),"c3c7bc",22)
				if j%4==0:K.box(n,Vector3(ai.x,y+1.79,ai.y+.04),Vector3(.07,3.52,.12),"6d7d78",false,11)
				continue
			for band:Vector2 in [Vector2(0,.9),Vector2(3.3,4.)]:wall(n,Vector3(a.x,y+band.x,a.y),Vector3(b.x,y+band.x,b.y),Vector3(b.x,y+band.y,b.y),Vector3(a.x,y+band.y,a.y),"c9c2ae",22,true)
			wall(n,Vector3(a.x,y+.9,a.y),Vector3(b.x,y+.9,b.y),Vector3(b.x,y+3.3,b.y),Vector3(a.x,y+3.3,a.y),"5b7274",5,true)
			for bar in 11:
				var yy:float=y+1+bar*.21
				wall(n,Vector3(a.x,yy,a.y+.07),Vector3(b.x,yy,b.y+.07),Vector3(b.x,yy+.06,b.y+.07),Vector3(a.x,yy+.06,a.y+.07),"b6aa83")
		if i>0:
			# Stone end panels flank the open shade rhythm.
			K.box(n,Vector3(-34.5,y+2.1,33.17),Vector3(7,2.6,.12),"c9c2ae",false,22)
			for j in 8:shade(n,-24.8+j*5.25,y)
	K.box(n,Vector3(-38,BASE+16,24),Vector3(.3,32,18),"c8c2b1",true,26)
	wall(n,Vector3(18,BASE,31),Vector3(18,BASE,33),Vector3(18,BASE+3.55,33),Vector3(18,BASE+3.55,31),"637f82",19,true)
	# Two unequal glazed arms linked only at the bottom form the photographed deep notch.
	glass_arm(n,24,31,8);glass_arm(n,35,44,11)
	K.box(n,Vector3(33,BASE+4,35.5),Vector3(4,8,7),"4e6d7d",true,5)
	for x in range(31,36):K.box(n,Vector3(x,BASE+4,39.23),Vector3(.065,8,.5),"bac3b8",false,22)
	for y:float in [43.5,55.5]:
		var cx:float=27.5 if y<50 else 39.5;var w:float=7 if y<50 else 9
		K.box(n,Vector3(cx,y+.15,27),Vector3(w,.30,24),"c8ccc2",true,22)
	K.finish(n)
