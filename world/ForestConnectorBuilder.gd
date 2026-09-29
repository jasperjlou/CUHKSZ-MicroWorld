extends RefCounted
const Layout := preload("res://world/ForestConnectorLayout.gd")
const Kit := preload("res://world/MeshKit.gd")
const Curb := preload("res://assets/campus/PaleCurb.tscn")
const Lamp := preload("res://assets/campus/SingleArmLamp.tscn")

static func build(builder: Node3D) -> void:
	# Broad non-walkable land underlay, below every authored walking/road surface.
	# Its outline is a placeholder, not an assertion about the surveyed shore.
	Kit.box(builder,Vector3(5,-0.6,150),Vector3(180,5.6,144),Color("7c956c"))
	for r: Dictionary in Layout.objects():
		var marker := Node3D.new()
		marker.name = r.id
		marker.position = Vector3(r.position[0],r.position[1],r.position[2])
		marker.set_meta("semantic",r.duplicate(true))
		marker.add_to_group("lake_semantics")
		builder.add_child(marker)
		builder.semantic_nodes[r.id] = marker
	for i in range(Layout.POINTS.size()-1):
		var a: Vector3 = Layout.POINTS[i]
		var b: Vector3 = Layout.POINTS[i+1]
		var ra := Layout.right_at(i)
		var rb := Layout.right_at(i+1)
		var wa: float = Layout.WIDTHS[i]
		var wb: float = Layout.WIDTHS[i+1]
		# A continuous, shared cross-section joins Phase A without a hidden floor shortcut.
		builder.strip(a-ra*wa,a+ra*wa,b+rb*wb,b-rb*wb,Color("acb5af") if i == 0 else Color("b78c7b"),true)
		for side: float in [-1,1]:
			var outer_a := a+ra*side*(wa+4)
			var outer_b := b+rb*side*(wb+4)
			builder.strip(a+ra*side*wa,outer_a-Vector3.UP*0.08,outer_b-Vector3.UP*0.08,b+rb*side*wb,Color("879e72"),true)
			# The first edge meets the old hedge. Then the lawn opens laterally.
			var boundary_a := a+ra*side*(wa+(0 if i == 0 else 4))
			builder.beam(boundary_a+Vector3.UP*0.35,outer_b+Vector3.UP*0.35,0.6,0.7,Color("6f8865"),true)
			var shoulder := 18.0 if side < 0 else 5.0
			builder.strip(outer_a-Vector3.UP*0.1,outer_a+ra*side*shoulder+Vector3.UP*(3 if side < 0 else -0.2),outer_b+rb*side*shoulder+Vector3.UP*(3 if side < 0 else -0.2),outer_b-Vector3.UP*0.1,Color("789366"),false)
			curb_between(builder,a+ra*side*wa,b+rb*side*wb)
			for j in range(3):
				var t := (j+0.5)/3.0
				var p := a.lerp(b,t)+ra.lerp(rb,t)*side*(lerpf(wa,wb,t)+7+(j%2)*3)
				if side < 0 or j == 1:
					Kit.tree(builder,p,5.3+(j%2)*1.2)
		var steps := maxi(1,int(a.distance_to(b)/1.8))
		for j in range(steps):
			var t := (j+0.5)/steps
			var p := a.lerp(b,t)+Vector3.UP*0.015
			var r := ra.lerp(rb,t)*lerpf(wa,wb,t)
			builder.beam(p-r,p+r,0.025,0.015,Color("9b9f92"))
		for side: float in [-1,1]:
			builder.beam(a+ra*side*wa*0.65+Vector3.UP*0.016,b+rb*side*wb*0.65+Vector3.UP*0.016,0.16,0.016,Color("c6c2ae"))
		if i > 0:
			var lamp := Lamp.instantiate()
			lamp.position = b-rb*(wb+2)
			builder.add_child(lamp)
	_build_road_view(builder)
	for i in range(8):
		Kit.tree(builder,Vector3(-45+i*11,2.2,151+(i%3)*9),6+(i%3))
	# Two anonymous pale silhouettes: visual source, not a claim about college identity.
	for i in range(2):
		var p := Vector3(-28+i*15,2.2,179+i*7)
		var height := 17.0+i*4
		Kit.box(builder,p+Vector3.UP*height/2,Vector3(7,height,6),Color("c3cdc6"))
		for floor_index in range(7+i*2):
			for col in range(3):
				for side: float in [-1,1]:
					Kit.box(builder,p+Vector3(-2+col*2,2+floor_index*2,side*3.02),Vector3(0.9,1.1,0.04),Color("839b96"))
	# Phase D2 construction explicitly opens this former cap into JunctionBuilder.

static func curb_between(builder: Node3D,a: Vector3,b: Vector3) -> void:
	var count := maxi(1,int(ceil(a.distance_to(b)/2)))
	for i in range(count):
		var p := a.lerp(b,float(i)/count)
		var q := a.lerp(b,float(i+1)/count)
		var curb := Curb.instantiate()
		curb.segment_length = p.distance_to(q)-0.035
		builder.add_child(curb)
		curb.look_at_from_position((p+q)*0.5,q,Vector3.UP)

static func _build_road_view(builder: Node3D) -> void:
	var points := [Vector3(44,2.5,82),Vector3(37,2.7,99),Vector3(26,2.85,117),Vector3(34,2.95,131),Vector3(50,2.95,142)]
	for i in range(points.size()-1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i+1]
		# Road is scenery outside the planted, collidable play boundary.
		builder.strip(a-Vector3(6,0,0),a+Vector3(6,0,0),b+Vector3(6,0,0),b-Vector3(6,0,0),Color("687777"),false)
		for side: float in [-1,1]:
			builder.strip(a+Vector3(side*6,-0.06,0),a+Vector3(side*10,-0.2,0),b+Vector3(side*10,-0.2,0),b+Vector3(side*6,-0.06,0),Color("91a477"),false)
			curb_between(builder,a+Vector3(side*6,0,0),b+Vector3(side*6,0,0))
			builder.beam(a+Vector3(side*5.5,0.02,0),b+Vector3(side*5.5,0.02,0),0.1,0.015,Color("d4c58c"))
		for j in range(3):
			var p := a.lerp(b,(j+0.25)/3.0)+Vector3.UP*0.025
			var q := a.lerp(b,(j+0.65)/3.0)+Vector3.UP*0.025
			builder.beam(p,q,0.12,0.015,Color("d8dace"))
