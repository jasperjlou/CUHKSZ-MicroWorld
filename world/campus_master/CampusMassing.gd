extends RefCounted
const G := preload("res://world/campus_master/CampusGeometry.gd")
const Kit := preload("res://world/MeshKit.gd")

static func build(parent: Node3D) -> Dictionary:
	var result: Dictionary = {}
	for r: Dictionary in G.master.regions:
		var group := Node3D.new();group.name=r.id;parent.add_child(group)
	for o: Dictionary in G.master.objects:
		if o.category == "lake": continue
		var root := Node3D.new();root.name=o.id
		root.position=G.vec(o.center);root.rotation_degrees.y=o.yaw_deg
		parent.get_node(o.region).add_child(root);G.provenance(root,o);result[o.id]=root
		var w := float(o.footprint_width);var d := float(o.footprint_depth);var h := float(o.estimated_height)
		if o.category == "building":
			Kit.box(root,Vector3(0,-.4,0),Vector3(w+2,.8,d+2),Color("c4c7b4"),true)
			if o.model_stage == "PLACEMENT":
				Kit.box(root,Vector3(0,h/2,0),Vector3(w,h,d),Color(o.accent),true)
			else:
				massing(root,o,w,d,h)
		elif o.category in ["plaza","garden","court","track"]:
			Kit.box(root,Vector3(0,.09,0),Vector3(w,.18,d),Color("bcbda0") if o.category=="plaza" else Color("829c76"),true)
			if o.category=="track": track(root,w,d)
			if o.category=="court": court(root,w,d)
		else:
			landmark(root,o)
	return result

static func block(root: Node3D,pos: Vector3,size: Vector3,color: Color) -> void:
	Kit.box(root,pos,size,color,true)
	Kit.box(root,pos+Vector3.UP*(size.y/2+.15),Vector3(size.x+.3,.3,size.z+.3),color.lightened(.13))

static func massing(root: Node3D,o: Dictionary,w: float,d: float,h: float) -> void:
	var color := Color(o.accent)
	var wall := Color("d3d6cb")
	match o.massing:
		"college","courtyard":
			# Four perimeter wings, open courtyard, varied heights; no solid infill cube.
			var wing := minf(w,d)*.22
			block(root,Vector3(-w/2+wing/2,h/2,0),Vector3(wing,h,d),wall)
			block(root,Vector3(w/2-wing/2,h*.43,0),Vector3(wing,h*.86,d),wall)
			block(root,Vector3(0,h*.35,-d/2+wing/2),Vector3(w-wing*2,h*.7,wing),wall)
			block(root,Vector3(0,h*.21,d/2-wing/2),Vector3(w-wing*2,h*.42,wing),color)
			if o.massing=="college":
				Kit.box(root,Vector3(-w/2-.12,h/2,-d*.18),Vector3(.25,h,wing*.5),color)
		"tower":
			block(root,Vector3(0,3,0),Vector3(w,6,d),color)
			block(root,Vector3(0,h/2+3,0),Vector3(w*.68,h-6,d*.7),wall)
		"library":
			block(root,Vector3(0,h*.18,0),Vector3(w,h*.36,d),color)
			block(root,Vector3(-w*.10,h*.59,-d*.12),Vector3(w*.8,h*.46,d*.62),wall)
			block(root,Vector3(w*.34,h*.32,d*.25),Vector3(w*.2,h*.64,d*.3),color)
			# Main roof terrace + two offset reading volumes, not a facade pass.
			Kit.box(root,Vector3(-w*.15,h*.86,-d*.18),Vector3(w*.6,.5,d*.42),Color("718f8a"))
		"admin":
			block(root,Vector3(0,h*.15,0),Vector3(w,h*.3,d*.65),color)
			block(root,Vector3(-w*.28,h*.55,0),Vector3(w*.25,h*.5,d),wall)
			block(root,Vector3(w*.28,h*.55,0),Vector3(w*.25,h*.5,d),wall)
			block(root,Vector3(0,h*.86,-d*.18),Vector3(w,h*.28,d*.64),wall)
		"student":
			block(root,Vector3(0,h*.2,0),Vector3(w,h*.4,d),color)
			block(root,Vector3(-w*.17,h*.66,-d*.18),Vector3(w*.66,h*.52,d*.58),wall)
			block(root,Vector3(w*.32,h*.43,d*.1),Vector3(w*.23,h*.46,d*.56),wall)
		"sports":
			block(root,Vector3(0,h*.4,0),Vector3(w,h*.8,d),wall)
			block(root,Vector3(0,h*.86,0),Vector3(w*.92,h*.12,d*.88),color)
		"music":
			for i in range(3):
				var volume := Kit.cylinder(root,Vector3((i-1)*w*.30,h*.42,(i-1)*d*.12),d*.32,h*.84,wall)
				volume.scale.x=1.15
				var roof := Kit.cylinder(root,Vector3((i-1)*w*.30,h*.89,(i-1)*d*.12),d*.29,h*.10,color)
				roof.scale.x=1.15
			# Solid footprint is conservative; precise curved contact geometry deferred.
			Kit.box(root,Vector3(0,1,0),Vector3(w,2,d),color,true)
		"bell":
			block(root,Vector3(0,h*.4,0),Vector3(w*.65,h*.8,d*.65),wall)
			block(root,Vector3(0,h*.84,0),Vector3(w*.8,h*.12,d*.8),color)
			Kit.cylinder(root,Vector3(0,h,0),w*.12,h*.18,color)
		"academic":
			block(root,Vector3(-w*.1,h*.44,0),Vector3(w*.8,h*.88,d*.62),wall)
			block(root,Vector3(w*.35,h*.3,0),Vector3(w*.3,h*.6,d),color)
			block(root,Vector3(-w*.36,h*.19,d*.27),Vector3(w*.26,h*.38,d*.38),color)
		_:
			block(root,Vector3(0,h*.35,0),Vector3(w,h*.7,d),wall)
			block(root,Vector3(-w*.1,h*.84,-d*.1),Vector3(w*.6,h*.28,d*.65),color)

