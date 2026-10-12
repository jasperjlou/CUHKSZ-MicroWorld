extends RefCounted
## Continuous shell, deep reveals and shaped roof read from the completed WWJ aerial.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Rear := preload("res://world/visual_campus/LibraryRearGlazing.gd")
const CLADDING := "626b6b"
const Registered := preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Lantern := preload("res://world/visual_campus/LibraryRoofLantern.gd")

static func registered_roof_y(p:Vector2)->float:
	return Registered.roof_height(p)

static func registered_upper(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryRegisteredUpperEnvelopeV110");var boundary:=Registered.outline()
	for i in boundary.size():
		var a:=boundary[i];var b:=boundary[(i+1)%boundary.size()];var length:=a.distance_to(b)
		if i in [0,12]:Rear.registered_end_frame(n,a,b,i)
		var count:=maxi(1,int(ceil(length/1.8)));var pitch:float=length/count;var yaw:float=-atan2(b.y-a.y,b.x-a.x)+PI
		for j in count:
			var p:=a.lerp(b,(j+.5)/count)
			if i in [0,12]:
				continue # V149 recessed complete frame owns the end, including its head.
			elif i<22 or i>29:framed_bay(n,Vector3(p.x,0,p.y),pitch+.025,yaw,i*31+j)
			var h:=registered_roof_y(p)
			K.box(n,Vector3(p.x,(h+24.8)/2,p.y),Vector3(pitch+.03,h-24.8,.55),CLADDING,false,13,yaw)
			K.box(n,Vector3(p.x,h+.04,p.y),Vector3(pitch+.035,.08,.64),"a2aaa0",false,11,yaw)
			K.box(n,Vector3(p.x,12.64,p.y),Vector3(pitch+.03,.32,.55),CLADDING,false,13,yaw)
	preload("res://world/visual_campus/LibraryPoolFacade.gd").build(n,boundary)
	var parts:Array[PackedVector2Array]=[boundary]
	parts=Registered.subtract(parts,Lantern.opening())
	# Split at both roof-height creases before triangulation. Otherwise adjacent
	# clipped polygons interpolate abs(x)/abs(z-10) differently and open long cracks.
	for crease in [[Vector2(0,-200),Vector2(0,200)],[Vector2(-200,10),Vector2(200,10)]]:
		var split:Array[PackedVector2Array]=[]
		for part in parts:
			for side in [true,false]:
				var piece:=Registered.halfplane(part,crease[0],crease[1],side)
				if piece.size()>=3:split.append(piece)
		parts=split
	var roof:=Registered.floor_vertices(parts,0);var underside:=PackedVector3Array()
	for i in roof.size():roof[i].y=registered_roof_y(Vector2(roof[i].x,roof[i].z))
	for i in range(0,roof.size(),3):underside.append_array(PackedVector3Array([roof[i]-Vector3.UP*.22,roof[i+2]-Vector3.UP*.22,roof[i+1]-Vector3.UP*.22]))
	K.surface(n,roof,"92988d",18);K.surface(n,underside,"d6d9cb",22)
	# Low metal upstand and cap trace every corner, rather than a flush white roof edge.
	var rim:=K.holder(n,"LibraryRoofPerimeterV149")
	var Member=preload("res://world/visual_campus/LibraryRegisteredUpper.gd")
	for i in boundary.size():
		var a:=boundary[i];var b:=boundary[(i+1)%boundary.size()]
		Member.segment(rim,Vector3(a.x,registered_roof_y(a)+.16,a.y),Vector3(b.x,registered_roof_y(b)+.16,b.y),.24,.32,"737e7c",false,13)
		Member.segment(rim,Vector3(a.x,registered_roof_y(a)+.34,a.y),Vector3(b.x,registered_roof_y(b)+.34,b.y),.38,.07,"a0aaa6",false,11)
	K.finish(rim)
	Lantern.build(n)
	K.finish(n)

static func front(x: float,w: float,d: float) -> float:
	return P.front(x,w,d)

static func top(x: float,w: float) -> float:
	var u:=x/(w/2)
	return 26.0+1.9*u*u+.48*sin(u*PI*1.5)

static func face(v: PackedVector3Array,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
	v.append_array(PackedVector3Array([a,b,c,a,c,d]))

static func interior_fascia(n: Node3D,outer: PackedVector3Array) -> void:
	var inside:=PackedVector3Array()
	for i in range(0,outer.size(),3):inside.append_array(PackedVector3Array([outer[i],outer[i+2],outer[i+1]]))
	if not inside.is_empty():K.surface(n,inside,"d5d5c9",22)

static func inner_bay(n: Node3D,p: Vector3,pitch: float,yaw: float,y: float,opening: float,blank: bool) -> void:
	var basis:=Basis(Vector3.UP,yaw)
	if blank:
		K.box(n,p+basis*Vector3(0,y,-.64),Vector3(pitch+.03,4,.075),"d4d4c8",false,22,yaw)
		return
	for side in [-1,1]:
		K.box(n,p+basis*Vector3(side*(opening/2+(pitch-opening)/4),y,-.64),Vector3((pitch-opening)/2+.02,4,.075),"d4d4c8",false,22,yaw)
		K.box(n,p+basis*Vector3(0,y+side*1.49,-.64),Vector3(opening,1.02,.075),"d4d4c8",false,22,yaw)

static func return_x(z: float,w: float,d: float,side: int) -> float:
	return P.side_x(z,w,d,side)

static func return_top(z: float,w: float,d: float,side: int) -> float:
	return P.roof_y(Vector2(return_x(z,w,d,side),z),w,d)

static func framed_bay(b: Node3D,p: Vector3,pitch: float,yaw: float,seed: int,door: bool=false) -> void:
	# Shared wall batching; every panel/window still follows its own facade tangent.
	var basis:=Basis(Vector3.UP,yaw)
	for row in 3:
		if door and row==0:
			K.box(b,p+basis*Vector3(0,16.45,-.28),Vector3(pitch+.02,.7,.56),CLADDING,true,13,yaw)
			continue
		var y:=14.8+row*4.0;var opening:=.92 if (seed+row)%7!=0 else .56
		var blank: bool=(row==2 and seed%13 in [0,1])
		inner_bay(b,p,pitch,yaw,y,opening,blank)
		if blank:
			K.box(b,p+basis*Vector3(0,y,-.28),Vector3(pitch+.02,4,.56),CLADDING,true,13,yaw)
			continue
		for side in [-1,1]:
			K.box(b,p+basis*Vector3(side*(opening/2+(pitch-opening)/4),y,-.28),Vector3((pitch-opening)/2+.02,4,.56),CLADDING,true,13,yaw)
			K.box(b,p+basis*Vector3(0,y+side*1.49,-.28),Vector3(opening,1.02,.56),CLADDING,true,13,yaw)
		K.box(b,p+basis*Vector3(0,y,-.52),Vector3(opening,1.96,.08),"516670",false,5,yaw)
		K.box(b,p+basis*Vector3(opening/2-.045,y,-.22),Vector3(.09,1.96,.60),"b27e5b",false,11,yaw)
		K.box(b,p+basis*Vector3(-opening/2+.025,y,-.22),Vector3(.05,1.96,.58),"4b5555",false,11,yaw)
		K.box(b,p+basis*Vector3(0,y-1.0,-.17),Vector3(opening+.06,.07,.56),"8f9189",false,11,yaw)
		K.box(b,p+basis*Vector3(0,y,-.455),Vector3(.035,1.92,.03),"778683",false,11,yaw)

static func returns(b: Node3D,w: float,d: float) -> void:
	var n:=K.holder(b,"LibraryContinuousReturnPanels")
	var fascia:=PackedVector3Array();var soffit:=PackedVector3Array()
	var z_start: float=-d*.47;var z_end:=front(w/2,w,d);var count:=28;var pitch: float=(z_end-z_start)/count
	for side in [-1,1]:
		for i in count:
			if side>0:continue # V116 registered right exhibition skin; rear still separate.
			var z0: float=z_start+i*pitch;var z1:=z0+pitch;var z: float=(z0+z1)/2
			if z < -11.4:continue # V150 independently registered rear/WC returns own this part.
			var x0:=return_x(z0,w,d,side);var x1:=return_x(z1,w,d,side);var x:=return_x(z,w,d,side)
			var slope: float=(x1-x0)/(z1-z0);var yaw: float=side*PI/2+atan(slope)
			var length: float=Vector2(x1-x0,z1-z0).length()
			var opening: bool=(side<0 and z>-22 and z<-12) or z>16
			if not opening:
				K.box(n,Vector3(x-side*.70,8.48 if side>0 else 6.28,z),Vector3(.12,8.16 if side>0 else 12.56,length+.03),"445961",true,5)
				for j in 2:
					var fz:=z0+(j+.5)*pitch/2;var fx:=return_x(fz,w,d,side)
					K.box(n,Vector3(fx+side*.16,8.45 if side>0 else 6.25,fz),Vector3(.65,8.1 if side>0 else 12.5,.12),"b6a17d",false,11,atan(slope))
				K.box(n,Vector3(x-side*.59,8.5 if side>0 else 6.3,z0),Vector3(.12,8.2 if side>0 else 12.6,.055),"566764",false,11)
		for zc in [-22,-13,-4,5]:
			if side<0 and zc in [-22,-13]:continue # remote core walls now support these occupied bays
			K.column(n,Vector3(side*(w/2-5),4.4 if side>0 else 0,zc),8.1 if side>0 else 12.5,.62)
	# V150 lower rear uses independent2F/3F lines, not the upper C-shaped notch.

	K.finish(n)

static func build(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	# Registered lower front and entry pavilion now own the complete entrance side.
	returns(b,w,d)
	preload("res://world/visual_campus/LibraryLowerFrontFacade.gd").build(b)
	registered_upper(b)
