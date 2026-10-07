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
			Kit.box(root,Vector3(0,h/2,0),Vector3(w,h,d),Color(o.accent),true)
		elif o.category in ["plaza","garden","court","track"]:
			Kit.box(root,Vector3(0,.09,0),Vector3(w,.18,d),Color("bcbda0") if o.category=="plaza" else Color("829c76"),true)
		else:
			Kit.box(root,Vector3(0,1.5,0),Vector3(minf(w,6),3,minf(d,3)),Color("c0b598"))
	return result
