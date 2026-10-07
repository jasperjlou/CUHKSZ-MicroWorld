extends RefCounted
const K := preload("res://world/campus_exterior/ExteriorArchitectureKit.gd")
const Modules := preload("res://world/campus_master/architecture/modules/CampusModuleCatalog.gd")
static var profiles: Dictionary = {}

static func load_profiles() -> void:
	profiles.clear()
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/building_architecture_profiles.json"))
	for p: Dictionary in data.buildings:profiles[p.id]=p

static func build(root: Node3D,o: Dictionary,w: float,d: float,h: float) -> void:
	if profiles.is_empty():load_profiles()
	var p: Dictionary=profiles[o.id];root.set_meta("architecture_profile",p)
	var wall: String=p.facade_primary
	if o.id.begins_with("conference"):
		conference(root,w,d,h);K.entrance(root,w,d,o.name_zh);K.bake(root);return
	match o.massing:
		"library": library(root,w,d,h)
		"admin": admin(root,w,d,h)
		"student": student(root,w,d,h)
		"college","courtyard":
			if o.region=="lower" and not o.id.begins_with("shaw"):
				academic_court(root,w,d,h)
			else:college(root,o,p,w,d,h)
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
	if o.massing=="bell":root.set_meta("entrance_local",Vector3(0,0,d/2-.5)) # Exterior approach, not a walk-through tower.
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

static func conference(root: Node3D,w: float,d: float,h: float) -> void:
	# Public assembly shell: broad glazed foyer and auditorium, rather than residential courtyard towers.
	K.arcade(root,Vector3.ZERO,w*.9,d*.75)
	K.volume(root,Vector3(0,5+h*.325,-d*.12),Vector3(w*.72,h*.65,d*.55),"light_stone")
	for side in [-1,1]:K.volume(root,Vector3(side*w*.41,h*.35,0),Vector3(w*.18,h*.7,d*.80),"warm_white")
	Modules.add(root,"GLASS_CURTAIN_WALL",Vector3(0,6.5,d*.32),Vector3(w*.68,7,.2))
	K.box(root,Vector3(0,10.2,d*.25),Vector3(w*.74,.6,d*.24),"warm_white")

static func academic_court(root: Node3D,w: float,d: float,h: float) -> void:
	# Lower-campus courts use horizontal stone teaching wings, not residential towers/roof pergolas.
	K.arcade(root,Vector3.ZERO,w*.9,d*.76)
	K.volume(root,Vector3(0,(h+5)/2,-d*.33),Vector3(w,h-5,d*.26),"light_stone")
	for side in [-1,1]:
		K.volume(root,Vector3(side*w*.37,(h*.74+5)/2,d*.06),Vector3(w*.24,h*.74-5,d*.56),"light_stone")
		K.box(root,Vector3(side*w*.37,h*.48,d*.341),Vector3(w*.22,2.5,.12),"glass_bluegray")
	K.volume(root,Vector3(0,6.5,d*.29),Vector3(w*.5,3,d*.14),"warm_white")
	K.screen(root,Vector3(0,4.9,d*.37),w*.5,3,"wood_accent")
	root.set_meta("courtyard_local",Vector3.ZERO)

static func college(root: Node3D,o: Dictionary,p: Dictionary,w: float,d: float,h: float) -> void:
	# Count evidence is distinct from inferred local arrangement and height ordering.
	var layouts: Dictionary={
		"ling":[[-.34,-.17,.25,.64,1.0],[.34,-.2,.25,.60,.88],[0,-.36,.42,.22,.55]],
		"muse":[[-.34,-.12,.24,.7,.94],[.34,-.12,.24,.7,1.0],[0,-.36,.44,.2,.80]],
		"diligentia":[[-.34,-.15,.23,.65,1.0],[.34,-.24,.23,.47,.92],[0,-.36,.43,.22,.84]],
		"harmonia":[[-.34,-.28,.24,.34,1.0],[-.34,.14,.24,.30,.86],[.34,-.28,.24,.34,.96],[.34,.14,.24,.30,.78]],
		"duan":[[-.33,-.10,.26,.75,1.0],[.33,-.24,.26,.47,.80],[0,-.37,.39,.2,.44]],
		"minerva":[[-.33,-.22,.24,.50,.88],[.33,-.09,.24,.75,1.0],[0,-.37,.4,.22,.70]],
		"eighth":[[-.32,-.08,.28,.72,1.0],[.32,-.08,.28,.72,.93]],
		"shaw_west":[[-.34,-.12,.24,.65,1.0],[.34,-.12,.24,.65,.92],[0,-.36,.44,.22,.82]],
		"shaw_east":[[-.34,-.12,.24,.65,.88],[.34,-.12,.24,.65,1.0],[0,-.36,.44,.22,.75]]}
	var layout: Array=layouts.get(o.id,layouts.muse)
	for tower: Array in layout:
		var height: float=h*tower[4]
		var pos:=Vector3(w*tower[0],(height+5)/2,d*tower[1])
		var size:=Vector3(w*tower[2],height-5,d*tower[3])
		K.volume(root,pos,size,"warm_white",true)
		K.arcade(root,Vector3(pos.x,0,pos.z),size.x,size.z)
		K.box(root,Vector3(pos.x,height*.52,pos.z+size.z/2+.10),Vector3(size.x*.22,height*.94,.15),o.accent)
		K.box(root,Vector3(pos.x,height*.30,pos.z-size.z/2-.10),Vector3(size.x*.65,.7,.15),"concrete_gray")
	# Shared court gallery, restrained enough to remain a conservative interpretation.
	K.arcade(root,Vector3(0,0,d*.29),w*.54,d*.13,4.5)
	K.box(root,Vector3(0,5.6,d*.29),Vector3(w*.54,.7,d*.13),o.accent)
	if o.id=="ling":
		for side in [-1,1]:K.box(root,Vector3(side*6,3,d*.43),Vector3(.75,6,1.4),"concrete_gray",true)
		K.box(root,Vector3(0,6.3,d*.43),Vector3(13.4,.9,1.8),"concrete_gray")
		var name:=Label3D.new();name.text="道扬书院";name.font=preload("res://systems/ChineseText.gd").FONT;name.font_size=72;name.pixel_size=.018
		name.position=Vector3(0,5.5,d*.43+1);name.modulate=Color("e5d8a9");name.outline_size=0;root.add_child(name)
	root.set_meta("courtyard_local",Vector3.ZERO)
	root.set_meta("tower_count",layout.size());root.set_meta("silhouette_layout",layout)
	root.set_meta("rear_confidence","INFERRED_REAR_FACADE")

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
	Modules.add(root,"GLASS_CURTAIN_WALL",Vector3(0,5.8,d/2+.03),Vector3(w*.9,1.7,.12))
	K.screen(root,Vector3(0,7,d/2+.16),w*.95,h-7,"warm_white")

