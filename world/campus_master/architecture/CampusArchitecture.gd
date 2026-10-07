extends RefCounted
const K := preload("res://world/campus_master/architecture/modules/ArchitectureKit.gd")
static var profiles: Dictionary = {}

static func load_profiles() -> void:
	profiles.clear()
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/building_architecture_profiles.json"))
	for p: Dictionary in data.buildings:profiles[p.id]=p

static func build(root: Node3D,o: Dictionary,w: float,d: float,h: float) -> void:
	if profiles.is_empty():load_profiles()
	var p: Dictionary=profiles[o.id];root.set_meta("architecture_profile",p)
	var wall: String=p.facade_primary
	match o.massing:
		"library": library(root,w,d,h)
		"admin": admin(root,w,d,h)
		"student": student(root,w,d,h)
		"college","courtyard": college(root,o,p,w,d,h)
		"music": music(root,w,d,h)
		"sports": sports(root,w,d,h)
		"tower":
			K.arcade(root,Vector3.ZERO,w,d*.7)
			K.volume(root,Vector3(0,(h+4.8)/2,0),Vector3(w*.72,h-4.8,d*.68),wall,true)
			K.screen(root,Vector3(0,h+.3,-d*.27),w*.6,1.8,"dark_frame")
			var balconies: Array[Transform3D]=[]
			for floor_index in range(2,int(h/3.4)):
				balconies.append(Transform3D(Basis.IDENTITY,Vector3(w*.16,floor_index*3.4,d*.35)))
			K.batch(root,balconies,Vector3(w*.24,.22,1.4),"warm_white")
		"bell":
			K.volume(root,Vector3(0,h*.4,0),Vector3(w*.55,h*.8,d*.55),wall)
			K.arcade(root,Vector3(0,h*.8,0),w*.7,d*.7,h*.15)
		_:
			academic(root,o,p,w,d,h)
	K.entrance(root,w,d,o.get("name_zh",o.get("name",o.id)))
	K.bake(root)

static func library(root: Node3D,w: float,d: float,h: float) -> void:
	# Lower and rotated upper C; both voids remain visible, never an infilled cube.
	var wing := minf(w,d)*.22;var half := (h-4.8)*.5
	K.arcade(root,Vector3.ZERO,w*.78,d*.72)
	K.volume(root,Vector3(-w/2+wing/2,4.8+half/2,0),Vector3(wing,half,d),"light_stone")
	for side in [-1,1]:K.volume(root,Vector3(0,4.8+half/2,side*(d/2-wing/2)),Vector3(w-wing*2,half,wing),"light_stone")
	K.volume(root,Vector3(0,4.8+half*1.5,-d/2+wing/2),Vector3(w,half,wing),"warm_white")
	for side in [-1,1]:K.volume(root,Vector3(side*(w/2-wing/2),4.8+half*1.5,0),Vector3(wing,half,d-wing*2),"warm_white")
	K.screen(root,Vector3(0,4.8,d/2-wing),w*.52,half,"wood_accent")
	K.box(root,Vector3(0,9.2,d/2+.09),Vector3(w*.54,2.4,.12),"glass_bluegray")

static func admin(root: Node3D,w: float,d: float,h: float) -> void:
	for side in [-1,1]:K.volume(root,Vector3(side*w*.34,h*.42,0),Vector3(w*.28,h*.84,d),"light_stone")
	K.volume(root,Vector3(0,h*.87,-d*.16),Vector3(w*.72,h*.26,d*.54),"light_stone")
	K.arcade(root,Vector3(0,0,-d*.25),w*.42,d*.3)
	K.box(root,Vector3(0,3,-d*.30),Vector3(w*.35,6,.2),"glass_bluegray")

static func student(root: Node3D,w: float,d: float,h: float) -> void:
	K.arcade(root,Vector3.ZERO,w*.9,d*.88)
	for side in [-1,1]:K.volume(root,Vector3(side*w*.34,(h+5)/2,0),Vector3(w*.23,h-5,d*.88),"light_stone")
	K.volume(root,Vector3(0,h*.72,-d*.29),Vector3(w*.46,h*.45,d*.25),"warm_white")
	K.volume(root,Vector3(0,7,d*.15),Vector3(w*.40,4,d*.22),"warm_white")
	K.screen(root,Vector3(0,4.8,d*.28),w*.40,4,"wood_accent")

