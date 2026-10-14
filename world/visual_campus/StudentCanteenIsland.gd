extends RefCounted
## Official 1F panorama 86404084/85: curved pale counter, green tiled core and lit fascia.
## Shape/metres/location are fitted; shop name and capture date are not established.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")

static func oval(n:Node3D,rx:float,rz:float,low:float,high:float,color:String,solid:bool,kind:int)->void:
	var vertices:=PackedVector3Array();var top:=PackedVector3Array()
	for i in 48:
		var a:float=TAU*i/48;var b:float=TAU*(i+1)/48
		var p:=Vector3(cos(a)*rx,low,sin(a)*rz);var q:=Vector3(cos(b)*rx,low,sin(b)*rz)
		var r:=Vector3(q.x,high,q.z);var s:=Vector3(p.x,high,p.z)
		vertices.append_array(PackedVector3Array([p,q,r,p,r,s]))
		top.append_array(PackedVector3Array([Vector3(0,high,0),s,r,Vector3(0,low,0),q,p]))
	K.surface(n,vertices,color,kind,solid);K.surface(n,top,color,kind,solid)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"CanteenCurvedIslandV236",P.point(565,430,.09))
	# 4.8 x 3.0 m counter; the main cross-aisle at v480 remains outside this footprint.
	oval(n,2.40,1.50,0,.12,"414e47",true,11)
	oval(n,2.37,1.47,.12,.98,"c0dbc2",true,22)
	oval(n,2.45,1.55,.98,1.05,"e0e1ce",true,22)
	oval(n,2.385,1.485,.91,.94,"e5f1da",false,17)
	# Enclosed back-of-counter core and equipment, not an invented walk-through shop.
	K.box(n,Vector3(0,1.72,0),Vector3(2.0,1.34,.80),"234c3d",true,75)
	K.box(n,Vector3(0,2.625,0),Vector3(2.0,.49,.80),"234c3d",false,75)
	# A thin raised light trace follows the curved front, including the observed short pulse.
	var trace:=PackedVector3Array()
	for i in 96:
		var a:float=TAU*i/96;var b:float=TAU*(i+1)/96
		var ya:float=.60;var yb:float=.60
		if i%24 in [10,11,12,13]:ya+=[-.06,.13,-.06,0.][i%24-10]
		if (i+1)%24 in [10,11,12,13]:yb+=[-.06,.13,-.06,0.][(i+1)%24-10]
		var p:=Vector3(cos(a)*2.378,ya,sin(a)*1.478);var q:=Vector3(cos(b)*2.378,yb,sin(b)*1.478)
		trace.append_array(PackedVector3Array([p,q,q+Vector3.UP*.013,p,q+Vector3.UP*.013,p+Vector3.UP*.013]))
	K.surface(n,trace,"e2edda",17,false)
	for x in [-.70,-.23,.23,.70]:
		K.box(n,Vector3(x,1.22,-.59),Vector3(.29,.34,.23),"929e93",false,11)
		K.box(n,Vector3(x,1.39,-.59),Vector3(.26,.025,.23),"38493e",false,11)
	for x in [-.58,.58]:
		K.box(n,Vector3(x,2.08,-.45),Vector3(.75,.44,.035),"333e39",false,11)
		K.box(n,Vector3(x,2.08,-.477),Vector3(.69,.37,.008),"acbdad",false,22)
	oval(n,2.52,1.62,2.87,3.25,"7eab4c",false,22)
	for y in [2.94,3.05,3.16]:oval(n,2.529,1.629,y,y+.022,"e5ecd7",false,17)
	# Smooth pale underside and warm recessed lamps observed under the curved fascia.
	oval(n,2.52,1.62,2.83,2.87,"d2cbb1",false,22)
	for i in 8:
		var a:float=TAU*i/8
		K.box(n,Vector3(cos(a)*1.9,2.825,sin(a)*1.10),Vector3(.09,.012,.09),"fff1cd",false,17)
	K.finish(n)
	# Two-column utensil consoles visible from the service aisle; local placement fitted.
	for v in [338,563]:
		var cabinet:=K.holder(parent,"CanteenUtensilConsole",P.point(620,v,.09))
		K.box(cabinet,Vector3(0,.42,0),Vector3(.72,.84,.55),"b8d5bd",true,22)
		K.box(cabinet,Vector3(0,.86,0),Vector3(.80,.055,.61),"c2ac70",true,11)
		for x in [-.36,0,.36]:K.box(cabinet,Vector3(x,.42,.28),Vector3(.018,.80,.012),"b89e56",false,11)
		for x in [-.19,.19]:
			K.box(cabinet,Vector3(x,.98,0),Vector3(.16,.21,.18),"e4e6d4",false,22)
			for j in 4:K.box(cabinet,Vector3(x-.052+j*.035,1.14,0),Vector3(.014,.15,.014),"c7c5ae",false,11)
		K.finish(cabinet)
