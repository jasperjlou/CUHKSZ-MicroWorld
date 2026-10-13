extends RefCounted
## V224: official2F83562024 interior,70037187 court. No independent2F plan available.
## Local placement retains fitted floors, doors, cores and court-stair footprint.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const C=preload("res://world/visual_campus/StudentFrontCore.gd")
const Y:float=4.4

static func table(n:Node3D,u:float,v:float,bench_side:int=0)->void:
	var h:=K.holder(n,"LotusPaleTable",P.point(u,v,Y+.02))
	K.box(h,Vector3(0,.76,0),Vector3(2.05,.065,.74),"cdbd8d",true,43)
	for x in [-.88,.88]:
		for z in [-.27,.27]:K.box(h,Vector3(x,.37,z),Vector3(.035,.74,.035),"989f93",false,11)
	for x in [-.67,.05,.77]:
		for sign in [-1,1]:
			if sign==bench_side:continue
			var color:String="c4bc50" if (sign==1) else "9fbfad"
			var z:float=sign*.68
			K.box(h,Vector3(x,.44,z),Vector3(.40,.05,.39),color,false,22)
			K.box(h,Vector3(x,.69,z+sign*.18),Vector3(.40,.43,.045),color,false,22)
			for dx in [-.15,.15]:
				for dz in [-.15,.15]:K.box(h,Vector3(x+dx,.21,z+dz),Vector3(.027,.42,.027),"989f93",false,11)
	K.finish(h)

static func banquette(n:Node3D)->void:
	# Two-sided yellow booth and end planters visible behind the interior panorama.
	C.rect(n,561,288,569,358,Y+.02,Y+.39,"b49d69",true,43)
	C.rect(n,555,288,575,358,Y+.39,Y+.47,"c6ac36",true)
	C.rect(n,563.5,288,566.5,358,Y+.47,Y+1.16,"d0b83e",true)
	for v in range(290,358,4):C.rect(n,563.2,v,566.8,v+.22,Y+.48,Y+1.15,"a58e31",false)
	for v in [280,366]:
		C.rect(n,555,v-6,575,v+6,Y+.02,Y+1.02,"b39e70",true,43)
		C.rect(n,556,v-5,574,v+5,Y+1.02,Y+1.04,"4b5340",false)
		K.V.shrub(n,P.point(565,v,Y+1.04),Vector3(.60,.35,1.1),int(v))

static func canopy(n:Node3D)->void:
	# Linear baffles: different from the1F hexagonal islands.
	C.rect(n,439,246,622,397,8.30,8.34,"505745",false)
	for v in range(247,397,2):C.rect(n,440,v,621,v+.55,8.17,8.30,"c0b476",false,43)
	for r in [[429,242,439,397],[622,242,706,400],[430,90,706,240]]:
		C.rect(n,r[0],r[1],r[2],r[3],8.23,8.34,"dddcc9",false)
	for u in [468,585]:
		for v in [270,315,370]:C.rect(n,u-10,v-.4,u+10,v+.4,8.14,8.17,"f0eacb",false,17)
	for v in [265,310,365]:
		K.box(n,P.point(656,v,8.20),Vector3(.12,.025,.12),"eee8d5",false,17)

static func double_quad(vertices:PackedVector3Array,a:Vector3,b:Vector3,c:Vector3,d:Vector3)->void:
	vertices.append_array(PackedVector3Array([a,b,c,a,c,d,c,b,a,d,c,a]))

static func flared_column(n:Node3D)->void:
	# Photo-based yellow radial ribs curve out below the baffle ceiling.
	# Position on the continued support grid is fitted, not a surveyed panorama station.
	var centre:=P.point(508,338);var vertices:=PackedVector3Array()
	for i in range(20):
		var radial:=Vector3(cos(TAU*i/20),0,sin(TAU*i/20))
		for j in range(12):
			var t0:float=j/12.;var t1:float=(j+1)/12.
			var y0:float=Y+.2+t0*3.57;var y1:float=Y+.2+t1*3.57
			var r0:float=.49+1.10*pow(maxf(0.,(t0-.64)/.36),2.)
			var r1:float=.49+1.10*pow(maxf(0.,(t1-.64)/.36),2.)
			double_quad(vertices,centre+radial*r0+Vector3.UP*y0,centre+radial*r1+Vector3.UP*y1,centre+radial*(r1+.12)+Vector3.UP*y1,centre+radial*(r0+.12)+Vector3.UP*y0)
	K.surface(n,vertices,"c6b43a",22,false)

static func services(n:Node3D)->void:
	# Short fitted service run between retained rear-facing portals atv306/439.
	C.rect(n,706,342,709,406,Y,8.4,"d8d5c0",true)
	for v in [352,376,400]:
		C.rect(n,685,v-10,706,v+10,Y,Y+.98,"c0ae84",true,43)
		C.rect(n,683,v-11,707,v+11,Y+.98,Y+1.05,"d8d2b8",true)
		C.rect(n,690,v-10,691,v+10,Y+1.06,Y+2.45,"9daf9f",true,19)
		for edge in [-10,10]:C.rect(n,689,v+edge-.45,692,v+edge+.45,Y+1.,Y+2.55,"d8dacd",false,11)
		C.rect(n,687,v-11,707,v+11,Y+2.56,Y+2.92,"c7c4ae",true)
		C.rect(n,686,v-6,687,v+6,Y+2.34,Y+2.53,"44504a",false,11)
		C.rect(n,684.5,v-9,685,v+9,Y+.72,Y+.76,"f0dfad",false,17)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentLotusDiningV224")
	# Existing4.4m slabs remain the only support; avoid front core openings.
	for r in [[428,85,705,240],[428,240,705,400],[560,400,705,500]]:
		C.rect(n,r[0],r[1],r[2],r[3],Y+.002,Y+.017,"c2bda7",false,69)
	# Continue four visible structural supports under the courtyard; height/location fitted.
	for u in [508,610]:
		for v in [235,338]:
			C.rect(n,u-5,v-5,u+5,v+5,Y,8.52,"d4d4c0",true)
			for edge in [-5.05,5.05]:C.rect(n,u+edge-.15,v-5.1,u+edge+.15,v+5.1,Y+.1,8.25,"8d7652",false,43)
	for q in [[470,180],[565,180],[470,270],[470,350]]:table(n,q[0],q[1])
	for v in [300,345]:
		table(n,540,v,-1);table(n,590,v,1)
	banquette(n);canopy(n);flared_column(n);services(n)
	n.set_meta("source","official2F83562024/70037187; no independent2F plan; positions/heights fitted")
	K.finish(n)