static func track(root: Node3D,w: float,d: float) -> void:
	var ring := PackedVector3Array()
	for i in range(80):
		var a := i*TAU/80;var b := (i+1)*TAU/80
		ring.append_array(G.quad(Vector3(cos(a)*w*.48,.25,sin(a)*d*.48),Vector3(cos(b)*w*.48,.25,sin(b)*d*.48),Vector3(cos(b)*w*.35,.25,sin(b)*d*.4),Vector3(cos(a)*w*.35,.25,sin(a)*d*.4)))
	G.surface(root,ring,Color("b97967"))
	for lane in range(1,5):
		var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_LINES)
		for i in range(80):
			for j in [i,i+1]: st.add_vertex(Vector3(cos(j*TAU/80)*w*(.35+lane*.026),.28,sin(j*TAU/80)*d*(.4+lane*.016)))
		Kit.mesh(root,st.commit(),Vector3.ZERO,Color("e8dcc4"))

static func court(root: Node3D,w: float,d: float) -> void:
	Kit.box(root,Vector3(0,.2,0),Vector3(w*.85,.1,d*.85),Color("728f91"))
	for z: float in [-d*.4,0,d*.4]: Kit.box(root,Vector3(0,.27,z),Vector3(w*.8,.02,.18),Color("eee6ce"))
	for x: float in [-w*.4,w*.4]: Kit.box(root,Vector3(x,.27,0),Vector3(.18,.02,d*.8),Color("eee6ce"))

static func landmark(root: Node3D,o: Dictionary) -> void:
	match o.category:
		"gate":
			for side in [-1,1]: Kit.box(root,Vector3(side*7,2.8,0),Vector3(1.1,5.6,1.6),Color("b4b79f"),true)
			Kit.box(root,Vector3(0,5.7,0),Vector3(16,.7,2.2),Color("9ba998"),true)
		"pavilion":
			Kit.cylinder(root,Vector3(0,.3,0),5,.6,Color("c5c5ad"))
			for i in range(6): Kit.cylinder(root,Vector3(cos(i*TAU/6)*3.5,2.5,sin(i*TAU/6)*3.5),.18,4.4,Color("a98468"))
			var roof := CylinderMesh.new();roof.top_radius=.2;roof.bottom_radius=5.2;roof.height=2.2;roof.radial_segments=6
			Kit.mesh(root,roof,Vector3(0,5.4,0),Color("697f7a"))
		"stone":
			var stone := Kit.cylinder(root,Vector3(0,2,0),1.5,4,Color("c6b38b"));stone.rotation.z=.12
		"stop","sign":
			Kit.box(root,Vector3(0,1.8,0),Vector3(.3,3.6,.3),Color("858f87"))
			Kit.box(root,Vector3(0,2.6,0),Vector3(2.4,1.6,.15),Color("b1c4b7"))
		_:
			Kit.box(root,Vector3(0,.1,0),Vector3(6,.2,3),Color("b4b79f"))
