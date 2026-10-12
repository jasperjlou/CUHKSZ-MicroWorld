extends RefCounted
## V178 reception panorama70037182: a hollow glazed waiting wing and an open side passage.
## Room extent/orientation use the retained Hall frame; exact floor plan remains unregistered.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const C=preload("res://world/visual_campus/ConferenceCentre.gd")
const Y:=.84

static func disc(n:Node3D,p:Vector3,r:float,h:float,color:String)->void:
	var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.radial_segments=24
	var m:=MeshInstance3D.new();m.mesh=mesh;m.position=p;m.material_override=K.material(color,22);n.add_child(m)

static func shell_chair(parent:Node3D,p:Vector3,yaw:float)->void:
	var n:=K.holder(parent,"RedWaitingChair",p);n.rotation.y=yaw
	disc(n,Vector3(0,.48,0),.31,.08,"99324d")
	# Low rounded back/arms follows the photographed red shell rather than a square office chair.
	var v:=PackedVector3Array()
	for i in 16:
		var a:float=PI*i/16;var b:float=PI*(i+1)/16
		var p0:=Vector3(cos(a)*.31,.48,sin(a)*.31);var p1:=Vector3(cos(b)*.31,.48,sin(b)*.31)
		var q0:=Vector3(cos(a)*.34,.85,sin(a)*.34);var q1:=Vector3(cos(b)*.34,.85,sin(b)*.34)
		v.append_array(PackedVector3Array([p0,p1,q1,p0,q1,q0,q1,p1,p0,q0,q1,p0]))
	K.surface(n,v,"99324d",22)
	K.box(n,Vector3(0,.5,0),Vector3(.58,.1,.58),"99324d",true,22)
	for x:float in [-.20,.20]:
		for z:float in [-.20,.20]:K.box(n,Vector3(x,.24,z),Vector3(.045,.48,.045),"ad8859",false,4)
	K.finish(n)

static func build(b:Node3D)->void:
	var n:=K.holder(b,"HallGlazedWaitingWingV178")
	K.box(n,Vector3(32.5,.42,15.5),Vector3(25,.84,21),"b8bcb3",true,22)
	K.box(n,Vector3(32.5,Y+.018,15.5),Vector3(25,.025,21),"a2a59e",false,53)
	K.box(n,Vector3(32.5,7.4,15.5),Vector3(25,.30,21),"bfc4bc",true,22)
	K.box(n,Vector3(33,8.36,14),Vector3(24,.28,24),"b3bdb2",true,22)
	# Return into reception through a real four-metre opening; neither paper wall nor solid volume.
	for span:Vector2 in [Vector2(5.25,8.25),Vector2(12.25,17.55)]:
		K.box(n,Vector3(19.42,4,(span.x+span.y)/2),Vector3(.20,6.3,span.y-span.x),"c2c3b7",true,22)
	K.box(n,Vector3(19.42,5.75,10.25),Vector3(.20,3,4),"c2c3b7",true,22)
	for z:float in [8.2,12.3]:K.box(n,Vector3(19.55,2.54,z),Vector3(.08,3.4,.07),"77887d",false,11)
	# Two-tier window bays, broad concrete columns and upper external vertical blades.
	for z:float in [5.3,10.4,15.5,20.6,25.7]:
		K.box(n,Vector3(44.7,4,z),Vector3(.62,6.32,.62),"c6ccc3",true,22)
	for z:float in [7.85,12.95,18.05,23.15]:
		C.glazing(n,Vector3(45.04,2.65,z),4.48,3.62,PI/2)
		C.glazing(n,Vector3(45.04,5.92,z),4.48,2.45,PI/2)
		K.box(n,Vector3(45.06,4.56,z),Vector3(.35,.42,4.48),"bdc5bb",true,22)
	for z in range(6,26):K.box(n,Vector3(45.42,6.05,z),Vector3(.7,2.7,.13),"59665e",false,11)
	C.glazing(n,Vector3(32.5,2.65,26),24.3,3.62)
	C.glazing(n,Vector3(32.5,5.92,26),24.3,2.45)
	K.box(n,Vector3(32.5,4.56,26.05),Vector3(24.3,.42,.35),"bdc5bb",true,22)
	# Close the clerestory head to the ceiling; visual trim does not alter the tested route.
	K.box(n,Vector3(45.04,7.2,15.5),Vector3(.22,.18,21),"bdc5bb",false,22)
	K.box(n,Vector3(32.5,7.2,26),Vector3(25,.18,.22),"bdc5bb",false,22)
	# Ribbed pale ceiling and small linear lights remain above the clear circulation area.
	for x in range(21,45):K.box(n,Vector3(x,7.19,15.5),Vector3(.08,.18,20.5),"909c91",false,11)
	for x in [25,33,41]:
		for z in [9,20]:K.box(n,Vector3(x,7.08,z),Vector3(.18,.06,1.1),"eee8d8",false,17)
	for z in [10,20]:
		disc(n,Vector3(39,Y+.77,z),.63,.06,"d7dad1")
		disc(n,Vector3(39,Y+.36,z),.07,.72,"9caaa0")
		disc(n,Vector3(39,Y+.035,z),.36,.06,"b8c1b6")
		for angle in 4:
			var a:float=angle*PI/2;var p:=Vector3(39+cos(a),Y,z+sin(a))
			shell_chair(n,p,PI/2-a)
	for z in [6.8,24]:K.planter(n,Vector3(42,Y,z))
	var light:=OmniLight3D.new();light.position=Vector3(31,5.8,15);light.omni_range=24;light.light_energy=.7;light.light_color=Color("f2f0e1");light.shadow_enabled=false;n.add_child(light)
	K.finish(n)