static func music(root: Node3D,w: float,d: float,h: float) -> void:
	# Official opening: performance petals + teaching/living courts; Eighth's
	# two dormitories remain separately anchored, for seven principal masses.
	for i in 2:
		var x: float=(-.25 if i==0 else .25)*w
		var z: float=d*.05 if i==0 else d*.13
		var roof_verts:=PackedVector3Array();var wall_verts:=PackedVector3Array()
		var radius_x: float=w*.21;var radius_z: float=d*.22
		var height: float=h*(.85 if i==0 else .67)
		for j in 32:
			var angle: float=j*TAU/32;var next: float=(j+1)*TAU/32
			var pa:=Vector3(x+cos(angle)*radius_x,5,z+sin(angle)*radius_z)
			var pb:=Vector3(x+cos(next)*radius_x,5,z+sin(next)*radius_z)
			var ra:=pa+Vector3.UP*(height-5+sin(angle)*2)
			var rb:=pb+Vector3.UP*(height-5+sin(next)*2)
			wall_verts.append_array(PackedVector3Array([pa,pb,rb,pa,rb,ra]))
			roof_verts.append_array(PackedVector3Array([Vector3(x,height+1,z),ra,rb]))
			var fin:=K.box(root,(pa+pb)/2+Vector3.UP*(height-5)/2,Vector3(.16,height-5,.18),"warm_white")
			fin.rotation.y=-angle
		var wall_mesh:=SurfaceTool.new();wall_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
		for vertex: Vector3 in wall_verts:wall_mesh.add_vertex(vertex)
		wall_mesh.generate_normals();var wall:=MeshInstance3D.new();wall.mesh=wall_mesh.commit();wall.material_override=K.material("light_stone");root.add_child(wall)
		var roof_mesh:=SurfaceTool.new();roof_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
		for vertex: Vector3 in roof_verts:roof_mesh.add_vertex(vertex)
		roof_mesh.generate_normals();var roof:=MeshInstance3D.new();roof.mesh=roof_mesh.commit();roof.material_override=K.material("warm_white");root.add_child(roof)
		# Conservative box collision is inset, leaving the curved facade decorative.
		K.box(root,Vector3(x,(height+5)/2,z),Vector3(radius_x*1.4,height-5,radius_z*1.4),"light_stone",true).visible=false
		K.arcade(root,Vector3(x,0,z),radius_x*1.5,radius_z*1.3)
		K.box(root,Vector3(x,4,z+radius_z+.06),Vector3(radius_x*1.4,3,.12),"glass_bluegray")
	# Three compact teaching/service masses have U courts and different heights.
	for i in 3:
		var x: float=(i-1)*w*.29;var width: float=w*.24;var depth: float=d*.3;var height: float=h*(.75-i*.08)
		for side in [-1,1]:K.volume(root,Vector3(x+side*width*.36,(height+5)/2,-d*.30),Vector3(width*.27,height-5,depth),"warm_white")
		K.volume(root,Vector3(x,(height+5)/2,-d*.43),Vector3(width*.47,height-5,depth*.20),"light_stone")
		K.arcade(root,Vector3(x,0,-d*.19),width,depth*.20)
	K.arcade(root,Vector3(0,0,-d*.11),w*.81,3,4.5)
	root.set_meta("principal_music_masses",5);root.set_meta("rear_confidence","INFERRED_REAR_FACADE")