static func college(root: Node3D,o: Dictionary,p: Dictionary,w: float,d: float,h: float) -> void:
	var wing := minf(w,d)*.24;var accent: String=o.accent
	var paired := int(p.variation)%3!=0
	for side in [-1,1]:
		var height: float=h if side==-1 else h*(.78 if paired else .58)
		K.volume(root,Vector3(side*(w/2-wing/2),(height+5)/2,-d*.08),Vector3(wing,height-5,d*.78),"warm_white",true)
		K.arcade(root,Vector3(side*(w/2-wing/2),0,-d*.08),wing,d*.78)
		K.box(root,Vector3(side*(w/2-.2),height/2,-d*.20),Vector3(.35,height,d*.18),accent)
		K.box(root,Vector3(side*(w/2-wing/2),height/2,d*.315),Vector3(wing*.30,height,.18),accent)
		K.screen(root,Vector3(side*(w/2-wing/2),height+.4,-d*.2),wing*.85,2,"dark_frame")
	K.volume(root,Vector3(0,h*.23+5,-d*.38),Vector3(w-wing*2,h*.46,d*.18),"warm_white",true)
	K.arcade(root,Vector3(0,0,d*.27),w-wing*2,d*.15)
	K.box(root,Vector3(0,5.8,d*.27),Vector3(w-wing*2,1.1,d*.16),accent)
	for i in range(4):
		K.box(root,Vector3((i-1.5)*(w-wing*2)/4,h*.46+6,-d*.38),Vector3(.5,1.8,d*.18),"dark_frame")
	root.set_meta("courtyard_local",Vector3.ZERO)

static func academic(root: Node3D,o: Dictionary,p: Dictionary,w: float,d: float,h: float) -> void:
	var variant := int(p.variation)%3
	K.arcade(root,Vector3.ZERO,w*.94,d*.72)
	K.volume(root,Vector3(-w*.11,(h+5)/2,-d*.13),Vector3(w*.76,h-5,d*.60),"light_stone")
	K.volume(root,Vector3(w*.35,h*.31+5,d*.12),Vector3(w*.24,h*.62,d*.68),"warm_white")
	K.screen(root,Vector3(-w*.11,4.8,d*.175),w*.76,3.5,"wood_accent")
	K.box(root,Vector3(-w*.1,h*.58,d*.176),Vector3(w*.65,2,.15),"glass_bluegray")
	if variant==1:K.screen(root,Vector3(w*.22,h*.85,-d*.15),w*.22,h*.15,"dark_frame")
	if o.id.begins_with("conference"):
		K.box(root,Vector3(-w*.15,4,d*.29),Vector3(w*.60,7,.18),"glass_bluegray")

static func sports(root: Node3D,w: float,d: float,h: float) -> void:
	K.arcade(root,Vector3.ZERO,w,d*.9)
	K.volume(root,Vector3(0,(h+5)/2,0),Vector3(w,h-5,d),"warm_white")
	K.box(root,Vector3(0,5.8,d/2+.03),Vector3(w*.9,1.7,.12),"glass_bluegray")
	K.screen(root,Vector3(0,7,d/2+.16),w*.95,h-7,"warm_white")

static func music(root: Node3D,w: float,d: float,h: float) -> void:
	for i in range(3):
		var height: float=h*(1.0-i*.16)
		var mesh := CylinderMesh.new();mesh.top_radius=1;mesh.bottom_radius=1;mesh.height=1;mesh.radial_segments=16
		var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=K.material("light_stone")
		node.position=Vector3((i-1)*w*.29,(height+5)/2,(i-1)*d*.15);node.scale=Vector3(w*.19,height-5,d*.32);root.add_child(node)
		K.box(root,Vector3((i-1)*w*.29,(height+5)/2,(i-1)*d*.15),Vector3(w*.29,height-5,d*.48),"light_stone",true).visible=false
		var cap := MeshInstance3D.new();cap.mesh=mesh;cap.material_override=K.material("roof_gray");cap.position=node.position+Vector3.UP*((height-5)/2+.5);cap.scale=Vector3(w*.19,1,d*.32);root.add_child(cap)
		K.arcade(root,Vector3((i-1)*w*.29,0,(i-1)*d*.15),w*.3,d*.48)
		var windows: Array[Transform3D]=[]
		for side in 16:
			var angle: float=side*TAU/16
			var point := Vector3((i-1)*w*.29+cos(angle)*w*.191,0,(i-1)*d*.15+sin(angle)*d*.321)
			var basis := Basis(Vector3.UP,PI/2-angle)
			for row in range(2,maxi(3,int(height/3.4))):
				windows.append(Transform3D(basis,point+Vector3.UP*(row*3.4)))
		K.batch(root,windows,Vector3(1.6,1.7,.10),"glass_bluegray")
	K.box(root,Vector3(0,3,d*.33),Vector3(w*.65,5,.18),"glass_bluegray")
