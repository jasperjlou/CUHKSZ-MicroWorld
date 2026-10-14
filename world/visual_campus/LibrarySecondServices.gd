extends RefCounted
## V228:2025-08-12 university service-upgrade photo. Capture date unknown.
## Adjacent to Ask Us, toward newspaper area on official2F map; metric pose fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
static func pose()->Transform3D:
	var a:=P.point2(808,480,4.4);var b:=P.point2(818,490,4.4)
	return Transform3D(Basis(Vector3.UP,-atan2((b-a).z,(b-a).x)),a)
static func point(x:float,y:float,z:float)->Vector3:return pose()*Vector3(x,y,z)
static func frontage_polygon()->PackedVector2Array:
	var poly:=PackedVector2Array()
	for q in [Vector2(-3.4,-1.75),Vector2(4.2,-1.75),Vector2(4.2,4.3),Vector2(-3.4,4.3)]:
		var p:=point(q.x,0,q.y);poly.append(Vector2(p.x,p.z))
	return poly
static func capsule_slots(n:Node3D,points:Array[Vector3])->void:
	var mesh:=CapsuleMesh.new();mesh.radius=.028;mesh.height=.30;mesh.radial_segments=8;mesh.rings=2
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=points.size()
	for i in points.size():mm.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3(1,1,.22)),points[i]))
	var model:=MultiMeshInstance3D.new();model.multimesh=mm;model.material_override=K.material("343d3a",22);n.add_child(model)
static func cabinet(parent:Node3D,p:Vector3)->void:
	var n:=K.holder(parent,"HoldsPickupCabinet2025",p)
	var slots:Array[Vector3]=[]
	for block in 2:
		var cx:float=(block-.5)*1.29
		K.box(n,Vector3(cx,1.23,0),Vector3(1.27,2.28,.43),"d9ded8",true,22)
		for row in 5:
			var cy:float=.36+row*.43
			if block==0 and row==2:
				K.box(n,Vector3(cx,cy,.223),Vector3(1.23,.41,.035),"e0e2db",false,22)
				K.box(n,Vector3(cx-.10,cy,.247),Vector3(.45,.29,.028),"293935",false,22)
				K.box(n,Vector3(cx-.10,cy,.263),Vector3(.36,.21,.012),"627f85",false,22)
				K.box(n,Vector3(cx+.35,cy-.06,.25),Vector3(.10,.06,.018),"3d4942",false,22)
				continue
			for col in 12:
				var x:float=cx-.572+col*.104
				K.box(n,Vector3(x,cy,.220),Vector3(.098,.408,.023),"e6e6dd",false,22)
				slots.append(Vector3(x,cy-.012,.237))
				K.box(n,Vector3(x,cy+.168,.240),Vector3(.034,.033,.012),"377c9a",false,22)
		for x in [cx-.50,cx+.50]:
			K.box(n,Vector3(x,.065,0),Vector3(.085,.13,.29),"7b827b",false,11)
			K.box(n,Vector3(x,.037,.09),Vector3(.105,.072,.072),"444e47",false,22)
	capsule_slots(n,slots)
	for label:Array in [["Holds Pickup",-.65],["预约取书",.65]]:
		var title:=K.label(n,label[0],Vector3(label[1],2.50,.09),.0028);title.modulate=Color("b69255")
	n.set_meta("source","official2025 service-upgrade photo; compartment count and metric dimensions fitted")
	K.finish(n)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibrarySecondServicesV228");n.transform=pose()
	# The map locates Ask Us on the office edge; only the observed shallow front is fitted.
	K.box(n,Vector3(-1.30,1.60,-1.65),Vector3(2.80,3.20,.16),"813350",true,22)
	K.box(n,Vector3(-2.74,1.60,-.72),Vector3(.16,3.20,2.0),"c7c9bd",true,22)
	K.box(n,Vector3(.20,1.60,-.85),Vector3(.16,3.20,1.6),"c7c9bd",true,22)
	K.box(n,Vector3(2.17,1.60,-.10),Vector3(3.60,3.20,.18),"d8d9cf",true,22)
	K.box(n,Vector3(-1.15,3.02,.03),Vector3(3.02,.20,.26),"b3b8af",false,11)
	for x in [-2.65,.35]:K.box(n,Vector3(x,1.46,.03),Vector3(.09,2.92,.26),"a7b0a7",true,11)
	K.box(n,Vector3(-1.5,.46,-1.11),Vector3(1.75,.92,.56),"927248",true,4)
	K.box(n,Vector3(-1.5,.94,-1.10),Vector3(1.82,.065,.63),"b59a70",false,4)
	K.box(n,Vector3(-1.12,1.15,-1.16),Vector3(.40,.30,.055),"35413d",false,22)
	K.box(n,Vector3(-1.12,1.13,-1.12),Vector3(.35,.24,.02),"61797b",false,22)
	K.label(n,"Ask Us",Vector3(-1.35,2.23,-1.545),.006).modulate=Color("f2eee0")
	# Neutral fitted stone apron matches the2025 photo; extent is not a surveyed boundary.
	preload("res://world/visual_campus/LibraryHallFloor.gd").service_finish(n)
	cabinet(n,Vector3(2.10,0,.25))
	var light:=OmniLight3D.new();light.position=Vector3(-.2,2.9,1.0);light.light_color=Color("f0ecdd");light.light_energy=.35;light.omni_range=6;light.shadow_enabled=false;n.add_child(light)
	n.set_meta("fit_limits","office front, cabinet pose and width fitted from2F map plus2025 photo; no claimed staff throughroute")
	K.finish(n)
